use crate::Args;

#[derive(Debug)]
pub struct Settings {
    pub los_cache: bool,
    pub aggressive_visuals: bool,
    pub scene_optimization: bool,
    pub anomaly_emitter_culling: bool,
    pub anomaly_collision_prefilter: bool,
    pub anomaly_fire_optimization: bool,
    pub gpu_scene_optimization: bool,
    pub background_fps: bool,
    pub static_menu_background: bool,
    pub static_pause_background: bool,
    pub anomaly_offscreen_culling: bool,
    pub anomaly_fire_visuals: bool,
    pub ai_timeslice: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            los_cache: true,
            aggressive_visuals: true,
            scene_optimization: true,
            anomaly_emitter_culling: true,
            anomaly_collision_prefilter: true,
            anomaly_fire_optimization: true,
            gpu_scene_optimization: false,
            background_fps: true,
            static_menu_background: true,
            static_pause_background: true,
            anomaly_offscreen_culling: true,
            anomaly_fire_visuals: true,
            ai_timeslice: true,
        }
    }
}

impl Settings {
    pub fn apply_cli(&mut self, args: &Args) {
        disable(args.no_los_cache, &mut self.los_cache);
        disable(args.no_aggressive_visuals, &mut self.aggressive_visuals);
        disable(args.no_scene_optimization, &mut self.scene_optimization);
        disable(
            args.no_anomaly_emitter_culling,
            &mut self.anomaly_emitter_culling,
        );
        disable(
            args.no_anomaly_fire_optimization,
            &mut self.anomaly_fire_optimization,
        );
        disable(
            args.no_anomaly_collision_prefilter,
            &mut self.anomaly_collision_prefilter,
        );
        disable(args.no_background_fps, &mut self.background_fps);
        disable(
            args.no_anomaly_offscreen_culling,
            &mut self.anomaly_offscreen_culling,
        );
        disable(args.no_anomaly_fire_visuals, &mut self.anomaly_fire_visuals);
        disable(args.no_ai_timeslice, &mut self.ai_timeslice);

        if args.menu_video {
            self.static_menu_background = false;
        }
        if args.pause_video {
            self.static_pause_background = false;
        }
        // GPU 场景优化默认关闭；显式传入才启用，而不是提供一个永远无效的
        // `--no-*` 开关。
        if args.gpu_scene_optimization {
            self.gpu_scene_optimization = true;
        }
    }
}

fn disable(flag: bool, setting: &mut bool) {
    if flag {
        *setting = false;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn defaults_enable_safe_optimizations() {
        let settings = Settings::default();
        assert!(settings.los_cache);
        assert!(settings.background_fps);
        assert!(settings.static_menu_background);
        assert!(settings.static_pause_background);
        assert!(settings.ai_timeslice);
        assert!(!settings.gpu_scene_optimization);
    }
}
