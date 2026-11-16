# ZERO Sievert 优化报告

## 本轮：火焰异常

用户实测：上一轮化学区域改善明显，火焰区域改善较小。该结果支持保留现有化学优化，
但不能据此断言火焰瓶颈一定在 GPU。

目标：`gml_Object_obj_anomaly_fire_Step_0`。
实现：`analysis/optimization/apply_anomaly_fire_optimization.csx`。

### 原始逻辑与成本

火焰父生成器在 Alarm 中创建多个火焰子实例。大火焰区域配置的 `place_amount`
为 65。每个子实例每帧遍历玩家、检测 NPC、检测探路螺栓并生成粒子，成本在区域
加载后就存在，不要求玩家触发异常。

NPC 命中分支先调用 `place_meeting(x, y, obj_npc_parent)`，命中后又调用同位置、
同目标类型的 `instance_place` 获取受伤 NPC，重复查找同一碰撞。

### 本轮实现

1. 玩家检测先比较两个实例的实际 `bbox_*` 是否重叠，重叠时仍执行原始
   `place_meeting`。不再使用未经碰撞尺寸验证的固定距离阈值。
2. NPC 检测改为一次 `instance_place`，返回非 `noone` 时复用该结果执行原伤害分支。
   未命中仍一次查询；命中从两次查询减少为一次。
3. 保留螺栓检测、激活状态、Alarm、音效、NPC 伤害和全部粒子调用。
   不根据玩家距离跳过整个 Step，不暂停屏外 NPC 受伤。

此项主要减少 CPU 碰撞成本。未改火焰粒子尺寸、数量、生命周期、透明度、颜色或
shader。它是独立实验，收益需要实测，不能声称已解决 GPU 瓶颈。

禁用对照：

```bash
./coop/target/release/zs-coop-loader --no-anomaly-fire-optimization
```

## 保留的既有优化

| 脚本 | 改动 | 边界 |
| --- | --- | --- |
| `apply_los_cache.csx` | LOS 短时间缓存 | 缓存键按脚本中的房间、目标和位置检查 |
| `apply_aggressive_visuals.csx` | 普通子弹屏外 Draw 裁剪 | 不修改粒子控制器或子弹碰撞 |
| `apply_scene_startup.csx` | 视频、菜单 UI、基地批处理和菜单标记 | 菜单动画更新频率有变化 |
| `apply_anomaly_emitter_culling.csx` | 火焰、化学父发射区域与摄像机矩形相交时发射粒子 | 原发射概率和粒子定义保留；屏外预热可能变化 |
| `apply_anomaly_collision_prefilter.csx` | 保留上一版化学、电异常的玩家距离预筛选 | 本轮未扩展雷电优化 |
| `apply_gpu_scene.csx` | 草地风摆动实验 | 默认关闭 |

`apply_anomaly_hotspots.csx` 是历史实验文件，当前流水线不执行它。
失败的子异常粒子 `sphere_is_visible` 裁剪和辐射阈值实验没有接入当前流水线。

## 加载器简化

- 固定原始文件为游戏目录下的 `data_original_backup.win`。
- 首次优化时若不存在，复制当前 `data.win`；存在则不覆盖内容，并设置只读权限。
- 每次都从它读取，保证参数切换不会叠加上次补丁。
- 一次 UTMT 进程执行全部启用脚本，只写一份临时输出；成功后替换 `data.win`。
- 失败或 dry-run 时删除临时输出；不创建 runtime、时间戳或多份备份。
- `--restore` 复制固定原始文件回 `data.win`，不会删除原始文件。
- 移除 `--keep-stage`、`--no-keep-stage`、`--base-data-win` 及其配置。

## 验证与后续判断

Rust 的备份回归测试覆盖：首次创建只读原件、连续优化、重复还原、原件内容保持不变。
UTMT 成功写出后重新反编译火焰 Step，检查 NPC 查询只剩一次、无新增 Step 提前退出，
并逐项对比原始 `part_*` 调用。化学、电异常与上一版的预筛选行为保持一致。

收益应在同一存档、位置、画质下比较默认版本与
`--no-anomaly-fire-optimization`。当前没有 GPU 时间测量，静态分析只确认调用路径，
不能把潜在热点当成已经测量到的瓶颈。
