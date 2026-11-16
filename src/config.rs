use crate::Args;

#[derive(Debug, Default)]
pub struct Settings {
    pub los_cache: bool,
    pub aggressive_visuals: bool,
    pub scene_optimization: bool,
    pub anomaly_emitter_culling: bool,
    pub anomaly_collision_prefilter: bool,
    pub anomaly_fire_optimization: bool,
    pub gpu_scene_optimization: bool,
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
        if args.no_anomaly_emitter_culling {
            self.anomaly_emitter_culling = false;
        }
        if args.no_anomaly_fire_optimization {
            self.anomaly_fire_optimization = false;
        }
        if args.no_anomaly_collision_prefilter {
            self.anomaly_collision_prefilter = false;
        }
        if args.no_gpu_scene_optimization {
            self.gpu_scene_optimization = false;
        }
    }
}