# ZERO Sievert 优化报告

## 本轮：UI/CSV 内嵌、外部 UTMT 与代码整合

用户已废弃 NPC Step 的摄像机外巡逻分帧（视野外敌人也是威胁），并把团队扫描的
分帧下限从 12 调到 4（实测 3-4 个 NPC 就开始卡顿）。本轮不再改变 NPC 行为，只
保留 `ai_team_step` 的协调扫描分帧，并把 NPC 计数改为每帧缓存一次。

### 资源嵌入与外部 UTMT

`build.rs` 现在生成两类编译期资源：

- `analysis/optimization/*.csx` 嵌成字符串；
- `ui_seed/*.ui` 与 `*.csv` 嵌成字节。

UTMT 不嵌入。它体积大，解压缓存并不比直接保留目录更轻，所以启动时仍从
`coop/tool/utmt/UndertaleModCli` 外部调用；缺失时直接报错，不再尝试释放归档。
加载器因此只有约 1.3 MB，CSX 与 UI 仍可随二进制一起分发。

### UI 与语言文件自动部署

- `npc_left_map_seed.ui` 内容不同才重写；
- `npc_left_talk.ui` 已有 `"map_seed"` 条目时完全不动，缺少时在 `nextPageDict`
  的闭合花括号前插入；找不到该结构就报错并停止替换 `data.win`；
- 语言 CSV 只维护 `npc.interaction.map_seed` 与 `ui.map_seed.*` 命名空间：
  先移除旧行，再按内嵌快照写回，因此历史 `cat >>` 留下的重复行会被清掉，其它
  Descriptor 原样保留；
- 部署发生在 `data.win` 替换之前；`--dry-run` 不修改 UI/CSV。

同时修复了一个实际断点：游戏目录里的 `npc_left_map_seed.ui` 会调用
`MapSeedFormat`，但上一版 `data.win` 没有这个函数。现在 `apply_conductor_seed.csx`
新增并注册 `MapSeedFormat`，按三位分组显示种子。

### Rust 与 CSX 整理

Rust：

- `Settings::default()` 统一默认值，`Settings` 与 `main` 不再各写一份；
- 补丁表用 `Feature` 枚举决定是否启用，新增补丁只改一处；
- 删除 `bool_literal`、`absolute_path` 等小包装；
- 修复 dry-run 逻辑：旧的 `BuildResult::Drop` 会在返回时删掉 `data.win.coop-tmp`，
  实际什么也检查不到；现在 dry-run 保留 `data.win.coop-dry-run`；
- 构建、部署或替换失败时清理临时输出；
- `--no-gpu-scene-optimization` 这个永远无效的开关改成
  `--gpu-scene-optimization`（默认关闭，显式启用）。

CSX：

- `map_seed_pending_text` 展开进 `map_seed_draft_begin`，`map_seed_draft_commit`
  不再重复调用 `map_seed_draft_valid`；
- 火焰 type 14 的数量改为 `min(c.particle_fire_amount, 2)`，低画质设置不会被
  反向加回；
- 异常父发射器先执行 `scr_chance` 再判断可见性，保持原全局随机序列；
- 异常子实例的摄像机值按 `current_time div 16` 加房间号缓存，避免 95+ 个子实例
  每帧各调用四次 `camera_get_view_*`；最多一帧陈旧，裁剪 margin 足以吸收；
- AI 团队扫描门控保留 2 帧（NPC ≥ 30 时 3 帧），下限 4 个 NPC；
- AI 分帧的相位计算改用 `arg0` 而不是 `arg0.id`。UTMT 会把 `arg0.id` 编译成
  “对数字做成员访问”，运行时报 `DoAdd :1: Malformed variable`；`arg0` 本身就是
  实例 id，直接相加即可。NPC 计数仍按帧 + 房间缓存。

### 验证

- `cargo test --release --offline`：9 个测试通过，覆盖真实对话 UI 的注入、CSV 去重/
  幂等、补丁表唯一性和备份恢复；
- `cargo clippy --release --offline -- -D warnings` 通过；
- dry-run 仍包含全部 12 个默认补丁，并保留生成文件；
- 反编译确认 AI 计数缓存、4 NPC 下限、`MapSeedFormat` 注册、异常子实例摄像机
  缓存、type 14 `min`、父发射器 RNG 顺序都正确；
- 反汇编确认 AI 相位相加直接使用 `argument0`，不再生成 `[stacktop]self.id`
  的成员访问；
- dry-run 在外部 `coop/tool/utmt` 下完成，缺失 UTMT 时会直接报错。

## 上一轮：火焰红光、长寿命粒子与 AI 分帧

用户实测：摄像机外裁剪收益不明显。真正的掉帧发生在玩家进入火焰异常范围时，
即使没有碰到伤害火焰也会明显下降；同时摄像机内 AI 较多时单核 CPU 占用集中。

### 火焰红光与长寿命小火球

从粒子定义可以对应到两个可见热点：

- 粒子类型 15 是覆盖整个异常范围的大尺寸红色烟雾云：`shape 11`，生命
  `90-180`，尺寸 `5-7`，火焰父生成器每帧发射一次。单颗 alpha 很低，但大量
  重叠后形成那层大范围红光，GPU 填充成本很高。
- 粒子类型 14 是寿命 `90-120` 的小火球/余烬，每次发射 5 颗；它们存在时间长，
  是“长时间漂浮的小火球”的主要来源。

本轮只调整这两个类型的寿命、尺寸和余烬数量，不删除粒子，也不改短寿命的
`type 13` 火焰：

| 项目 | 原值 | 新值 |
| --- | --- | --- |
| type 15 寿命 | 90-180 | 60-110 |
| type 15 尺寸 | 5-7 | 3-5 |
| type 14 寿命 | 90-120 | 60-90 |
| type 14 单次数量 | 5 | 2 |
| wraith 火光半径/alpha | 0.5 / 0.9 | 0.35 / 0.65 |
| wraith 死亡火光半径/alpha | 1.0 / 0.7 | 0.7 / 0.5 |

type 15 的屏幕填充约下降到原来的四分之一，type 14 的存活数量约下降到原来的
三成；可见的火焰爆发、伤害、短寿命火焰和颜色都保留。

关闭对照：

```bash
./target/release/zs-coop-loader "../ZERO Sievert.exe" --no-anomaly-fire-visuals
```

### AI 分帧调度与多线程边界

结论先说清楚：GameMaker VM 的 GML 逻辑运行在单一主线程上，**不能通过
`data.win` 补丁把 AI 真正移到其它 CPU 核心**。视频解码、音频和 GPU 有各自的
线程，但 AI、碰撞、粒子模拟仍在主线程；真正的多线程需要原生 DLL/扩展，并与
VM 的对象、实例和 GC 做同步，风险和工程量都远超当前加载器的范围。

本轮做的是单核内的分帧调度：

- `ai_team_step` 是每个 NPC 每帧执行的 O(N) 接触/换弹/附近单位扫描；NPC 多时
  整体接近 O(N²)，是摄像机内 AI 密集时的明显热点。
- 在 `ai_human_dispatch` 的调用点增加分帧门控：用户把下限调到 4 个 NPC 后，
  从第 4 个 NPC 开始把团队扫描分摊到 2 帧，达到 30 个时 3 帧，按实例 id 错开；
- NPC 少于 4 时完全保持原频率；
- 用户已明确废弃“摄像机外巡逻 NPC 隔帧”的行为：视野外敌人也是威胁，当前实现
  不检查摄像机，也不跳过任何 NPC 的 dispatch；
- 团队调度只跳过协调扫描，不跳过移动、战斗、感知、行为树和动画。

这会把单帧的 AI 尖峰摊平并减少总的主线程工作量，但不会让游戏使用更多核心；
它是“时间片”而不是“多线程”。

关闭对照：

```bash
./target/release/zs-coop-loader "../ZERO Sievert.exe" --no-ai-timeslice
```

边界：

- NPC 较多时，队友之间的接触/换弹信息最多晚 1-2 帧到达；
- 所有 NPC（包括摄像机外）仍按原频率执行移动、感知和战斗，只是团队协调扫描
  被分摊；
- 火焰红光会变短、变淡、范围变小，余烬数量减少；如果更喜欢原版浓雾，用
  `--no-anomaly-fire-visuals`；
- 当前没有运行时 profiler，收益仍需游戏内 F11/外部监控对比。

验证：

- `cargo test --release --offline` 通过；
- 反编译确认 type 15/14 的寿命、尺寸和数量按表修改，`type 13` 保持原值；
- 确认 `wraith_fire` / `wraith_fire_dead` 光照参数修改，没有删除光照；
- 确认 `ai_team_step` 门控位于 `ai_human_dispatch` 内，移动/战斗调用未被包裹；
- 确认 NPC Step 已移除摄像机外巡逻门控；
- 默认 dry-run 包含“火焰异常视觉降载”和“AI 分帧调度”；两个 `--no-*` 开关能
  分别移除对应补丁。

## 上一轮：异常屏外裁剪与粒子可见性

用户反馈：上一轮火焰区域改善较小，异常整体仍有性能问题。本轮不再只改火焰碰撞，
而是处理异常系统在摄像机外的持续开销。

### 定位

- 大火焰区域由父生成器创建 `place_amount = 65` 个子实例，大化学区域创建 30 个；
  每个子实例都有独立 Step，房间加载后一直执行，不要求玩家靠近或触发。
- `obj_anomaly_gas_Step_0` 每帧执行三次 `scr_chance` 并在命中时发射粒子；
  `obj_anomaly_electric_generator_Step_0` 每帧以 `scr_chance(100)` 发射一次
  10 颗粒子爆发；异常区域的火焰/电光 wraith 每帧发射 15 颗粒子。
- 这些粒子在摄像机外仍然被创建、更新和提交绘制。多个异常区域同时存在于地图上
  时，摄像机外的子实例和粒子会持续叠加，形成“区域加载后就存在”的固定开销。

### 实现

新脚本 `analysis/optimization/apply_anomaly_offscreen.csx`：

- 在火焰、化学、电异常子实例和电异常发生器的 Step 开头检查摄像机矩形；
- 超出摄像机加 margin 的实例直接 `exit`，不再做玩家/NPC/螺栓碰撞和粒子创建；
- margin 为 `max(96, 摄像机宽度 * 0.25)`，480 宽的视野下是 120 世界像素；
  电异常发生器因为火花路径可达 96 像素，使用 `max(160, 摄像机宽度 * 0.33)`；
- 在 margin 内但仍然在视野外的实例，保留碰撞、伤害和 `alarm` 更新，只跳过
  粒子 burst。`scr_chance` 仍先执行，避免改变全局随机数序列；
- 异常 wraith 的 AI Step 不裁剪，只把它的身体粒子 burst 限制在摄像机附近，
  避免为了省粒子而影响寻路、感知或战斗；
- 没有删除粒子定义，没有改粒子数量、尺寸、生命周期、颜色或 shader；视野内的
  异常表现保持原样。

开关：

```bash
# 默认启用
./target/release/zs-coop-loader "../ZERO Sievert.exe"

# 关闭屏外裁剪，用于 A/B 对比
./target/release/zs-coop-loader "../ZERO Sievert.exe" --no-anomaly-offscreen-culling
```

边界：

- 超出 margin 的屏外 NPC 不再受到异常伤害；margin 内的 NPC 伤害保持原逻辑。
  这是用少量屏外模拟换 CPU/GPU 的取舍，默认 margin 约为视野的四分之一屏宽。
- 未来如果实现同屏多摄像机联机，需要把 `view_camera[0]` 的裁剪改成所有玩家
  摄像机的并集；当前游戏只有一个主摄像机。
- 视野内的火焰/化学/电异常仍保留全部粒子和碰撞；如果站进异常内部仍然掉帧，
  下一步应做每帧粒子预算或粒子密度分级，而不是继续扩大屏外裁剪。

验证：

- `cargo test --release --offline` 通过；
- 默认 dry-run 包含“异常屏外裁剪”；加 `--no-anomaly-offscreen-culling` 时该补丁
  从已执行列表消失；
- 已写入并反编译确认火焰/化学/电异常、电异常发生器和两种异常 wraith 的 Step
  开头都有摄像机检查，粒子 burst 的可见性条件正确，原有碰撞/伤害代码仍在；
- 之前的火焰 bbox/NPC 查询优化、化学/电玩家距离预筛选、`lista_text` 种子对话、
  `obj_cursor` 降帧等补丁都仍然存在。

## 历史：火焰异常

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
| `apply_anomaly_offscreen.csx` | 摄像机外异常子实例提前退出 Step；视野外 64 像素不生成粒子；wraith AI 保留 | 超出 margin 的屏外 NPC 伤害停止 |
| `apply_anomaly_fire_visuals.csx` | 缩短火焰大范围红光和长寿命余烬，降低 wraith 火光 | 红光更短更淡，余烬更少 |
| `apply_ai_timeslice.csx` | NPC 较多时把团队扫描分摊到 2-3 帧 | 团队信息最多延迟 1-2 帧；不跨核心 |
| `apply_gpu_scene.csx` | 草地风摆动实验 | 默认关闭 |

`apply_anomaly_hotspots.csx` 是历史实验文件，当前流水线不执行它。
失败的子异常粒子 `sphere_is_visible` 裁剪和辐射阈值实验没有接入当前流水线。

## 加载器简化

- 固定原始文件为游戏目录下的 `data_original_backup.win`。
- 首次优化时若不存在，复制当前 `data.win`；存在则不覆盖内容，并设置只读权限。
- 每次都从它读取，保证参数切换不会叠加上次补丁。
- 一次 UTMT 进程执行全部启用脚本，只写一份临时输出；成功后替换 `data.win`。
- 失败时删除临时输出；dry-run 保留 `data.win.coop-dry-run`；UTMT 从 `coop/tool/utmt` 外部调用。
- `--restore` 复制固定原始文件回 `data.win`，不会删除原始文件。
- 移除 `--keep-stage`、`--no-keep-stage`、`--base-data-win` 及其配置。

## 验证与后续判断

Rust 的备份回归测试覆盖：首次创建只读原件、连续优化、重复还原、原件内容保持不变。
UTMT 成功写出后重新反编译异常 Step，检查摄像机守卫、粒子可见性条件、NPC 单次查询
和化学/电玩家距离预筛选都在，并确认粒子定义与可见区域内的调用没有变化。

收益应在同一存档、位置、画质下比较默认版本与
`--no-anomaly-offscreen-culling`：先站在异常区域外观察远处异常是否仍拖低帧率，
再走进火焰/化学/电区域观察视野内表现是否保持。当前没有 GPU 时间测量，静态分析
只确认调用路径和屏外浪费，不能把潜在热点当成已经测量到的瓶颈。

## 列车长种子选择界面

上一版在选好地图后调用 `get_string` 弹出系统输入框，界面与游戏不一致。本版把
种子设置移到列车长的对话选项中，在打开地图选择之前完成：

- `lista_text` 为 `capotreno` 增加对话项 `npc.interaction.map_seed`，类型为
  `map_seed`，位置在“列车涂装”和“我要离开”之间；
- `ZS_vanilla/ui/npc_left_talk.ui` 的 `nextPageDict` 注册 `map_seed` 页面；
- 新页面 `ZS_vanilla/ui/npc_left_map_seed.ui` 用数字键输入种子，提供“随机种子 /
  删除最后一位 / 清空 / 确认种子”按钮；留空并确认表示使用随机种子；
- 确认后页面直接返回列车长对话，随后可从“我要离开”进入地图选择；
- 种子仍由 `obj_map_generator_Create_0` 一次性消费，消费后清除覆盖值；
- 输入、校验和格式化放在 `apply_conductor_seed.csx` 新增的 GML 辅助函数中，
  并通过 `ui_initialize_functions` 注册给 UI 的 Catspeak 环境。

实现文件：

```text
coop/analysis/optimization/apply_conductor_seed.csx   data.win 补丁
ZS_vanilla/ui/npc_left_map_seed.ui                    新页面
ZS_vanilla/ui/npc_left_talk.ui                        页面注册
ZS_vanilla/languages/english/english.csv              英文文案
ZS_vanilla/languages/chinese_simplified/chinese_simplified.csv  中文文案
coop/ui_seed/                                         内嵌 UI/CSV 快照，加载器自动部署
```

边界与行为：

- `.ui` 和语言 CSV 不写入 `data.win`，但已嵌入加载器并在替换前自动部署；游戏
  更新覆盖这些文件后，下次运行加载器会补齐。其它语言没有新增文案时会回退到英文。
- 种子页面没有把 Backspace 绑定为“返回”，因此 Backspace 在该页用于删除一位数字；
  要回到列车长对话请点击“返回”，Escape 仍会关闭整个对话。
- 确认后的种子作用于下一次生成的地图。若确认后不乘车直接离开对话，种子仍会保留
  到下一次地图生成时使用。
- 种子范围 0 到 4294967295，最多 10 位数字；超过范围时确认会提示错误，显示为红色。
- 任意数字输入依赖键盘数字键；手柄可以操作“随机种子 / 删除最后一位 / 清空 / 确认”
  按钮，但不能直接输入任意数字。手柄的返回键在该页不触发返回，需要导航到“返回”
  按钮。

验证：

```bash
cd coop
./target/release/zs-coop-loader "../ZERO Sievert.exe" --dry-run
```

该命令从 `data_original_backup.win` 重新生成全部补丁并只写临时文件；本轮已确认
UTMT 能编译新增的 GML，反编译 `npc_dialogue_map_go`、`lista_text`、
`ui_initialize_functions` 和 `obj_map_generator_Create_0` 后，新增函数、对话项和
种子消费逻辑均保持完整。UI 页面无法在当前环境启动游戏窗口验证，需要在游戏内
实际打开列车长对话检查排版与输入。

当前已写入游戏的 `data.win`：375869464 字节，
SHA-256 `b65ca83a1c30e0ec59c44078198ea8e8d1eecffcbbeaddd67dc3030aaefd7b12`。
原始备份仍为 `95252ac0...a7a7daa`，未改动。

## 编译期嵌入 csx

目标：加载器运行时不再依赖 `analysis/optimization/*.csx` 这些外部文件。

实现：

```text
coop/build.rs                     读取 optimization 目录，生成 generated_globals.rs
coop/src/scripts.rs               include! 生成的文件
coop/src/pipeline.rs              Spec 直接持有嵌入的源码；运行时落临时目录再交给 UTMT
```

- `build.rs` 对目录内所有 `.csx` 排序后生成一个 `&str` 静态量，并把整个目录加入
  `cargo:rerun-if-changed`，新增或删除脚本都会触发重新生成。
- 生成的字符串使用 Rust 调试转义（`{source:?}`），脚本里出现引号、反斜杠或
  `"#` 都不会破坏生成代码。
- UTMT CLI 只接受脚本路径，因此启用补丁时仍会把源码写到
  `$TMPDIR/zs-coop-scripts-<pid>-<nanos>/`，命令结束后由 `Drop` 删除；失败路径
  同样会清理。
- 本次先移除了对 csx 文件的运行期依赖；本轮进一步把 UI 和 CSV 也嵌入二进制，
  UTMT 仍保持外部引用，见顶部“资源嵌入与外部 UTMT”。

验证（隐藏脚本目录后仍能生成全部补丁）：

```bash
cd coop
mv analysis/optimization analysis/optimization.hidden
./target/release/zs-coop-loader "../ZERO Sievert.exe" --dry-run
mv analysis/optimization.hidden analysis/optimization
```

## 后台低帧率

目标：窗口失去焦点时把帧率降到 5 FPS，降低 GPU 和 CPU 占用；重新获得焦点后恢复。

实现文件：`coop/analysis/optimization/apply_background_fps.csx`，修改
`gml_Object_obj_cursor_Step_1`（Begin Step）。

选择这个钩子的原因：

- `obj_cursor` 是 persistent 对象，在 logo 画面创建，之后在菜单、hub、raid 和
  暂停菜单都存在；
- 它的 Step 本来每帧就会调用 `game_in_focus()`，新增的 `window_has_focus()`
  只是同类调用，额外开销可以忽略；
- 只改一个代码段，不新增对象、不新增每帧循环。

行为：

- logo 画面（`obj_logo_screen` 存在）不降帧，避免启动和加载被拖慢；
- 失焦时记录当前帧率（例如调试菜单的“Unlock framerate”可能设为 1000），再设为 5；
- 如果失焦期间切换房间导致帧率被重置，下一帧会重新降回 5；
- 重新获得焦点后恢复记录的帧率；
- 命令行 `--no-background-fps` 可以完全关闭该补丁。

边界与代价：

- 降帧会同时降低逻辑步进频率，所有按步计算的计时（alarm、冷却、移动、动画）
  在后台会慢 12 倍；用 `room_speed * 秒数` 计算的旧计时器会被拉长。这是“后台
  低帧率”本身的语义，不是补丁额外引入的。
- 音频线程不受影响；5 FPS 下重新获得焦点后最多约 200 毫秒恢复，输入延迟只影响刚切回的一瞬。
- 没有采用 `sleep()`：它会阻塞音频和窗口事件；也没有只关闭绘制：那样 CPU
  仍然跑满。`game_set_speed` 是游戏已经使用的运行时接口（调试菜单的
  “Unlock framerate”就调用它），风险最小。
- 如果游戏更新改名了 `obj_cursor` 或删除该事件，UTMT 会在补丁阶段报错，
  不会生成半截代码。

验证：

- `cargo test --release --offline` 通过；
- 隐藏 `analysis/optimization` 后 dry-run 通过；
- 已写入并反编译确认 `obj_cursor_Step_1` 开头是降帧逻辑，原有光标逻辑完整保留；
- 游戏内可通过 F11 打开帧率显示，切到后台应看到帧率降到约 5，切回后恢复。
  当前环境无法启动游戏窗口，这一步需要人工确认。

## 菜单静态背景

调查结论：主菜单和暂停菜单共用 `ZS_vanilla/ui/mm_root.ui`，其中最底层是一个
`UiVideo`，`source = "ZS_menu.mp4"`。`uiClassVideo` 的 Draw 回调每帧调用
`video_draw()` 解码并绘制整张 1920x1080 视频；暂停时 `game_pause()` 在当前房间
创建 `obj_main_menu`，仍然会加载同一个 `mm_root.ui`。所以暂停界面背后不是一张
静态图，而是持续解码的视频。这就是这两个界面主要的动态 CPU/GPU 开销。

游戏本身已经为无法播放视频的情况准备了 `spr_videoreplacement_mainmenu`
（1920x1080，单帧静态图），`uiClassVideo` 在视频不可用或 Steam Deck 上本来就会
画它。补丁直接复用这条现成的回退路径：

- 在 `gml_GlobalScript_uiClassVideo` 的 Draw 回调开头加一个条件分支；
- 命中静态模式时，第一次关闭视频（`video_close()`），之后只画
  `spr_videoreplacement_mainmenu`，不再调用 `video_draw()`；
- 用一个实例变量记录“已经关闭过”，避免每帧重复调用 `video_close()`；
- 分支只做一次 `room` 比较和一次整数/布尔判断，没有新增对象、循环或额外纹理。

开关：

```bash
# 默认：主菜单和暂停菜单都使用静态背景
./target/release/zs-coop-loader "../ZERO Sievert.exe"

# 主菜单保留动态视频，暂停菜单仍静态
./target/release/zs-coop-loader "../ZERO Sievert.exe" --menu-video

# 暂停菜单保留动态视频，主菜单仍静态
./target/release/zs-coop-loader "../ZERO Sievert.exe" --pause-video

# 两个都保留动态视频（等价于不打这个补丁）
./target/release/zs-coop-loader "../ZERO Sievert.exe" --menu-video --pause-video
```

代价：

- 主菜单和暂停菜单的背景从视频变成静态 key art，这是可见的画面变化；需要原视频
  时用上面的 `--menu-video` / `--pause-video` 重新生成；
- 静态图是游戏自带的 Steam Deck 回退图，分辨率与视频一致，不需要新增资源；
- 进入游戏、退出到主菜单、暂停/恢复时，UI 元素会正常创建和销毁，视频会在离开
  静态模式后按原有队列逻辑重新打开。

验证：

- 默认 dry-run 的已执行列表包含“菜单静态背景”；同时加
  `--menu-video --pause-video` 时该补丁被跳过；
- 已写入并反编译确认 `uiClassVideo` 的 Draw 回调开头是静态分支，后面的
  `video_draw()` 原逻辑完整保留；
- 之前的 `obj_cursor` 降帧、`lista_text` 种子对话等补丁仍然存在；
- 当前环境无法启动游戏窗口，静态背景的实际观感需要在游戏内确认。

当前 `data.win`：375867928 字节，
SHA-256 `b1e3e1915b56b4f966b3c328ecd18a09c82ddd2318cf83c082b78b42078a45ee`。
