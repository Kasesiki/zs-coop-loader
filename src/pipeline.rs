use crate::config::Settings;
use crate::scripts;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

struct Spec {
    enabled: bool,
    /// 生成脚本文件名，同时用于临时文件命名。
    name: &'static str,
    /// build.rs 在编译期嵌入的 csx 内容。
    source: &'static str,
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

pub fn build(coop_dir: &Path, original: &Path, settings: &Settings) -> Result<BuildResult, String> {
    if !original.is_file() {
        return Err(format!("找不到原始备份：{}", original.display()));
    }
    let specs = specs(settings);
    let enabled: Vec<&Spec> = specs.iter().filter(|spec| spec.enabled).collect();
    let utmt = coop_dir.join("tool/utmt/UndertaleModCli");
    if !enabled.is_empty() && !utmt.is_file() {
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
    let result = BuildResult {
        output,
        applied: enabled.iter().map(|spec| spec.label).collect(),
    };

    if enabled.is_empty() {
        fs::copy(original, &result.output).map_err(|error| format!("复制原始备份失败：{error}"))?;
    } else {
        let files = materialize(&enabled, settings)?;
        let mut command = Command::new(&utmt);
        command.current_dir(coop_dir).arg("load").arg(original);
        for path in &files.paths {
            command.arg("-s").arg(path);
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

fn specs(settings: &Settings) -> [Spec; 10] {
    [
        Spec {
            enabled: settings.los_cache,
            name: "apply_los_cache.csx",
            source: scripts::apply_los_cache,
            label: "LOS 缓存",
        },
        Spec {
            enabled: settings.aggressive_visuals,
            name: "apply_aggressive_visuals.csx",
            source: scripts::apply_aggressive_visuals,
            label: "激进视觉优化",
        },
        Spec {
            enabled: settings.scene_optimization,
            name: "apply_scene_startup.csx",
            source: scripts::apply_scene_startup,
            label: "场景与启动优化",
        },
        Spec {
            enabled: settings.anomaly_emitter_culling,
            name: "apply_anomaly_emitter_culling.csx",
            source: scripts::apply_anomaly_emitter_culling,
            label: "异常父发射器裁剪",
        },
        Spec {
            enabled: settings.anomaly_fire_optimization,
            name: "apply_anomaly_fire_optimization.csx",
            source: scripts::apply_anomaly_fire_optimization,
            label: "火焰异常碰撞优化",
        },
        Spec {
            enabled: settings.anomaly_collision_prefilter,
            name: "apply_anomaly_collision_prefilter.csx",
            source: scripts::apply_anomaly_collision_prefilter,
            label: "化学、电异常碰撞预筛选",
        },
        Spec {
            enabled: true,
            name: "apply_conductor_seed.csx",
            source: scripts::apply_conductor_seed,
            label: "列车长 seed 选择",
        },
        Spec {
            enabled: settings.background_fps,
            name: "apply_background_fps.csx",
            source: scripts::apply_background_fps,
            label: "后台低帧率",
        },
        Spec {
            enabled: settings.gpu_scene_optimization,
            name: "apply_gpu_scene.csx",
            source: scripts::apply_gpu_scene,
            label: "GPU 场景优化",
        },
        Spec {
            enabled: settings.static_menu_background || settings.static_pause_background,
            name: "apply_menu_background.csx",
            source: scripts::apply_menu_background,
            label: "菜单静态背景",
        },
    ]
}

/// 把编译期嵌入的脚本里的开关占位符替换成本次运行的配置。
/// 这样同一个 csx 可以服务“仅暂停静态”“仅主菜单静态”“全部静态”等模式。
fn render_source(spec: &Spec, settings: &Settings) -> String {
    let menu = bool_literal(settings.static_menu_background);
    let pause = bool_literal(settings.static_pause_background);
    spec.source
        .replace("@@COOP_STATIC_MENU@@", menu)
        .replace("@@COOP_STATIC_PAUSE@@", pause)
}

fn bool_literal(value: bool) -> &'static str {
    if value { "true" } else { "false" }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn every_spec_has_an_embedded_script() {
        for spec in specs(&Settings::default()) {
            assert!(!spec.source.is_empty(), "{} 的脚本为空", spec.name);
            assert!(spec.name.ends_with(".csx"));
        }
    }

    #[test]
    fn menu_background_script_is_rendered_from_settings() {
        let mut settings = Settings::default();
        settings.static_menu_background = true;
        settings.static_pause_background = false;
        let specs = specs(&settings);
        let spec = specs
            .iter()
            .find(|spec| spec.name == "apply_menu_background.csx")
            .expect("菜单背景脚本缺失");
        let rendered = render_source(spec, &settings);
        assert!(!rendered.contains("@@COOP_STATIC_"));
        assert!(rendered.contains("true && room == r_menu"));
        assert!(rendered.contains("false && room != r_menu"));
    }
}
