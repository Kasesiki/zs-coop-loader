use crate::config::Settings;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

struct Spec {
    enabled: bool,
    tag: &'static str,
    script: &'static str,
    label: &'static str,
}

pub struct BuildResult {
    pub stage: PathBuf,
    pub output: PathBuf,
    pub applied: Vec<&'static str>,
}

pub fn build(coop_dir: &Path, baseline: &Path, settings: &Settings) -> Result<BuildResult, String> {
    if !baseline.is_file() {
        return Err(format!("找不到基线 data.win：{}", baseline.display()));
    }
    let specs = specs(settings);
    let utmt = coop_dir.join("tool/utmt/UndertaleModCli");
    if specs.iter().any(|spec| spec.enabled) && !utmt.is_file() {
        return Err(format!("找不到 UTMT CLI：{}", utmt.display()));
    }
    let stage = create_stage(coop_dir)?;
    let mut input = stage.join("data.win");
    fs::copy(baseline, &input).map_err(|error| format!("复制基线 data.win 失败：{error}"))?;
    let mut applied = Vec::new();
    for spec in specs.iter().filter(|spec| spec.enabled) {
        let output = stage.join(format!("data.win.{}", spec.tag));
        let script = coop_dir.join("analysis/optimization").join(spec.script);
        if !script.is_file() {
            return Err(format!("找不到优化脚本：{}", script.display()));
        }
        let status = Command::new(&utmt)
            .current_dir(script.parent().unwrap_or(Path::new(".")))
            .args(["load"])
            .arg(&input)
            .args(["-s"])
            .arg(&script)
            .args(["-o"])
            .arg(&output)
            .args(["-f"])
            .status()
            .map_err(|error| format!("执行 {} 失败：{error}", spec.label))?;
        if !status.success() || !output.is_file() {
            return Err(format!("UTMT 没有生成 {} 的输出", spec.label));
        }
        input = output;
        applied.push(spec.label);
    }
    Ok(BuildResult {
        stage,
        output: input,
        applied,
    })
}

fn specs(settings: &Settings) -> [Spec; 5] {
    [
        Spec {
            enabled: settings.los_cache,
            tag: "los",
            script: "apply_los_cache.csx",
            label: "LOS 缓存",
        },
        Spec {
            enabled: settings.aggressive_visuals,
            tag: "visuals",
            script: "apply_aggressive_visuals.csx",
            label: "激进视觉优化",
        },
        Spec {
            enabled: settings.scene_optimization,
            tag: "scene",
            script: "apply_scene_startup.csx",
            label: "场景与启动优化",
        },
        Spec {
            enabled: settings.anomaly_optimization,
            tag: "anomaly",
            script: "apply_anomaly_hotspots.csx",
            label: "异常区域优化",
        },
        Spec {
            enabled: settings.gpu_scene_optimization,
            tag: "gpu-scene",
            script: "apply_gpu_scene.csx",
            label: "GPU 场景优化",
        },
    ]
}

fn create_stage(coop_dir: &Path) -> Result<PathBuf, String> {
    let stamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|error| format!("读取系统时间失败：{error}"))?
        .as_millis();
    let stage = coop_dir.join("runtime").join(stamp.to_string());
    fs::create_dir_all(&stage).map_err(|error| format!("创建 runtime 目录失败：{error}"))?;
    Ok(stage)
}
