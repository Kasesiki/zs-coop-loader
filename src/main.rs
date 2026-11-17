mod assets;
mod backup;
mod config;
mod pipeline;
mod scripts;
mod seed_ui;

use clap::Parser;
use std::env;
use std::path::PathBuf;
use std::process::ExitCode;

use crate::config::Settings;

const DEFAULT_EXE: &str = "ZERO Sievert.exe";

#[derive(Debug, Parser)]
#[command(
    name = "zs-coop-loader",
    version,
    about = "ZERO Sievert data.win 优化加载器",
    long_about = "生成、检查、替换或恢复 ZERO Sievert 的 data.win。优化脚本、种子界面和语言文案已嵌入二进制；UTMT 仍从 coop/tool/utmt 外部调用。启动器不会启动游戏，也不会加载 Proton。",
    help_template = "{about-with-newline}\n用法：{usage}\n\n参数：\n{positionals}\n\n选项：\n{options}\n"
)]
struct Args {
    /// 游戏可执行文件路径，默认是当前目录下的 ZERO Sievert.exe。
    #[arg(value_name = "游戏EXE", default_value = DEFAULT_EXE)]
    game: PathBuf,

    /// 禁用 LOS 视线缓存；默认启用。
    #[arg(long)]
    no_los_cache: bool,
    /// 禁用视觉优化；默认启用，保留粒子，只裁剪屏幕外普通子弹绘制。
    #[arg(long)]
    no_aggressive_visuals: bool,
    /// 禁用主菜单和静态场景优化；默认启用。
    #[arg(long)]
    no_scene_optimization: bool,
    /// 禁用异常父发射器屏外裁剪；默认启用，保留可见范围内粒子。
    #[arg(long)]
    no_anomaly_emitter_culling: bool,
    /// 禁用已有的化学、电异常玩家碰撞预筛选；默认启用。
    #[arg(long)]
    no_anomaly_collision_prefilter: bool,
    /// 禁用火焰异常碰撞优化；默认启用，保留粒子和屏外伤害。
    #[arg(long)]
    no_anomaly_fire_optimization: bool,
    /// 启用实验性 GPU 场景优化；默认关闭，会关闭草地风摆动。
    #[arg(long)]
    gpu_scene_optimization: bool,
    /// 禁用后台低帧率；默认启用，窗口失去焦点时降到 5 FPS。
    #[arg(long)]
    no_background_fps: bool,
    /// 主菜单保留动态视频背景；默认使用静态背景图以降低 CPU/GPU 占用。
    #[arg(long)]
    menu_video: bool,
    /// 暂停菜单保留动态视频背景；默认使用静态背景图以降低 CPU/GPU 占用。
    #[arg(long)]
    pause_video: bool,
    /// 禁用异常屏外裁剪；默认启用，远离摄像机的异常子实例不再执行 Step。
    #[arg(long)]
    no_anomaly_offscreen_culling: bool,
    /// 保留火焰异常原始红光和长寿命小火球；默认启用降载。
    #[arg(long)]
    no_anomaly_fire_visuals: bool,
    /// 禁用 AI 分帧调度；默认启用，在 NPC 较多时把团队扫描分摊到多帧。
    #[arg(long)]
    no_ai_timeslice: bool,

    /// 只生成优化后的 data.win，不替换游戏文件；文件保留为 data.win.coop-dry-run。
    #[arg(long, conflicts_with = "restore")]
    dry_run: bool,

    /// 使用游戏目录下的 data_original_backup.win 恢复 data.win。
    #[arg(long, conflicts_with = "dry_run")]
    restore: bool,
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
    let game = if args.game.is_absolute() {
        args.game.clone()
    } else {
        env::current_dir()
            .map_err(|error| format!("读取当前目录失败：{error}"))?
            .join(&args.game)
    };
    let game_dir = game.parent().ok_or("游戏路径没有父目录")?;
    let coop_dir = game_dir.join("coop");
    let game_data = game_dir.join("data.win");

    if args.restore {
        backup::restore(&game_data)?;
        return Ok(());
    }

    let mut settings = Settings::default();
    settings.apply_cli(&args);

    let original = backup::ensure_original(&game_data)?;
    let result = pipeline::build(&coop_dir, &original, &settings, args.dry_run)?;

    println!("原始文件：{}", original.display());
    if result.applied.is_empty() {
        println!("已执行：无（所有补丁都已禁用）");
    } else {
        println!("已执行：{}", result.applied.join(", "));
    }

    if args.dry_run {
        println!(
            "dry-run：已生成 {}，没有替换游戏 data.win。",
            result.output.display()
        );
        return Ok(());
    }

    // 先部署 UI/CSV，再替换 data.win。这样部署失败时游戏仍保持旧文件，
    // 不会出现“data.win 已引用新对话页，但页面文件不存在”的状态。
    if let Err(error) = seed_ui::deploy(game_dir) {
        let _ = std::fs::remove_file(&result.output);
        return Err(error);
    }
    if let Err(error) = backup::replace(&game_data, &result.output) {
        let _ = std::fs::remove_file(&result.output);
        return Err(error);
    }
    println!("已替换：{}", game_data.display());
    println!("请手动从 Steam 启动游戏；需要恢复时使用 --restore。");
    Ok(())
}
