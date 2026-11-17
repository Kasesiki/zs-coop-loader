use crate::config::Settings;
use crate::scripts;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Clone, Copy)]
enum Feature {
    LosCache,
    AggressiveVisuals,
    SceneOptimization,
    AnomalyEmitterCulling,
    AnomalyFireOptimization,
    AnomalyCollisionPrefilter,
    ConductorSeed,
    BackgroundFps,
    GpuScene,
    MenuBackground,
    AnomalyFireVisuals,
    AnomalyOffscreenCulling,
    AiTimeslice,
}

struct Spec {
    feature: Feature,
    /// 生成脚本文件名，同时用于临时文件命名。
    name: &'static str,
    /// build.rs 在编译期嵌入的 csx 内容。
    source: &'static str,
    label: &'static str,
}

impl Feature {
    fn enabled(self, settings: &Settings) -> bool {
        match self {
            Self::LosCache => settings.los_cache,
            Self::AggressiveVisuals => settings.aggressive_visuals,
            Self::SceneOptimization => settings.scene_optimization,
            Self::AnomalyEmitterCulling => settings.anomaly_emitter_culling,
            Self::AnomalyFireOptimization => settings.anomaly_fire_optimization,
            Self::AnomalyCollisionPrefilter => settings.anomaly_collision_prefilter,
            Self::ConductorSeed => true,
            Self::BackgroundFps => settings.background_fps,
            Self::GpuScene => settings.gpu_scene_optimization,
            Self::MenuBackground => {
                settings.static_menu_background || settings.static_pause_background
            }
            Self::AnomalyFireVisuals => settings.anomaly_fire_visuals,
            Self::AnomalyOffscreenCulling => settings.anomaly_offscreen_culling,
            Self::AiTimeslice => settings.ai_timeslice,
        }
    }
}

/// 顺序有依赖：火焰视觉降载必须排在异常屏外裁剪之前，后者的替换锚点
/// 依赖前者改写后的 type 14 代码块。
const SPECS: [Spec; 13] = [
    Spec {
        feature: Feature::LosCache,
        name: "apply_los_cache.csx",
        source: scripts::apply_los_cache,
        label: "LOS 缓存",
    },
    Spec {
        feature: Feature::AggressiveVisuals,
        name: "apply_aggressive_visuals.csx",
        source: scripts::apply_aggressive_visuals,
        label: "激进视觉优化",
    },
    Spec {
        feature: Feature::SceneOptimization,
        name: "apply_scene_startup.csx",
        source: scripts::apply_scene_startup,
        label: "场景与启动优化",
    },
    Spec {
        feature: Feature::AnomalyEmitterCulling,
        name: "apply_anomaly_emitter_culling.csx",
        source: scripts::apply_anomaly_emitter_culling,
        label: "异常父发射器裁剪",
    },
    Spec {
        feature: Feature::AnomalyFireOptimization,
        name: "apply_anomaly_fire_optimization.csx",
        source: scripts::apply_anomaly_fire_optimization,
        label: "火焰异常碰撞优化",
    },
    Spec {
        feature: Feature::AnomalyCollisionPrefilter,
        name: "apply_anomaly_collision_prefilter.csx",
        source: scripts::apply_anomaly_collision_prefilter,
        label: "化学、电异常碰撞预筛选",
    },
    Spec {
        feature: Feature::ConductorSeed,
        name: "apply_conductor_seed.csx",
        source: scripts::apply_conductor_seed,
        label: "列车长 seed 选择",
    },
    Spec {
        feature: Feature::BackgroundFps,
        name: "apply_background_fps.csx",
        source: scripts::apply_background_fps,
        label: "后台低帧率",
    },
    Spec {
        feature: Feature::GpuScene,
        name: "apply_gpu_scene.csx",
        source: scripts::apply_gpu_scene,
        label: "GPU 场景优化",
    },
    Spec {
        feature: Feature::MenuBackground,
        name: "apply_menu_background.csx",
        source: scripts::apply_menu_background,
        label: "菜单静态背景",
    },
    Spec {
        feature: Feature::AnomalyFireVisuals,
        name: "apply_anomaly_fire_visuals.csx",
        source: scripts::apply_anomaly_fire_visuals,
        label: "火焰异常视觉降载",
    },
    Spec {
        feature: Feature::AnomalyOffscreenCulling,
        name: "apply_anomaly_offscreen.csx",
        source: scripts::apply_anomaly_offscreen,
        label: "异常屏外裁剪",
    },
    Spec {
        feature: Feature::AiTimeslice,
        name: "apply_ai_timeslice.csx",
        source: scripts::apply_ai_timeslice,
        label: "AI 分帧调度",
    },
];

pub struct BuildResult {
    pub output: PathBuf,
    pub applied: Vec<&'static str>,
}

/// 把嵌入的 csx 落到临时目录，UTMT CLI 目前只接受脚本路径。
/// 目录在离开作用域时删除，失败路径也不会留下垃圾。
struct ScriptFiles {
    dir: PathBuf,
    paths: Vec<PathBuf>,
}

impl Drop for ScriptFiles {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.dir);
    }
}

fn materialize(specs: &[&Spec], settings: &Settings) -> Result<ScriptFiles, String> {
    let stamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|elapsed| elapsed.as_nanos())
        .unwrap_or_default();
    let dir = std::env::temp_dir().join(format!("zs-coop-scripts-{}-{stamp}", std::process::id()));
    fs::create_dir_all(&dir)
        .map_err(|error| format!("无法创建临时脚本目录 {}：{error}", dir.display()))?;

    let mut files = ScriptFiles {
        dir,
        paths: Vec::with_capacity(specs.len()),
    };
    for spec in specs {
        let path = files.dir.join(spec.name);
        fs::write(&path, render_source(spec, settings))
            .map_err(|error| format!("无法写入临时脚本 {}：{error}", path.display()))?;
        files.paths.push(path);
    }
    Ok(files)
}

pub fn build(
    coop_dir: &Path,
    original: &Path,
    settings: &Settings,
    dry_run: bool,
) -> Result<BuildResult, String> {
    if !original.is_file() {
        return Err(format!("找不到原始备份：{}", original.display()));
    }

    let enabled: Vec<&Spec> = SPECS
        .iter()
        .filter(|spec| spec.feature.enabled(settings))
        .collect();
    let output = if dry_run {
        original.with_file_name("data.win.coop-dry-run")
    } else {
        original.with_file_name("data.win.coop-tmp")
    };
    if dry_run {
        let _ = fs::remove_file(&output);
    }
    // 先占位再让 UTMT 覆盖，避免两个加载器同时写同一个临时文件。
    fs::OpenOptions::new()
        .write(true)
        .create_new(true)
        .open(&output)
        .map_err(|error| {
            format!(
                "无法创建 {}（请确认没有其它加载器在运行）：{error}",
                output.display()
            )
        })?;

    let result = if enabled.is_empty() {
        fs::copy(original, &output)
            .map(|_| ())
            .map_err(|error| format!("复制原始备份失败：{error}"))
    } else {
        run_utmt(coop_dir, original, &output, &enabled, settings)
    };

    match result {
        Ok(()) => Ok(BuildResult {
            output,
            applied: enabled.iter().map(|spec| spec.label).collect(),
        }),
        Err(error) => {
            let _ = fs::remove_file(&output);
            Err(error)
        }
    }
}

fn run_utmt(
    coop_dir: &Path,
    original: &Path,
    output: &Path,
    specs: &[&Spec],
    settings: &Settings,
) -> Result<(), String> {
    let executable = coop_dir.join("tool/utmt/UndertaleModCli");
    if !executable.is_file() {
        return Err(format!(
            "找不到 UTMT CLI：{}；请保留外部 tool/utmt（或解压 UTMT 发行包）",
            executable.display()
        ));
    }
    let directory = executable
        .parent()
        .ok_or_else(|| format!("UTMT 路径没有父目录：{}", executable.display()))?;

    let files = materialize(specs, settings)?;
    let mut command = Command::new(&executable);
    command.current_dir(directory).arg("load").arg(original);
    for path in &files.paths {
        command.arg("-s").arg(path);
    }
    let status = command
        .args(["-o"])
        .arg(output)
        .args(["-f"])
        .status()
        .map_err(|error| format!("执行 UTMT 失败：{error}"))?;

    if !status.success() || fs::metadata(output).map(|meta| meta.len()).unwrap_or(0) == 0 {
        return Err("UTMT 未能生成优化文件；游戏 data.win 未替换".into());
    }
    Ok(())
}

/// 把编译期嵌入的脚本里的开关占位符替换成本次运行的配置。
/// 这样同一个 csx 可以服务“仅暂停静态”“仅主菜单静态”“全部静态”等模式。
fn render_source(spec: &Spec, settings: &Settings) -> String {
    let menu = if settings.static_menu_background {
        "true"
    } else {
        "false"
    };
    let pause = if settings.static_pause_background {
        "true"
    } else {
        "false"
    };
    spec.source
        .replace("@@COOP_STATIC_MENU@@", menu)
        .replace("@@COOP_STATIC_PAUSE@@", pause)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn every_spec_has_an_embedded_script() {
        for spec in &SPECS {
            assert!(!spec.source.is_empty(), "{} 的脚本为空", spec.name);
            assert!(spec.name.ends_with(".csx"));
        }
    }

    #[test]
    fn spec_names_are_unique() {
        let mut names: Vec<_> = SPECS.iter().map(|spec| spec.name).collect();
        names.sort_unstable();
        names.dedup();
        assert_eq!(names.len(), SPECS.len());
    }

    #[test]
    fn menu_background_script_is_rendered_from_settings() {
        let mut settings = Settings::default();
        settings.static_menu_background = true;
        settings.static_pause_background = false;
        let spec = SPECS
            .iter()
            .find(|spec| spec.name == "apply_menu_background.csx")
            .expect("菜单背景脚本缺失");
        let rendered = render_source(spec, &settings);
        assert!(!rendered.contains("@@COOP_STATIC_"));
        assert!(rendered.contains("true && room == r_menu"));
        assert!(rendered.contains("false && room != r_menu"));
    }
}
