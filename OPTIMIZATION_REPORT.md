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
coop/ui_seed/                                         松散文件快照与重新部署说明
```

边界与行为：

- `.ui` 和语言 CSV 是游戏目录中的松散文件，不写入 `data.win`；游戏更新覆盖这些
  文件后需要重新应用。其它语言没有新增文案时会回退到英文。
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

当前已写入游戏的 `data.win`：375862552 字节，
SHA-256 `df6c43148b7e59a813dd69874609aa6b0310b5b286a5af2ace45ecff1469baac`。
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
- 外部依赖只剩 `tool/utmt/UndertaleModCli`，本次移除的是对 csx 文件的运行期依赖。

验证（隐藏脚本目录后仍能生成全部补丁）：

```bash
cd coop
mv analysis/optimization analysis/optimization.hidden
./target/release/zs-coop-loader "../ZERO Sievert.exe" --dry-run
mv analysis/optimization.hidden analysis/optimization
```

## 后台低帧率

目标：窗口失去焦点时把帧率降到 10 FPS，降低 GPU 和 CPU 占用；重新获得焦点后恢复。

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
- 失焦时记录当前帧率（例如调试菜单的“Unlock framerate”可能设为 1000），再设为 10；
- 如果失焦期间切换房间导致帧率被重置，下一帧会重新降回 10；
- 重新获得焦点后恢复记录的帧率；
- 命令行 `--no-background-fps` 可以完全关闭该补丁。

边界与代价：

- 降帧会同时降低逻辑步进频率，所有按步计算的计时（alarm、冷却、移动、动画）
  在后台会慢 6 倍；用 `room_speed * 秒数` 计算的旧计时器会被拉长。这是“后台
  低帧率”本身的语义，不是补丁额外引入的。
- 音频线程不受影响；重新获得焦点后约 100 毫秒内恢复，输入延迟只影响刚切回的一瞬。
- 没有采用 `sleep()`：它会阻塞音频和窗口事件；也没有只关闭绘制：那样 CPU
  仍然跑满。`game_set_speed` 是游戏已经使用的运行时接口（调试菜单的
  “Unlock framerate”就调用它），风险最小。
- 如果游戏更新改名了 `obj_cursor` 或删除该事件，UTMT 会在补丁阶段报错，
  不会生成半截代码。

验证：

- `cargo test --release --offline` 通过；
- 隐藏 `analysis/optimization` 后 dry-run 通过；
- 已写入并反编译确认 `obj_cursor_Step_1` 开头是降帧逻辑，原有光标逻辑完整保留；
- 游戏内可通过 F11 打开帧率显示，切到后台应看到帧率降到约 10，切回后恢复。
  当前环境无法启动游戏窗口，这一步需要人工确认。

当前 `data.win`：375862296 字节，
SHA-256 `b30f7f5ea433d4bcf7975471a8cf34845908a7b8c34a5e582785c744ffea5558`。
