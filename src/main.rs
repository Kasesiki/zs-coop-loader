mod backup;
mod config;
mod pipeline;

use clap::Parser;
use std::env;
use std::path::PathBuf;
use std::process::ExitCode;

const DEFAULT_EXE: &str = "ZERO Sievert.exe";

#[derive(Debug, Parser)]
#[command(
    name = "zs-coop-loader",
    version,
    about = "ZERO Sievert data.win 优化加载器",
    long_about = "生成、检查、替换或恢复 ZERO Sievert 的 data.win。启动器不会启动游戏，也不会加载 Proton。",
    help_template = "{about-with-newline}\n用法：{usage}\n\n参数：\n{positionals}\n\n选项：\n{options}\n"
)]
struct Args {
    /// 游戏可执行文件路径，默认是当前目录下的 ZERO Sievert.exe。
    #[arg(value_name = "游戏EXE", default_value = DEFAULT_EXE)]
    game: PathBuf,

    /// 指定配置文件，默认使用游戏目录下的 coop/coop.conf。
    #[arg(long, value_name = "路径")]
    config: Option<PathBuf>,

    /// 禁用 LOS 视线缓存；默认启用。
    #[arg(long)]
    no_los_cache: bool,
    /// 禁用视觉优化；默认启用，保留粒子，只裁剪屏幕外普通子弹绘制。
    #[arg(long)]
    no_aggressive_visuals: bool,
    /// 禁用主菜单和静态场景优化；默认启用。
    #[arg(long)]
    no_scene_optimization: bool,
    /// 禁用异常区域 shader 优化；默认启用，异常粒子保持原样。
    #[arg(long)]
    no_anomaly_optimization: bool,
    /// 禁用 GPU 场景优化；默认关闭，因为实验版本会关闭草地风摆动。
    #[arg(long)]
    no_gpu_scene_optimization: bool,

    /// 保留生成的 runtime 目录。
    #[arg(long, conflicts_with = "no_keep_stage")]
    keep_stage: bool,
    /// 游戏处理完成后删除 runtime 目录；默认保留。
    #[arg(long, conflicts_with = "keep_stage")]
    no_keep_stage: bool,

    /// 只生成优化后的 data.win，不替换游戏文件。
    #[arg(long, conflicts_with = "restore")]
    dry_run: bool,

    /// 使用活动备份恢复游戏 data.win。
    #[arg(long, conflicts_with = "dry_run")]
    restore: bool,

    /// 覆盖配置中的基线 data.win 路径。
    #[arg(long, value_name = "路径")]
    base_data_win: Option<PathBuf>,
}

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("zs-coop-loader: {error}");
            ExitCode::FAILURE
        }
    }
}

fn run() -> Result<(), String> {
    let args = Args::parse();
    let game = absolute_path(&args.game)?;
    let game_dir = game.parent().ok_or("游戏路径没有父目录")?;
    let coop_dir = game_dir.join("coop");
    let config_path = args
        .config
        .as_deref()
        .map(|path| config::resolve_path(path, game_dir))
        .unwrap_or_else(|| coop_dir.join("coop.conf"));
    let mut settings = config::load(&config_path, game_dir)?;
    settings.apply_cli(&args);

    let game_data = game_dir.join("data.win");
    if args.restore {
        backup::restore(&coop_dir, &game_data)?;
        return Ok(());
    }

    let baseline = settings
        .base_data_win
        .as_deref()
        .map(|path| config::resolve_path(path, game_dir))
        .unwrap_or_else(|| game_data.clone());
    let result = pipeline::build(&coop_dir, &baseline, &settings)?;

    println!("生成目录：{}", result.stage.display());
    println!("基线文件：{}", baseline.display());
    println!("已执行：{}", result.applied.join(", "));
    if args.dry_run {
        println!("dry-run：没有替换游戏 data.win。 ");
        return Ok(());
    }

    backup::replace(&coop_dir, &game_data, &result.output)?;
    if !settings.keep_stage {
        std::fs::remove_dir_all(&result.stage)
            .map_err(|error| format!("清理生成目录失败：{error}"))?;
    }
    println!("已替换：{}", game_data.display());
    println!("请手动从 Steam 启动游戏；需要恢复时使用 --restore。 ");
    Ok(())
}

fn absolute_path(path: &std::path::Path) -> Result<PathBuf, String> {
    if path.is_absolute() {
        return Ok(path.to_path_buf());
    }
    env::current_dir()
        .map(|cwd| cwd.join(path))
        .map_err(|error| format!("读取当前目录失败：{error}"))
}
