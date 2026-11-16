use crate::config::Settings;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

struct Spec {
    enabled: bool,
    script: &'static str,
    label: &'static str,
}

pub struct BuildResult {
    pub output: PathBuf,
    pub applied: Vec<&'static str>,
}

impl Drop for BuildResult {
    fn drop(&mut self) {
        let _ = fs::remove_file(&self.output);
    }
}

pub fn build(coop_dir: &Path, original: &Path, settings: &Settings) -> Result<BuildResult, String> {
    if !original.is_file() {
        return Err(format!("找不到原始备份：{}", original.display()));
    }
    let specs = specs(settings);
    let utmt = coop_dir.join("tool/utmt/UndertaleModCli");
    if specs.iter().any(|spec| spec.enabled) && !utmt.is_file() {
        return Err(format!("找不到 UTMT CLI：{}", utmt.display()));
    }
    let output = original.with_file_name("data.win.coop-tmp");
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
    let mut result = BuildResult {
        output,
        applied: Vec::new(),
    };
    let mut scripts = Vec::new();
    for spec in specs.iter().filter(|spec| spec.enabled) {
        let script = coop_dir.join("analysis/optimization").join(spec.script);
        if !script.is_file() {
            return Err(format!("找不到优化脚本：{}", script.display()));
        }
        scripts.push(script);
        result.applied.push(spec.label);
    }
    if scripts.is_empty() {
        fs::copy(original, &result.output).map_err(|error| format!("复制原始备份失败：{error}"))?;
    } else {
        let mut command = Command::new(&utmt);
        command
            .current_dir(coop_dir.join("analysis/optimization"))
            .arg("load")
            .arg(original);
        for script in &scripts {
            command.arg("-s").arg(script);
        }
        let status = command
            .args(["-o"])
            .arg(&result.output)
            .args(["-f"])
            .status()
            .map_err(|error| format!("执行 UTMT 失败：{error}"))?;
        if !status.success() || fs::metadata(&result.output).map(|m| m.len()).unwrap_or(0) == 0 {
            return Err("UTMT 未能生成优化文件；游戏 data.win 未替换".into());
        }
    }
    Ok(result)
}

fn specs(settings: &Settings) -> [Spec; 8] {
    [
        Spec {
            enabled: settings.los_cache,
            script: "apply_los_cache.csx",
            label: "LOS 缓存",
        },
        Spec {
            enabled: settings.aggressive_visuals,
            script: "apply_aggressive_visuals.csx",
            label: "激进视觉优化",
        },
        Spec {
            enabled: settings.scene_optimization,
            script: "apply_scene_startup.csx",
            label: "场景与启动优化",
        },
        Spec {
            enabled: settings.anomaly_emitter_culling,
            script: "apply_anomaly_emitter_culling.csx",
            label: "异常父发射器裁剪",
        },
        Spec {
            enabled: settings.anomaly_fire_optimization,
            script: "apply_anomaly_fire_optimization.csx",
            label: "火焰异常碰撞优化",
        },
        Spec {
            enabled: settings.anomaly_collision_prefilter,
            script: "apply_anomaly_collision_prefilter.csx",
            label: "化学、电异常碰撞预筛选",
        },
        Spec {
            enabled: true,
            script: "apply_conductor_seed.csx",
            label: "列车长 seed 选择",
        },
        Spec {
            enabled: settings.gpu_scene_optimization,
            script: "apply_gpu_scene.csx",
            label: "GPU 场景优化",
        },
    ]
}
