use crate::Args;
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Default)]
pub struct Settings {
    pub los_cache: bool,
    pub aggressive_visuals: bool,
    pub scene_optimization: bool,
    pub anomaly_optimization: bool,
    pub gpu_scene_optimization: bool,
    pub keep_stage: bool,
    pub base_data_win: Option<PathBuf>,
}

impl Settings {
    pub fn apply_cli(&mut self, args: &Args) {
        if args.no_los_cache {
            self.los_cache = false;
        }
        if args.no_aggressive_visuals {
            self.aggressive_visuals = false;
        }
        if args.no_scene_optimization {
            self.scene_optimization = false;
        }
        if args.no_anomaly_optimization {
            self.anomaly_optimization = false;
        }
        if args.no_gpu_scene_optimization {
            self.gpu_scene_optimization = false;
        }
        if args.keep_stage {
            self.keep_stage = true;
        }
        if args.no_keep_stage {
            self.keep_stage = false;
        }
        if let Some(path) = &args.base_data_win {
            self.base_data_win = Some(path.clone());
        }
    }
}

pub fn load(path: &Path, game_dir: &Path) -> Result<Settings, String> {
    let mut settings = Settings {
        los_cache: true,
        aggressive_visuals: true,
        scene_optimization: true,
        anomaly_optimization: true,
        gpu_scene_optimization: false,
        ..Settings::default()
    };
    if !path.is_file() {
        return Ok(settings);
    }
    let contents = fs::read_to_string(path)
        .map_err(|error| format!("读取配置文件 {} 失败：{error}", path.display()))?;
    for (index, raw) in contents.lines().enumerate() {
        let line = raw.split('#').next().unwrap_or("").trim();
        if line.is_empty() {
            continue;
        }
        let (key, value) = line
            .split_once('=')
            .ok_or_else(|| format!("配置文件第 {} 行缺少 '='", index + 1))?;
        let key = key.trim();
        let value = value.trim().trim_matches('"');
        match key {
            "los_cache" => settings.los_cache = parse_bool(value, key)?,
            "aggressive_visuals" => settings.aggressive_visuals = parse_bool(value, key)?,
            "scene_optimization" => settings.scene_optimization = parse_bool(value, key)?,
            "anomaly_optimization" => settings.anomaly_optimization = parse_bool(value, key)?,
            "gpu_scene_optimization" => settings.gpu_scene_optimization = parse_bool(value, key)?,
            "keep_stage" => settings.keep_stage = parse_bool(value, key)?,
            "base_data_win" => {
                settings.base_data_win = Some(resolve_path(Path::new(value), game_dir))
            }
            _ => return Err(format!("配置文件存在未知选项：{key}")),
        }
    }
    Ok(settings)
}

pub fn resolve_path(path: &Path, base: &Path) -> PathBuf {
    if path.is_absolute() {
        path.to_path_buf()
    } else {
        base.join(path)
    }
}

fn parse_bool(value: &str, key: &str) -> Result<bool, String> {
    match value.to_ascii_lowercase().as_str() {
        "true" | "1" | "yes" | "on" => Ok(true),
        "false" | "0" | "no" | "off" => Ok(false),
        _ => Err(format!("配置项 {key} 不是布尔值：{value}")),
    }
}
