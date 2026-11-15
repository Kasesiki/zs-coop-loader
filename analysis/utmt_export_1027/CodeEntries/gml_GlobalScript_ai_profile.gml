function __ai_profile_trait_names()
{
    return ["aggression", "risk_tolerance", "patience", "reposition_preference", "teamwork"];
}

function __ai_profile_capabilities(arg0)
{
    return 
    {
        shoot: true,
        reload: true,
        chase: true,
        search: true,
        push: true,
        cover: true,
        recovery: true,
        peek_cycle: true
    };
}

function __ai_profile_training_tiers()
{
    return ["rookie", "intermediate", "skilled", "expert", "veteran", "master"];
}

function ai_profile_training_lowered(arg0, arg1)
{
    var _tiers = __ai_profile_training_tiers();
    for (var _i = 0; _i < array_length(_tiers); _i++)
    {
        if (_tiers[_i] == arg0)
        {
            return _tiers[max(0, _i - max(0, arg1))];
        }
    }
    return arg0;
}

function ai_profile_defaults()
{
    return 
    {
        schema_version: 1,
        profile: "safe_human",
        tree: "human_basic",
        training: "rookie",
        traits: 
        {
            aggression: [0.5, 0.5],
            risk_tolerance: [0.5, 0.5],
            patience: [0.5, 0.5],
            reposition_preference: [0.5, 0.5],
            teamwork: [0.5, 0.5]
        },
        personality_pool: [],
        shoot_retreat: 
        {
            enabled: false,
            sprint: true,
            shots: 3,
            burst_seconds: 3,
            min_distance_px: 160,
            preferred_distance_px: 280,
            distance_px: 128,
            min_move_px: 48,
            distance_gain_px: 32,
            move_seconds: 6,
            memory_seconds: 4,
            settle_seconds: 0.25,
            cooldown_seconds: 0.5,
            retry_seconds: 1.5
        },
        hunter: 
        {
            enabled: false,
            relocate_after_burst: false,
            sprint_multiplier: 1.18,
            sprint_reload: true,
            intel_radius_px: 336,
            intel_memory_seconds: 6,
            sample_seconds: 0.2,
            intent_seconds: 3,
            low_health_ratio: 0.45,
            bleeding_health_ratio: 0.7,
            safe_health_ratio: 0.35,
            hit_memory_seconds: 2,
            peek_min_seconds: 0.18,
            peek_max_seconds: 0.32,
            prefire_seconds: 0.35,
            prefire_memory_seconds: 3,
            prefire_cooldown_seconds: 1.5,
            prefire_distance_px: 12,
            prefire_shots: 4,
            prefire_reserve_rounds: 2,
            cover_peek_chance: 0.8,
            cover_peek_limit: 2
        },
        awareness: 
        {
            enabled: false,
            acquisition_multiplier: 1.35,
            trained_multiplier: 1.75,
            perception_steps: 3,
            scan_min_seconds: 1.2,
            scan_max_seconds: 2,
            scan_hold_seconds: 0.55,
            scan_angle_degrees: 95,
            rear_scan_every: 3,
            night_sight_multiplier: 0.8
        },
        routines: 
        {
            aim_cursor_radius_px: 12,
            aim_notice_distance_px: 200,
            aim_group_distance_px: 300,
            aim_min_seconds: 2.5,
            aim_linger_seconds: 0.5,
            aim_line_repeat_seconds: 6,
            body_notice_distance_px: 260,
            activity_limit_seconds: 6,
            leisure_chance: 0.2,
            leisure_interval_seconds: 10,
            leisure_seconds: 3,
            campfire_notice_distance_px: 160,
            campfire_seconds: 5,
            wander_chance: 0.55,
            wander_radius_px: 64
        },
        approach: 
        {
            enabled: false,
            memory_seconds: 6,
            anchor_reset_px: 128,
            spacing_px: 64,
            side_weight: 1.5,
            crowd_weight: 3
        },
        pursuit: 
        {
            max_distance_px: 640,
            lost_contact_seconds: 8,
            search_seconds: 35,
            tracking_seconds: 0,
            tracking_uncertainty_px: 16,
            tracking_rookie_scale: 1,
            tracking_intermediate_scale: 1,
            tracking_skilled_scale: 1,
            tracking_expert_scale: 1,
            tracking_veteran_scale: 1,
            tracking_master_scale: 1,
            chase_chance: 1,
            chase_aggression_min: 0,
            direct_chase_chance: 0.95,
            direct_chase_scale: 1,
            hold_scale: 1,
            hold_min_seconds: 0.1,
            hold_max_seconds: 0.35,
            advance_seconds: 3,
            advance_cooldown_seconds: 0.15,
            advance_distance_px: 96,
            spread_px: 32,
            separation_px: 24,
            stop_distance_px: 40,
            sprint_aggression_min: 0.65,
            ally_sprint_aggression_min: 0.25,
            sprint_stop_distance_px: 80
        },
        schedule: 
        {
            decision_steps: 8,
            perception_steps: 6
        },
        queries: 
        {
            candidate_limit: 12,
            path_limit: 2,
            retry_seconds: 0.5,
            max_defer_seconds: 0.5
        },
        communication: 
        {
            sight_update_seconds: 0.1,
            radius_px: 260,
            report_cooldown_seconds: 3,
            report_max_age_seconds: 3,
            uncertainty_px: 24,
            callout_cooldown_seconds: 4,
            max_pushers: 4,
            engagement_seconds: 8,
            join_teamwork_min: 0.25
        },
        abandonment: 
        {
            enabled: false,
            health_ratio: 0.25,
            cooldown_seconds: 10,
            recovery_margin: 0.1,
            distance_px: 192,
            min_move_px: 48,
            distance_gain_px: 32,
            safe_distance_px: 384,
            fight_range_ratio: 1.3,
            retry_seconds: 1,
            settle_seconds: 0.5
        },
        opportunity_response: 
        {
            enabled: false,
            reaction_scale: 0.4,
            rookie_chance: 0.45,
            intermediate_chance: 0.6,
            skilled_chance: 0.8,
            expert_chance: 0.95,
            veteran_chance: 1,
            master_chance: 1
        },
        flank_opportunity: 
        {
            enabled: false,
            base_multiplier: 1.15,
            ally_fire_seconds: 1.25,
            ally_fire_bonus: 1.25,
            distracted_bonus: 2,
            stalled_bonus: 2,
            max_bonus: 2,
            reaction_seconds: 0.5,
            aim_confirm_seconds: 0.25,
            aim_cone_degrees: 18,
            stall_seconds: 4,
            hold_multiplier: 0.2,
            shooter_multiplier: 0.4,
            stagger_seconds: 1,
            rookie_scale: 0.4,
            intermediate_scale: 0.6,
            skilled_scale: 0.85,
            expert_scale: 1,
            veteran_scale: 1.2,
            master_scale: 1.4,
            angle_route_enabled: true,
            angle_distance_px: 112,
            angle_min_move_px: 32,
            angle_close_px: 24,
            angle_max_seconds: 2.5
        },
        relocation: 
        {
            enabled: false,
            sprint: true,
            weight: 4,
            memory_seconds: 8,
            contact_seconds: 4,
            route_enabled: false,
            route_min_seconds: 3,
            route_max_seconds: 4,
            route_min_angle: 65,
            route_max_angle: 135,
            route_min_move_px: 96,
            route_close_px: 56,
            route_max_waypoints: 3,
            aim_cone_degrees: 12,
            aim_confirm_seconds: 0.1,
            close_aim_stop_px: 80,
            lost_sight_multiplier: 0.6,
            failed_angle_multiplier: 1.75,
            patch_radius_px: 24,
            repeat_peek_gap_seconds: 0.35,
            probe_radius_px: 96,
            probe_seconds: 0.75,
            cover_multiplier: 2,
            repeat_peek_multiplier: 1.5,
            exposed_multiplier: 0.25,
            min_move_px: 32,
            distance_px: 96,
            cover_probe_px: 32,
            move_seconds: 3,
            cooldown_seconds: 4,
            pause_seconds: 0.25
        },
        defensive_reposition: 
        {
            enabled: true,
            weight: 0.6,
            close_ratio: 0.5,
            distance_slack_px: 24,
            support_radius_px: 192,
            support_memory_seconds: 2,
            unsupported_seconds: 0.5,
            memory_seconds: 6,
            cover_probe_px: 32,
            min_move_px: 32,
            max_move_px: 96,
            min_gain_px: 24,
            move_seconds: 3,
            cooldown_seconds: 5,
            settle_seconds: 0.25,
            watch_peek_multiplier: 2
        },
        peek_reposition: 
        {
            enabled: true,
            failed_attempts: 2,
            distance_px: 80,
            move_seconds: 2.5,
            cooldown_seconds: 8,
            pause_seconds: 0.25
        },
        scatter: 
        {
            opening_distance_px: 96,
            opening_max_simultaneous: 1,
            opening_chance: 1,
            rookie_scale: 1,
            intermediate_scale: 1,
            panic_rookie_chance: 0,
            panic_intermediate_chance: 0,
            enabled: true,
            sprint: true,
            max_simultaneous: 1,
            fire_angle_degrees: 45,
            fire_first_seconds: 1.5,
            facing_recheck_seconds: 0.5,
            distance_px: 96,
            cluster_radius_px: 96,
            min_target_distance_px: 48,
            window_seconds: 2.5,
            move_seconds: 1.5,
            pause_seconds: 0.1,
            repeat_chance: 0.65,
            repeat_min_seconds: 5,
            repeat_max_seconds: 9,
            repeat_memory_seconds: 3
        },
        flank: 
        {
            enabled: true,
            sprint: true,
            chance: 0.9,
            distance_px: 128,
            min_target_distance_px: 64,
            max_target_distance_px: 320,
            memory_seconds: 4,
            move_seconds: 2.5,
            cooldown_seconds: 8,
            pause_seconds: 0.25
        },
        flash_push: 
        {
            enabled: true,
            sprint: true,
            direct_chance: 1,
            report_teamwork_min: 0,
            guaranteed_teamwork: 0.7,
            reaction_seconds: 0.05,
            opportunity_seconds: 5,
            distance_px: 192,
            min_target_distance_px: 80,
            max_target_distance_px: 224,
            range_ratio: 1.5,
            move_seconds: 5,
            cooldown_seconds: 4,
            pause_seconds: 0.25
        },
        reload_push: 
        {
            enabled: true,
            direct_chance: 0.65,
            report_teamwork_min: 0.55,
            guaranteed_teamwork: 0.7,
            reaction_seconds: 0.15,
            opportunity_seconds: 1.8,
            distance_px: 64,
            min_target_distance_px: 64,
            range_ratio: 1.5,
            move_seconds: 1.5,
            cooldown_seconds: 4,
            pause_seconds: 0.25
        },
        heal_push: 
        {
            enabled: true,
            direct_chance: 0.8,
            report_teamwork_min: 0.55,
            guaranteed_teamwork: 0.7,
            reaction_seconds: 0.2,
            opportunity_seconds: 3,
            distance_px: 64,
            min_target_distance_px: 64,
            range_ratio: 1.5,
            move_seconds: 2,
            cooldown_seconds: 4,
            pause_seconds: 0.25
        },
        covering_fire: 
        {
            enabled: false,
            teamwork_min: 0.55,
            memory_seconds: 2,
            burst_seconds: 1.2,
            cooldown_seconds: 4,
            max_shots: 4,
            min_rounds: 6,
            reserve_rounds: 3,
            opening_radius_px: 32,
            ally_clearance_px: 16
        },
        suppression: 
        {
            enabled: true,
            pressure_enabled: true,
            near_miss_pressure: 0.25,
            hit_pressure: 0.45,
            decay_per_second: 0.18,
            heavy_threshold: 0.6,
            risk_floor: 0.25,
            near_misses: 3,
            window_seconds: 1.2,
            radius_px: 32,
            move_seconds: 1.5,
            cooldown_seconds: 8
        },
        cover_assessment: 
        {
            enabled: true,
            radius_px: 96,
            near_radius_px: 48,
            continuous_span_px: 128,
            refresh_seconds: 1.5,
            evidence_seconds: 4,
            isolated_angle_multiplier: 1.5,
            isolated_flank_multiplier: 1.5,
            isolated_advance_multiplier: 1.4,
            continuous_hold_multiplier: 1.5
        },
        targeting: 
        {
            enabled: true,
            closer_ratio: 0.65,
            min_gain_px: 24,
            switch_cooldown_seconds: 1,
            unseen_switch_seconds: 0.5,
            damage_switch: true
        },
        grenade: 
        {
            enabled: true,
            memory_seconds: 3,
            retry_seconds: 5,
            group_cooldown_seconds: 4,
            base_weight_scale: 4,
            isolated_weight_multiplier: 4,
            cover_weight_multiplier: 2,
            isolated_priority: true,
            assessment_wait_seconds: 0.25,
            min_distance_px: 80,
            max_distance_px: 210
        },
        grenade_evasion: 
        {
            enabled: true,
            view_angle_degrees: 140,
            rookie_min_seconds: 0.7,
            rookie_max_seconds: 2,
            skilled_min_seconds: 0.4,
            skilled_max_seconds: 1.1,
            master_min_seconds: 0.15,
            master_max_seconds: 0.5,
            rookie_miss_chance: 0.35,
            intermediate_miss_chance: 0.25,
            skilled_miss_chance: 0.15,
            expert_miss_chance: 0.08,
            veteran_miss_chance: 0.03,
            master_miss_chance: 0,
            rookie_panic_chance: 0.4,
            intermediate_panic_chance: 0.2,
            skilled_panic_chance: 0,
            expert_panic_chance: 0,
            veteran_panic_chance: 0,
            master_panic_chance: 0,
            reaction_scale: 1,
            miss_scale: 1,
            panic_scale: 1,
            ally_warning: true,
            warned_reaction_seconds: 0.25,
            cover_enabled: true,
            cover_distance_px: 96,
            fallback_margin_px: 48,
            shelter: true,
            shelter_max_seconds: 3
        },
        roaming_movement: 
        {
            enabled: false,
            decide_seconds: 2,
            lookahead_waypoints: 6,
            open_radius_px: 48,
            open_blocked_cells_max: 3,
            open_run_chance: 0.85,
            covered_run_chance: 0.15,
            sprint_chance: 0.3,
            sprint_seconds: 2.5,
            sprint_cooldown_seconds: 8
        },
        engagement: 
        {
            contact_grace_seconds: 1.25,
            hold_seconds: 1.2,
            angle_distance_px: 128,
            angle_move_seconds: 3,
            angle_cooldown_seconds: 2,
            angle_weight: 3,
            advance_weight: 2,
            hold_weight: 1,
            flank_weight: 1
        },
        strafe: 
        {
            enabled: true,
            weight: 1.5,
            distance_px: 40,
            move_seconds: 1.25,
            pause_seconds: 0.25,
            cooldown_seconds: 4
        },
        spacing: 
        {
            enabled: true,
            weight: 1.5,
            near_ratio: 0.35,
            far_ratio: 1.3,
            hysteresis_px: 24,
            min_move_px: 32,
            max_move_px: 96,
            min_gain_px: 24,
            move_seconds: 2,
            pause_seconds: 0.25,
            cooldown_seconds: 5
        },
        interception: 
        {
            enabled: true,
            chance: 0.65,
            aggressive_chance_scale: 0.25,
            hold_min_seconds: 1,
            hold_max_seconds: 3,
            cooldown_seconds: 8,
            memory_age_seconds: 4,
            range_ratio: 1,
            watch_offset_px: 32,
            move_px: 48,
            move_seconds: 2
        },
        tactics: 
        {
            shoot_weight: 1,
            patience_weight: 2,
            reposition_weight: 1.5,
            cover_weight: 1.5,
            peek_weight: 3,
            push_weight: 2,
            push_range_ratio: 0.7
        },
        firing: 
        {
            close_reflex_distance_px: 80,
            close_reflex_angle_degrees: 60,
            close_reflex_min_seconds: 0.1,
            close_reflex_max_seconds: 0.16,
            heard_reflex_seconds: 0.4,
            heard_reflex_distance_px: 48,
            heard_peek_min_seconds: 0.06,
            heard_peek_max_seconds: 0.12,
            distant_reflex_start_px: 180,
            distant_reflex_span_px: 240,
            distant_reflex_extra_seconds: 0.3,
            camera_enabled: true,
            camera_opening_seconds: 0.3,
            camera_continue_seconds: 0.5,
            expected_memory_seconds: 4,
            expected_prepare_seconds: 0.15,
            expected_angle_degrees: 20,
            expected_reflex_multiplier: 1,
            walking_spread_multiplier: 1.5,
            burst_min_seconds: 0.6,
            burst_max_seconds: 6,
            burst_extra_seconds: 0.6,
            min_far_effectiveness: 0.4,
            outranged_cover_multiplier: 2,
            settle_enabled: true,
            settle_min_distance_px: 96,
            settle_offset_px: 8,
            settle_min_seconds: 0.15,
            settle_max_seconds: 0.3,
            settle_expected_multiplier: 0.5,
            trigger_enabled: true,
            trigger_full_auto_px: 200,
            trigger_rounds_min: 6,
            trigger_rounds_max: 10,
            trigger_pause_min_seconds: 0.08,
            trigger_pause_max_seconds: 0.15,
            trigger_threat_pressure: 0.25,
            trigger_threat_rounds_multiplier: 1,
            trigger_threat_pause_multiplier: 1,
            outranged_fire_enabled: true,
            outranged_rounds_min: 2,
            outranged_rounds_max: 3,
            outranged_pause_min_seconds: 0.8,
            outranged_pause_max_seconds: 1.3,
            outranged_shoot_multiplier: 0.35,
            return_fire_seconds: 4,
            return_fire_sight_px: 400,
            return_fire_shoot_multiplier: 1,
            cover_fire_distance_px: 64,
            lead_enabled: true,
            lead_min_fraction: 0.2,
            lead_max_fraction: 0.8,
            lead_smoothing_steps: 4,
            lead_max_px: 24
        },
        magazine: 
        {
            enabled: true,
            solo_ratio: 0.25,
            supported_ratio: 0.08,
            solo_rounds_max: 8,
            supported_rounds_max: 3,
            ally_radius_px: 160
        },
        hearing: 
        {
            enabled: true,
            actions_enabled: true,
            action_radius_px: 160,
            walk_radius_px: 112,
            run_radius_px: 224,
            wall_range_multiplier: 0.55,
            walk_uncertainty_px: 36,
            run_uncertainty_px: 24,
            wall_uncertainty_px: 20,
            memory_seconds: 3,
            event_max_age_seconds: 0.75,
            listen_seconds: 0.1,
            sight_priority_seconds: 0.35,
            update_distance_px: 32,
            update_seconds: 0.65,
            share_teamwork_min: 0.25,
            approach_multiplier: 2,
            rookie_scale: 0.35,
            intermediate_scale: 0.5,
            skilled_scale: 0.7,
            expert_scale: 0.85,
            veteran_scale: 1,
            master_scale: 1
        },
        vulnerability: 
        {
            enabled: true,
            low_health_ratio: 0.4,
            memory_seconds: 3,
            hit_memory_seconds: 1.5,
            retreat_window_seconds: 0.75,
            retreat_distance_px: 20,
            aggression_bonus: 0.35,
            approach_multiplier: 2,
            hold_multiplier: 0.4,
            wounded_strength: 0.5,
            retreat_strength: 1,
            rookie_scale: 0,
            intermediate_scale: 0.15,
            skilled_scale: 0.4,
            expert_scale: 0.65,
            veteran_scale: 0.85,
            master_scale: 1
        },
        reload: 
        {
            retreat_distance_px: 160,
            retreat_seconds: 2.5
        },
        investigation: 
        {
            enabled: true,
            first_inspection_sprint: true,
            trigger_distance_px: 180,
            pocket_radius_px: 96,
            viewpoint_radius_px: 64,
            move_seconds: 4,
            inspect_seconds: 0.35,
            retry_seconds: 2,
            memory_seconds: 12,
            checked_radius_px: 20,
            memory_limit: 16,
            share_teamwork_min: 0.25
        },
        search: 
        {
            radius_min_px: 60,
            radius_max_px: 100,
            pause_min_seconds: 0.2,
            pause_max_seconds: 0.45,
            cone_degrees: 140
        },
        hit_reaction: 
        {
            directional_enabled: false,
            unseen_shooter_enabled: true,
            fire_angle_degrees: 35,
            rear_angle_degrees: 100,
            far_distance_px: 128,
            cooldown_seconds: 4,
            cover_distance_px: 160,
            rookie_min_seconds: 0.25,
            rookie_max_seconds: 0.4,
            skilled_min_seconds: 0.15,
            skilled_max_seconds: 0.25,
            master_min_seconds: 0.08,
            master_max_seconds: 0.15,
            pending_seconds: 2,
            active_seconds: 2.5
        },
        peek: 
        {
            distance_px: 24,
            max_path_px: 32,
            fire_chance: 0.7,
            fire_min_seconds: 1.2,
            fire_max_seconds: 3,
            reaction_extra_seconds: 0.9,
            variation_seconds: 0.35,
            feint_min_seconds: 0.4,
            feint_max_seconds: 0.65,
            wait_min_seconds: 0.2,
            wait_max_seconds: 0.6,
            shots: 3,
            burst_seconds: 0.25,
            deadline_seconds: 5
        },
        capabilities: __ai_profile_capabilities("rookie")
    };
}

function __ai_profile_number(arg0)
{
    return is_numeric(arg0) && !is_bool(arg0) && !is_nan(arg0) && !is_infinity(arg0);
}

function __ai_profile_between(arg0, arg1, arg2, arg3, arg4 = false)
{
    if (!__ai_profile_number(arg0))
    {
        return false;
    }
    if (arg3 && sign(frac(arg0)) != 0)
    {
        return false;
    }
    if (sign(arg0 - arg1) < 0 || sign(arg0 - arg2) > 0)
    {
        return false;
    }
    return !arg4 || sign(arg0 - arg1) > 0;
}

function __ai_profile_contains(arg0, arg1)
{
    for (var _i = 0; _i < array_length(arg0); _i++)
    {
        if (arg0[_i] == arg1)
        {
            return true;
        }
    }
    return false;
}

function __ai_profile_error(arg0, arg1, arg2)
{
    arg0.valid = false;
    arg0.errors++;
    if (array_length(arg0.diagnostics) < 16)
    {
        array_push(arg0.diagnostics, arg1 + ": " + arg2);
    }
}

function __ai_profile_is_note(arg0)
{
    return is_string(arg0) && string_char_at(arg0, 1) == "_";
}

function __ai_profile_copy(arg0)
{
    if (is_array(arg0))
    {
        var _copy = [];
        for (var _i = 0; _i < array_length(arg0); _i++)
        {
            array_push(_copy, __ai_profile_copy(arg0[_i]));
        }
        return _copy;
    }
    if (is_struct(arg0))
    {
        var _copy = {};
        var _names = variable_struct_get_names(arg0);
        for (var _i = 0; _i < array_length(_names); _i++)
        {
            var _key = _names[_i];
            variable_struct_set(_copy, _key, __ai_profile_copy(variable_struct_get(arg0, _key)));
        }
        return _copy;
    }
    return arg0;
}

function __ai_profile_trait_valid(arg0)
{
    if (__ai_profile_between(arg0, 0, 1, false))
    {
        return true;
    }
    return is_array(arg0) && array_length(arg0) == 2 && __ai_profile_between(arg0[0], 0, 1, false) && __ai_profile_between(arg0[1], 0, 1, false) && sign(arg0[1] - arg0[0]) >= 0;
}

function __ai_profile_traits(arg0, arg1, arg2, arg3, arg4, arg5)
{
    var _names = __ai_profile_trait_names();
    if (!is_struct(arg1))
    {
        __ai_profile_error(arg3, arg4, "expected a traits object; using safe traits");
        for (var _i = 0; _i < array_length(_names); _i++)
        {
            var _key = _names[_i];
            variable_struct_set(arg0, _key, __ai_profile_copy(variable_struct_get(arg2, _key)));
            if (is_struct(arg5))
            {
                variable_struct_set(arg5, _key, variable_struct_get(arg0, _key));
            }
        }
        exit;
    }
    var _keys = variable_struct_get_names(arg1);
    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        if (__ai_profile_is_note(_key))
        {
            continue;
        }
        if (!__ai_profile_contains(_names, _key))
        {
            __ai_profile_error(arg3, arg4 + "." + _key, "unknown trait");
        }
        else
        {
            var _trait = variable_struct_get(arg1, _key);
            if (!__ai_profile_trait_valid(_trait))
            {
                __ai_profile_error(arg3, arg4 + "." + _key, "expected a number or ordered two-number range in [0,1]");
                _trait = variable_struct_get(arg2, _key);
            }
            variable_struct_set(arg0, _key, __ai_profile_copy(_trait));
            if (is_struct(arg5))
            {
                variable_struct_set(arg5, _key, variable_struct_get(arg0, _key));
            }
        }
    }
}

function __ai_profile_pool(arg0, arg1, arg2, arg3)
{
    if (!is_array(arg0) || array_length(arg0) > 32)
    {
        __ai_profile_error(arg2, arg3, "expected an array with at most 32 styles; using empty pool");
        return [];
    }
    var _errors_before = arg2.errors;
    var _pool = [];
    var _ids = [];
    var _total = 0;
    for (var _i = 0; _i < array_length(arg0); _i++)
    {
        var _style = arg0[_i];
        var _item_path = arg3 + "[" + string(_i) + "]";
        if (!is_struct(_style))
        {
            __ai_profile_error(arg2, _item_path, "expected a style object");
        }
        else
        {
            var _keys = variable_struct_get_names(_style);
            for (var _k = 0; _k < array_length(_keys); _k++)
            {
                if (!__ai_profile_is_note(_keys[_k]) && !__ai_profile_contains(["id", "weight", "traits"], _keys[_k]))
                {
                    __ai_profile_error(arg2, _item_path + "." + _keys[_k], "unknown style field");
                }
            }
            var _id = variable_struct_exists(_style, "id") ? _style.id : undefined;
            var _weight = variable_struct_exists(_style, "weight") ? _style.weight : undefined;
            var _traits = {};
            if (!is_string(_id) || string_length(_id) == 0 || __ai_profile_contains(_ids, _id))
            {
                __ai_profile_error(arg2, _item_path + ".id", "expected a unique nonempty string");
            }
            else
            {
                array_push(_ids, _id);
            }
            if (!__ai_profile_number(_weight) || sign(_weight) <= 0)
            {
                __ai_profile_error(arg2, _item_path + ".weight", "expected a positive finite number");
            }
            else
            {
                _total += _weight;
            }
            if (!variable_struct_exists(_style, "traits"))
            {
                __ai_profile_error(arg2, _item_path + ".traits", "missing traits object");
            }
            else
            {
                __ai_profile_traits(_traits, _style.traits, arg1, arg2, _item_path + ".traits", undefined);
            }
            array_push(_pool, 
            {
                id: _id,
                weight: _weight,
                traits: _traits
            });
        }
    }
    if (is_infinity(_total))
    {
        __ai_profile_error(arg2, arg3, "total weight overflow; using empty pool");
    }
    return (arg2.errors == _errors_before) ? _pool : [];
}

function __ai_profile_group(arg0, arg1, arg2, arg3, arg4, arg5, arg6 = "")
{
    if (!is_struct(arg1))
    {
        __ai_profile_error(arg4, arg5, "expected an object; using safe group defaults");
        arg1 = arg2;
    }
    var _keys = variable_struct_get_names(arg1);
    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        if (__ai_profile_is_note(_key))
        {
            continue;
        }
        if (arg3 == "pursuit" && _key == "sniper_chase_chance")
        {
            var _legacy = variable_struct_get(arg1, _key);
            if (!__ai_profile_between(_legacy, 0, 1, false))
            {
                __ai_profile_error(arg4, arg5 + "." + _key, "expected chance in [0,1]");
            }
            else if (arg6 == "sniper")
            {
                arg0.chase_chance = _legacy;
            }
        }
        else if (!variable_struct_exists(arg2, _key))
        {
            __ai_profile_error(arg4, arg5 + "." + _key, "unknown field");
        }
        else
        {
            var _field = variable_struct_get(arg1, _key);
            var _valid = false;
            switch (arg3)
            {
                case "shoot_retreat":
                    if (_key == "enabled" || _key == "sprint")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "shots")
                    {
                        _valid = __ai_profile_between(_field, 1, 16, true);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 16, 768, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.1, 10, false);
                    }
                    break;
                case "awareness":
                    if (_key == "enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "perception_steps")
                    {
                        _valid = __ai_profile_between(_field, 1, 12, true);
                    }
                    else if (_key == "rear_scan_every")
                    {
                        _valid = __ai_profile_between(_field, 1, 8, true);
                    }
                    else if (_key == "scan_angle_degrees")
                    {
                        _valid = __ai_profile_between(_field, 30, 150, false);
                    }
                    else if (string_pos("multiplier", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0.5, 4, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.1, 10, false);
                    }
                    break;
                case "routines":
                    if (string_pos("_chance", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 1, 1024, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 600, false);
                    }
                    break;
                case "hunter":
                    if (_key == "enabled" || _key == "sprint_reload" || _key == "relocate_after_burst")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "cover_peek_chance")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "cover_peek_limit")
                    {
                        _valid = __ai_profile_between(_field, 1, 4, true);
                    }
                    else if (_key == "sprint_multiplier")
                    {
                        _valid = __ai_profile_between(_field, 1, 1.5, false);
                    }
                    else if (string_pos("_ratio", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0.05, 1, false);
                    }
                    else if (_key == "prefire_shots" || _key == "prefire_reserve_rounds")
                    {
                        _valid = __ai_profile_between(_field, 1, 12, true);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 4, 512, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.05, 10, false);
                    }
                    break;
                case "scatter":
                case "peek_reposition":
                case "flank":
                case "reload_push":
                case "heal_push":
                case "covering_fire":
                case "flash_push":
                case "suppression":
                    if (_key == "enabled" || _key == "sprint" || _key == "pressure_enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (arg3 == "scatter" && (_key == "max_simultaneous" || _key == "opening_max_simultaneous"))
                    {
                        _valid = __ai_profile_between(_field, 1, 8, true);
                    }
                    else if (arg3 == "scatter" && _key == "fire_angle_degrees")
                    {
                        _valid = __ai_profile_between(_field, 0, 90, false);
                    }
                    else if (_key == "max_shots" || _key == "min_rounds" || _key == "reserve_rounds")
                    {
                        _valid = __ai_profile_between(_field, 1, 30, true);
                    }
                    else if (_key == "near_miss_pressure" || _key == "hit_pressure" || _key == "heavy_threshold" || _key == "risk_floor")
                    {
                        _valid = __ai_profile_between(_field, 0.01, 1, false);
                    }
                    else if (_key == "decay_per_second")
                    {
                        _valid = __ai_profile_between(_field, 0.01, 2, false);
                    }
                    else if (_key == "failed_attempts" || _key == "near_misses")
                    {
                        _valid = __ai_profile_between(_field, 1, 16, true);
                    }
                    else if (string_pos("chance", _key) > 0 || string_pos("teamwork", _key) > 0 || string_pos("_scale", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "range_ratio")
                    {
                        _valid = __ai_profile_between(_field, 0.1, 3, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 512, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.05, 60, false);
                    }
                    break;
                case "investigation":
                    if (_key == "enabled" || _key == "first_inspection_sprint")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "memory_limit")
                    {
                        _valid = __ai_profile_between(_field, 1, 32, true);
                    }
                    else if (_key == "share_teamwork_min")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 256, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.1, 60, false);
                    }
                    break;
                case "flank_opportunity":
                    if (_key == "enabled" || _key == "angle_route_enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "aim_cone_degrees")
                    {
                        _valid = __ai_profile_between(_field, 1, 45, false);
                    }
                    else if (_key == "hold_multiplier" || _key == "shooter_multiplier")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 16, 192, false);
                    }
                    else if (string_pos("_seconds", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0.1, 10, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 3, false);
                    }
                    break;
                case "approach":
                    if (_key == "enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "memory_seconds")
                    {
                        _valid = __ai_profile_between(_field, 1, 15, false);
                    }
                    else if (_key == "anchor_reset_px")
                    {
                        _valid = __ai_profile_between(_field, 32, 256, false);
                    }
                    else if (_key == "spacing_px")
                    {
                        _valid = __ai_profile_between(_field, 24, 128, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 8, false);
                    }
                    break;
                case "pursuit":
                    if (_key == "tracking_seconds")
                    {
                        _valid = __ai_profile_between(_field, 0, 1.25, false);
                    }
                    else if (_key == "tracking_uncertainty_px")
                    {
                        _valid = __ai_profile_between(_field, 0, 32, false);
                    }
                    else if (string_pos("tracking_", _key) == 1)
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "sprint_aggression_min" || _key == "ally_sprint_aggression_min")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "sprint_stop_distance_px")
                    {
                        _valid = __ai_profile_between(_field, 0, 512, false);
                    }
                    else if (_key == "advance_distance_px")
                    {
                        _valid = __ai_profile_between(_field, 24, 256, false);
                    }
                    else if (_key == "spread_px")
                    {
                        _valid = __ai_profile_between(_field, 16, 96, false);
                    }
                    else if (_key == "separation_px")
                    {
                        _valid = __ai_profile_between(_field, 16, 32, false);
                    }
                    else if (_key == "stop_distance_px")
                    {
                        _valid = __ai_profile_between(_field, 16, 256, false);
                    }
                    else if (_key == "direct_chase_scale" || _key == "hold_scale")
                    {
                        _valid = __ai_profile_between(_field, 0, 3, false);
                    }
                    else if (_key == "chase_chance" || _key == "chase_aggression_min" || _key == "direct_chase_chance")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "hold_min_seconds" || _key == "hold_max_seconds" || _key == "advance_cooldown_seconds")
                    {
                        _valid = __ai_profile_between(_field, 0, 60, false);
                    }
                    else if (_key == "advance_seconds")
                    {
                        _valid = __ai_profile_between(_field, 0.1, 60, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, (_key == "max_distance_px") ? 65536 : 3600, false, true);
                    }
                    break;
                case "schedule":
                    _valid = __ai_profile_between(_field, 1, 120, true);
                    break;
                case "queries":
                    if (_key == "candidate_limit")
                    {
                        _valid = __ai_profile_between(_field, 1, 64, true);
                    }
                    else if (_key == "path_limit")
                    {
                        _valid = __ai_profile_between(_field, 1, 8, true);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 60, false, true);
                    }
                    break;
                case "communication":
                    if (_key == "join_teamwork_min")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                        break;
                    }
                    if (_key == "max_pushers")
                    {
                        _valid = __ai_profile_between(_field, 1, 8, true);
                    }
                    else if (_key == "radius_px")
                    {
                        _valid = __ai_profile_between(_field, 1, 2048, false);
                    }
                    else if (_key == "uncertainty_px")
                    {
                        _valid = __ai_profile_between(_field, 0, 256, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 60, false, true);
                    }
                    break;
                case "tactics":
                    _valid = __ai_profile_between(_field, 0, (_key == "push_range_ratio") ? 3 : 10, false);
                    break;
                case "firing":
                case "reload":
                case "search":
                case "hit_reaction":
                case "peek":
                    if (arg3 == "firing" && (_key == "camera_enabled" || _key == "settle_enabled" || _key == "trigger_enabled" || _key == "outranged_fire_enabled"))
                    {
                        _valid = is_bool(_field);
                    }
                    else if (arg3 == "firing" && (_key == "outranged_rounds_min" || _key == "outranged_rounds_max"))
                    {
                        _valid = __ai_profile_between(_field, 1, 16, true);
                    }
                    else if (arg3 == "firing" && _key == "outranged_shoot_multiplier")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (arg3 == "firing" && _key == "return_fire_shoot_multiplier")
                    {
                        _valid = __ai_profile_between(_field, 0, 2, false);
                    }
                    else if (arg3 == "firing" && _key == "cover_fire_distance_px")
                    {
                        _valid = __ai_profile_between(_field, 0, 256, false);
                    }
                    else if (arg3 == "firing" && _key == "lead_enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (arg3 == "firing" && (_key == "lead_min_fraction" || _key == "lead_max_fraction"))
                    {
                        _valid = __ai_profile_between(_field, 0, 1.5, false);
                    }
                    else if (arg3 == "firing" && _key == "lead_smoothing_steps")
                    {
                        _valid = __ai_profile_between(_field, 1, 60, false);
                    }
                    else if (arg3 == "firing" && _key == "lead_max_px")
                    {
                        _valid = __ai_profile_between(_field, 0, 128, false);
                    }
                    else if (arg3 == "firing" && (_key == "trigger_rounds_min" || _key == "trigger_rounds_max"))
                    {
                        _valid = __ai_profile_between(_field, 1, 64, true);
                    }
                    else if (arg3 == "firing" && (_key == "trigger_threat_pressure" || _key == "settle_expected_multiplier"))
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (arg3 == "firing" && (_key == "trigger_threat_rounds_multiplier" || _key == "trigger_threat_pause_multiplier"))
                    {
                        _valid = __ai_profile_between(_field, 0.1, 4, false);
                    }
                    else if (arg3 == "firing" && (_key == "settle_offset_px" || _key == "settle_min_distance_px" || _key == "trigger_full_auto_px"))
                    {
                        _valid = __ai_profile_between(_field, 0, (_key == "settle_offset_px") ? 64 : 1024, false);
                    }
                    else if (arg3 == "firing" && (_key == "settle_min_seconds" || _key == "settle_max_seconds"))
                    {
                        _valid = __ai_profile_between(_field, 0, 3, false);
                    }
                    else if (arg3 == "firing" && (_key == "camera_opening_seconds" || _key == "camera_continue_seconds"))
                    {
                        _valid = __ai_profile_between(_field, 0, 2, false);
                    }
                    else if (arg3 == "hit_reaction" && (_key == "directional_enabled" || _key == "unseen_shooter_enabled"))
                    {
                        _valid = is_bool(_field);
                    }
                    else if (arg3 == "hit_reaction" && string_pos("_degrees", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0, 180, false);
                    }
                    else if (arg3 == "peek" && (_key == "distance_px" || _key == "max_path_px"))
                    {
                        _valid = __ai_profile_between(_field, 8, 96, false);
                    }
                    else if (arg3 == "firing" && (_key == "expected_angle_degrees" || _key == "close_reflex_angle_degrees"))
                    {
                        _valid = __ai_profile_between(_field, 1, 90, false);
                    }
                    else if (arg3 == "firing" && _key == "expected_reflex_multiplier")
                    {
                        _valid = __ai_profile_between(_field, 0, 2, false);
                    }
                    else if (arg3 == "firing" && _key == "min_far_effectiveness")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (arg3 == "search" && _key == "cone_degrees")
                    {
                        _valid = __ai_profile_between(_field, 10, 180, false);
                    }
                    else if (_key == "fire_chance")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "shots")
                    {
                        _valid = __ai_profile_between(_field, 1, 32, true);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, (string_pos("_px", _key) > 0) ? 1024 : 60, false, true);
                    }
                    break;
                case "opportunity_response":
                    if (_key == "enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    break;
                case "relocation":
                    if (_key == "enabled" || _key == "sprint" || _key == "route_enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "route_max_waypoints")
                    {
                        _valid = __ai_profile_between(_field, 2, 3, true);
                    }
                    else if (_key == "aim_cone_degrees")
                    {
                        _valid = __ai_profile_between(_field, 1, 45, false);
                    }
                    else if (_key == "aim_confirm_seconds")
                    {
                        _valid = __ai_profile_between(_field, 0.05, 1, false);
                    }
                    else if (_key == "route_min_angle" || _key == "route_max_angle")
                    {
                        _valid = __ai_profile_between(_field, 30, 160, false);
                    }
                    else if (_key == "route_min_seconds" || _key == "route_max_seconds")
                    {
                        _valid = __ai_profile_between(_field, 1, 6, false);
                    }
                    else if (_key == "exposed_multiplier")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "weight" || string_pos("multiplier", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0, 10, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 192, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.05, 30, false);
                    }
                    break;
                case "defensive_reposition":
                    if (_key == "enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "weight" || _key == "watch_peek_multiplier")
                    {
                        _valid = __ai_profile_between(_field, 0, 10, false);
                    }
                    else if (_key == "close_ratio")
                    {
                        _valid = __ai_profile_between(_field, 0.1, 2, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 256, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.05, 30, false);
                    }
                    break;
                case "cover_assessment":
                case "targeting":
                case "grenade":
                    if (_key == "enabled" || _key == "isolated_priority" || _key == "damage_switch")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "assessment_wait_seconds")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "closer_ratio")
                    {
                        _valid = __ai_profile_between(_field, 0.1, 0.95, false);
                    }
                    else if (string_pos("multiplier", _key) > 0 || _key == "base_weight_scale")
                    {
                        _valid = __ai_profile_between(_field, 0, 10, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 256, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.05, 60, false);
                    }
                    break;
                case "roaming_movement":
                    if (_key == "enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "lookahead_waypoints")
                    {
                        _valid = __ai_profile_between(_field, 1, 16, true);
                    }
                    else if (_key == "open_blocked_cells_max")
                    {
                        _valid = __ai_profile_between(_field, 0, 64, true);
                    }
                    else if (string_pos("_chance", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 256, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.1, 60, false);
                    }
                    break;
                case "grenade_evasion":
                    if (_key == "enabled" || _key == "ally_warning" || _key == "cover_enabled" || _key == "shelter")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "view_angle_degrees")
                    {
                        _valid = __ai_profile_between(_field, 0, 360, false);
                    }
                    else if (string_pos("_chance", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (string_pos("_scale", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0, 3, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 256, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 10, false);
                    }
                    break;
                case "hearing":
                case "magazine":
                case "vulnerability":
                    if (_key == "enabled" || _key == "actions_enabled")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (string_pos("rounds_max", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 1, 60, true);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 1, 512, false);
                    }
                    else if (string_pos("seconds", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0.05, 10, false);
                    }
                    else if (_key == "approach_multiplier")
                    {
                        _valid = __ai_profile_between(_field, 1, 5, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    break;
                case "engagement":
                    if (string_pos("weight", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0, 10, false);
                    }
                    else if (_key == "angle_distance_px")
                    {
                        _valid = __ai_profile_between(_field, 16, 128, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.05, 10, false);
                    }
                    break;
                case "strafe":
                case "spacing":
                case "interception":
                    if (_key == "enabled" || _key == "sprint")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "chance" || _key == "aggressive_chance_scale")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "weight")
                    {
                        _valid = __ai_profile_between(_field, 0, 10, false);
                    }
                    else if (string_pos("ratio", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 0.05, 3, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 256, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0.1, 60, false);
                    }
                    break;
                case "abandonment":
                    if (_key == "enabled" || _key == "sprint")
                    {
                        _valid = is_bool(_field);
                    }
                    else if (_key == "health_ratio" || _key == "recovery_margin")
                    {
                        _valid = __ai_profile_between(_field, 0, 1, false);
                    }
                    else if (_key == "fight_range_ratio")
                    {
                        _valid = __ai_profile_between(_field, 0.25, 2, false);
                    }
                    else if (string_pos("_px", _key) > 0)
                    {
                        _valid = __ai_profile_between(_field, 8, 768, false);
                    }
                    else
                    {
                        _valid = __ai_profile_between(_field, 0, 3600, false, true);
                    }
                    break;
            }
            if (!_valid)
            {
                __ai_profile_error(arg4, arg5 + "." + _key, "invalid type or range; using safe default");
                _field = variable_struct_get(arg2, _key);
            }
            variable_struct_set(arg0, _key, _field);
        }
    }
}

function __ai_profile_apply(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7 = "")
{
    if (is_undefined(arg1))
    {
        exit;
    }
    var _invalid_layer = !is_struct(arg1);
    var _invalid_version = !_invalid_layer && variable_struct_exists(arg1, "schema_version") && !__ai_profile_between(arg1.schema_version, 1, 1, true);
    if (_invalid_layer || _invalid_version)
    {
        __ai_profile_error(arg3, _invalid_layer ? arg4 : (arg4 + ".schema_version"), "expected an AI object with schema version 1; using safe defaults");
        var _safe_keys = variable_struct_get_names(arg2);
        for (var _i = 0; _i < array_length(_safe_keys); _i++)
        {
            var _key = _safe_keys[_i];
            if (_key != "profile")
            {
                variable_struct_set(arg0, _key, __ai_profile_copy(variable_struct_get(arg2, _key)));
            }
        }
        if (is_struct(arg6))
        {
            var _traits = __ai_profile_trait_names();
            for (var _i = 0; _i < array_length(_traits); _i++)
            {
                variable_struct_set(arg6, _traits[_i], __ai_profile_copy(variable_struct_get(arg2.traits, _traits[_i])));
            }
        }
        exit;
    }
    var _keys = variable_struct_get_names(arg1);
    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        if (__ai_profile_is_note(_key))
        {
            continue;
        }
        var _value = variable_struct_get(arg1, _key);
        var _field_path = arg4 + "." + _key;
        switch (_key)
        {
            case "id":
                if (!arg5)
                {
                    __ai_profile_error(arg3, _field_path, "unknown field");
                }
                break;
            case "profile":
                if (!is_string(_value) || string_length(_value) == 0)
                {
                    __ai_profile_error(arg3, _field_path, "expected a nonempty profile name");
                }
                break;
            case "schema_version":
                if (!__ai_profile_between(_value, 1, 1, true))
                {
                    __ai_profile_error(arg3, _field_path, "only schema version 1 is supported");
                }
                arg0.schema_version = 1;
                break;
            case "tree":
                if (!is_string(_value) || !__ai_profile_contains(["human_basic", "test_idle"], _value))
                {
                    __ai_profile_error(arg3, _field_path, "unknown tree; using human_basic");
                    _value = arg2.tree;
                }
                arg0.tree = _value;
                break;
            case "training":
                if (!is_string(_value) || !__ai_profile_contains(["rookie", "intermediate", "skilled", "expert", "veteran", "master"], _value))
                {
                    __ai_profile_error(arg3, _field_path, "unknown training tier; using rookie");
                    _value = arg2.training;
                }
                arg0.training = _value;
                break;
            case "traits":
                __ai_profile_traits(arg0.traits, _value, arg2.traits, arg3, _field_path, arg6);
                break;
            case "personality_pool":
                arg0.personality_pool = __ai_profile_pool(_value, arg2.traits, arg3, _field_path);
                break;
            case "weapon_overrides":
                if (!is_struct(_value))
                {
                    __ai_profile_error(arg3, _field_path, "expected weapon-type overrides object");
                }
                break;
            case "scatter":
            case "peek_reposition":
            case "flank":
            case "reload_push":
            case "heal_push":
            case "covering_fire":
            case "flash_push":
            case "suppression":
            case "shoot_retreat":
            case "awareness":
            case "routines":
            case "hunter":
            case "flank_opportunity":
            case "approach":
            case "relocation":
            case "opportunity_response":
            case "defensive_reposition":
            case "hearing":
            case "magazine":
            case "vulnerability":
            case "cover_assessment":
            case "targeting":
            case "grenade":
            case "grenade_evasion":
            case "roaming_movement":
            case "engagement":
            case "investigation":
            case "pursuit":
            case "schedule":
            case "queries":
            case "communication":
            case "abandonment":
            case "strafe":
            case "spacing":
            case "interception":
            case "tactics":
            case "firing":
            case "reload":
            case "search":
            case "hit_reaction":
            case "peek":
                __ai_profile_group(variable_struct_get(arg0, _key), _value, variable_struct_get(arg2, _key), _key, arg3, _field_path, arg7);
                break;
            default:
                __ai_profile_error(arg3, _field_path, "unknown field");
                break;
        }
    }
    if (variable_struct_exists(arg1, "weapon_overrides") && is_struct(arg1.weapon_overrides) && is_string(arg7) && variable_struct_exists(arg1.weapon_overrides, arg7))
    {
        __ai_profile_weapon_layer(arg0, variable_struct_get(arg1.weapon_overrides, arg7), arg2, arg3, arg4 + ".weapon_overrides." + arg7, arg7);
    }
}

function __ai_profile_weapon_layer(arg0, arg1, arg2, arg3, arg4, arg5)
{
    if (!is_struct(arg1))
    {
        __ai_profile_error(arg3, arg4, "expected a weapon tuning object");
        exit;
    }
    var _keys = variable_struct_get_names(arg1);
    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        if (_key == "id" || __ai_profile_is_note(_key))
        {
            continue;
        }
        if (!__ai_profile_contains(["shoot_retreat", "awareness", "hunter", "flank_opportunity", "approach", "relocation", "opportunity_response", "defensive_reposition", "hearing", "magazine", "vulnerability", "cover_assessment", "targeting", "grenade", "grenade_evasion", "roaming_movement", "engagement", "investigation", "pursuit", "schedule", "queries", "communication", "abandonment", "strafe", "spacing", "interception", "tactics", "firing", "reload", "search", "hit_reaction", "peek", "scatter", "peek_reposition", "flank", "reload_push", "heal_push", "covering_fire", "flash_push", "suppression"], _key))
        {
            __ai_profile_error(arg3, arg4 + "." + _key, "unknown weapon tuning group");
        }
        else
        {
            __ai_profile_group(variable_struct_get(arg0, _key), variable_struct_get(arg1, _key), variable_struct_get(arg2, _key), _key, arg3, arg4 + "." + _key, arg5);
        }
    }
}

function ai_profile_rng(arg0)
{
    return 
    {
        state: __ai_profile_between(arg0, 1, 2147483646, true) ? arg0 : 1
    };
}

function ai_profile_random(arg0)
{
    arg0.state = (arg0.state * 16807) % 2147483647;
    return arg0.state / 2147483647;
}

function ai_profile_resolve(arg0, arg1, arg2, arg3, arg4, arg5 = "", arg6 = 0)
{
    var _safe = ai_profile_defaults();
    var _config = ai_profile_defaults();
    var _audit = 
    {
        valid: true,
        errors: 0,
        diagnostics: []
    };
    var _layers = [arg1, arg2, arg3];
    var _paths = ["preset.ai", "npc.ai", "spawn.ai"];
    var _selected = _safe.profile;
    var _selected_explicit = false;
    for (var _i = 0; _i < array_length(_layers); _i++)
    {
        if (is_struct(_layers[_i]) && variable_struct_exists(_layers[_i], "profile"))
        {
            _selected = struct_get_from_hash(_layers[_i], variable_get_hash("profile"));
            _selected_explicit = true;
        }
    }
    if (!is_string(_selected) || string_length(_selected) == 0)
    {
        _selected = _safe.profile;
    }
    if (!is_undefined(arg0) && !is_struct(arg0))
    {
        __ai_profile_error(_audit, "registry", "expected a profile registry object");
        arg0 = undefined;
    }
    if (_selected == "_defaults" || _selected == "_weapons")
    {
        __ai_profile_error(_audit, "profile", "reserved tuning entry cannot select a faction profile");
        _selected = _safe.profile;
    }
    if (is_struct(arg0))
    {
        __ai_profile_apply(_config, struct_get_from_hash(arg0, variable_get_hash("_defaults")), _safe, _audit, "defaults", true, undefined, arg5);
        var _weapons = struct_get_from_hash(arg0, variable_get_hash("_weapons"));
        if (!is_undefined(_weapons) && !is_struct(_weapons))
        {
            __ai_profile_error(_audit, "weapons", "expected weapon table");
        }
        if (is_struct(_weapons) && is_string(arg5) && variable_struct_exists(_weapons, arg5))
        {
            __ai_profile_weapon_layer(_config, variable_struct_get(_weapons, arg5), _safe, _audit, "weapons." + arg5, arg5);
        }
    }
    var _profile = undefined;
    if (is_struct(arg0) && variable_struct_exists(arg0, _selected))
    {
        _profile = variable_struct_get(arg0, _selected);
        if (!is_struct(_profile))
        {
            __ai_profile_error(_audit, "profiles." + _selected, "expected a profile object; using safe defaults");
            _profile = undefined;
            _selected = _safe.profile;
        }
    }
    else if (_selected_explicit && _selected != _safe.profile)
    {
        __ai_profile_error(_audit, "profile", "unknown profile '" + _selected + "'; using safe defaults");
        _selected = _safe.profile;
    }
    _config.profile = _selected;
    __ai_profile_apply(_config, _profile, _safe, _audit, "profiles." + _selected, true, undefined, arg5);
    var _explicit_traits = {};
    for (var _i = 0; _i < array_length(_layers); _i++)
    {
        __ai_profile_apply(_config, _layers[_i], _safe, _audit, _paths[_i], false, _explicit_traits, arg5);
    }
    if (_config.shoot_retreat.min_distance_px >= _config.shoot_retreat.preferred_distance_px || _config.shoot_retreat.min_move_px > _config.shoot_retreat.distance_px || _config.shoot_retreat.distance_gain_px > _config.shoot_retreat.min_move_px)
    {
        __ai_profile_error(_audit, "shoot_retreat", "expected minimum range < preferred range and gain <= minimum move <= maximum move");
        _config.shoot_retreat = __ai_profile_copy(_safe.shoot_retreat);
    }
    if (_config.defensive_reposition.min_move_px > _config.defensive_reposition.max_move_px || _config.defensive_reposition.min_gain_px > _config.defensive_reposition.max_move_px)
    {
        __ai_profile_error(_audit, "defensive_reposition", "minimum distances exceed maximum move; using safe group");
        _config.defensive_reposition = __ai_profile_copy(_safe.defensive_reposition);
    }
    if (_config.spacing.near_ratio >= _config.spacing.far_ratio || _config.spacing.min_move_px > _config.spacing.max_move_px || _config.spacing.min_gain_px > _config.spacing.max_move_px)
    {
        __ai_profile_error(_audit, "spacing", "expected near < far and minimum distances <= maximum move; using safe group");
        _config.spacing = __ai_profile_copy(_safe.spacing);
    }
    if (_config.interception.hold_min_seconds > _config.interception.hold_max_seconds)
    {
        __ai_profile_error(_audit, "interception", "expected minimum hold <= maximum hold; using safe group");
        _config.interception = __ai_profile_copy(_safe.interception);
    }
    var _ordered = [["abandonment", "min_move_px", "distance_px"], ["abandonment", "distance_gain_px", "min_move_px"], ["firing", "close_reflex_min_seconds", "close_reflex_max_seconds"], ["firing", "heard_peek_min_seconds", "heard_peek_max_seconds"], ["flash_push", "min_target_distance_px", "max_target_distance_px"], ["heal_push", "reaction_seconds", "opportunity_seconds"], ["covering_fire", "reserve_rounds", "min_rounds"], ["relocation", "route_min_seconds", "route_max_seconds"], ["relocation", "route_min_angle", "route_max_angle"], ["relocation", "min_move_px", "distance_px"], ["relocation", "contact_seconds", "memory_seconds"], ["scatter", "repeat_min_seconds", "repeat_max_seconds"], ["pursuit", "hold_min_seconds", "hold_max_seconds"], ["flank", "min_target_distance_px", "max_target_distance_px"], ["hunter", "peek_min_seconds", "peek_max_seconds"], ["flash_push", "reaction_seconds", "opportunity_seconds"], ["reload_push", "reaction_seconds", "opportunity_seconds"], ["firing", "burst_min_seconds", "burst_max_seconds"], ["firing", "settle_min_seconds", "settle_max_seconds"], ["firing", "trigger_rounds_min", "trigger_rounds_max"], ["firing", "trigger_pause_min_seconds", "trigger_pause_max_seconds"], ["firing", "outranged_rounds_min", "outranged_rounds_max"], ["firing", "outranged_pause_min_seconds", "outranged_pause_max_seconds"], ["firing", "lead_min_fraction", "lead_max_fraction"], ["search", "radius_min_px", "radius_max_px"], ["search", "pause_min_seconds", "pause_max_seconds"], ["hit_reaction", "rookie_min_seconds", "rookie_max_seconds"], ["hit_reaction", "skilled_min_seconds", "skilled_max_seconds"], ["hit_reaction", "master_min_seconds", "master_max_seconds"], ["peek", "fire_min_seconds", "fire_max_seconds"], ["grenade_evasion", "rookie_min_seconds", "rookie_max_seconds"], ["grenade_evasion", "skilled_min_seconds", "skilled_max_seconds"], ["grenade_evasion", "master_min_seconds", "master_max_seconds"], ["awareness", "scan_min_seconds", "scan_max_seconds"], ["hit_reaction", "fire_angle_degrees", "rear_angle_degrees"], ["peek", "distance_px", "max_path_px"], ["peek", "feint_min_seconds", "feint_max_seconds"], ["peek", "wait_min_seconds", "wait_max_seconds"]];
    for (var _i = 0; _i < array_length(_ordered); _i++)
    {
        var _rule = _ordered[_i];
        var _group = variable_struct_get(_config, _rule[0]);
        if (variable_struct_get(_group, _rule[1]) > variable_struct_get(_group, _rule[2]))
        {
            __ai_profile_error(_audit, _rule[0], "minimum exceeds maximum; using safe group");
            variable_struct_set(_config, _rule[0], __ai_profile_copy(variable_struct_get(_safe, _rule[0])));
        }
    }
    if (_config.abandonment.enabled && !__ai_profile_contains(["hunter", "bandit"], _selected))
    {
        __ai_profile_error(_audit, "abandonment.enabled", "voluntary abandonment is enabled only for hunter and bandit profiles");
        _config.abandonment.enabled = false;
    }
    if (arg6 > 0 && string_copy(_selected, 1, 5) != "boss_")
    {
        _config.training = ai_profile_training_lowered(_config.training, arg6);
    }
    _config.pursuit.tracking_seconds *= variable_struct_get(_config.pursuit, "tracking_" + _config.training + "_scale");
    _config.capabilities = __ai_profile_capabilities(_config.training);
    if (!__ai_profile_between(arg4, 1, 2147483646, true))
    {
        __ai_profile_error(_audit, "seed", "expected an integer in 1..2147483646; using 1");
        arg4 = 1;
    }
    var _stream = ai_profile_rng(arg4);
    var _style_id = "default";
    var _ranges = __ai_profile_copy(_config.traits);
    var _pool = _config.personality_pool;
    if (array_length(_pool) > 0)
    {
        var _total = 0;
        for (var _i = 0; _i < array_length(_pool); _i++)
        {
            _total += _pool[_i].weight;
        }
        var _choice = ai_profile_random(_stream) * _total;
        var _style = _pool[array_length(_pool) - 1];
        for (var _i = 0; _i < array_length(_pool); _i++)
        {
            _choice -= _pool[_i].weight;
            if (sign(_choice) < 0)
            {
                _style = _pool[_i];
                break;
            }
        }
        _style_id = _style.id;
        _keys = variable_struct_get_names(_style.traits);
        for (var _i = 0; _i < array_length(_keys); _i++)
        {
            variable_struct_set(_ranges, _keys[_i], variable_struct_get(_style.traits, _keys[_i]));
        }
    }
    var _keys = variable_struct_get_names(_explicit_traits);
    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        variable_struct_set(_ranges, _keys[_i], variable_struct_get(_explicit_traits, _keys[_i]));
    }
    var _sampled = {};
    var _names = __ai_profile_trait_names();
    for (var _i = 0; _i < array_length(_names); _i++)
    {
        var _range = variable_struct_get(_ranges, _names[_i]);
        var _random = ai_profile_random(_stream);
        variable_struct_set(_sampled, _names[_i], is_array(_range) ? (_range[0] + ((_range[1] - _range[0]) * _random)) : _range);
    }
    return 
    {
        config: _config,
        weapon_type: arg5,
        personality: 
        {
            style: _style_id,
            traits: _sampled
        },
        seed: arg4,
        random_state: _stream.state,
        diagnostics: _audit.diagnostics,
        valid: _audit.valid
    };
}

function __ai_profile_patch(arg0, arg1, arg2 = 0)
{
    if (arg2 > 8)
    {
        throw "AI patch exceeds maximum nesting";
    }
    if (!is_struct(arg1))
    {
        if (is_array(arg1))
        {
            _out = [];
            for (var _i = 0; _i < array_length(arg1); _i++)
            {
                array_push(_out, __ai_profile_patch(undefined, arg1[_i], arg2 + 1));
            }
            return _out;
        }
        return arg1;
    }
    var _out = is_struct(arg0) ? __ai_profile_copy(arg0) : {};
    var _keys = variable_struct_get_names(arg1);
    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        variable_struct_set(_out, _key, __ai_profile_patch(variable_struct_get(_out, _key), variable_struct_get(arg1, _key), arg2 + 1));
    }
    return _out;
}

function ai_profile_validate_registry(arg0)
{
    var _audit = 
    {
        valid: true,
        errors: 0,
        diagnostics: []
    };
    if (!is_struct(arg0))
    {
        __ai_profile_error(_audit, "registry", "expected object");
        return _audit;
    }
    var _types = [""];
    var _names = variable_struct_get_names(arg0);
    var _tables = [struct_get_from_hash(arg0, variable_get_hash("_weapons"))];
    for (var _i = 0; _i < array_length(_names); _i++)
    {
        var _entry = variable_struct_get(arg0, _names[_i]);
        if (is_struct(_entry) && variable_struct_exists(_entry, "weapon_overrides"))
        {
            array_push(_tables, _entry.weapon_overrides);
        }
    }
    for (var _i = 0; _i < array_length(_tables); _i++)
    {
        if (is_undefined(_tables[_i]))
        {
            continue;
        }
        if (!is_struct(_tables[_i]))
        {
            __ai_profile_error(_audit, "weapons", "expected weapon override object");
        }
        else
        {
            var _keys = variable_struct_get_names(_tables[_i]);
            for (var _j = 0; _j < array_length(_keys); _j++)
            {
                if (_keys[_j] == "id" || __ai_profile_is_note(_keys[_j]))
                {
                    continue;
                }
                if (_keys[_j] == "")
                {
                    __ai_profile_error(_audit, "weapons", "empty weapon type");
                }
                else if (!__ai_profile_contains(_types, _keys[_j]))
                {
                    array_push(_types, _keys[_j]);
                }
            }
        }
    }
    if (array_length(_names) > 256 || array_length(_types) > 65)
    {
        __ai_profile_error(_audit, "registry", "too many profiles or weapon types");
        return _audit;
    }
    for (var _i = 0; _i < array_length(_names); _i++)
    {
        if (__ai_profile_is_note(_names[_i]))
        {
            continue;
        }
        for (var _j = 0; _j < array_length(_types); _j++)
        {
            var _r = ai_profile_resolve(arg0, undefined, 
            {
                profile: _names[_i]
            }, undefined, 123, _types[_j]);
            if (!_r.valid)
            {
                __ai_profile_error(_audit, _names[_i] + "/" + _types[_j], string(_r.diagnostics));
                return _audit;
            }
        }
    }
    return _audit;
}

function ai_profile_apply_mod_json(arg0)
{
    if (!is_struct(arg0) || !__ai_profile_between(struct_get_from_hash(arg0, variable_get_hash("version")), 0, 0, true) || struct_get_from_hash(arg0, variable_get_hash("usage")) != "ai_profiles" || !is_struct(struct_get_from_hash(arg0, variable_get_hash("data"))))
    {
        return 
        {
            valid: false,
            diagnostics: ["expected version 0, usage ai_profiles and data object"]
        };
    }
    try
    {
        var _candidate = __ai_profile_patch(global.ai_profile_data, arg0.data);
        var _audit = ai_profile_validate_registry(_candidate);
        if (!_audit.valid)
        {
            return _audit;
        }
        global.ai_profile_data = _candidate;
        global.ai_profile_data_array = variable_struct_get_names(_candidate);
        return _audit;
    }
    catch (_error)
    {
        return 
        {
            valid: false,
            diagnostics: [string(_error)]
        };
    }
}

function ai_profiles_mod_autoload()
{
    for (var _i = 0; _i < array_length(global.Mods_Order); _i++)
    {
        var _name = global.Mods_Order[_i];
        var _mod = variable_struct_get(global.Mods_Data, _name);
        if (!is_struct(_mod))
        {
            continue;
        }
        var _path = _mod.file_path + "/gamedata/ai_profiles.json";
        if (!file_exists(_path))
        {
            continue;
        }
        try
        {
            var _result = ai_profile_apply_mod_json(json_parse(SnapStringFromFile(_path)));
            if (!_result.valid)
            {
                trace("AI tuning mod ", _name, " skipped: ", string(_result.diagnostics));
            }
        }
        catch (_error)
        {
            trace("AI tuning mod ", _name, " skipped: ", string(_error));
        }
    }
}
