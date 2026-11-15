# ZERO Sievert 性能优化分析报告

本文记录 `coop` 项目当前对 ZERO Sievert 的静态 `data.win` 优化。启动器只负责
生成、备份和替换 `data.win`，不会启动游戏，也不会注入 DLL。

## 当前改动

### 1. LOS 视线缓存

目标代码：`gml_GlobalScript_instance_line_of_sight`

原始逻辑每次调用都执行：

```gml
!collision_line(arg0, arg1, arg2.x, arg2.y, obj_solid, true, true)
```

NPC 感知、目标选择和战斗逻辑会在同一帧中多次请求相同的观察者坐标、目标坐标
和房间组合。`collision_line` 会访问固体实例并执行线段碰撞检查，调用次数会随
NPC 数量增加。

优化后缓存最近一次结果，缓存键包含：

- 房间
- 观察者坐标
- 目标实例
- 目标坐标
- 最近时间帧

缓存最多保留约两帧。坐标、目标、房间变化时立即失效。它减少重复查询，但仍然
允许动态移动的目标很快重新计算。

实现文件：`analysis/optimization/apply_los_cache.csx`

### 2. 视觉优化

目标代码：

- `gml_Object_obj_particles_controller_Step_0`
- `gml_Object_obj_bullet_regular_Draw_0`

粒子控制器会持续生成天气、异常和辐射相关粒子。当前脚本完全保留粒子控制器和
粒子 API，只对屏幕外普通子弹跳过 Draw 提交。子弹移动、碰撞、粒子和音效逻辑都保留。

子弹仍然执行移动和碰撞。Draw 事件增加屏幕可见性检查，屏幕外的普通子弹不再提交
精灵绘制。

实现文件：`analysis/optimization/apply_aggressive_visuals.csx`

### 3. 主菜单与静态场景优化

目标代码：

- `gml_Object_obj_logo_screen_Step_0`
- `gml_Object_obj_logo_screen_Draw_64`
- `gml_Object_obj_main_menu_Step_0`
- `gml_Object_obj_main_menu_Draw_64`
- `gml_Object_obj_vertex_props_Step_0`

启动画面原本会打开 `ZS_boot.mp4`，查询视频时长并进行视频绘制。优化跳过视频打开
和解码，保留继续提示、淡入和正常进入主菜单的流程，并对 `video_draw` 和
`video_close` 增加空值保护。

主菜单原本每个 Step 都执行完整 UI 树更新。输入处理位于 UI 树更新之前，因此优化
保留每帧输入处理，只把 UI 树更新改为隔帧执行。菜单动画更新频率降低，菜单按钮仍可
正常响应。

静态物品原本已经使用 `obj_vertex_props` 批处理。该对象会扫描静态装饰和固体对象，
把同类精灵写入顶点缓冲区，然后销毁或隐藏原始实例，后续通过一次或少量顶点提交
绘制。基地场景原本要等待约 8 帧才开始构建批次，优化将等待缩短到约 2 帧，减少
进入基地时静态物品以独立实例存在的时间。

主菜单右下角的绿色 `Improvement` 是优化版本标记，用于确认实际运行的 `data.win`
确实经过了当前脚本处理。

实现文件：`analysis/optimization/apply_scene_startup.csx`

### 4. 异常区域粒子优化

这是针对异常密集区域新增的修复，目标代码：

- `gml_Object_obj_anomaly_electric_Step_0`
- `gml_Object_obj_anomaly_electric_generator_Step_0`
- `gml_Object_obj_anomaly_fire_Step_0`
- `gml_Object_obj_anomaly_gas_Step_0`

原有的粒子控制器优化不能覆盖这些路径，因为异常对象会直接访问
`obj_particles_controller` 并调用粒子 API。

电异常在每个 Step 中以 `scr_chance(100)` 发射一次粒子爆发。这个条件在正常运行中
等价于每帧执行。电异常发生器也在每个 Step 中发射一次范围粒子，同时还会搜索附近
玩家和 NPC、播放声音、生成电火花和伤害对象。

火异常在 `active` 时每帧创建火焰粒子，并额外按概率创建另一组粒子。气异常每帧执行
多组随机判定，既有常规气体粒子，也有激活后的额外粒子。异常实例数量增加后，这些
调用会按异常数量线性增长；粒子系统内部还会继续更新和绘制已生成粒子，因此在异常
密集区域会同时形成 CPU 和 GPU 压力。

早期实验曾直接移除异常视觉粒子生成块，保留：

- 玩家与 NPC 的接触检测
- 异常伤害和治疗
- `alarm[10]` 激活状态
- 异常网格阻塞和销毁逻辑
- 电火花、命中反馈和主要异常音效
- 火异常的持续声音
- 序章相关状态推进

这样优化目标集中在高频视觉生成，不改变异常本身的游戏规则。代价是异常区域的
粒子表现会明显减少，便于用开关对比。

该方案视觉损失明显，因此已移除异常粒子重写：

```ini
anomaly_optimization = true
```

当前脚本完全保留异常对象和粒子控制器中的原始 `part_*` 调用，不创建包装函数，
不替换异常 Step 事件。异常的火焰、气体、电光效果、伤害、碰撞和音效逻辑保持原样。

另外，异常区域的颜色模糊与全屏辐射 shader 有直接关系。`obj_shader_controller_Draw_77`
会把 `application_surface` 复制到内部 surface，再用 `shd_radiation` 对整屏重新采样。
原始条件只判断 `amount > 0`，即使模糊强度非常低也会触发完整的全屏 pass。当前只把
触发阈值提高到 `0.08`，高强度辐射仍然使用原 shader，低强度、几乎不可见的效果不再
支付整屏 surface 和 shader 成本。这是针对触发条件的算法优化，不是删除异常画面。

### 5. GPU 场景优化（已默认关闭）

重新检查 GPU 路径后，发现草地已经通过 `obj_vertex_grass` 的顶点缓冲区批量提交，
但 Draw 事件每帧仍根据 `dynamic grass` 设置风摆动相关的 shader 参数。草地数量很大
时，顶点数量和透明像素覆盖面积都可能成为 GPU 成本来源，风摆动还会增加顶点着色器
计算。

该实验曾将：

```gml
if (settings_get("dynamic grass"))
```

替换为：

```gml
if (false)
```

草地顶点、纹理和绘制仍然存在，但会关闭动态风摆动。由于风摆动属于玩家可感知的
场景表现，当前配置将该优化关闭：

```ini
gpu_scene_optimization = false
```

实现文件：`analysis/optimization/apply_gpu_scene.csx`

雾效、阴影和静态物品顶点提交目前仍是 GPU 候选项。它们会影响整张屏幕或较大的
surface，不能在没有 GPU 时间或游戏内统计的情况下直接删除，因此暂时只记录为分析对象。

## 如何定位这些热点

本次定位采用静态逆向分析，步骤如下：

1. 使用 UTMT 从基线 `data.win` 导出全部 GML 代码入口。
2. 按 `obj_anomaly_*`、`particle`、`part_emitter`、`part_particles_create`、
   `collision_line`、`instance_create` 和 `Draw` 等高成本 API 搜索。
3. 从异常对象的 Create、Step、Alarm 和 Destroy 事件还原生命周期。
4. 区分每帧路径、概率路径、进入区域时路径和只执行一次的初始化路径。
5. 检查调用是否已经经过现有优化入口。异常对象的粒子调用没有经过粒子控制器
   Step，因此确定为遗漏路径。
6. 用独立 CSX 修改脚本生成中间 `data.win`，再由 UTMT 重新导出目标代码确认替换
   已写入。
7. 对 GPU 路径额外检查 `vertex_submit`、`surface_set_target`、shader 设置、透明
   混合和屏幕覆盖范围，区分 CPU 实例数量与 GPU 像素/着色器成本。
8. 用启动器的 `--dry-run` 验证脚本顺序、目标名称和输出文件，再执行实际替换。

当前证据主要来自静态代码路径和 UTMT 导出结果。环境限制使得这里不能可靠地读取
游戏内部的实时帧时间、实例数量或 GPU 时间，因此异常优化的收益需要在实际游戏中用
同一地图、同一位置和同一画质设置对比确认。

## 优化流水线

启动器按以下顺序处理基线文件：

1. LOS 缓存
2. 激进视觉优化
3. 主菜单与静态场景优化
4. 异常区域粒子优化
5. GPU 场景优化（当前默认关闭）

每一项都是独立 CSX 文件。某项关闭时不会执行对应脚本，便于逐项回归测试。

当前配置启用 `aggressive_visuals`，但脚本只裁剪屏幕外普通子弹绘制，不修改粒子。
异常粒子与通用粒子控制器均保留。

配置文件为 `coop/coop.conf`，命令行开关优先级更高：

```bash
./coop/target/release/zs-coop-loader \
  --no-los-cache \
  --no-aggressive-visuals \
  --no-scene-optimization \
  --no-anomaly-optimization \
  "./ZERO Sievert.exe"
```

只测试异常优化：

```bash
./coop/target/release/zs-coop-loader \
  --no-los-cache \
  --no-aggressive-visuals \
  --no-scene-optimization \
  --anomaly-optimization \
  "./ZERO Sievert.exe"
```

恢复替换前的文件：

```bash
./coop/target/release/zs-coop-loader --restore "./ZERO Sievert.exe"
```

## 当前限制

- 静态物品批处理只减少实例和绘制提交，不能减少大型地图本身的纹理内存占用。
- 异常优化减少视觉粒子，不会减少异常碰撞、伤害和音效逻辑。
- 异常优化当前完全保留粒子逻辑，只处理低强度全屏辐射 pass。
- GPU 草地优化当前默认关闭，以保留草地风摆动效果。
- 主菜单 UI 隔帧更新可能降低部分动画的流畅度，但输入处理仍保持每帧执行。
- 当前报告中的热点排序来自反编译代码和调用频率推断，还需要游戏内帧时间采样来
  确定每项优化的实际收益。
