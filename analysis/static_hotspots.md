# ZERO Sievert 静态性能分析报告

本报告基于当前本地 `data.win` 和 UndertaleModTool 的只读反编译结果。它用于定位静态热点，不等同于运行时性能采样。

## 一、引擎确认

UTMT 报告如下：

```text
项目名：ZERO_Sievert
GMS2：True
YYC：False
字节码版本：17
代码条目：9439
游戏对象：1557
房间：369
```

结论：游戏是 **GameMaker Studio 2 VM 版本**，不是 YYC 原生编译版本。第一优先级应放在 GameMaker 字节码、脚本和对象事件层。Proton 下的原生进程 Hook 可以作为运行时观测手段，但不应一开始就依赖固定的 native 地址。

## 二、已确认的资源结构

`data.win` 包含 `GEN8`、`CODE`、`FUNC`、`OBJT`、`ROOM`、`STRG` 等 GameMaker 数据块，并保留了大量 `gml_Script_*` 和对象事件名称。当前分析副本位于：

```text
analysis/utmt_input/data.win
```

它与原始 `../data.win` 的 SHA-256 相同：

```text
95252ac09897e99ca7f10e40e99d25f5c099e67fa912c0f7cabce73f9a7a7daa
```

报告中的所有反编译代码均来自这个副本，尚未改写原始游戏文件。

## 三、子弹碰撞热点

已解码的调用链：

```text
obj_bullet_parent_Step_0
  -> bullet_check_for_collisions
      -> collision_line_list(... obj_solid ...)
      -> collision_line_list(... obj_npc_parent ...)
      -> collision_line_list(... obj_player_parent ...)
      -> distance_to_object 筛选
      -> collision_line 二分搜索命中位置
```

每个活动子弹每帧会执行三次线段列表碰撞查询，即使最终没有命中任何对象。霰弹枪等武器通过创建多个子弹实例进一步放大这个开销。

函数内部的三个 `ds_list` 是静态创建的，因此不是每帧创建；但每帧仍然会清空并重新填充这些列表。当前最值得验证的优化方向是：

1. 在不改变最近命中顺序的前提下减少无效的 NPC/玩家查询。
2. 保留墙体、NPC、玩家三个碰撞类别的优先级。
3. 保留阵营判断、射手排除、穿透和命中位置二分逻辑。
4. 不直接把 `collision_line_list` 替换为单目标查询，因为这样可能改变最近目标和穿透行为。

## 四、NPC 与 AI 热点

已确认的对象事件链：

```text
obj_npc_parent_Step_0
  -> ai_human_before_step(id)
  -> human_general 状态下调用 ai_human_dispatch(id)
      -> ai_compat_step
      -> ai_bridge_step
      -> ai_perception_step
      -> ai_hearing_step
      -> ai_team_step
      -> ai_bt_tick
      -> ai_cover_step
```

AI 默认配置包含一定的预算控制：

```text
decision_steps：8
perception_steps：6
全局候选点上限：64 / 世界帧
全局路径查询上限：8 / 世界帧
单个 AI 候选点上限：12
单个 AI 路径查询上限：2
查询延迟窗口：0.5 秒
```

`ai_spatial_query` 的候选点验证会混合使用：

```text
collision_line
collision_circle
mp_grid_path
路径点安全采样
```

这意味着 AI 已经尝试进行分帧预算，但在 NPC 数量较多时，预算内的碰撞检查和路径查询仍然可能集中在同一帧产生尖峰。

另外，旧式 NPC 状态仍然在 `obj_npc_parent_Step_0` 中直接调用 `mp_grid_path`。因此，只给新 AI 查询系统增加预算并不能覆盖所有寻路开销。

## 五、视线检测

`instance_line_of_sight` 本身很薄：

```gml
return !collision_line(arg0, arg1, arg2.x, arg2.y, obj_solid, true, true);
```

它同时被传统 AI 和新 AI 路径调用。适合做低风险实验的是短时间 LOS 缓存，但缓存必须在以下条件变化时失效：

```text
房间变化
观察者位置变化
目标位置变化
地图障碍物变化
```

不能使用无条件的全局缓存，否则会产生穿墙射击、目标延迟发现等行为错误。

## 六、当前优化顺序

### P0：只读运行时观测

记录以下函数的调用次数、每帧次数和耗时：

```text
bullet_check_for_collisions
collision_line_list
ai_perception_step
ai_spatial_query
ai_world_path
instance_line_of_sight
```

### P1：子弹碰撞优化实验

首先做无行为变化的观测；随后在独立输出文件上尝试减少候选查询。测试重点是密集子弹、霰弹枪、穿透、NPC 与玩家混战四种场景。

### P1：AI 调度优化实验

对远离玩家、不可见且没有新声音线索的 NPC 增加更新间隔，同时保留受伤、开火、警觉和路径执行中的 NPC 的高频更新。

### P2：LOS 短缓存

只在观察者和目标移动低于阈值、房间未变化且障碍物状态未变化时复用结果。

### P3：对象创建与绘制

只有在确认 CPU 热点不是碰撞和 AI 后，再检查子弹、弹壳、枪口火焰、手雷和绘制事件的创建销毁成本。

## 七、为什么不直接修改原始 data.win

当前只有静态反编译证据，还没有运行时帧耗时、调用计数和行为回归结果。直接覆盖原始文件会让以下问题难以区分：

```text
性能优化失败
碰撞行为改变
AI 状态机失步
房间切换或存档损坏
Proton/驱动差异
```

因此第一轮优化将生成独立的候选脚本和独立的 `data.win` 输出。通过验证后才考虑把改动接入加载器。

## 八、Hook 边界

推荐边界顺序：

```text
GameMaker VM 脚本/对象事件
  -> VM 调度观测
  -> 狭窄的 native 计时或调度 Hook
  -> 经过回归验证的行为替换
```

任何 native 地址或结构偏移都必须绑定到精确的 `ZERO Sievert.exe`、`data.win` 和 Proton 版本哈希。遇到未知版本时应自动停用，而不是继续使用旧偏移。
