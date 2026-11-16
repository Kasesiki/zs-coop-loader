# ZERO Sievert 优化加载器

Rust 程序调用 UTMT 修改 GameMaker 字节码，替换游戏目录中的 `data.win`。
处理结束后手动从 Steam 启动游戏。目前没有运行时 DLL 注入或联机功能。

## 使用

在游戏目录执行：

```bash
cargo build --release --offline --manifest-path coop/Cargo.toml
./coop/target/release/zs-coop-loader
```

首次运行检查游戏目录下的 `data_original_backup.win`：不存在则复制当前
`data.win` 创建它，存在则保留其内容。每次运行都会确保备份只读；Linux 下权限为
`444`。请确保首次备份时的 `data.win` 是需要保存的原始版本。

每次优化都读取这一份原始备份，因此关闭某项优化会真正移除该项改动。
所有启用的 CSX 在一次 UTMT 进程内执行。只有一个短暂的输出文件
`data.win.coop-tmp`；成功后替换 `data.win`，失败时保留现有游戏文件。
不创建 runtime、时间戳目录或多份备份。

还原：

```bash
./coop/target/release/zs-coop-loader --restore
```

还原将 `data_original_backup.win` 复制回 `data.win`，保留原始备份。

## 参数与配置

默认读取 `coop/coop.conf`，命令行禁用参数优先。一个开关只占一个参数，无需填写
`true` 或 `false`。完整中文帮助：

```bash
./coop/target/release/zs-coop-loader --help
```

| 参数 | 含义 |
| --- | --- |
| `--no-anomaly-fire-optimization` | 禁用本轮火焰碰撞优化 |
| `--no-anomaly-emitter-culling` | 禁用已有的火焰、化学父发射器裁剪 |
| `--no-anomaly-collision-prefilter` | 禁用已有的化学、电异常玩家碰撞预筛选 |
| `--no-los-cache` | 禁用 LOS 缓存 |
| `--no-aggressive-visuals` | 禁用普通子弹屏外绘制裁剪 |
| `--no-scene-optimization` | 禁用启动视频、菜单与静态物品批处理改动 |
| `--no-gpu-scene-optimization` | 禁用草地实验；该实验默认已关闭 |
| `--config 路径` | 指定配置文件，相对路径按游戏目录解析 |
| `--dry-run` | 验证编译并丢弃输出，不替换游戏文件 |
| `--restore` | 从固定的原始备份还原游戏文件 |

```ini
los_cache = true
aggressive_visuals = true
scene_optimization = true
anomaly_emitter_culling = true
anomaly_collision_prefilter = true
anomaly_fire_optimization = true
gpu_scene_optimization = false
```

只关闭本轮火焰优化进行对照：

```bash
./coop/target/release/zs-coop-loader --no-anomaly-fire-optimization
```

可选位置参数是游戏 EXE 路径，默认 `./ZERO Sievert.exe`。加载器不会启动 EXE。
优化原理、变化范围与验证记录见 `OPTIMIZATION_REPORT.md`。
