# ZERO Sievert 联机模组启动器

这是 ZERO Sievert 联机模组的 Rust 文件处理器。目前负责在启动前生成优化
后的 GameMaker `data.win`，备份原文件并替换游戏目录中的文件。它不会启动
游戏，也不执行 native DLL 注入。

## 构建

需要 Rust 工具链。项目依赖的 `clap` 已加入命令行解析，支持离线构建：

```sh
cargo build --release
cargo test --offline
```

## 基本启动

从游戏目录执行：

```sh
cargo run --release --manifest-path coop/Cargo.toml -- "./ZERO Sievert.exe"
```

默认读取 `coop/coop.conf`。启动器会：

1. 读取配置和命令行覆盖项。
2. 创建 `coop/runtime/<时间戳>/` 隔离目录。
3. 在 `coop/runtime/<时间戳>/` 中只准备工作用的 `data.win`。
4. 按启用项顺序使用 UTMT 脚本生成优化版本。
5. 备份当前游戏 `data.win`，并将优化版本替换到游戏目录。

处理完成后请手动从 Steam 启动游戏。游戏退出后可以使用 `--restore` 还原。

## 配置文件

`coop/coop.conf`：

```ini
# 是否启用视线检测短缓存
los_cache = true

# 保留粒子并裁剪屏幕外普通子弹绘制
aggressive_visuals = true

# 是否优化启动视频、主菜单 UI 更新和基地静态物品批处理
scene_optimization = true

# 是否保留隔离运行目录，便于检查生成的 data.win
keep_stage = true

# 每次生成时使用的未修改基线文件
base_data_win = "coop/backups/20261115_174509/data.win"
```

路径默认相对于游戏目录解析，也可以填写绝对路径。

## 命令行参数

运行 `zs-coop-loader --help` 可以查看同样的中文帮助。常用参数如下：

```text
--config <路径>
    指定配置文件。

--los-cache
    本次启动启用 LOS 视线缓存。

--no-los-cache
    本次启动禁用 LOS 视线缓存。

--aggressive-visuals
    本次启动启用激进视觉优化。

--no-aggressive-visuals
    本次启动禁用视觉优化；默认启用。

--scene-optimization
    本次启动启用主菜单和静态场景优化。

--no-scene-optimization
    本次启动禁用主菜单和静态场景优化。

--anomaly-optimization
    本次启动启用异常区域粒子优化。

--no-anomaly-optimization
    本次启动禁用异常区域粒子优化。

--gpu-scene-optimization
    本次启动启用 GPU 场景优化，保留草地绘制但关闭风摆动着色计算。

--no-gpu-scene-optimization
    本次启动禁用 GPU 场景优化。

--keep-stage
    保留本次隔离运行目录。

--no-keep-stage
    游戏退出后删除本次隔离运行目录。

--dry-run
    只生成隔离目录，不启动游戏。

--base-data-win <路径>
    覆盖配置中的 data.win 基线文件。

--restore
    使用活动备份还原游戏目录中的 data.win。
```

命令行开关优先级高于配置文件。启用和禁用同一选项不能同时使用。

## 使用示例

```sh
# 使用配置文件中的默认优化
cargo run --release --manifest-path coop/Cargo.toml -- "./ZERO Sievert.exe"

# 本次只启用激进视觉优化
cargo run --release --manifest-path coop/Cargo.toml -- \
  --no-los-cache --aggressive-visuals "./ZERO Sievert.exe"

# 本次关闭全部优化
cargo run --release --manifest-path coop/Cargo.toml -- \
  --no-los-cache --no-aggressive-visuals "./ZERO Sievert.exe"

# 只生成并保留 staging 目录，不启动游戏
cargo run --release --manifest-path coop/Cargo.toml -- \
  --dry-run --keep-stage "./ZERO Sievert.exe"

# 生成、备份并替换游戏 data.win，然后手动从 Steam 启动
cargo run --release --manifest-path coop/Cargo.toml -- \
  "./ZERO Sievert.exe"

# 游戏退出后还原原始 data.win
cargo run --release --manifest-path coop/Cargo.toml -- \
  --restore "./ZERO Sievert.exe"
```

## 当前优化

- LOS 缓存：减少同一房间、同一坐标的重复 `collision_line` 查询。
- 激进视觉优化：停止天气、异常和辐射粒子的新发射，并跳过屏幕外子弹
  的绘制。子弹移动和碰撞仍然执行。
- 场景与启动优化：跳过启动视频解码，主菜单 UI 树隔帧更新，并将基地静态
  物品批处理从进入场景后约 8 帧提前到约 2 帧。菜单输入仍然每帧处理。

优化脚本位于 `analysis/optimization/`，每个脚本只负责一项优化；
隔离工作目录位于 `runtime/`，其中只保存 UTMT 的输入和中间输出文件。

## 术语说明

- **加载**：在启动前准备修改后的资源或运行时模块。
- **Hook**：观察或重定向函数、事件、导入表或消息路径。
- **注入**：把模块加载进目标进程；注入本身不等于 Hook。
- **静态 data.win 优化**：在进程启动前修改 GameMaker VM 资源。

当前方案使用静态 `data.win` 优化，不是运行时内存 Hook。对于这个 GMS2 VM
版本，它比固定 native 地址更容易校验和回退。启动器默认不会启动 Proton，
因此 Steam 的兼容层、启动参数和存档环境由 Steam 自己管理。
