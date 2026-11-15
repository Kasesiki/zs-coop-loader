function __ai_hunter_enabled(arg0)
{
    return arg0.profile.config.hunter.enabled;
}

function __ai_hunter_sprint_reload(arg0)
{
    return __ai_hunter_enabled(arg0) && arg0.profile.config.hunter.sprint_reload;
}

function __ai_hunter_create()
{
    return 
    {
        target: noone,
        room_id: room,
        next_sample: 0,
        sampled_at: -1000,
        sample_frame: -1,
        hp_ratio: 1,
        bleeding: false,
        reloading: false,
        medicine: undefined,
        fleeing: false,
        motion_at: -1000,
        ox: 0,
        oy: 0,
        distance: 0,
        hit_at: -1000,
        damage: 0,
        intent: "",
        intent_until: 0,
        cover_peeks: 0,
        peek_x: 0,
        peek_y: 0
    };
}

function __ai_hunter_intel_fresh(arg0)
{
    var _h = arg0.combat.hunter;
    return __ai_hunter_enabled(arg0) && arg0.knowledge.valid && _h.target == arg0.knowledge.target && _h.room_id == room && !is_in_hub() && !arg0.npc.grenade_flash && (arg0.now - _h.sampled_at) <= (arg0.profile.config.hunter.sample_seconds * 2) && (arg0.now - arg0.knowledge.observed_at) <= arg0.profile.config.hunter.intel_memory_seconds;
}

function __ai_hunter_risk_bad(arg0)
{
    return (arg0.npc.hp / max(1, npc_get_hp(arg0.npc.npc_id))) <= arg0.profile.config.hunter.safe_health_ratio || __ai_human_pressure_high(arg0);
}

function ai_hunter_confirm_hit(arg0, arg1, arg2)
{
    if (arg2 <= 0 || !instance_exists(arg0) || !instance_exists(arg1) || !variable_instance_exists(arg0, "ai_execution"))
    {
        exit;
    }
    var _e = arg0.ai_execution;
    if (!is_struct(_e) || !variable_struct_exists(_e, "combat") || !__ai_hunter_enabled(_e) || arg0.hp <= 0 || arg0.state != "human_general" || !_e.knowledge.valid || _e.knowledge.target != arg1 || !__ai_perception_hostile(arg0, arg1))
    {
        exit;
    }
    var _h = _e.combat.hunter;
    if (_h.target != arg1)
    {
        _h = __ai_hunter_create();
        _h.target = arg1;
        _e.combat.hunter = _h;
    }
    _h.hit_at = _e.now;
    _h.damage = arg2;
}

function __ai_hunter_step(arg0)
{
    if (!__ai_hunter_enabled(arg0))
    {
        exit;
    }
    var _h = arg0.combat.hunter;
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.hunter;
    if (!_k.valid || _h.target != _k.target || _h.room_id != room)
    {
        _h = __ai_hunter_create();
        arg0.combat.hunter = _h;
        if (!_k.valid)
        {
            exit;
        }
        _h.target = _k.target;
    }
    if (arg0.now < _h.next_sample)
    {
        exit;
    }
    _h.next_sample = arg0.now + _c.sample_seconds;
    var _target = _k.target;
    if (is_in_hub() || arg0.npc.grenade_flash || !__ai_investigation_player(arg0) || !__ai_perception_hostile(arg0.npc, _target) || !variable_instance_exists(_target, "hp_max") || _target.hp <= 0 || (arg0.now - _k.observed_at) > _c.intel_memory_seconds || (arg0.perception.search_until > 0 && arg0.now >= arg0.perception.search_until) || point_distance(arg0.npc.x, arg0.npc.y, _target.x, _target.y) > _c.intel_radius_px)
    {
        _h.sampled_at = -1000;
        _h.intent = "";
        _h.fleeing = false;
        exit;
    }
    _h.hp_ratio = clamp(_target.hp / max(1, _target.hp_max), 0, 1);
    _h.bleeding = variable_instance_exists(_target, "bleed") && _target.bleed > 0;
    var _reload = variable_instance_exists(_target, "reloading") && _target.reloading;
    var _med = __ai_perception_medication(_target);
    var _focus = ai_contact_focus(arg0);
    if (_reload && !_h.reloading)
    {
        __ai_human_opportunity_notice(arg0, "reload_push", _target, _focus.x, _focus.y, 0, false);
    }
    if (is_struct(_med) && _med != _h.medicine)
    {
        var _remaining = variable_struct_exists(_med, "alarm2") ? (_med.alarm2 / 60) : 1000;
        __ai_human_opportunity_notice(arg0, "heal_push", _target, _focus.x, _focus.y, 0, false, _remaining);
    }
    if (is_struct(_med) && variable_struct_exists(_med, "alarm2") && is_struct(arg0.combat.adaptation.heal_cue))
    {
        arg0.combat.adaptation.heal_cue.until = min(arg0.combat.adaptation.heal_cue.until, arg0.now + (max(0, _med.alarm2) / 60));
    }
    if (!_reload)
    {
        arg0.combat.adaptation.reload_cue = undefined;
    }
    if (!is_struct(_med))
    {
        arg0.combat.adaptation.heal_cue = undefined;
    }
    _h.reloading = _reload;
    _h.medicine = _med;
    _h.sampled_at = arg0.now;
    _h.sample_frame = ai_world_get().frame;
    if ((arg0.now - _h.motion_at) <= 0.8)
    {
        _h.fleeing = (point_distance(_h.ox, _h.oy, _target.x, _target.y) - _h.distance) >= 12;
    }
    else
    {
        _h.fleeing = false;
    }
    if ((arg0.now - _h.motion_at) >= 0.6)
    {
        _h.motion_at = arg0.now;
        _h.ox = arg0.npc.x;
        _h.oy = arg0.npc.y;
        _h.distance = point_distance(_h.ox, _h.oy, _target.x, _target.y);
    }
}

function __ai_hunter_choose(arg0)
{
    if (!__ai_hunter_intel_fresh(arg0) || __ai_human_pursuit_committed(arg0) || arg0.now < arg0.withdrawal.until || arg0.now < arg0.combat.movement_until)
    {
        return false;
    }
    var _h = arg0.combat.hunter;
    var _c = arg0.profile.config.hunter;
    var _k = arg0.knowledge;
    var _m = __ai_human_memory(arg0);
    var _focus = ai_contact_focus(arg0);
    var _recent_hit = (arg0.now - _h.hit_at) <= _c.hit_memory_seconds;
    var _weak = _h.hp_ratio <= _c.low_health_ratio || ((_h.bleeding || _recent_hit) && _h.hp_ratio <= _c.bleeding_health_ratio);
    var _exchange = is_struct(_m) && _m.shot_at > _m.consumed_at && (arg0.now - _m.shot_at) <= _c.intel_memory_seconds;
    var _in_cover = is_struct(arg0.combat.cover) && point_distance(arg0.npc.x, arg0.npc.y, arg0.combat.cover.x, arg0.combat.cover.y) <= 6;
    if (point_distance(arg0.npc.x, arg0.npc.y, _h.peek_x, _h.peek_y) > 32)
    {
        _h.cover_peeks = 0;
    }
    if (__ai_hunter_risk_bad(arg0))
    {
        _h.intent = "recover";
        _h.intent_until = arg0.now + _c.intent_seconds;
        if (!_in_cover && arg0.now >= arg0.combat.cooldowns.cover)
        {
            arg0.combat.tactic = "cover";
            arg0.combat.decision_reason = "hunter_recover";
            return true;
        }
        return false;
    }
    if (!_c.relocate_after_burst && _k.visible && _recent_hit && !_weak && ai_commands_camera_step(arg0) && ai_commands_in_effective_range(arg0, _k.x, _k.y))
    {
        _h.intent = "";
        arg0.combat.tactic = "shoot";
        arg0.combat.decision_reason = "hunter_winning_exchange";
        return true;
    }
    var _desired = (_exchange && _c.relocate_after_burst) ? "relocate" : (_weak ? "pressure" : (_h.fleeing ? "intercept" : (_exchange ? "relocate" : "")));
    if (arg0.now >= _h.intent_until || _h.intent == "" || _h.intent == "recover" || (_c.relocate_after_burst && _exchange && _h.intent != "relocate") || (_weak && _h.intent != "pressure") || (!_weak && _h.intent == "pressure"))
    {
        _h.intent = _desired;
        _h.intent_until = arg0.now + _c.intent_seconds;
    }
    if (_h.intent == "pressure" || _h.intent == "intercept")
    {
        if (!__ai_human_pursuit_allowed(arg0) || !ai_team_can_push(arg0) || arg0.npc.ammo_now <= 0)
        {
            return false;
        }
        if (_h.intent == "intercept" && __ai_human_can_intercept(arg0.tree_context))
        {
            arg0.combat.tactic = "interception";
        }
        else if (point_distance(arg0.npc.x, arg0.npc.y, _focus.x, _focus.y) > (arg0.profile.config.pursuit.stop_distance_px + 8) && arg0.now >= arg0.combat.cooldowns.push)
        {
            arg0.combat.tactic = _k.visible ? "push" : "advance";
        }
        else
        {
            return false;
        }
        arg0.combat.decision_reason = "hunter_" + _h.intent;
        return true;
    }
    var _failed_peek = arg0.combat.adaptation.peek_target == _k.target && arg0.combat.adaptation.peek_failures >= arg0.profile.config.peek_reposition.failed_attempts;
    if (_exchange && _in_cover && !_failed_peek && _h.cover_peeks < _c.cover_peek_limit && arg0.now >= arg0.combat.cooldowns.peek && ai_profile_random(arg0.rng) < _c.cover_peek_chance)
    {
        arg0.combat.tactic = "peek";
        arg0.combat.decision_reason = "hunter_cover_peek";
        return true;
    }
    if (_h.intent == "relocate" && _exchange && __ai_human_relocation_weight(arg0, false) > 0)
    {
        arg0.combat.tactic = "relocation";
        arg0.combat.decision_reason = "hunter_change_angle";
        return true;
    }
    if (_exchange && _in_cover && !_failed_peek && arg0.now >= arg0.combat.cooldowns.peek)
    {
        arg0.combat.tactic = "peek";
        return true;
    }
    if (_exchange && _k.visible && arg0.profile.config.strafe.enabled && arg0.now >= arg0.combat.cooldowns.strafe)
    {
        arg0.combat.tactic = "strafe";
        arg0.combat.decision_reason = "hunter_mobile_exchange";
        return true;
    }
    return false;
}

function ai_human_combat_init(arg0)
{
    arg0.now = 0;
    arg0.rng = 
    {
        state: arg0.profile.random_state
    };
    var _npc = arg0.npc;
    var _radius = arg0.profile.config.pursuit.max_distance_px;
    if (variable_instance_exists(_npc, "leash_to_spawn") && _npc.leash_to_spawn)
    {
        _radius = min(_radius, _npc.leash_radius);
    }
    arg0.assignment = 
    {
        x: _npc.original_x,
        y: _npc.original_y,
        radius: _radius
    };
    arg0.knowledge = ai_perception_create(arg0);
    ai_commands_init(arg0);
    arg0.combat = 
    {
        chase_done: -1,
        blocked_until: 0,
        return_failures: 0,
        return_retry_at: 0,
        tactic: "shoot",
        engaging: false,
        angle_failed: false,
        decision_reason: "initial",
        committed: false,
        advanced: true,
        cover: undefined,
        peek_return: false,
        weapon_range: ai_human_weapon_range(_npc.arma_now),
        pursuit_allowed: undefined,
        lost_contact: 
        {
            active: false,
            target: noone,
            chase_allowed: false,
            hold_until: 0,
            search_at: 0,
            next_advance: 0
        },
        chase_active: false,
        preparing: false,
        preparing_reload: false,
        scatter: 
        {
            panic: false,
            fire_first_until: 0,
            encounter: false,
            pending: false,
            until: 0,
            repeating: false,
            next_repeat: 0,
            started_at: -1000
        },
        movement_until: 0,
        intercept_active: false,
        intercept_observed_at: -1,
        defense: 
        {
            target: noone,
            unsupported_at: -1,
            next_probe: 0,
            checked_at: -1000,
            mode: "none",
            protected: false,
            close: false,
            reason: "initial"
        },
        memory: undefined,
        approach: undefined,
        maneuver: undefined,
        hunter: __ai_hunter_create(),
        hunter_reload: false,
        pressure: 
        {
            value: 0,
            at: 0,
            frame: -1
        },
        covering: undefined,
        covering_until: 0,
        shoot_retreat_until: 0,
        adaptation: 
        {
            active: "",
            peek_failures: 0,
            peek_target: noone,
            flash_cue: undefined,
            flash_seen_until: 0,
            heal_cue: undefined,
            heal_seen_until: 0,
            reload_cue: undefined,
            reload_seen_until: 0,
            miss_count: 0,
            miss_started: 0,
            miss_frame: -1,
            miss_threat: undefined
        },
        adaptation_cooldowns: 
        {
            relocation: 0,
            peek_reposition: 0,
            flank: 0,
            reload_push: 0,
            heal_push: 0,
            flash_push: 0,
            suppression: 0
        },
        cooldowns: 
        {
            relocation: 0,
            defensive_reposition: 0,
            angle: 0,
            hold_angle: 0,
            advance: 0,
            scatter: 0,
            panic: 0,
            flank: 0,
            reload_push: 0,
            peek_reposition: 0,
            strafe: 0,
            spacing: 0,
            interception: 0,
            shoot: 0,
            reposition: 0,
            cover: 0,
            peek: 0,
            push: 0,
            grenade: 0
        }
    };
    ai_spatial_create(arg0);
    ai_investigation_create(arg0);
    ai_bridge_create(arg0);
    ai_assignments_create(arg0);
    ai_team_create(arg0);
    ai_compat_create(arg0);
    ai_grenade_create(arg0);
    ai_routines_create(arg0);
    ai_scene_assignments_create(arg0);
    ai_routes_create(arg0);
}

function ai_human_weapon_range(arg0)
{
    var _points = glance_get_eff_range(item_weapon_get_type_effective_range(arg0));
    if (!is_array(_points))
    {
        return 160;
    }
    var _first = -1;
    var _last = -1;
    for (var _i = 0; _i < array_length(_points); _i++)
    {
        if (!is_array(_points[_i]) || array_length(_points[_i]) < 2 || !__ai_profile_number(_points[_i][0]) || !__ai_profile_number(_points[_i][1]) || _points[_i][0] < 0)
        {
            continue;
        }
        if (_points[_i][1] >= 1)
        {
            if (_first < 0)
            {
                _first = _points[_i][0];
            }
            _last = _points[_i][0];
        }
    }
    return (_first < 0) ? 160 : clamp((_first + _last) / 2, 32, 480);
}

function ai_human_basic_tree()
{
    static _tree = ai_bt_tree(ai_bt_priority("human", [ai_bt_branch(function(arg0)
    {
        return ai_compat_danger(arg0.user_data);
    }, ai_bt_action("danger", ai_compat_danger_enter, ai_compat_danger_update, ai_compat_danger_exit)), ai_bt_branch(ai_assignments_pending, ai_bt_action("assignment", ai_assignments_enter, ai_assignments_update, ai_assignments_exit)), ai_bt_branch(function(arg0)
    {
        var _h = arg0.user_data.bridge.hit;
        return _h.active || (_h.pending && __ai_bt_due(arg0.user_data.now, _h.ready_at));
    }, ai_bt_action("hit_reaction", __ai_human_hit_enter, __ai_human_hit_update, __ai_human_hit_exit)), ai_bt_branch(ai_withdrawal_ready, ai_bt_action("withdraw", ai_withdrawal_enter, ai_withdrawal_update, ai_withdrawal_exit)), ai_bt_branch(__ai_human_need_reload, ai_bt_timeout("reload_deadline", 16, ai_bt_action("reload", __ai_human_reload_enter, __ai_human_reload, __ai_human_reload_exit))), ai_bt_branch(__ai_human_can_suppress, ai_bt_action("suppression_cover", __ai_human_suppression_enter, __ai_human_adapt_move, __ai_human_adapt_exit)), ai_bt_branch(__ai_human_can_combat, ai_bt_sequence("engage_target", [ai_bt_action("choose_tactic", undefined, __ai_human_choose_tactic, undefined), ai_bt_priority("execute_tactic", [ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "shoot_retreat";
    }, ai_bt_action("shoot_retreat", __ai_human_shoot_retreat_enter, __ai_human_shoot_retreat_update, __ai_human_shoot_retreat_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "panic";
    }, ai_bt_action("panic", __ai_human_panic_enter, __ai_human_hit_update, __ai_human_hit_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "scatter";
    }, ai_bt_action("scatter", __ai_human_scatter_enter, __ai_human_adapt_move, __ai_human_adapt_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "relocation";
    }, ai_bt_action("relocation", __ai_human_gain_angle_enter, __ai_human_gain_angle, __ai_human_gain_angle_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "defensive_reposition";
    }, ai_bt_action("defensive_reposition", __ai_human_defense_enter, __ai_human_defense_move, __ai_human_defense_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "reload_push";
    }, __ai_human_prepared_approach(ai_bt_action("reload_push", __ai_human_reload_push_enter, __ai_human_adapt_move, __ai_human_adapt_exit))), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "flash_push";
    }, __ai_human_prepared_approach(ai_bt_action("flash_push", __ai_human_flash_push_enter, __ai_human_adapt_move, __ai_human_adapt_exit))), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "peek_reposition";
    }, ai_bt_action("peek_reposition", __ai_human_peek_reposition_enter, __ai_human_adapt_move, __ai_human_adapt_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "flank";
    }, __ai_human_prepared_approach(ai_bt_action("flank", __ai_human_flank_enter, __ai_human_adapt_move, __ai_human_adapt_exit))), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "interception";
    }, ai_bt_action("interception", __ai_human_intercept_enter, __ai_human_intercept, __ai_human_intercept_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "advance";
    }, __ai_human_prepared_approach(ai_bt_action("chase", __ai_human_chase_enter, __ai_human_chase, __ai_human_chase_exit))), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "angle";
    }, ai_bt_action("find_angle", __ai_human_gain_angle_enter, __ai_human_gain_angle, __ai_human_gain_angle_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "heal_push";
    }, __ai_human_prepared_approach(ai_bt_action("heal_push", __ai_human_heal_push_enter, __ai_human_adapt_move, __ai_human_adapt_exit))), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "covering_fire";
    }, ai_bt_action("covering_fire", __ai_human_covering_enter, __ai_human_covering_update, __ai_human_covering_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "hold_angle";
    }, ai_bt_action("hold_angle", __ai_human_action_enter, __ai_human_hold_angle, __ai_human_hold_angle_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "peek";
    }, ai_bt_action("peek", __ai_human_peek_enter, __ai_human_peek, __ai_human_tactic_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "grenade";
    }, ai_bt_action("grenade", ai_grenade_enter, ai_grenade_update, ai_grenade_exit)), ai_bt_branch(function(arg0)
    {
        return arg0.user_data.combat.tactic == "strafe" || arg0.user_data.combat.tactic == "spacing";
    }, __ai_human_prepared_approach(ai_bt_action("combat_move", __ai_human_combat_move_enter, __ai_human_combat_move, __ai_human_combat_move_exit), __ai_human_prepare_optional_enter)), ai_bt_branch(function(arg0)
    {
        return __ai_profile_contains(["cover", "push", "reposition"], arg0.user_data.combat.tactic);
    }, __ai_human_prepared_approach(ai_bt_action("position", __ai_human_position_enter, __ai_human_position, __ai_human_tactic_exit), __ai_human_prepare_optional_enter)), ai_bt_branch(function(arg0)
    {
        return true;
    }, ai_bt_action("shoot", __ai_human_action_enter, __ai_human_shoot, __ai_human_action_exit))])])), ai_bt_branch(__ai_human_can_search, ai_bt_priority("recover_contact", [ai_bt_branch(ai_investigation_ready, __ai_human_prepared_approach(ai_bt_action("investigate", ai_investigation_enter, ai_investigation_update, ai_investigation_exit))), ai_bt_branch(__ai_human_should_hold, ai_bt_action("hold_position", __ai_human_action_enter, __ai_human_hold, __ai_human_action_exit)), ai_bt_branch(__ai_human_can_chase, __ai_human_prepared_approach(ai_bt_action("chase", __ai_human_chase_enter, __ai_human_chase, __ai_human_chase_exit))), ai_bt_branch(__ai_human_can_search, __ai_human_prepared_approach(ai_bt_action("search", __ai_human_search_enter, __ai_human_search, __ai_human_search_exit)))])), ai_bt_branch(ai_aim_reaction_ready, ai_bt_action("aim_reaction", __ai_human_action_enter, ai_aim_reaction_update, __ai_human_action_exit)), ai_bt_branch(ai_routes_pending, ai_bt_action("route", ai_routes_enter, ai_routes_update, ai_routes_exit)), ai_bt_branch(__ai_human_should_return, ai_bt_action("return_assignment", __ai_human_action_enter, __ai_human_return, __ai_human_action_exit)), ai_bt_branch(ai_scene_assignments_ready, ai_bt_action("scene_assignment", ai_scene_assignments_enter, ai_scene_assignments_update, ai_scene_assignments_exit)), ai_bt_branch(function(arg0)
    {
        var _e = arg0.user_data;
        return _e.combat.advanced && !_e.knowledge.valid && __ai_human_ready(_e) && (_e.routines.active || point_distance(_e.npc.x, _e.npc.y, _e.assignment.x, _e.assignment.y) <= 6);
    }, ai_bt_action("routine", ai_routines_enter, ai_routines_update, ai_routines_exit)), ai_bt_branch(function(arg0)
    {
        return true;
    }, ai_bt_action("idle", __ai_human_action_enter, __ai_human_wait, __ai_human_action_exit))]));
    
    return _tree;
}

function __ai_human_ready(arg0)
{
    return sign(arg0.now - arg0.combat.blocked_until) >= 0;
}

function __ai_human_need_reload(arg0)
{
    var _e = arg0.user_data;
    return __ai_human_ready(_e) && !_e.combat.peek_return && !_e.combat.preparing_reload && (_e.npc.ammo_now <= 0 || _e.npc.reloading || _e.combat.hunter_reload);
}

function __ai_human_contact_fresh(arg0)
{
    var _k = arg0.knowledge;
    if (!_k.valid)
    {
        return false;
    }
    if (_k.visible)
    {
        return true;
    }
    var _grace = arg0.profile.config.engagement.contact_grace_seconds;
    if (_k.source == "sight" && (arg0.now - _k.observed_at) <= _grace)
    {
        return true;
    }
    var _s = arg0.team.support;
    return is_struct(_s) && _s.target == _k.target && (_s.age + (max(0, ai_world_get().frame - _s.frame) / 60)) <= _grace;
}

function __ai_human_can_combat(arg0)
{
    var _e = arg0.user_data;
    if (!_e.knowledge.valid || !__ai_human_ready(_e))
    {
        return false;
    }
    if (_e.combat.engaging || _e.combat.committed)
    {
        return true;
    }
    if (__ai_human_can_flash_push(arg0) || (_e.knowledge.visible && _e.now < _e.perception.close_ready_until))
    {
        return true;
    }
    if (__ai_human_pursuit_committed(_e))
    {
        return false;
    }
    return __ai_human_contact_fresh(_e) || ai_hearing_active(_e) || __ai_hunter_intel_fresh(_e) || __ai_human_defense_recovery(_e) || __ai_human_opening_ready(arg0) || __ai_human_relocation_weight(_e, false) > 0;
}

function __ai_human_pursuit_allowed(arg0)
{
    if (is_undefined(arg0.combat.pursuit_allowed))
    {
        var _policy = arg0.profile.config.pursuit;
        arg0.combat.pursuit_allowed = arg0.profile.personality.traits.aggression >= _policy.chase_aggression_min && _policy.chase_chance > 0 && (_policy.chase_chance >= 1 || ai_profile_random(arg0.rng) < _policy.chase_chance);
    }
    return arg0.combat.pursuit_allowed;
}

function __ai_human_can_chase(arg0)
{
    var _e = arg0.user_data;
    return __ai_human_ready(_e) && _e.now >= _e.withdrawal.until && _e.knowledge.valid && !_e.knowledge.visible && (is_undefined(_e.combat.pursuit_allowed) || _e.combat.pursuit_allowed) && !(ai_investigation_enabled_for(_e) && _e.investigation.engaged) && _e.combat.lost_contact.chase_allowed && _e.now >= _e.combat.lost_contact.hold_until && _e.now < _e.combat.lost_contact.search_at && (_e.combat.chase_active || (_e.now >= _e.combat.lost_contact.next_advance && ai_team_can_push(_e))) && _e.combat.chase_done != ai_contact_focus(_e).revision && (_e.now - _e.knowledge.observed_at) <= _e.profile.config.pursuit.lost_contact_seconds;
}

function __ai_human_lost_contact_step(arg0)
{
    var _k = arg0.knowledge;
    var _lost = arg0.combat.lost_contact;
    var _c = arg0.profile.config.pursuit;
    if (!_k.valid || _k.visible)
    {
        if (_k.visible && ai_investigation_committed(arg0))
        {
            exit;
        }
        _lost.active = false;
        if (!_k.valid)
        {
            _lost.target = -4;
            _lost.next_advance = 0;
        }
        exit;
    }
    if (_lost.active && _lost.target == _k.target)
    {
        ai_team_support_step(arg0);
        exit;
    }
    _lost.active = true;
    _lost.target = _k.target;
    _lost.search_at = arg0.now + max(0, _c.lost_contact_seconds - (arg0.now - _k.observed_at));
    var _chance = arg0.combat.advanced ? clamp(_c.direct_chase_chance * _c.direct_chase_scale, 0, 1) : 1;
    _lost.chase_allowed = _chance >= 1 || (_chance > 0 && ai_profile_random(arg0.rng) < _chance);
    var _wait = arg0.combat.advanced ? (lerp(_c.hold_min_seconds, _c.hold_max_seconds, (arg0.profile.personality.traits.patience + ai_profile_random(arg0.rng)) * 0.5) * _c.hold_scale * lerp(1.5, 0.5, __ai_human_aggression(arg0))) : 0;
    _lost.hold_until = arg0.now + _wait;
    ai_team_support_step(arg0);
}

function __ai_human_should_hold(arg0)
{
    var _e = arg0.user_data;
    var _k = _e.knowledge;
    var _lost = _e.combat.lost_contact;
    if (!__ai_human_ready(_e) || !_k.valid || _k.visible || !_lost.active || _e.combat.chase_active || _e.now >= _lost.search_at || _e.now < _e.withdrawal.until)
    {
        return false;
    }
    if (_e.combat.pursuit_allowed == false)
    {
        return false;
    }
    return !_lost.chase_allowed || _e.now < _lost.hold_until || _e.now < _lost.next_advance || !ai_team_can_push(_e);
}

function __ai_human_hold(arg0, arg1)
{
    var _e = arg0.user_data;
    if (__ai_human_opening_ready(arg0))
    {
        return UnknownEnum.Value_1;
    }
    ai_commands_stop(_e, arg1.token);
    if (!_e.knowledge.valid || _e.knowledge.visible)
    {
        return UnknownEnum.Value_1;
    }
    var _focus = ai_contact_focus(_e);
    ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    return __ai_human_should_hold(arg0) ? UnknownEnum.Value_0 : UnknownEnum.Value_1;
}

function __ai_human_can_search(arg0)
{
    var _e = arg0.user_data;
    return __ai_human_ready(_e) && _e.now >= _e.withdrawal.until && _e.knowledge.valid && (!_e.knowledge.visible || (_e.investigation.active && ai_investigation_committed(_e)));
}

function __ai_human_should_return(arg0)
{
    var _e = arg0.user_data;
    return __ai_human_ready(_e) && !_e.routines.active && (_e.combat.return_failures < 3 || _e.now >= _e.combat.return_retry_at) && point_distance(_e.npc.x, _e.npc.y, _e.assignment.x, _e.assignment.y) > 6;
}

function __ai_human_action_enter(arg0, arg1)
{
    var _e = arg0.user_data;
    _e.active = true;
    _e.npc.human_state_now = -1;
    _e.enter_count++;
    ai_commands_begin(_e, arg1.token);
}

function __ai_human_action_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    _e.active = false;
    _e.combat.engaging = false;
    _e.exit_count++;
    ai_commands_release(_e, arg1.token);
    if (arg2 == "failure" || arg2 == "timeout")
    {
        _e.combat.blocked_until = _e.now + _e.profile.config.queries.retry_seconds;
    }
}

function __ai_human_speed(arg0)
{
    var _speed = 0;
    with (arg0.npc)
    {
        _speed = npc_get_spd_alerted(npc_id);
    }
    return _speed * (__ai_hunter_enabled(arg0) ? arg0.profile.config.hunter.sprint_multiplier : 1);
}

function __ai_human_reload_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    __ai_human_reload_prepare(arg0.user_data, arg1);
}

function __ai_human_reload_prepare(arg0, arg1)
{
    var _npc = arg0.npc;
    var _focus = ai_contact_focus(arg0);
    var _close = _focus.valid && point_distance(_npc.x, _npc.y, _focus.x, _focus.y) < arg0.profile.config.reload.retreat_distance_px;
    var _protected = _close && is_struct(arg0.combat.cover) && point_distance(_npc.x, _npc.y, arg0.combat.cover.x, arg0.combat.cover.y) <= 6 && !__ai_spatial_clear_line(_npc.x, _npc.y, _focus.x, _focus.y);
    var _mobile = __ai_hunter_sprint_reload(arg0) && _focus.valid && !_protected;
    arg0.combat.hunter_reload = _mobile;
    arg1.data.phase = ((_close || _mobile) && !_protected) ? "reload_cover" : "reload";
    arg1.data.retreat_until = arg0.now + arg0.profile.config.reload.retreat_seconds;
    arg1.data.result = undefined;
}

function __ai_human_reload(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _focus = ai_contact_focus(_e);
    if (_focus.valid)
    {
        ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    }
    if (_d.phase != "reload")
    {
        if (!_e.knowledge.valid || _e.now >= _d.retreat_until)
        {
            _d.phase = "reload";
        }
        else if (!is_struct(_d.result))
        {
            var _position = ai_spatial_query(_e, _d.phase, arg1.token);
            if (_position.status == "DEFERRED")
            {
                return UnknownEnum.Value_0;
            }
            if (_position.status == "FOUND" && ai_spatial_claim(_e, _position, arg1.token))
            {
                _d.result = _position;
            }
            else if (_d.phase == "reload_cover")
            {
                ai_spatial_release(_e);
                _d.phase = "retreat";
                return UnknownEnum.Value_0;
            }
            else
            {
                _d.phase = "reload";
            }
        }
        if (_d.phase != "reload" && is_struct(_d.result))
        {
            if (!ai_spatial_validate(_e, _d.result))
            {
                ai_spatial_release(_e);
                _d.result = undefined;
                ai_commands_stop(_e, arg1.token);
                return UnknownEnum.Value_0;
            }
            var _move = ai_commands_move(_e, arg1.token, _d.result.x, _d.result.y, ai_commands_transfer_speed(_e, _d.result, __ai_hunter_sprint_reload(_e)), 2);
            if (_move != "arrived" && _move != "failed")
            {
                var _reload_status = __ai_human_reload_progress(_e, arg1);
                return (_e.combat.hunter_reload && _reload_status == UnknownEnum.Value_1) ? UnknownEnum.Value_0 : _reload_status;
            }
            if (_move == "arrived" && _d.phase == "reload_cover")
            {
                _e.combat.cover = _d.result;
            }
            _d.phase = "reload";
        }
    }
    ai_commands_stop(_e, arg1.token);
    return __ai_human_reload_progress(_e, arg1);
}

function __ai_human_reload_progress(arg0, arg1)
{
    var _k = arg0.knowledge;
    if (_k.valid && _k.visible && arg0.npc.ammo_now > 0 && point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y) <= arg0.combat.weapon_range)
    {
        ai_commands_reload_stop_early(arg0);
    }
    var _result = ai_commands_reload(arg0, arg1.token, !arg0.combat.preparing_reload && !arg0.combat.hunter_reload);
    if (_result == "running" && !variable_struct_exists(arg1.data, "announced"))
    {
        arg1.data.announced = true;
        ai_compat_callout(arg0.npc, "reload");
    }
    if (_result == "complete")
    {
        return UnknownEnum.Value_1;
    }
    return (_result == "failed") ? UnknownEnum.Value_2 : UnknownEnum.Value_0;
}

function __ai_human_reload_exit(arg0, arg1, arg2)
{
    arg0.user_data.combat.hunter_reload = false;
    ai_spatial_release(arg0.user_data);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_can_shoot_retreat(arg0)
{
    var _c = arg0.profile.config.shoot_retreat;
    return _c.enabled && arg0.knowledge.valid && arg0.knowledge.visible && !arg0.npc.reloading && arg0.npc.ammo_now > 0 && !arg0.npc.grenade_flash && !arg0.combat.peek_return && !ai_scene_assignments_force_shoot(arg0) && arg0.now >= arg0.combat.shoot_retreat_until;
}

function __ai_human_shoot_retreat_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _d = arg1.data;
    _e.combat.committed = true;
    _d.target = _e.knowledge.target;
    _d.weapon = _e.npc.arma_now;
    _d.phase = "fire";
    _d.shots = 0;
    _d.result = undefined;
    _d.failed = false;
    _d.until = _e.now + _e.profile.config.shoot_retreat.burst_seconds;
}

function __ai_human_shoot_retreat_begin(arg0, arg1)
{
    var _d = arg1.data;
    var _c = arg0.profile.config.shoot_retreat;
    var _k = ai_contact_focus(arg0);
    if (!_k.valid || _k.target != _d.target || (arg0.now - arg0.knowledge.observed_at) > _c.memory_seconds)
    {
        return false;
    }
    var _distance = point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y);
    if (_distance >= (_c.preferred_distance_px - _c.distance_gain_px))
    {
        return false;
    }
    _d.threat = 
    {
        valid: true,
        target: _k.target,
        x: _k.x,
        y: _k.y,
        revision: _k.revision
    };
    _d.until = min(arg0.now + _c.move_seconds, arg0.knowledge.observed_at + arg0.profile.config.pursuit.lost_contact_seconds + arg0.profile.config.pursuit.search_seconds);
    if (arg0.perception.search_until > 0)
    {
        _d.until = min(_d.until, arg0.perception.search_until);
    }
    _d.phase = "retreat";
    ai_commands_stop(arg0, arg1.token);
    return true;
}

function __ai_human_shoot_retreat_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _c = _e.profile.config.shoot_retreat;
    var _k = _e.knowledge;
    if (!_c.enabled || !_k.valid || _k.target != _d.target || _e.npc.arma_now != _d.weapon || _e.npc.grenade_flash)
    {
        return UnknownEnum.Value_1;
    }
    if (_d.phase == "fire")
    {
        ai_commands_stop(_e, arg1.token);
        var _close = _k.visible && point_distance(_e.npc.x, _e.npc.y, _k.x, _k.y) < _c.min_distance_px;
        if (!_close && _k.visible && _e.now < _d.until && _d.shots < _c.shots)
        {
            ai_commands_aim(_e, arg1.token, _k.x, _k.y);
            if (ai_commands_fire(_e, arg1.token, _k))
            {
                _d.shots++;
            }
            if (_d.shots < _c.shots)
            {
                return UnknownEnum.Value_0;
            }
        }
        if ((!_close && _d.shots == 0) || !__ai_human_shoot_retreat_begin(_e, arg1))
        {
            return UnknownEnum.Value_1;
        }
        return UnknownEnum.Value_0;
    }
    if (_e.now >= _d.until)
    {
        _d.failed = _d.phase == "retreat";
        return UnknownEnum.Value_1;
    }
    ai_commands_aim(_e, arg1.token, _d.threat.x, _d.threat.y);
    if (_d.phase == "settle")
    {
        ai_commands_stop(_e, arg1.token);
        return UnknownEnum.Value_0;
    }
    if (is_undefined(_d.result))
    {
        var _result = ai_spatial_query(_e, "shoot_retreat", arg1.token, _d.threat);
        if (_result.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_result.status != "FOUND" || ai_commands_travel_seconds(_e, _result, _c.sprint) > (_d.until - _e.now) || !ai_spatial_claim(_e, _result, arg1.token))
        {
            _d.failed = true;
            return UnknownEnum.Value_1;
        }
        _d.result = _result;
    }
    var _valid = ai_spatial_progress(_e, arg1, _d.result);
    if (_valid == "waiting")
    {
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid")
    {
        _d.failed = true;
        return UnknownEnum.Value_1;
    }
    var _move = ai_commands_move_position(_e, arg1.token, _d.result, ai_commands_transfer_speed(_e, _d.result, _c.sprint), 2);
    if (_move == "failed")
    {
        _d.failed = true;
        return UnknownEnum.Value_1;
    }
    if (_move == "arrived")
    {
        ai_commands_stop(_e, arg1.token);
        ai_spatial_release(_e);
        _d.phase = "settle";
        _d.until = min(_d.until, _e.now + _c.settle_seconds);
    }
    return UnknownEnum.Value_0;
}

function __ai_human_shoot_retreat_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    var _c = _e.profile.config.shoot_retreat;
    _e.combat.committed = false;
    _e.combat.shoot_retreat_until = _e.now + ((arg1.data.failed || arg2 != "success") ? _c.retry_seconds : _c.cooldown_seconds);
    ai_spatial_release(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_shoot(arg0, arg1)
{
    var _e = arg0.user_data;
    ai_commands_stop(_e, arg1.token);
    if (!_e.knowledge.valid || !_e.knowledge.visible)
    {
        return UnknownEnum.Value_1;
    }
    if (__ai_human_opening_ready(arg0))
    {
        return UnknownEnum.Value_1;
    }
    ai_commands_aim(_e, arg1.token, _e.knowledge.x, _e.knowledge.y);
    ai_commands_fire(_e, arg1.token, _e.knowledge);
    var _firing = _e.profile.config.firing;
    var _burst_deadline = min(_firing.burst_max_seconds, max(_firing.burst_min_seconds, ((_e.commands.reflex_required + 1) / 60) + _firing.burst_extra_seconds));
    if (_e.npc.ammo_now <= 0 || (_e.now - arg1.started_at) >= _burst_deadline)
    {
        return UnknownEnum.Value_1;
    }
    return UnknownEnum.Value_0;
}

function __ai_human_chase_enter(arg0, arg1)
{
    if (ai_investigation_enabled_for(arg0.user_data))
    {
        ai_investigation_enter(arg0, arg1);
        arg1.data.inspect = true;
        exit;
    }
    arg1.data.inspect = false;
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _k = ai_contact_focus(_e);
    arg1.data.sound = _k == _e.perception.hearing.clue;
    arg1.data.allowed = __ai_human_pursuit_allowed(_e) && ai_team_begin_push(_e, arg1.token);
    _e.combat.chase_active = true;
    arg1.data.x = _k.x;
    arg1.data.y = _k.y;
    arg1.data.target = _k.target;
    arg1.data.revision = _k.revision;
    arg1.data.threat = ai_movement_snapshot(_e);
    var _c = _e.profile.config.pursuit;
    var _aggression = __ai_human_aggression(_e);
    arg1.data.sprint = _aggression >= _c.sprint_aggression_min || (_aggression >= _c.ally_sprint_aggression_min && !is_undefined(ai_team_nearby_ally(_e)));
    arg1.data.result = undefined;
    arg1.data.until = _e.now + _c.advance_seconds;
}

function __ai_human_chase(arg0, arg1)
{
    if (arg1.data.inspect)
    {
        return ai_investigation_update(arg0, arg1);
    }
    var _e = arg0.user_data;
    var _k = _e.knowledge;
    if (!arg1.data.allowed)
    {
        _e.combat.chase_done = _k.revision;
        return UnknownEnum.Value_1;
    }
    if (_k.visible)
    {
        return UnknownEnum.Value_1;
    }
    if (!_k.valid || _k.target != arg1.data.target || (!arg1.data.sound && _e.now >= _e.combat.lost_contact.search_at) || (!arg1.data.sound && (_e.now - _k.observed_at) > _e.profile.config.pursuit.lost_contact_seconds) || (arg1.data.sound && _e.perception.search_until > 0 && _e.now >= _e.perception.search_until) || point_distance(_k.engagement_x, _k.engagement_y, arg1.data.x, arg1.data.y) > _e.profile.config.pursuit.max_distance_px)
    {
        _e.combat.chase_done = _k.revision;
        return UnknownEnum.Value_1;
    }
    var _focus = ai_contact_focus(_e);
    ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    var _c = _e.profile.config.pursuit;
    var _stop = _c.stop_distance_px * lerp(1.5, 0.75, _e.profile.personality.traits.aggression);
    if (point_distance(_e.npc.x, _e.npc.y, arg1.data.x, arg1.data.y) <= (_stop + 8))
    {
        _e.combat.chase_done = arg1.data.revision;
        return UnknownEnum.Value_1;
    }
    if (_e.now >= arg1.data.until)
    {
        return UnknownEnum.Value_1;
    }
    if (is_undefined(arg1.data.result))
    {
        var _query = ai_spatial_query(_e, "advance", arg1.token, arg1.data.threat);
        if (_query.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_query.status != "FOUND" || !ai_spatial_claim(_e, _query, arg1.token))
        {
            return UnknownEnum.Value_2;
        }
        arg1.data.result = _query;
        arg1.data.until = _e.now + ai_commands_travel_seconds(_e, _query, arg1.data.sprint, _c.advance_seconds);
    }
    if (ai_spatial_tracking_correct(_e, arg1, "advance", arg1.data.sprint, _c.advance_seconds))
    {
        arg1.data.x = arg1.data.threat.x;
        arg1.data.y = arg1.data.threat.y;
    }
    var _valid = ai_spatial_progress(_e, arg1, arg1.data.result);
    if (_valid == "waiting")
    {
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid")
    {
        return UnknownEnum.Value_1;
    }
    var _point = arg1.data.result;
    var _result = ai_commands_move_position(_e, arg1.token, _point, ai_commands_transfer_speed(_e, _point, arg1.data.sprint));
    if (_result == "arrived")
    {
        return UnknownEnum.Value_1;
    }
    if (_result == "failed")
    {
        return UnknownEnum.Value_2;
    }
    return UnknownEnum.Value_0;
}

function __ai_human_chase_exit(arg0, arg1, arg2)
{
    if (arg1.data.inspect)
    {
        ai_investigation_exit(arg0, arg1, arg2);
        exit;
    }
    var _e = arg0.user_data;
    _e.combat.chase_active = false;
    _e.combat.lost_contact.next_advance = _e.now + (_e.profile.config.pursuit.advance_cooldown_seconds * lerp(1.5, 0.5, _e.profile.personality.traits.aggression));
    ai_spatial_release(_e);
    ai_team_release(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_search_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    if (_e.perception.search_until <= 0)
    {
        _e.perception.search_until = _e.now + _e.profile.config.pursuit.search_seconds;
    }
    arg1.data.until = _e.perception.search_until;
    arg1.data.stationary = ai_investigation_enabled_for(_e) || !__ai_human_pursuit_allowed(_e) || !_e.combat.lost_contact.chase_allowed || !ai_team_begin_push(_e, arg1.token);
    var _k = ai_contact_focus(_e);
    arg1.data.center_x = _k.x;
    arg1.data.center_y = _k.y;
    var _direction = ai_contact_direction(_e, _k);
    arg1.data.threat = 
    {
        valid: true,
        x: _k.x,
        y: _k.y,
        revision: _k.revision,
        escape_direction: _direction
    };
    arg1.data.result = undefined;
    arg1.data.look_until = 0;
    arg1.data.check_pending = false;
    arg1.data.look_x = _k.x;
    arg1.data.look_y = _k.y;
    ai_compat_callout(_e.npc, "search");
}

function __ai_human_search(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    if (_e.knowledge.visible)
    {
        return UnknownEnum.Value_1;
    }
    _d.until = _e.perception.search_until;
    if (!_e.knowledge.valid || __ai_bt_due(_e.now, _d.until))
    {
        ai_perception_forget(_e, "search_complete");
        return UnknownEnum.Value_1;
    }
    if (_d.stationary || ai_investigation_enabled_for(_e))
    {
        ai_commands_stop(_e, arg1.token);
        var _focus = ai_contact_focus(_e);
        ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
        return UnknownEnum.Value_0;
    }
    if (_e.now < _d.look_until)
    {
        ai_commands_stop(_e, arg1.token);
        ai_commands_aim(_e, arg1.token, _d.look_x, _d.look_y);
        return UnknownEnum.Value_0;
    }
    if (_d.check_pending)
    {
        ai_investigation_check(_e, _d.look_x, _d.look_y);
        _d.check_pending = false;
        if (_e.knowledge.visible)
        {
            return UnknownEnum.Value_1;
        }
    }
    if (is_undefined(_d.result))
    {
        var _query = ai_spatial_query(_e, "search", arg1.token, _d.threat);
        if (_query.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_query.status != "FOUND" || !ai_spatial_claim(_e, _query, arg1.token))
        {
            ai_spatial_release(_e);
            _d.look_until = _e.now + _e.profile.config.queries.retry_seconds;
            return UnknownEnum.Value_0;
        }
        _d.result = _query;
    }
    var _result = "failed";
    if (ai_spatial_validate(_e, _d.result))
    {
        ai_commands_aim(_e, arg1.token, _d.result.x, _d.result.y);
        _result = ai_commands_move(_e, arg1.token, _d.result.x, _d.result.y, ai_commands_walk_speed(_e));
    }
    if (_result == "arrived" || _result == "failed")
    {
        ai_commands_stop(_e, arg1.token);
        _d.check_pending = _result == "arrived" && _e.profile.config.investigation.enabled && __ai_investigation_player(_e);
        _d.look_x = _d.check_pending ? (_d.result.x + lengthdir_x(16, _d.threat.escape_direction)) : _d.threat.x;
        _d.look_y = _d.check_pending ? (_d.result.y + lengthdir_y(16, _d.threat.escape_direction)) : _d.threat.y;
        ai_spatial_release(_e);
        _d.result = undefined;
        var _c = _e.profile.config.search;
        _d.look_until = _e.now + ((_result == "failed") ? _e.profile.config.queries.retry_seconds : lerp(_c.pause_min_seconds, _c.pause_max_seconds, ai_profile_random(_e.rng)));
    }
    return UnknownEnum.Value_0;
}

function __ai_human_search_exit(arg0, arg1, arg2)
{
    ai_spatial_release(arg0.user_data);
    ai_team_release(arg0.user_data);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_return(arg0, arg1)
{
    var _e = arg0.user_data;
    if (_e.combat.return_failures >= 3)
    {
        _e.combat.return_failures = 0;
    }
    var _result = ai_commands_move(_e, arg1.token, _e.assignment.x, _e.assignment.y, __ai_human_speed(_e));
    if (_result == "arrived")
    {
        _e.combat.return_failures = 0;
        return UnknownEnum.Value_1;
    }
    if (_result == "failed" || (_e.now - arg1.started_at) >= 8)
    {
        _e.combat.return_failures++;
        _e.combat.return_retry_at = _e.now + 5;
        return UnknownEnum.Value_2;
    }
    return UnknownEnum.Value_0;
}

function __ai_human_wait(arg0, arg1)
{
    ai_commands_stop(arg0.user_data, arg1.token);
    return UnknownEnum.Value_0;
}

function __ai_human_choose_tactic(arg0, arg1)
{
    var _e = arg0.user_data;
    var _combat = _e.combat;
    var _camera_ready = ai_commands_camera_step(_e);
    var _offscreen = !_camera_ready && !_e.commands.camera_fire.in_view;
    _combat.tactic = _offscreen ? "hold_angle" : "shoot";
    _combat.engaging = true;
    _combat.decision_reason = _e.knowledge.visible ? "personal_sight" : (__ai_human_contact_fresh(_e) ? "recent_contact" : "committed_tactic");
    __ai_human_maneuver_choose(_e);
    if (__ai_human_can_shoot_retreat(_e))
    {
        _combat.tactic = "shoot_retreat";
        _combat.decision_reason = "shoot_then_gain_distance";
        return UnknownEnum.Value_1;
    }
    var _flash_ready = __ai_human_can_flash_push(arg0);
    var _reload_ready = __ai_human_can_reload_push(arg0);
    var _heal_ready = __ai_human_can_heal_push(arg0);
    if (!_offscreen && !_flash_ready && !_reload_ready && !_heal_ready && _e.knowledge.visible && _e.perception.expected && _e.now < _e.perception.expected_until)
    {
        return UnknownEnum.Value_1;
    }
    if (_flash_ready)
    {
        _combat.tactic = "flash_push";
        _combat.decision_reason = "observed_flash";
        return UnknownEnum.Value_1;
    }
    if (!_offscreen && __ai_human_flash_close(_e))
    {
        _combat.decision_reason = "flash_in_range";
        return UnknownEnum.Value_1;
    }
    if (!_offscreen && _e.knowledge.visible && _e.now < _e.perception.close_ready_until)
    {
        _combat.decision_reason = "close_threat";
        return UnknownEnum.Value_1;
    }
    var _opening = _combat.scatter;
    if (_opening.panic && _e.now < _opening.until && !_e.bridge.hit.pending && !_e.bridge.hit.active)
    {
        _combat.tactic = "panic";
        return UnknownEnum.Value_1;
    }
    var _defensive = __ai_human_defense_context(_e);
    if (!_offscreen && _defensive && _e.knowledge.visible && _combat.defense.mode == "fight")
    {
        _combat.decision_reason = "exposed_fight_back";
        return UnknownEnum.Value_1;
    }
    if (ai_grenade_isolated_opportunity(_e))
    {
        _combat.tactic = "grenade";
        _combat.decision_reason = "isolated_cover_grenade";
        return UnknownEnum.Value_1;
    }
    if (_heal_ready)
    {
        _combat.tactic = "heal_push";
        _combat.decision_reason = "healing_opening";
        return UnknownEnum.Value_1;
    }
    if (_reload_ready)
    {
        _combat.tactic = "reload_push";
        _combat.decision_reason = _combat.adaptation.reload_cue.heard ? "heard_reload" : "observed_reload";
        return UnknownEnum.Value_1;
    }
    if (__ai_human_can_covering(_e))
    {
        _combat.tactic = "covering_fire";
        _combat.decision_reason = "cover_ally";
        return UnknownEnum.Value_1;
    }
    if (!_offscreen && _e.knowledge.visible && _e.now < _combat.scatter.fire_first_until)
    {
        return UnknownEnum.Value_1;
    }
    if (ai_scene_assignments_force_shoot(_e))
    {
        return UnknownEnum.Value_1;
    }
    if (__ai_human_can_scatter(arg0) && (!_opening.repeating || !_e.profile.config.relocation.route_enabled))
    {
        _combat.tactic = "scatter";
        return UnknownEnum.Value_1;
    }
    __ai_human_recognize_cover(_e);
    if (__ai_hunter_choose(_e))
    {
        return UnknownEnum.Value_1;
    }
    if (__ai_human_can_peek_reposition(arg0) && (!_e.profile.config.relocation.route_enabled || __ai_human_relocation_weight(_e, false) <= 0))
    {
        _combat.tactic = "peek_reposition";
        return UnknownEnum.Value_1;
    }
    if (!_combat.advanced && _e.knowledge.visible)
    {
        return UnknownEnum.Value_1;
    }
    if (_e.now < _e.withdrawal.until)
    {
        return _e.knowledge.visible ? UnknownEnum.Value_1 : UnknownEnum.Value_2;
    }
    var _focus = ai_contact_focus(_e);
    var _heard = __ai_hearing_source(_focus);
    var _traits = _e.profile.personality.traits;
    var _pressure = ai_perception_vulnerability(_e);
    var _aggression = __ai_human_aggression(_e);
    var _distance = point_distance(_e.npc.x, _e.npc.y, _focus.x, _focus.y);
    var _in_cover = is_struct(_combat.cover) && point_distance(_e.npc.x, _e.npc.y, _combat.cover.x, _combat.cover.y) <= 6;
    var _spacing = _e.profile.config.spacing;
    var _strafe = _e.profile.config.strafe;
    var _can_move = _e.now >= _combat.movement_until;
    var _outranged = _e.knowledge.visible && !ai_commands_in_effective_range(_e, _e.knowledge.x, _e.knowledge.y);
    var _can_approach = __ai_human_pursuit_allowed(_e) && (_outranged || !__ai_human_pressure_high(_e));
    var _weights_config = _e.profile.config.tactics;
    var _spacing_direction = __ai_human_spacing_direction(_e, _distance);
    var _engage = _e.profile.config.engagement;
    var _hidden = !_e.knowledge.visible;
    var _local = _distance <= ((_combat.weapon_range * _spacing.far_ratio) + _engage.angle_distance_px);
    var _advance = _hidden && _can_move && _can_approach && (_distance > (_combat.weapon_range * _spacing.far_ratio) || _combat.angle_failed || _pressure > 0 || _heard) && _distance > (_e.profile.config.pursuit.stop_distance_px + 8) && _e.now >= _combat.lost_contact.next_advance && ai_team_can_push(_e);
    var _names = ["shoot", "reposition", "cover", "peek", "push", "grenade", "strafe", "spacing", "angle", "hold_angle", "advance", "flank", "interception", "defensive_reposition", "relocation"];
    var _weights = [(_e.knowledge.visible && !_offscreen) ? (_weights_config.shoot_weight + (_weights_config.patience_weight * _traits.patience)) : 0, (_e.knowledge.visible && _can_move && !_strafe.enabled) ? (_weights_config.reposition_weight * _traits.reposition_preference) : 0, ((_e.knowledge.visible && !_in_cover) || (!_e.knowledge.visible && _in_cover && _combat.angle_failed && _can_move)) ? (_weights_config.cover_weight * (1 - _traits.risk_tolerance)) : 0, (_in_cover && _e.profile.config.capabilities.peek_cycle) ? _weights_config.peek_weight : 0, (_e.knowledge.visible && _can_move && !_spacing.enabled && _can_approach && _distance > (_combat.weapon_range * _weights_config.push_range_ratio) && ai_team_can_push(_e)) ? (_weights_config.push_weight * _aggression) : 0, ai_grenade_weight(_e), (_e.knowledge.visible && _can_move && !_in_cover && _strafe.enabled) ? (_strafe.weight * _traits.reposition_preference) : 0, (_e.knowledge.visible && _can_move && !_in_cover && _spacing.enabled && _spacing_direction != 0 && (_spacing_direction < 0 || (_can_approach && ai_team_can_push(_e)))) ? (_spacing.weight * ((_spacing_direction > 0) ? _aggression : (1 - _aggression))) : 0, (_hidden && _can_move && _local) ? (_engage.angle_weight * lerp(0.5, 1, _traits.reposition_preference)) : 0, _hidden ? (_engage.hold_weight * lerp(0.5, 1.5, _traits.patience)) : 0, _advance ? (_engage.advance_weight * lerp(0.5, 1.5, _aggression)) : 0, (!_e.profile.config.relocation.route_enabled && __ai_human_can_flank(arg0)) ? (_engage.flank_weight * _e.profile.config.flank.chance * _aggression) : 0, __ai_human_can_intercept(arg0) ? (_e.profile.config.interception.chance * lerp(1, _e.profile.config.interception.aggressive_chance_scale, _aggression)) : 0, (_defensive && _can_move && (_combat.defense.mode == "retreat" || _combat.defense.mode == "cover")) ? (_e.profile.config.defensive_reposition.weight * lerp(1.5, 0.5, (_traits.aggression + _traits.risk_tolerance) * 0.5)) : 0, __ai_human_relocation_weight(_e)];
    var _risk = lerp(1, _e.profile.config.suppression.risk_floor, __ai_human_pressure(_e));
    var _risky = [3, 4, 8, 10, 11, 14];
    for (var _i = 0; _i < array_length(_risky); _i++)
    {
        _weights[_risky[_i]] *= _risk;
    }
    var _failed_peek = _combat.adaptation.peek_target == _e.knowledge.target && _combat.adaptation.peek_failures >= _e.profile.config.peek_reposition.failed_attempts;
    if (_weights[14] > 0)
    {
        if (_combat.angle_failed || _failed_peek)
        {
            _weights[8] *= 0.25;
        }
        if (_failed_peek)
        {
            _weights[3] = 0;
        }
        if (__ai_hunter_enabled(_e) && _e.combat.hunter.cover_peeks >= _e.profile.config.hunter.cover_peek_limit)
        {
            _weights[3] = 0;
        }
        if (__ai_human_maneuver_reason(_e) == "stalled_contact")
        {
            _weights[8] *= 0.25;
            _weights[9] *= _e.profile.config.flank_opportunity.hold_multiplier;
            _weights[12] *= _e.profile.config.flank_opportunity.hold_multiplier;
            _weights[3] *= _e.profile.config.flank_opportunity.hold_multiplier;
        }
    }
    if (_defensive && _in_cover)
    {
        _weights[3] *= _e.profile.config.defensive_reposition.watch_peek_multiplier;
    }
    var _assessment = (_focus != _e.knowledge) ? undefined : ai_cover_current(_e);
    var _assessment_config = _e.profile.config.cover_assessment;
    if (_hidden && is_struct(_assessment))
    {
        if (_assessment.kind == "isolated")
        {
            _weights[8] *= _assessment_config.isolated_angle_multiplier;
            _weights[10] *= _assessment_config.isolated_advance_multiplier;
            _weights[11] *= _assessment_config.isolated_flank_multiplier;
            _weights[14] *= _assessment_config.isolated_flank_multiplier;
        }
        else if (_assessment.kind == "continuous")
        {
            _weights[9] *= _assessment_config.continuous_hold_multiplier;
        }
    }
    var _v = _e.profile.config.vulnerability;
    var _press = lerp(1, _v.approach_multiplier, _pressure);
    _weights[4] *= _press;
    _weights[10] *= _press;
    _weights[11] *= _press;
    if (_spacing_direction > 0)
    {
        _weights[7] *= _press;
    }
    _weights[9] *= lerp(1, _v.hold_multiplier, _pressure);
    _weights[12] *= lerp(1, _v.hold_multiplier, _pressure);
    if (_pressure > 0)
    {
        _combat.decision_reason = "observed_wound_pressure";
    }
    if (_heard)
    {
        var _hearing = _e.profile.config.hearing;
        var _response = variable_struct_get(_hearing, _e.profile.config.training + "_scale");
        _weights[10] *= _hearing.approach_multiplier * _response;
        _weights[11] *= _hearing.approach_multiplier * _response;
        _weights[14] *= _hearing.approach_multiplier * _response;
        _weights[9] *= lerp(1, 0.5, _response);
        _combat.decision_reason = "heard_movement";
    }
    var _total = 0;
    for (var _i = 0; _i < array_length(_weights); _i++)
    {
        if (_e.now < variable_struct_get(_combat.cooldowns, _names[_i]))
        {
            _weights[_i] = 0;
        }
    }
    if (_e.profile.config.relocation.route_enabled && _weights[14] > 0)
    {
        _weights[14] = max(_weights[14], _weights[8]);
        _weights[8] = 0;
        if (_opening.repeating && __ai_human_can_scatter(arg0))
        {
            _weights[14] *= 1 + _traits.reposition_preference;
        }
    }
    var _intercept_weight = _weights[12];
    var _hold_weight = _weights[9];
    _weights[9] = max(_hold_weight, _intercept_weight);
    _weights[12] = 0;
    if (_outranged)
    {
        var _returning_fire = ai_commands_returning_fire(_e);
        if (!_returning_fire && __ai_human_pressure(_e) > 0)
        {
            _weights[2] *= _e.profile.config.firing.outranged_cover_multiplier;
        }
        var _alternatives = 0;
        for (var _i = 1; _i < array_length(_weights); _i++)
        {
            _alternatives += _weights[_i];
        }
        if (_alternatives > 0)
        {
            var _shoot_multiplier = 0;
            if (_returning_fire)
            {
                _shoot_multiplier = _e.profile.config.firing.return_fire_shoot_multiplier;
            }
            else if (ai_commands_outranged_fire_allowed(_e, _e.knowledge.target))
            {
                _shoot_multiplier = _e.profile.config.firing.outranged_shoot_multiplier;
            }
            _weights[0] *= _shoot_multiplier;
            _combat.decision_reason = _returning_fire ? "outranged_return_fire" : "out_of_effective_range";
        }
    }
    for (var _i = 0; _i < array_length(_weights); _i++)
    {
        _total += _weights[_i];
    }
    if (_total <= 0)
    {
        if (!_hidden && !_offscreen)
        {
            _combat.engaging = false;
            return UnknownEnum.Value_2;
        }
        _combat.tactic = "hold_angle";
        _combat.decision_reason = _offscreen ? "camera_fire_blocked" : "waiting_for_useful_action";
        return UnknownEnum.Value_1;
    }
    var _choice = ai_profile_random(_e.rng) * _total;
    for (var _i = 0; _i < array_length(_weights); _i++)
    {
        _choice -= _weights[_i];
        if (sign(_choice) < 0)
        {
            _combat.tactic = _names[_i];
            break;
        }
    }
    if (_combat.tactic == "hold_angle" && _intercept_weight > 0 && ai_profile_random(_e.rng) < (_intercept_weight / max(0.001, _hold_weight + _intercept_weight)))
    {
        _combat.tactic = "interception";
    }
    if (_combat.tactic == "relocation")
    {
        _combat.decision_reason = __ai_human_relocation_reason(_e);
    }
    if (_combat.tactic == "defensive_reposition")
    {
        _combat.decision_reason = "unsupported_" + _combat.defense.mode;
    }
    return UnknownEnum.Value_1;
}

function __ai_human_position_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    arg0.user_data.combat.committed = true;
    arg1.data.result = undefined;
    arg1.data.cover_fire = false;
    arg1.data.arrived_at = -1;
    arg1.data.tactic = arg0.user_data.combat.tactic;
    var _e = arg0.user_data;
    var _k = ai_contact_focus(_e);
    arg1.data.threat = 
    {
        valid: _k.valid,
        target: _k.target,
        x: _k.x,
        y: _k.y,
        revision: _k.revision
    };
    arg1.data.kind = (arg1.data.tactic == "cover" && is_struct(_e.combat.cover) && point_distance(_e.npc.x, _e.npc.y, _e.combat.cover.x, _e.combat.cover.y) <= 6) ? "cover_move" : arg1.data.tactic;
    if (arg1.data.tactic == "push" && __ai_hunter_enabled(_e) && _e.combat.hunter.intent == "pressure")
    {
        arg1.data.kind = "advance";
    }
    arg1.data.until = _e.now + 8;
    arg1.data.permit = arg1.data.tactic != "push" || ai_team_begin_push(arg0.user_data, arg1.token);
    if (arg1.data.tactic == "push" && arg1.data.permit)
    {
        __ai_human_push_callout(_e);
    }
}

function __ai_human_push_callout(arg0)
{
    var _wound = arg0.perception.wound;
    var _target_backing_off = is_struct(_wound) && _wound.target == arg0.knowledge.target && (arg0.now - _wound.retreat_at) <= arg0.profile.config.vulnerability.memory_seconds;
    if (_target_backing_off && ai_compat_callout(arg0.npc, "push_weak_target"))
    {
        exit;
    }
    ai_compat_callout(arg0.npc, "push");
}

function __ai_human_position(arg0, arg1)
{
    var _e = arg0.user_data;
    if (arg1.data.tactic == "push" && __ai_hunter_enabled(_e) && __ai_hunter_risk_bad(_e))
    {
        return UnknownEnum.Value_1;
    }
    if (!arg1.data.permit || !_e.knowledge.valid || _e.knowledge.target != arg1.data.threat.target || _e.now >= arg1.data.until)
    {
        return UnknownEnum.Value_2;
    }
    var _focus = ai_contact_focus(_e);
    ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    if (is_undefined(arg1.data.result))
    {
        var _result = ai_spatial_query(_e, arg1.data.kind, arg1.token, arg1.data.threat);
        if (_result.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_result.status != "FOUND" || !ai_spatial_claim(_e, _result, arg1.token))
        {
            return UnknownEnum.Value_2;
        }
        arg1.data.result = _result;
        arg1.data.cover_fire = arg1.data.tactic == "cover" && _e.knowledge.visible && variable_struct_exists(_result, "route_length") && _result.route_length <= _e.profile.config.firing.cover_fire_distance_px;
        arg1.data.run = (arg1.data.tactic == "cover" && !arg1.data.cover_fire) || !_e.knowledge.visible || (arg1.data.tactic == "push" && !ai_commands_in_effective_range(_e, _e.knowledge.x, _e.knowledge.y) && !ai_commands_returning_fire(_e));
        arg1.data.until = _e.now + ai_commands_travel_seconds(_e, _result, arg1.data.run) + 1;
    }
    var _position = arg1.data.result;
    var _valid = ai_spatial_progress(_e, arg1, _position);
    if (_valid == "waiting")
    {
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid")
    {
        return UnknownEnum.Value_2;
    }
    var _walking_fire = _e.knowledge.visible && (arg1.data.tactic == "push" || arg1.data.tactic == "reposition" || arg1.data.cover_fire);
    var _speed = ai_commands_transfer_speed(_e, _position, arg1.data.run);
    var _move = ai_commands_move_position(_e, arg1.token, _position, _speed, 1);
    if (_move == "failed")
    {
        return UnknownEnum.Value_2;
    }
    if (_walking_fire)
    {
        ai_commands_fire(_e, arg1.token, _e.knowledge);
    }
    if (_move == "arrived")
    {
        if (arg1.data.tactic != "cover")
        {
            return UnknownEnum.Value_1;
        }
        _e.combat.cover = _position;
        if (arg1.data.kind == "cover_move")
        {
            _e.combat.angle_failed = false;
        }
        if (arg1.data.arrived_at < 0)
        {
            arg1.data.arrived_at = _e.now;
        }
        if ((_e.now - arg1.data.arrived_at) >= (0.25 + (_e.profile.personality.traits.patience * 0.5)))
        {
            return UnknownEnum.Value_1;
        }
    }
    return UnknownEnum.Value_0;
}

function __ai_human_peek_enter(arg0, arg1)
{
    __ai_human_position_enter(arg0, arg1);
    arg1.data.tactic = "peek";
    arg1.data.phase = "query";
    arg1.data.exposed_at = -1;
    var _e = arg0.user_data;
    var _npc = _e.npc;
    var _peek = _e.profile.config.peek;
    if (__ai_hunter_enabled(_e))
    {
        var _hunter = _e.combat.hunter;
        if (point_distance(_npc.x, _npc.y, _hunter.peek_x, _hunter.peek_y) > 32)
        {
            _hunter.cover_peeks = 0;
        }
        _hunter.cover_peeks++;
        _hunter.peek_x = _npc.x;
        _hunter.peek_y = _npc.y;
    }
    var _trained = !__ai_profile_contains(["rookie", "intermediate"], _e.profile.config.training);
    arg1.data.fire = ai_profile_random(_e.rng) < (_peek.fire_chance * (_trained ? 1 : 0.75));
    arg1.data.quick = __ai_hunter_enabled(_e) && !arg1.data.fire;
    arg1.data.visible_until = -1;
    var _distance = point_distance(_npc.x, _npc.y, _e.knowledge.x, _e.knowledge.y);
    var _reaction = max(0, _npc.reflexes_minimum + lerp(_npc.reflexes_distance_min, _npc.reflexes_distance_max, clamp(_distance / 180, 0, 1)) + max(_npc.reflexes_angle_min, _npc.reflexes_angle_max)) / 60;
    arg1.data.exposure_seconds = arg1.data.fire ? min(_peek.fire_max_seconds, max(_peek.fire_min_seconds, _reaction + _peek.reaction_extra_seconds) + (ai_profile_random(_e.rng) * _peek.variation_seconds)) : lerp(_peek.feint_min_seconds, _peek.feint_max_seconds, ai_profile_random(_e.rng));
    if (arg1.data.quick)
    {
        arg1.data.exposure_seconds = lerp(_e.profile.config.hunter.peek_min_seconds, _e.profile.config.hunter.peek_max_seconds, ai_profile_random(_e.rng));
    }
    arg1.data.first_shot_at = -1;
    arg1.data.shots = 0;
    _e.combat.peek_return = true;
}

function __ai_human_peek(arg0, arg1)
{
    var _e = arg0.user_data;
    var _focus = ai_contact_focus(_e);
    if ((_e.now - arg1.started_at) >= _e.profile.config.peek.deadline_seconds)
    {
        return UnknownEnum.Value_2;
    }
    if (_focus.valid)
    {
        ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    }
    if (arg1.data.phase == "query")
    {
        var _result = ai_spatial_query(_e, "peek", arg1.token, arg1.data.threat);
        if (_result.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_result.status != "FOUND" || !ai_spatial_claim(_e, _result, arg1.token))
        {
            return UnknownEnum.Value_2;
        }
        arg1.data.result = _result;
        arg1.data.phase = "wait";
        arg1.data.until = _e.now + (lerp(_e.profile.config.peek.wait_min_seconds, _e.profile.config.peek.wait_max_seconds, _e.profile.personality.traits.patience) * (__ai_hunter_enabled(_e) ? 0.5 : (__ai_profile_contains(["rookie", "intermediate"], _e.profile.config.training) ? 1.4 : 1)));
    }
    var _position = arg1.data.result;
    if (arg1.data.phase == "wait")
    {
        _e.combat.peek_return = false;
        var _opening = __ai_human_opening_ready(arg0);
        _e.combat.peek_return = true;
        if (_opening)
        {
            return UnknownEnum.Value_1;
        }
        ai_commands_stop(_e, arg1.token);
        var _valid = ai_spatial_progress(_e, arg1, _position, true);
        if (_valid == "waiting")
        {
            return UnknownEnum.Value_0;
        }
        if (_valid != "valid")
        {
            return UnknownEnum.Value_2;
        }
        if (_e.now < arg1.data.until)
        {
            return UnknownEnum.Value_0;
        }
        var _speed = __ai_human_speed(_e);
        if (_speed <= 0)
        {
            return UnknownEnum.Value_2;
        }
        if (!arg1.data.quick && (((2 * _position.route_length) / (_speed * 60)) + (1/30)) > arg1.data.exposure_seconds)
        {
            return UnknownEnum.Value_2;
        }
        if (arg1.data.quick)
        {
            arg1.data.quick_deadline = _e.now + (_position.route_length / (_speed * 60)) + arg1.data.exposure_seconds + 0.15;
        }
        arg1.data.phase = "out";
        arg1.data.exposed_at = _e.now;
    }
    if (arg1.data.phase == "out" || arg1.data.phase == "exposed")
    {
        var _speed = __ai_human_speed(_e);
        var _return_seconds = (_speed > 0) ? ((_position.route_length / (_speed * 60)) + (1/30)) : 0.5;
        var _timed_out = ((_e.now - arg1.data.exposed_at) + _return_seconds) >= arg1.data.exposure_seconds;
        if (arg1.data.quick)
        {
            if (arg1.data.visible_until < 0 && (_e.knowledge.visible || arg1.data.phase == "exposed"))
            {
                arg1.data.visible_until = _e.now + arg1.data.exposure_seconds;
            }
            _timed_out = _e.now >= arg1.data.quick_deadline || (arg1.data.visible_until >= 0 && _e.now >= arg1.data.visible_until);
        }
        if (_timed_out || !_e.knowledge.valid || _e.npc.ammo_now <= 0 || !ai_spatial_validate(_e, _position))
        {
            arg1.data.phase = "return";
            ai_commands_stop(_e, arg1.token);
        }
    }
    if (arg1.data.phase == "out")
    {
        var _move = ai_commands_move(_e, arg1.token, _position.x, _position.y, __ai_human_speed(_e), 1);
        if (_move == "arrived")
        {
            arg1.data.phase = "exposed";
        }
        else if (_move == "failed")
        {
            arg1.data.phase = "return";
            ai_commands_stop(_e, arg1.token);
        }
    }
    if (arg1.data.phase == "exposed")
    {
        ai_commands_stop(_e, arg1.token);
        if (ai_commands_aim(_e, arg1.token, _focus.x, _focus.y))
        {
            if (!ai_perception_can_fire(_e))
            {
                arg1.data.phase = "return";
            }
            else if (arg1.data.fire && ai_commands_fire(_e, arg1.token, _e.knowledge))
            {
                if (arg1.data.first_shot_at < 0)
                {
                    arg1.data.first_shot_at = _e.now;
                }
                arg1.data.shots++;
            }
        }
    }
    if (arg1.data.phase == "exposed" && arg1.data.first_shot_at >= 0 && (arg1.data.shots >= _e.profile.config.peek.shots || (_e.now - arg1.data.first_shot_at) >= _e.profile.config.peek.burst_seconds))
    {
        arg1.data.phase = "return";
    }
    if (arg1.data.phase == "return")
    {
        if (_e.commands.last_fire_step == _e.step)
        {
            return UnknownEnum.Value_0;
        }
        var _valid = ai_spatial_progress(_e, arg1, _position, true);
        if (_valid == "waiting")
        {
            return UnknownEnum.Value_0;
        }
        if (_valid != "valid")
        {
            _e.combat.cover = undefined;
            return UnknownEnum.Value_2;
        }
        var _move = ai_commands_move(_e, arg1.token, _position.cover_x, _position.cover_y, __ai_human_speed(_e), 1);
        if (_move == "arrived")
        {
            return UnknownEnum.Value_1;
        }
        if (_move == "failed")
        {
            _e.combat.cover = undefined;
            return UnknownEnum.Value_2;
        }
    }
    return UnknownEnum.Value_0;
}

function __ai_human_tactic_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    if (arg1.data.tactic == "peek")
    {
        var _a = _e.combat.adaptation;
        if (_a.peek_target != _e.knowledge.target)
        {
            _a.peek_failures = 0;
        }
        _a.peek_target = _e.knowledge.target;
        if (arg1.data.shots > 0)
        {
            _a.peek_failures = 0;
        }
        else if (arg1.data.fire && (arg2 == "success" || arg2 == "failure" || arg2 == "timeout"))
        {
            _a.peek_failures++;
            if (_a.peek_failures >= _e.profile.config.peek_reposition.failed_attempts)
            {
                __ai_human_memory_pressure(_e, "failed_peek");
            }
        }
    }
    _e.combat.committed = false;
    _e.combat.peek_return = false;
    ai_spatial_release(_e);
    ai_team_release(_e);
    var _cooldown = (arg2 == "success") ? ((arg1.data.tactic == "peek") ? 0 : 0.5) : 1;
    variable_struct_set(_e.combat.cooldowns, arg1.data.tactic, _e.now + _cooldown);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_hit_schedule(arg0, arg1, arg2)
{
    __ai_human_pressure_add(arg0, arg1, arg2, true);
    if (arg0.knowledge.valid && arg0.knowledge.target == arg1.target)
    {
        __ai_human_memory_pressure(arg0, "position_under_fire", arg2);
    }
    var _h = arg0.bridge.hit;
    if (_h.pending || _h.active)
    {
        exit;
    }
    var _tier = arg0.profile.config.training;
    var _hit = arg0.profile.config.hit_reaction;
    _h.surprised = false;
    if (_hit.directional_enabled)
    {
        if (arg0.now < _h.cooldown_until)
        {
            exit;
        }
        var _angle = variable_struct_exists(arg1, "hit_angle") ? arg1.hit_angle : abs(angle_difference(point_direction(arg0.npc.x, arg0.npc.y, arg1.x, arg1.y), arg0.npc.weapon_pointing_direction));
        var _distance = variable_struct_exists(arg1, "hit_distance") ? arg1.hit_distance : point_distance(arg0.npc.x, arg0.npc.y, arg1.x, arg1.y);
        if (_angle <= _hit.fire_angle_degrees && _distance <= arg0.combat.weapon_range && !arg0.npc.reloading && arg0.npc.ammo_now > 0)
        {
            exit;
        }
        var _lower = _tier == "rookie" || _tier == "intermediate";
        var _rear_far = _angle >= _hit.rear_angle_degrees && _distance >= _hit.far_distance_px;
        var _unseen_shooter = _hit.unseen_shooter_enabled && !(arg0.knowledge.visible && arg0.knowledge.target == arg1.target);
        if (arg0.knowledge.valid && !_lower && !_rear_far && !_unseen_shooter)
        {
            exit;
        }
        _h.surprised = _angle > _hit.fire_angle_degrees;
        _h.cooldown_until = arg0.now + _hit.cooldown_seconds;
    }
    else if (arg0.knowledge.valid)
    {
        exit;
    }
    var _minimum = _hit.rookie_min_seconds;
    var _maximum = _hit.rookie_max_seconds;
    if (_tier == "master" || _tier == "veteran")
    {
        _minimum = _hit.master_min_seconds;
        _maximum = _hit.master_max_seconds;
    }
    else if (_tier == "skilled" || _tier == "expert")
    {
        _minimum = _hit.skilled_min_seconds;
        _maximum = _hit.skilled_max_seconds;
    }
    _h.pending = true;
    _h.ready_at = arg0.now + max(0, lerp(_minimum, _maximum, ai_profile_random(arg0.rng)) - arg2);
    _h.expires = arg0.now + _hit.pending_seconds;
    _h.threat = 
    {
        valid: true,
        target: arg1.target,
        x: arg1.x,
        y: arg1.y,
        revision: 0
    };
}

function __ai_human_hit_step(arg0)
{
    var _h = arg0.bridge.hit;
    if (!_h.pending || _h.active || !__ai_bt_due(arg0.now, _h.ready_at))
    {
        return false;
    }
    if (arg0.now >= _h.expires || !__ai_perception_hostile(arg0.npc, _h.threat.target))
    {
        _h.pending = false;
        return false;
    }
    var _cover = arg0.combat.cover;
    var _threat = _h.threat;
    var _safe = is_struct(_cover) && point_distance(arg0.npc.x, arg0.npc.y, _cover.x, _cover.y) <= 6 && !__ai_spatial_clear_line(arg0.npc.x, arg0.npc.y, _threat.x, _threat.y);
    var _index = arg0.tree_context._active_action;
    if (_index >= 0)
    {
        var _slot = arg0.tree_context._slots[_index];
        var _data = _slot.data;
        var _name = arg0.tree_context.tree.nodes[_index].name;
        if (_name == "danger" || _name == "withdraw")
        {
            _safe = true;
        }
        if (arg0.commands.moving)
        {
            if (_name == "position" && _data.tactic == "cover")
            {
                _safe = !__ai_spatial_clear_line(arg0.commands.goal_x, arg0.commands.goal_y, _threat.x, _threat.y);
            }
            if (_name == "reload" && (_data.phase == "reload_cover" || _data.phase == "retreat"))
            {
                _safe = point_distance(arg0.commands.goal_x, arg0.commands.goal_y, _threat.x, _threat.y) >= point_distance(arg0.npc.x, arg0.npc.y, _threat.x, _threat.y);
            }
            if (_name == "peek" && _data.phase == "return")
            {
                _safe = !__ai_spatial_clear_line(arg0.commands.goal_x, arg0.commands.goal_y, _threat.x, _threat.y);
            }
        }
    }
    if (_safe)
    {
        _h.pending = false;
        return false;
    }
    return true;
}

function __ai_human_hit_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    _e.bridge.hit.pending = false;
    _e.bridge.hit.active = true;
    _e.combat.scatter.panic = false;
    _e.combat.scatter.pending = false;
    _e.combat.blocked_until = 0;
    arg1.data.threat = _e.bridge.hit.threat;
    arg1.data.phase = "hit_cover";
    arg1.data.result = undefined;
    arg1.data.until = _e.now + _e.profile.config.hit_reaction.active_seconds;
    arg1.data.avoid_threat_aim = _e.bridge.hit.surprised;
    ai_compat_callout(_e.npc, "hit");
}

function __ai_human_hit_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    if (_e.now >= _d.until || !__ai_perception_hostile(_e.npc, _d.threat.target))
    {
        return UnknownEnum.Value_1;
    }
    if (variable_struct_exists(_d, "avoid_threat_aim") && _d.avoid_threat_aim)
    {
        _e.commands.aim = false;
    }
    else
    {
        ai_commands_aim(_e, arg1.token, _d.threat.x, _d.threat.y);
    }
    if (is_undefined(_d.result))
    {
        var _result = ai_spatial_query(_e, _d.phase, arg1.token, _d.threat);
        if (_result.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_result.status == "FOUND" && ai_spatial_claim(_e, _result, arg1.token))
        {
            _d.result = _result;
            if (_e.profile.config.hit_reaction.directional_enabled)
            {
                _d.until = _e.now + ai_commands_travel_seconds(_e, _result, true, _e.profile.config.hit_reaction.active_seconds);
            }
        }
        else if (_d.phase == "hit_cover")
        {
            ai_spatial_release(_e);
            _d.phase = "retreat";
            return UnknownEnum.Value_0;
        }
        else
        {
            return UnknownEnum.Value_1;
        }
    }
    if (!ai_spatial_validate(_e, _d.result))
    {
        return UnknownEnum.Value_1;
    }
    var _move = ai_commands_move(_e, arg1.token, _d.result.x, _d.result.y, __ai_human_speed(_e), 2);
    if (_move == "arrived")
    {
        if (_d.phase == "hit_cover")
        {
            _e.combat.cover = _d.result;
        }
        return UnknownEnum.Value_1;
    }
    return (_move == "failed") ? UnknownEnum.Value_1 : UnknownEnum.Value_0;
}

function __ai_human_hit_exit(arg0, arg1, arg2)
{
    arg0.user_data.bridge.hit.active = false;
    ai_spatial_release(arg0.user_data);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_spacing_direction(arg0, arg1)
{
    var _c = arg0.profile.config.spacing;
    var _range = arg0.combat.weapon_range;
    if (arg1 > ((_range * _c.far_ratio) + _c.hysteresis_px))
    {
        return 1;
    }
    if (arg1 < max(0, (_range * _c.near_ratio) - _c.hysteresis_px))
    {
        return -1;
    }
    return 0;
}

function __ai_human_combat_move_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    _d.tactic = _e.combat.tactic;
    _d.config = variable_struct_get(_e.profile.config, _d.tactic);
    _d.threat = 
    {
        valid: _k.valid,
        target: _k.target,
        x: _k.x,
        y: _k.y,
        revision: _k.revision
    };
    _d.direction = __ai_human_spacing_direction(_e, point_distance(_e.npc.x, _e.npc.y, _k.x, _k.y));
    _d.kind = (_d.tactic == "strafe") ? "strafe" : ((_d.direction > 0) ? "space_in" : "space_out");
    _d.result = undefined;
    _d.phase = "move";
    _d.lost_at = -1;
    _d.arrived = false;
    _d.run = false;
    _d.origin_x = _e.npc.x;
    _d.origin_y = _e.npc.y;
    _d.until = _e.now + _d.config.move_seconds;
    _d.permit = _d.kind != "space_in" || ai_team_begin_push(_e, arg1.token);
    _e.combat.committed = true;
}

function __ai_human_combat_move(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    if (!_k.valid || _k.target != _d.threat.target || _e.npc.ammo_now <= 0)
    {
        return UnknownEnum.Value_1;
    }
    if (_k.visible)
    {
        _d.lost_at = -1;
    }
    else
    {
        if (_d.lost_at < 0)
        {
            _d.lost_at = _e.now;
        }
        if ((_e.now - _d.lost_at) >= 0.2)
        {
            return UnknownEnum.Value_1;
        }
    }
    ai_commands_aim(_e, arg1.token, _k.x, _k.y);
    if (_d.phase == "move")
    {
        var _distance = point_distance(_e.npc.x, _e.npc.y, _k.x, _k.y);
        var _comfortable = _d.tactic == "spacing" && (_d.direction == 0 || (_d.direction > 0) ? (_distance <= (_e.combat.weapon_range * _d.config.far_ratio)) : (_distance >= (_e.combat.weapon_range * _d.config.near_ratio)));
        if (!_d.permit || _comfortable || _e.now >= _d.until)
        {
            _d.phase = "settle";
        }
        else
        {
            if (is_undefined(_d.result))
            {
                var _result = ai_spatial_query(_e, _d.kind, arg1.token, _d.threat);
                if (_result.status == "FOUND" && ai_spatial_claim(_e, _result, arg1.token))
                {
                    _d.result = _result;
                    _d.run = _d.tactic == "spacing" && _result.route_length >= 48;
                    _d.until = _e.now + ai_commands_travel_seconds(_e, _result, _d.run, _d.config.move_seconds);
                }
                else if (_result.status != "DEFERRED")
                {
                    _d.phase = "settle";
                }
            }
            if (is_struct(_d.result))
            {
                var _valid = ai_spatial_progress(_e, arg1, _d.result);
                if (_valid == "waiting")
                {
                    return UnknownEnum.Value_0;
                }
                if (_valid != "valid")
                {
                    _d.phase = "settle";
                }
                else
                {
                    var _move = ai_commands_move_position(_e, arg1.token, _d.result, ai_commands_transfer_speed(_e, _d.result, _d.run), 2);
                    _d.arrived = _move == "arrived";
                    if (_move == "arrived" || _move == "failed")
                    {
                        _d.phase = "settle";
                    }
                }
            }
        }
        if (_d.phase == "settle")
        {
            ai_commands_stop(_e, arg1.token);
            ai_spatial_release(_e);
            ai_team_release(_e);
            _d.until = _e.now + ((_d.arrived || _comfortable) ? _d.config.pause_seconds : 0);
        }
    }
    else
    {
        ai_commands_stop(_e, arg1.token);
    }
    ai_commands_fire(_e, arg1.token, _k);
    return (_d.phase == "settle" && _e.now >= _d.until) ? UnknownEnum.Value_1 : UnknownEnum.Value_0;
}

function __ai_human_combat_move_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    _e.combat.committed = false;
    if (_d.phase == "settle")
    {
        _e.combat.movement_until = max(_e.combat.movement_until, _d.until);
    }
    var _moved = point_distance(_d.origin_x, _d.origin_y, _e.npc.x, _e.npc.y) >= 8;
    variable_struct_set(_e.combat.cooldowns, _d.tactic, _e.now + (_moved ? _d.config.cooldown_seconds : 0.5));
    ai_spatial_release(_e);
    ai_team_release(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_can_intercept(arg0)
{
    var _e = arg0.user_data;
    var _k = _e.knowledge;
    var _c = _e.profile.config.interception;
    if (__ai_human_pursuit_committed(_e) || !_e.combat.advanced || !_c.enabled || !_k.valid || _k.visible || !__ai_human_ready(_e) || _e.now < _e.withdrawal.until || ai_scene_assignments_force_shoot(_e))
    {
        return false;
    }
    if (_e.combat.intercept_active)
    {
        return true;
    }
    var _focus = ai_contact_focus(_e);
    return (_k.source == "sight" || _k.source == "ally_report") && _k.observed_at > _e.combat.intercept_observed_at && (_e.now - _k.observed_at) <= _c.memory_age_seconds && _e.now >= _e.combat.cooldowns.interception && point_distance(_e.npc.x, _e.npc.y, _focus.x, _focus.y) <= (_e.combat.weapon_range * _c.range_ratio);
}

function __ai_human_intercept_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = ai_contact_focus(_e);
    var _c = _e.profile.config.interception;
    var _aggression = _e.profile.personality.traits.aggression;
    _e.combat.intercept_active = true;
    _e.combat.intercept_observed_at = _e.knowledge.observed_at;
    _d.threat = 
    {
        valid: true,
        target: _k.target,
        x: _k.x,
        y: _k.y,
        revision: _k.revision
    };
    _d.skip = !_e.combat.engaging && ai_profile_random(_e.rng) >= (_c.chance * lerp(1, _c.aggressive_chance_scale, _aggression));
    _d.result = undefined;
    _d.phase = "move";
    _d.until = _e.now + _c.move_seconds;
    _d.hold_seconds = lerp(_c.hold_max_seconds, _c.hold_min_seconds, _aggression);
}

function __ai_human_intercept(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    if (_d.phase == "hold" && __ai_human_opening_ready(arg0))
    {
        return UnknownEnum.Value_1;
    }
    if (_d.skip || !_k.valid || _k.visible || _k.target != _d.threat.target || _e.now >= _d.until)
    {
        return UnknownEnum.Value_1;
    }
    if (is_undefined(_d.result))
    {
        var _result = ai_spatial_query(_e, "interception", arg1.token, _d.threat);
        if (_result.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_result.status != "FOUND" || !ai_spatial_claim(_e, _result, arg1.token))
        {
            return UnknownEnum.Value_1;
        }
        _d.result = _result;
        _d.until = _e.now + ai_commands_travel_seconds(_e, _result, true, _e.profile.config.interception.move_seconds);
    }
    var _p = _d.result;
    var _valid = ai_spatial_progress(_e, arg1, _p);
    if (_valid == "waiting")
    {
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid" || !__ai_spatial_clear_line(_p.x, _p.y, _p.watch_x, _p.watch_y))
    {
        return UnknownEnum.Value_1;
    }
    ai_commands_aim(_e, arg1.token, _p.watch_x, _p.watch_y);
    if (_d.phase == "move")
    {
        var _move = ai_commands_move_position(_e, arg1.token, _p, ai_commands_transfer_speed(_e, _p), 2);
        if (_move == "failed")
        {
            return UnknownEnum.Value_1;
        }
        if (_move == "arrived")
        {
            _d.phase = "hold";
            _d.until = _e.now + _d.hold_seconds;
        }
    }
    else
    {
        ai_commands_stop(_e, arg1.token);
    }
    return UnknownEnum.Value_0;
}

function __ai_human_intercept_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    _e.combat.intercept_active = false;
    _e.combat.cooldowns.interception = _e.now + _e.profile.config.interception.cooldown_seconds;
    ai_spatial_release(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_adapt_reset(arg0)
{
    if (!variable_struct_exists(arg0.combat, "adaptation"))
    {
        exit;
    }
    var _a = arg0.combat.adaptation;
    _a.flash_cue = undefined;
    _a.heal_cue = undefined;
    _a.reload_cue = undefined;
    _a.peek_failures = 0;
    _a.peek_target = -4;
    _a.miss_count = 0;
    _a.miss_threat = undefined;
    arg0.combat.angle_failed = false;
    arg0.combat.memory = undefined;
    arg0.combat.approach = undefined;
    arg0.combat.maneuver = undefined;
}

function __ai_human_adapt_ready(arg0, arg1)
{
    if (arg1 != "suppression" && arg1 != "flash_push" && __ai_human_pursuit_committed(arg0))
    {
        return false;
    }
    if (!arg0.combat.advanced || !arg0.knowledge.valid || ai_scene_assignments_force_shoot(arg0) || arg0.now < arg0.withdrawal.until || arg0.combat.peek_return)
    {
        return false;
    }
    if (arg0.combat.adaptation.active == arg1)
    {
        return true;
    }
    if (arg1 == "flash_push")
    {
        return arg0.profile.config.flash_push.enabled;
    }
    return __ai_human_ready(arg0) && arg0.combat.adaptation.active == "" && arg0.now >= arg0.combat.movement_until && arg0.now >= variable_struct_get(arg0.combat.adaptation_cooldowns, arg1) && variable_struct_get(arg0.profile.config, arg1).enabled;
}

function __ai_human_reload_notice(arg0, arg1, arg2, arg3, arg4, arg5)
{
    return __ai_human_opportunity_notice(arg0, "reload_push", arg1, arg2, arg3, arg4, arg5);
}

function __ai_human_opportunity_notice(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7 = 1000, arg8 = false)
{
    var _a = arg0.combat.adaptation;
    var _c = variable_struct_get(arg0.profile.config, arg1);
    var _prefix = __ai_human_opportunity_prefix(arg1);
    var _window = min(_c.opportunity_seconds, arg7);
    var _personal = arg0.profile.config.opportunity_response;
    var _tier_chance = variable_struct_get(_personal, arg0.profile.config.training + "_chance");
    var _reaction = _c.reaction_seconds;
    if (!arg6 && _personal.enabled)
    {
        _reaction *= lerp(1, _personal.reaction_scale, _tier_chance);
    }
    if (!_c.enabled || arg5 < 0 || arg5 >= _c.opportunity_seconds || arg5 > arg0.now || (_window - arg5) <= _reaction || (arg1 != "flash_push" && arg0.now < variable_struct_get(_a, _prefix + "_seen_until")) || !__ai_perception_hostile(arg0.npc, arg2))
    {
        return false;
    }
    if (arg0.knowledge.valid && arg0.knowledge.target != arg2)
    {
        return false;
    }
    variable_struct_set(_a, _prefix + "_seen_until", arg0.now + _c.cooldown_seconds);
    var _teamwork = arg0.profile.personality.traits.teamwork;
    var _trained = __ai_profile_contains(["expert", "veteran", "master"], arg0.profile.config.training);
    var _chance = arg6 ? (_teamwork * _teamwork) : (_c.direct_chance * lerp(0.5, 1, arg0.profile.personality.traits.aggression));
    if (!arg6 && _personal.enabled)
    {
        _chance = _c.direct_chance * _tier_chance;
    }
    if (arg6 && _teamwork < _c.report_teamwork_min)
    {
        _chance = 0;
    }
    else if ((arg6 || !_personal.enabled) && _trained && _teamwork >= _c.guaranteed_teamwork)
    {
        _chance = 1;
    }
    if (arg1 == "flash_push")
    {
        _chance = _c.direct_chance;
    }
    var _allowed = _chance >= 1 || (_chance > 0 && ai_profile_random(arg0.rng) < _chance);
    if (!_allowed)
    {
        return false;
    }
    variable_struct_set(_a, _prefix + "_cue", 
    {
        target: arg2,
        x: arg3,
        y: arg4,
        valid: true,
        revision: 0,
        ready_at: arg0.now + max(0, _reaction - arg5),
        until: (arg0.now + _window) - arg5,
        reported: arg6,
        heard: arg8,
        frame: ai_world_get().frame - round(arg5 * 60)
    });
    return true;
}

function __ai_human_opportunity_prefix(arg0)
{
    return (arg0 == "flash_push") ? "flash" : ((arg0 == "heal_push") ? "heal" : "reload");
}

function __ai_human_can_heal_push(arg0)
{
    return __ai_human_can_opportunity_push(arg0, "heal_push");
}

function __ai_human_opening_ready(arg0)
{
    return __ai_human_can_flash_push(arg0) || __ai_human_can_reload_push(arg0) || __ai_human_can_heal_push(arg0);
}

function __ai_human_can_reload_push(arg0)
{
    return __ai_human_can_opportunity_push(arg0, "reload_push");
}

function __ai_human_can_flash_push(arg0)
{
    return __ai_human_can_opportunity_push(arg0, "flash_push");
}

function __ai_human_can_opportunity_push(arg0, arg1)
{
    var _e = arg0.user_data;
    var _a = _e.combat.adaptation;
    var _c = variable_struct_get(_e.profile.config, arg1);
    if (arg1 != "flash_push" && __ai_hunter_enabled(_e) && __ai_hunter_risk_bad(_e))
    {
        return false;
    }
    if (!__ai_human_adapt_ready(_e, arg1))
    {
        return false;
    }
    if (_a.active == arg1)
    {
        return true;
    }
    var _cue = variable_struct_get(_a, __ai_human_opportunity_prefix(arg1) + "_cue");
    if ((arg1 != "flash_push" && __ai_human_pressure_high(_e)) || !is_struct(_cue) || _e.now < _cue.ready_at || _e.now >= _cue.until || _cue.target != _e.knowledge.target || _e.npc.reloading || _e.npc.ammo_now <= 0)
    {
        return false;
    }
    var _distance = point_distance(_e.npc.x, _e.npc.y, _cue.x, _cue.y);
    if (arg1 == "flash_push")
    {
        return _distance > (_c.min_target_distance_px + 2) && _distance <= _c.max_target_distance_px;
    }
    return _distance >= _c.min_target_distance_px && _distance <= (_e.combat.weapon_range * _c.range_ratio) && (is_undefined(_e.combat.pursuit_allowed) || _e.combat.pursuit_allowed) && ai_team_can_push(_e);
}

function __ai_human_near_miss(arg0, arg1, arg2)
{
    __ai_human_pressure_add(arg0, arg1, arg2, false);
    var _a = arg0.combat.adaptation;
    var _c = arg0.profile.config.suppression;
    if (!_c.enabled || arg2 > _c.window_seconds || arg0.now < arg0.combat.adaptation_cooldowns.suppression || _a.miss_frame == arg1.frame)
    {
        exit;
    }
    if (_a.miss_count == 0 || (arg0.now - _a.miss_started) > _c.window_seconds || !is_struct(_a.miss_threat) || _a.miss_threat.target != arg1.target)
    {
        _a.miss_count = 0;
        _a.miss_started = arg0.now - arg2;
    }
    _a.miss_frame = arg1.frame;
    _a.miss_count++;
    if (_a.miss_count >= _c.near_misses && arg0.knowledge.target == arg1.target)
    {
        __ai_human_memory_pressure(arg0, "position_under_fire", arg2);
    }
    _a.miss_threat = 
    {
        valid: true,
        target: arg1.target,
        x: arg1.x,
        y: arg1.y,
        revision: 0
    };
}

function __ai_human_can_suppress(arg0)
{
    var _e = arg0.user_data;
    var _a = _e.combat.adaptation;
    var _c = _e.profile.config.suppression;
    if (!__ai_human_adapt_ready(_e, "suppression"))
    {
        return false;
    }
    if (_a.active == "suppression")
    {
        return true;
    }
    return is_struct(_a.miss_threat) && _a.miss_threat.target == _e.knowledge.target && _a.miss_count >= _c.near_misses && (_e.now - _a.miss_started) <= _c.window_seconds && !_e.commands.moving && __ai_spatial_clear_line(_e.npc.x, _e.npc.y, _a.miss_threat.x, _a.miss_threat.y);
}

function __ai_human_can_peek_reposition(arg0)
{
    var _e = arg0.user_data;
    var _a = _e.combat.adaptation;
    if (!__ai_human_adapt_ready(_e, "peek_reposition"))
    {
        return false;
    }
    return _a.active == "peek_reposition" || (_a.peek_target == _e.knowledge.target && _a.peek_failures >= _e.profile.config.peek_reposition.failed_attempts);
}

function __ai_human_can_flank(arg0)
{
    var _e = arg0.user_data;
    var _k = _e.knowledge;
    var _c = _e.profile.config.flank;
    if (!__ai_human_adapt_ready(_e, "flank"))
    {
        return false;
    }
    if (_e.combat.adaptation.active != "flank" && __ai_human_pressure_high(_e))
    {
        return false;
    }
    if (_e.combat.adaptation.active == "flank")
    {
        return true;
    }
    var _distance = point_distance(_e.npc.x, _e.npc.y, _k.x, _k.y);
    return (_k.source == "sight" || _k.source == "ally_report") && (_c.chance * _e.profile.personality.traits.aggression) > 0 && (_e.now - _k.observed_at) <= _c.memory_seconds && _distance >= _c.min_target_distance_px && _distance <= _c.max_target_distance_px && (is_undefined(_e.combat.pursuit_allowed) || _e.combat.pursuit_allowed) && (__ai_human_contact_fresh(_e) || _e.now < _e.combat.lost_contact.search_at) && ai_team_can_push(_e);
}

function __ai_human_adapt_enter(arg0, arg1, arg2, arg3 = false)
{
    if (!arg3)
    {
        __ai_human_action_enter(arg0, arg1);
    }
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    if (arg2 == "flank")
    {
        _k = ai_contact_focus(_e);
    }
    _d.kind = arg2;
    _d.config = variable_struct_get(_e.profile.config, arg2);
    _d.origin_x = _e.npc.x;
    _d.origin_y = _e.npc.y;
    _d.threat = 
    {
        valid: true,
        target: _k.target,
        x: _k.x,
        y: _k.y,
        revision: _k.revision
    };
    _d.until = _e.now + _d.config.move_seconds;
    _d.result = undefined;
    _d.skip = false;
    _d.started_visible = _k.visible;
    _d.route_mode = false;
    _d.close_aim_watch = arg2 == "relocation" || arg2 == "flank";
    _d.fighting = false;
    _e.combat.adaptation.active = arg2;
    if (arg2 != "scatter")
    {
        variable_struct_set(_e.combat.adaptation_cooldowns, arg2, _e.now + _d.config.cooldown_seconds);
    }
}

function __ai_human_heal_push_enter(arg0, arg1)
{
    __ai_human_opportunity_push_enter(arg0, arg1, "heal_push");
}

function __ai_human_reload_push_enter(arg0, arg1)
{
    __ai_human_opportunity_push_enter(arg0, arg1, "reload_push");
}

function __ai_human_flash_push_enter(arg0, arg1)
{
    __ai_human_opportunity_push_enter(arg0, arg1, "flash_push");
}

function __ai_human_opportunity_push_enter(arg0, arg1, arg2)
{
    __ai_human_adapt_enter(arg0, arg1, arg2);
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _key = __ai_human_opportunity_prefix(arg2) + "_cue";
    var _cue = variable_struct_get(_e.combat.adaptation, _key);
    if (!is_struct(_cue) || _cue.target != _e.knowledge.target || _cue.until <= _e.now)
    {
        _d.skip = true;
        exit;
    }
    _d.threat = _cue;
    _d.until = min(_d.until, _d.threat.until);
    variable_struct_set(_e.combat.adaptation, _key, undefined);
    _d.skip = arg2 != "flash_push" && (!__ai_human_pursuit_allowed(_e) || !ai_team_begin_push(_e, arg1.token));
    if (!_d.skip)
    {
        __ai_human_push_callout(_e);
    }
}

function __ai_human_suppression_enter(arg0, arg1)
{
    __ai_human_adapt_enter(arg0, arg1, "suppression");
    var _e = arg0.user_data;
    arg1.data.threat = _e.combat.adaptation.miss_threat;
    _e.combat.adaptation.miss_count = 0;
}

function __ai_human_peek_reposition_enter(arg0, arg1)
{
    __ai_human_adapt_enter(arg0, arg1, "peek_reposition");
    arg0.user_data.combat.adaptation.peek_failures = 0;
    __ai_human_pursuit_allowed(arg0.user_data);
}

function __ai_human_flank_enter(arg0, arg1)
{
    __ai_human_adapt_enter(arg0, arg1, "flank");
    var _e = arg0.user_data;
    var _d = arg1.data;
    _d.skip = !__ai_human_pursuit_allowed(_e) || (!_e.combat.engaging && ai_profile_random(_e.rng) >= (_d.config.chance * _e.profile.personality.traits.aggression)) || !ai_team_begin_push(_e, arg1.token);
    if (!_d.skip && _e.profile.config.relocation.route_enabled)
    {
        __ai_human_route_enter(arg0, arg1);
    }
    if (!_d.skip)
    {
        ai_compat_callout(_e.npc, "flank");
    }
}

function __ai_human_adapt_move(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    if (_d.skip || !_k.valid || _k.target != _d.threat.target || _e.now >= _d.until || _e.npc.ammo_now <= 0 || _e.npc.reloading)
    {
        return UnknownEnum.Value_1;
    }
    if (_d.route_mode)
    {
        return __ai_human_route_move(arg0, arg1);
    }
    if (_d.close_aim_watch && (_d.fighting || ai_perception_close_aimed_at(_e)))
    {
        if (!_d.fighting)
        {
            __ai_human_relocation_fight_enter(arg0, arg1, "close_player_aiming");
        }
        return __ai_human_relocation_fight(arg0, arg1);
    }
    var _opportunity = __ai_profile_contains(["reload_push", "heal_push", "flash_push"], _d.kind);
    if (_opportunity && _d.kind != "flash_push" && __ai_hunter_enabled(_e))
    {
        if (__ai_hunter_risk_bad(_e))
        {
            return UnknownEnum.Value_1;
        }
        var _intel = _e.combat.hunter;
        if (__ai_hunter_intel_fresh(_e) && _intel.sample_frame > _d.threat.frame && ((_d.kind == "reload_push" && !_intel.reloading) || (_d.kind == "heal_push" && !is_struct(_intel.medicine))))
        {
            return UnknownEnum.Value_1;
        }
    }
    if (_opportunity && variable_struct_exists(_d.threat, "heard") && _d.threat.heard)
    {
        var _h = _e.perception.hearing;
        if (_h.action_target == _d.threat.target && _h.sampled_frame > _d.threat.frame && _h.action != __ai_human_opportunity_prefix(_d.kind))
        {
            return UnknownEnum.Value_1;
        }
    }
    if (_d.kind == "heal_push" && _k.visible && !_e.perception.heal_seen)
    {
        return UnknownEnum.Value_1;
    }
    if (_d.kind == "reload_push" && _k.visible && !_e.perception.reload_seen)
    {
        return UnknownEnum.Value_1;
    }
    if (_d.kind == "flash_push" && _k.visible && (!is_struct(_e.perception.flash) || !_e.perception.flash.active))
    {
        return UnknownEnum.Value_1;
    }
    if (_d.kind == "flash_push" && _k.visible && point_distance(_e.npc.x, _e.npc.y, _k.x, _k.y) <= (_d.config.min_target_distance_px + 2))
    {
        ai_commands_stop(_e, arg1.token);
        ai_commands_aim(_e, arg1.token, _k.x, _k.y);
        ai_commands_fire(_e, arg1.token, _k);
        return UnknownEnum.Value_0;
    }
    if ((_d.kind == "reload_push" || _d.kind == "heal_push") && _k.visible && point_distance(_e.npc.x, _e.npc.y, _k.x, _k.y) < (_d.config.min_target_distance_px * 0.5))
    {
        return UnknownEnum.Value_1;
    }
    if ((_d.kind == "flank" || _d.kind == "relocation") && _k.visible && !_d.started_visible)
    {
        return UnknownEnum.Value_1;
    }
    var _focus = (_d.kind == "flank" || _d.kind == "relocation") ? ai_contact_focus(_e) : ((_opportunity && !_k.visible) ? _d.threat : _k);
    ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    if (is_undefined(_d.result))
    {
        var _query = (_d.kind == "suppression") ? "hit_cover" : _d.kind;
        var _result = ai_spatial_query(_e, _query, arg1.token, _d.threat);
        if (_result.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_result.status != "FOUND" || !ai_spatial_claim(_e, _result, arg1.token))
        {
            if (_d.kind == "relocation")
            {
                _e.combat.decision_reason = "no_useful_cover";
            }
            return UnknownEnum.Value_1;
        }
        var _opening_run = (_d.kind == "flash_push" && _d.config.sprint) || (!_k.visible && __ai_hunter_enabled(_e) && _opportunity);
        if (_opportunity && (ai_commands_walk_speed(_e) <= 0 || ai_commands_travel_seconds(_e, _result, _opening_run, 0, 0.1) > (_d.until - _e.now)))
        {
            return UnknownEnum.Value_1;
        }
        _d.result = _result;
        _d.run = _d.kind == "suppression" || ((_d.kind == "flank" || _d.kind == "scatter" || _d.kind == "relocation" || _d.kind == "flash_push") && _d.config.sprint);
        if (_opportunity && __ai_hunter_enabled(_e))
        {
            _d.run = !_k.visible;
        }
        if (!_opportunity)
        {
            _d.until = _e.now + ai_commands_travel_seconds(_e, _result, _d.run, _d.config.move_seconds);
        }
    }
    var _valid = ai_spatial_progress(_e, arg1, _d.result);
    if (_valid == "waiting")
    {
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid")
    {
        return UnknownEnum.Value_1;
    }
    if (_d.kind == "relocation" && _d.settled)
    {
        ai_commands_stop(_e, arg1.token);
        ai_commands_fire(_e, arg1.token, _k);
        return (_e.now >= _d.settle_until) ? UnknownEnum.Value_1 : UnknownEnum.Value_0;
    }
    var _run = (_d.kind == "flash_push") ? _d.config.sprint : ((_opportunity && __ai_hunter_enabled(_e)) ? !_k.visible : _d.run);
    var _move = ai_commands_move_position(_e, arg1.token, _d.result, ai_commands_transfer_speed(_e, _d.result, _run), 2);
    if (_k.visible)
    {
        ai_commands_fire(_e, arg1.token, _k);
    }
    if (_move == "arrived")
    {
        if (!__ai_spatial_clear_line(_e.npc.x, _e.npc.y, _d.threat.x, _d.threat.y))
        {
            _e.combat.cover = _d.result;
        }
        else
        {
            _e.combat.cover = undefined;
        }
        if (_d.kind == "relocation")
        {
            _d.settled = true;
            _d.settle_until = _e.now + _d.config.pause_seconds;
            _d.until = _d.settle_until;
            return UnknownEnum.Value_0;
        }
    }
    return (_move == "arrived" || _move == "failed") ? UnknownEnum.Value_1 : UnknownEnum.Value_0;
}

function __ai_human_adapt_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _moved = point_distance(_d.origin_x, _d.origin_y, _e.npc.x, _e.npc.y) >= 16;
    if ((_d.kind == "scatter" || _d.kind == "relocation" || _d.kind == "flank") && _e.knowledge.valid && is_struct(_d.threat) && _d.threat.target == _e.knowledge.target && _moved)
    {
        ai_spatial_approach_remember(_e, _d.threat, true);
    }
    _e.combat.adaptation.active = "";
    if (_d.kind == "scatter")
    {
        _e.combat.scatter.next_repeat = _e.now + lerp(_d.config.repeat_min_seconds, _d.config.repeat_max_seconds, ai_profile_random(_e.rng));
    }
    if (_d.kind != "scatter")
    {
        variable_struct_set(_e.combat.adaptation_cooldowns, _d.kind, _e.now + (_moved ? _d.config.cooldown_seconds : 0.5));
    }
    if ((_d.kind == "relocation" || _d.route_mode) && _moved)
    {
        var _m = __ai_human_memory(_e);
        if (is_struct(_m))
        {
            _m.consumed_at = _e.now;
            __ai_human_memory_retire(_e, _d.origin_x, _d.origin_y, _e.now);
        }
    }
    if (_d.kind != "suppression" && !_d.skip && point_distance(_d.origin_x, _d.origin_y, _e.npc.x, _e.npc.y) >= 8)
    {
        _e.combat.movement_until = max(_e.combat.movement_until, (variable_struct_exists(_d, "settled") && _d.settled) ? _d.settle_until : (_e.now + _d.config.pause_seconds));
    }
    if (_d.route_mode)
    {
        ai_team_relocation_finish(_e, arg1.token, _moved);
        _e.combat.adaptation_cooldowns.flank = _e.now + (_moved ? _e.profile.config.flank.cooldown_seconds : 0.5);
        _e.combat.adaptation_cooldowns.relocation = _e.now + (_moved ? _e.profile.config.relocation.cooldown_seconds : 0.5);
    }
    ai_spatial_release(_e);
    ai_team_release(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_pursuit_committed(arg0)
{
    return arg0.knowledge.valid && (ai_investigation_committed(arg0) || (!arg0.knowledge.visible && (arg0.combat.chase_active || arg0.combat.preparing || arg0.investigation.active)));
}

function __ai_human_scatter_facing(arg0)
{
    var _k = arg0.knowledge;
    return _k.visible && !arg0.npc.reloading && arg0.npc.ammo_now > 0 && (ai_commands_in_effective_range(arg0, _k.x, _k.y) || ai_commands_outranged_fire_allowed(arg0, _k.target)) && abs(angle_difference(point_direction(arg0.npc.x, arg0.npc.y, _k.x, _k.y), arg0.npc.weapon_pointing_direction)) <= arg0.profile.config.scatter.fire_angle_degrees;
}

function __ai_human_scatter_fire_first(arg0)
{
    var _s = arg0.combat.scatter;
    _s.pending = false;
    _s.panic = false;
    _s.fire_first_until = arg0.now + arg0.profile.config.scatter.fire_first_seconds;
}

function __ai_human_scatter_step(arg0)
{
    var _s = arg0.combat.scatter;
    var _c = arg0.profile.config.scatter;
    if (!arg0.knowledge.valid)
    {
        _s.encounter = false;
        _s.panic = false;
        _s.pending = false;
        _s.repeating = false;
        _s.fire_first_until = 0;
        exit;
    }
    var _tier = arg0.profile.config.training;
    var _scale = (_tier == "rookie") ? _c.rookie_scale : ((_tier == "intermediate") ? _c.intermediate_scale : 1);
    if (!_s.encounter)
    {
        _s.fire_first_until = 0;
        _s.started_at = arg0.now;
        var _panic = (_tier == "rookie") ? _c.panic_rookie_chance : ((_tier == "intermediate") ? _c.panic_intermediate_chance : 0);
        _s.panic = !arg0.bridge.hit.pending && !arg0.bridge.hit.active && _panic > 0 && (_panic >= 1 || ai_profile_random(arg0.rng) < _panic);
        var _chance = _c.opening_chance * _scale;
        _s.encounter = true;
        _s.repeating = false;
        _s.pending = !_s.panic && _c.enabled && _chance > 0 && (_chance >= 1 || ai_profile_random(arg0.rng) < _chance);
        if (__ai_human_scatter_facing(arg0))
        {
            __ai_human_scatter_fire_first(arg0);
        }
        _s.until = arg0.now + _c.window_seconds;
        _s.next_repeat = arg0.now + lerp(_c.repeat_min_seconds, _c.repeat_max_seconds, ai_profile_random(arg0.rng));
        exit;
    }
    if (!_s.repeating && _s.fire_first_until <= 0 && (_s.pending || _s.panic) && (arg0.now - _s.started_at) <= _c.facing_recheck_seconds && arg0.combat.adaptation.active != "scatter" && arg0.combat.tactic != "panic" && __ai_human_scatter_facing(arg0))
    {
        __ai_human_scatter_fire_first(arg0);
    }
    if (arg0.now < _s.next_repeat || arg0.combat.adaptation.active == "scatter")
    {
        exit;
    }
    _s.next_repeat = arg0.now + lerp(_c.repeat_min_seconds, _c.repeat_max_seconds, ai_profile_random(arg0.rng));
    if (!_c.enabled || (arg0.now - arg0.knowledge.observed_at) > _c.repeat_memory_seconds || is_undefined(ai_team_nearby_ally(arg0)))
    {
        exit;
    }
    if ((_c.repeat_chance * _scale) <= 0 || ((_c.repeat_chance * _scale) < 1 && ai_profile_random(arg0.rng) >= (_c.repeat_chance * _scale)))
    {
        exit;
    }
    _s.pending = true;
    _s.repeating = true;
    _s.until = arg0.now + _c.window_seconds;
}

function __ai_human_can_scatter(arg0)
{
    var _e = arg0.user_data;
    var _s = _e.combat.scatter;
    var _c = _e.profile.config.scatter;
    if (_e.combat.adaptation.active == "scatter")
    {
        return true;
    }
    if (__ai_human_pursuit_committed(_e) || !_c.enabled || !_s.pending || _e.now >= _s.until || !__ai_human_ready(_e) || _e.combat.peek_return || ai_scene_assignments_force_shoot(_e) || !_e.knowledge.valid || _e.npc.reloading || _e.npc.ammo_now <= 0 || _e.now < _e.withdrawal.until)
    {
        return false;
    }
    if (!_s.repeating && _e.now < _s.fire_first_until)
    {
        return false;
    }
    var _action = arg0._active_action;
    if (_s.repeating && _action >= 0 && arg0.tree.nodes[_action].name == "shoot")
    {
        return false;
    }
    if (_s.repeating && (_e.combat.committed || _e.now < _e.combat.movement_until || (_e.now - _e.knowledge.observed_at) > _c.repeat_memory_seconds))
    {
        return false;
    }
    if (point_distance(_e.npc.x, _e.npc.y, _e.knowledge.x, _e.knowledge.y) < _c.min_target_distance_px)
    {
        return false;
    }
    var _ally = ai_team_nearby_ally(_e);
    return !is_undefined(_ally) && __ai_team_push_capacity(_e, "scatter") && (_s.repeating || point_distance(_e.npc.x, _e.npc.y, _ally.npc.x, _ally.npc.y) <= _c.cluster_radius_px);
}

function __ai_human_scatter_enter(arg0, arg1)
{
    __ai_human_adapt_enter(arg0, arg1, "scatter");
    arg0.user_data.combat.scatter.pending = false;
    arg1.data.skip = !ai_team_begin_push(arg0.user_data, arg1.token, "scatter");
}

function __ai_human_hold_angle(arg0, arg1)
{
    var _e = arg0.user_data;
    ai_commands_stop(_e, arg1.token);
    if (__ai_human_opening_ready(arg0))
    {
        return UnknownEnum.Value_1;
    }
    if (!_e.knowledge.valid || (_e.knowledge.visible && ai_commands_camera_step(_e)) || (!__ai_human_contact_fresh(_e) && !ai_hearing_active(_e) && !__ai_human_defense_recovery(_e)))
    {
        return UnknownEnum.Value_1;
    }
    var _focus = ai_contact_focus(_e);
    ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    return ((_e.now - arg1.started_at) >= _e.profile.config.engagement.hold_seconds) ? UnknownEnum.Value_1 : UnknownEnum.Value_0;
}

function __ai_human_hold_angle_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    if (arg2 == "success" && !_e.knowledge.visible)
    {
        _e.combat.cooldowns.hold_angle = _e.now + _e.profile.config.engagement.hold_seconds;
        _e.combat.angle_failed = true;
    }
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_gain_angle_enter(arg0, arg1)
{
    var _e = arg0.user_data;
    var _local = _e.combat.tactic == "angle" || (!_e.knowledge.visible && !_e.combat.angle_failed && _e.combat.decision_reason == "seek_new_angle" && _e.profile.config.engagement.angle_weight > 0 && point_distance(_e.npc.x, _e.npc.y, _e.knowledge.x, _e.knowledge.y) <= ((_e.combat.weapon_range * _e.profile.config.spacing.far_ratio) + _e.profile.config.engagement.angle_distance_px) && _e.now >= _e.combat.cooldowns.angle);
    if (_local)
    {
        __ai_human_angle_enter(arg0, arg1);
    }
    else
    {
        __ai_human_relocation_enter(arg0, arg1);
    }
    arg1.data.gain_local = _local;
}

function __ai_human_gain_angle(arg0, arg1)
{
    if (!arg1.data.gain_local)
    {
        return __ai_human_adapt_move(arg0, arg1);
    }
    var _e = arg0.user_data;
    var _result = __ai_human_angle(arg0, arg1);
    if (_result == UnknownEnum.Value_0 || !_e.combat.angle_failed || !_e.knowledge.valid || _e.knowledge.visible || !_e.profile.config.relocation.route_enabled || __ai_human_relocation_weight(_e, false) <= 0)
    {
        return _result;
    }
    ai_spatial_release(_e);
    ai_commands_stop(_e, arg1.token);
    __ai_human_relocation_enter(arg0, arg1, true);
    arg1.data.gain_local = false;
    _e.combat.decision_reason = "angle_escalation";
    return __ai_human_adapt_move(arg0, arg1);
}

function __ai_human_gain_angle_exit(arg0, arg1, arg2)
{
    if (arg1.data.gain_local)
    {
        __ai_human_angle_exit(arg0, arg1, arg2);
    }
    else
    {
        __ai_human_adapt_exit(arg0, arg1, arg2);
    }
}

function __ai_human_angle_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _d = arg1.data;
    _d.threat = ai_movement_snapshot(_e);
    _d.threat.allow_close = __ai_human_pursuit_allowed(_e) && __ai_human_magazine_ready(_e) && ai_team_can_push(_e);
    _d.origin_x = _e.npc.x;
    _d.origin_y = _e.npc.y;
    _d.result = undefined;
    _d.close_aim_watch = true;
    _d.fighting = false;
    _d.until = _e.now + _e.profile.config.engagement.angle_move_seconds;
}

function __ai_human_angle(arg0, arg1)
{
    var _e = arg0.user_data;
    var _k = _e.knowledge;
    var _d = arg1.data;
    if (!_k.valid || _k.target != _d.threat.target || _e.npc.ammo_now <= 0 || _e.npc.reloading)
    {
        return UnknownEnum.Value_1;
    }
    if (_e.now >= _d.until)
    {
        _e.combat.angle_failed = true;
        return UnknownEnum.Value_1;
    }
    if (_d.fighting || ai_perception_close_aimed_at(_e))
    {
        if (!_d.fighting)
        {
            __ai_human_relocation_fight_enter(arg0, arg1, "close_player_aiming");
        }
        return __ai_human_relocation_fight(arg0, arg1);
    }
    if (ai_investigation_fire_opportunity(_e))
    {
        return UnknownEnum.Value_1;
    }
    var _focus = ai_contact_focus(_e);
    ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    if (is_undefined(_d.result))
    {
        var _point = ai_spatial_query(_e, "angle", arg1.token, _d.threat);
        if (_point.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_point.status != "FOUND" || !ai_spatial_claim(_e, _point, arg1.token))
        {
            _e.combat.decision_reason = "no_useful_angle";
            _e.combat.angle_failed = true;
            return UnknownEnum.Value_1;
        }
        if (_d.threat.allow_close && !ai_team_begin_push(_e, arg1.token))
        {
            _e.combat.angle_failed = true;
            return UnknownEnum.Value_1;
        }
        _e.combat.angle_failed = false;
        _d.result = _point;
        _d.until = _e.now + ai_commands_travel_seconds(_e, _point, true, _e.profile.config.engagement.angle_move_seconds);
    }
    ai_spatial_tracking_correct(_e, arg1, "angle", true, _e.profile.config.engagement.angle_move_seconds);
    var _valid = ai_spatial_progress(_e, arg1, _d.result);
    if (_valid == "waiting")
    {
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid")
    {
        _e.combat.angle_failed = true;
        return UnknownEnum.Value_1;
    }
    var _move = ai_commands_move_position(_e, arg1.token, _d.result, ai_commands_transfer_speed(_e, _d.result), 2);
    if (_move == "failed" || (_move == "arrived" && !_k.visible))
    {
        _e.combat.angle_failed = true;
    }
    return (_move == "arrived" || _move == "failed") ? UnknownEnum.Value_1 : UnknownEnum.Value_0;
}

function __ai_human_angle_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    _e.combat.cooldowns.angle = _e.now + ((point_distance(arg1.data.origin_x, arg1.data.origin_y, _e.npc.x, _e.npc.y) >= 8) ? _e.profile.config.engagement.angle_cooldown_seconds : 0.5);
    ai_spatial_release(_e);
    ai_team_release(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_panic_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _k = _e.knowledge;
    _e.combat.scatter.panic = false;
    _e.combat.scatter.pending = false;
    arg1.data.threat = 
    {
        valid: true,
        target: _k.target,
        x: _k.x,
        y: _k.y,
        revision: _k.revision
    };
    arg1.data.phase = "hit_cover";
    arg1.data.result = undefined;
    arg1.data.until = _e.now + _e.profile.config.hit_reaction.active_seconds;
}

function __ai_human_aggression(arg0)
{
    return clamp(arg0.profile.personality.traits.aggression + (ai_perception_vulnerability(arg0) * arg0.profile.config.vulnerability.aggression_bonus), 0, 1) * lerp(1, arg0.profile.config.suppression.risk_floor, __ai_human_pressure(arg0));
}

function __ai_human_magazine_ready(arg0)
{
    var _c = arg0.profile.config.magazine;
    var _npc = arg0.npc;
    if (_npc.reloading || _npc.ammo_now <= 0)
    {
        return false;
    }
    if (!_c.enabled)
    {
        return true;
    }
    var _capacity = max(1, item_weapon_get_modded_magazine_size(_npc.arma_now, _npc.mod_container));
    var _supported = ai_team_advancing_ally(arg0);
    var _required = min(_supported ? min(_c.solo_rounds_max, _c.supported_rounds_max) : _c.solo_rounds_max, max(1, ceil(_capacity * (_supported ? min(_c.solo_ratio, _c.supported_ratio) : _c.solo_ratio))));
    return _npc.ammo_now >= min(_capacity, _required);
}

function __ai_human_prepared_approach(arg0, arg1 = __ai_human_prepare_enter)
{
    return ai_bt_sequence(arg0.name + "_prepared", [ai_bt_action("prepare_advance", arg1, __ai_human_prepare_update, __ai_human_prepare_exit), arg0]);
}

function __ai_human_prepare_optional_enter(arg0, arg1)
{
    var _e = arg0.user_data;
    var _t = _e.combat.tactic;
    var _forward = _t == "push" || (_t == "spacing" && __ai_human_spacing_direction(_e, point_distance(_e.npc.x, _e.npc.y, _e.knowledge.x, _e.knowledge.y)) > 0);
    __ai_human_prepare_enter(arg0, arg1, _forward);
}

function __ai_human_prepare_enter(arg0, arg1, arg2 = true)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _d = arg1.data;
    _d.mode = (arg2 && _e.combat.tactic != "flash_push" && __ai_human_pursuit_allowed(_e)) ? "assess" : "done";
    _d.target = _e.knowledge.target;
    _d.reselect = false;
    _d.hidden = !_e.knowledge.visible;
    _d.wait_until = _e.now + _e.profile.config.grenade.assessment_wait_seconds;
    _e.combat.preparing = _d.mode != "done";
}

function __ai_human_prepare_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    if (!_k.valid || _k.target != _d.target)
    {
        return UnknownEnum.Value_2;
    }
    if (_d.mode == "done")
    {
        return UnknownEnum.Value_1;
    }
    if ((_e.now - arg1.started_at) >= 12)
    {
        return UnknownEnum.Value_2;
    }
    if (_d.mode == "assess" && _d.hidden && ai_investigation_fire_opportunity(_e))
    {
        _d.reselect = true;
        return UnknownEnum.Value_2;
    }
    var _focus = ai_contact_focus(_e);
    ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    if (_d.mode == "assess")
    {
        var _g = _e.profile.config.grenade;
        var _npc = _e.npc;
        var _can_throw = !__ai_profile_contains(["flash_push", "reload_push", "heal_push"], _e.combat.tactic) && _g.enabled && _g.isolated_priority && _e.profile.config.cover_assessment.enabled && !_k.visible && _focus == _k && __ai_investigation_player(_e) && variable_instance_exists(_npc, "grenade_amount_max") && _npc.grenade_amount_thrown < _npc.grenade_amount_max && _e.now >= _e.grenade.retry_at && (_e.now - _k.observed_at) <= _g.memory_seconds && npc_get_prob_grenade_throw(_npc.npc_id) > 0;
        if (_can_throw && !is_struct(ai_cover_current(_e)) && _e.now < _d.wait_until)
        {
            ai_commands_stop(_e, arg1.token);
            return UnknownEnum.Value_0;
        }
        if (_can_throw && ai_grenade_isolated_opportunity(_e) && __ai_grenade_start(_e, arg1, false))
        {
            _d.mode = "grenade";
            _e.combat.decision_reason = "grenade_before_advance";
        }
        else
        {
            _d.mode = "magazine";
        }
    }
    if (_d.mode == "grenade")
    {
        var _status = ai_grenade_update(arg0, arg1);
        if (_status == UnknownEnum.Value_0)
        {
            return _status;
        }
        ai_grenade_cancel(_e);
        _d.reselect = true;
        _d.mode = "magazine";
    }
    if (_d.mode == "magazine")
    {
        if (__ai_human_magazine_ready(_e))
        {
            return _d.reselect ? UnknownEnum.Value_2 : UnknownEnum.Value_1;
        }
        _d.mode = "reload";
        _e.combat.preparing_reload = true;
        _e.combat.decision_reason = "low_magazine_before_advance";
        __ai_human_reload_prepare(_e, arg1);
    }
    if (_d.mode == "reload")
    {
        var _status = __ai_human_reload(arg0, arg1);
        if (_status == UnknownEnum.Value_1)
        {
            _d.reselect = true;
        }
        return (_status == UnknownEnum.Value_0) ? _status : UnknownEnum.Value_2;
    }
    return UnknownEnum.Value_1;
}

function __ai_human_prepare_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    if (arg1.data.mode == "grenade")
    {
        ai_grenade_cancel(_e);
    }
    ai_spatial_release(_e);
    _e.combat.preparing = false;
    _e.combat.preparing_reload = false;
    _e.combat.hunter_reload = false;
    var _engaging = _e.combat.engaging;
    __ai_human_action_exit(arg0, arg1, (arg2 == "failure" && arg1.data.reselect) ? "reselect" : arg2);
    if (arg2 == "success")
    {
        _e.combat.engaging = _engaging;
    }
}

function __ai_human_recognize_cover(arg0)
{
    if (!arg0.knowledge.valid || arg0.knowledge.visible || arg0.commands.moving || arg0.combat.committed || arg0.combat.peek_return || !ai_world_take_candidate(arg0))
    {
        exit;
    }
    var _focus = ai_contact_focus(arg0);
    if (__ai_human_defense_protected(arg0, arg0.npc.x, arg0.npc.y, _focus))
    {
        arg0.combat.cover = 
        {
            x: arg0.npc.x,
            y: arg0.npc.y
        };
    }
}

function __ai_human_defense_context(arg0)
{
    var _d = arg0.combat.defense;
    var _c = arg0.profile.config.defensive_reposition;
    return arg0.combat.advanced && _c.enabled && _c.weight > 0 && arg0.knowledge.valid && _d.target == arg0.knowledge.target && _d.mode != "none" && (arg0.now - _d.checked_at) <= 0.25 && (arg0.knowledge.visible || (arg0.now - arg0.knowledge.observed_at) <= _c.memory_seconds || ai_hearing_active(arg0)) && (arg0.perception.search_until <= 0 || arg0.now < arg0.perception.search_until);
}

function __ai_human_defense_recovery(arg0)
{
    if (!__ai_human_defense_context(arg0))
    {
        return false;
    }
    if (arg0.combat.defense.mode == "watch")
    {
        return arg0.combat.pursuit_allowed == false;
    }
    if (arg0.combat.defense.mode == "cover" && arg0.combat.pursuit_allowed != false)
    {
        return false;
    }
    return arg0.combat.defense.mode != "fight" && arg0.now >= arg0.combat.cooldowns.defensive_reposition;
}

function __ai_human_defense_protected(arg0, arg1, arg2, arg3)
{
    var _distance = min(arg0.profile.config.defensive_reposition.cover_probe_px, point_distance(arg1, arg2, arg3.x, arg3.y));
    var _direction = point_direction(arg1, arg2, arg3.x, arg3.y);
    return !__ai_spatial_clear_line(arg1, arg2, arg1 + lengthdir_x(_distance, _direction), arg2 + lengthdir_y(_distance, _direction));
}

function __ai_human_defense_step(arg0)
{
    var _d = arg0.combat.defense;
    var _c = arg0.profile.config.defensive_reposition;
    var _k = arg0.knowledge;
    if (!arg0.combat.advanced || !_c.enabled || _c.weight <= 0 || !_k.valid || arg0.npc.grenade_flash || ai_scene_assignments_force_shoot(arg0))
    {
        _d.mode = "none";
        _d.unsupported_at = -1;
        _d.reason = "unavailable";
        exit;
    }
    if (_d.target != _k.target)
    {
        _d.target = _k.target;
        _d.unsupported_at = -1;
        _d.next_probe = 0;
        _d.mode = "none";
    }
    if (!is_undefined(ai_team_combat_ally(arg0)))
    {
        _d.unsupported_at = -1;
        _d.mode = "none";
        _d.reason = "supported";
        exit;
    }
    if (_d.unsupported_at < 0)
    {
        _d.unsupported_at = arg0.now;
    }
    if ((arg0.now - _d.unsupported_at) < _c.unsupported_seconds)
    {
        _d.mode = "none";
        _d.reason = "support_grace";
        exit;
    }
    if ((!_k.visible && (arg0.now - _k.observed_at) > _c.memory_seconds && !ai_hearing_active(arg0)) || (arg0.perception.search_until > 0 && arg0.now >= arg0.perception.search_until))
    {
        _d.mode = "none";
        _d.reason = "stale_contact";
        exit;
    }
    if (arg0.now < _d.next_probe)
    {
        exit;
    }
    if (!ai_world_take_candidate(arg0))
    {
        exit;
    }
    _d.next_probe = arg0.now + 0.1;
    _d.checked_at = arg0.now;
    var _focus = ai_contact_focus(arg0);
    var _traits = arg0.profile.personality.traits;
    var _comfortable = arg0.combat.weapon_range * _c.close_ratio * lerp(1.1, 0.9, (_traits.aggression + _traits.risk_tolerance) * 0.5);
    _d.close = point_distance(arg0.npc.x, arg0.npc.y, _focus.x, _focus.y) < max(16, _comfortable - _c.distance_slack_px);
    _d.protected = __ai_human_defense_protected(arg0, arg0.npc.x, arg0.npc.y, _focus);
    _d.mode = "watch";
    if (_d.close)
    {
        _d.mode = (_k.visible && !_d.protected) ? "fight" : "retreat";
    }
    else if (!_k.visible && !_d.protected)
    {
        _d.mode = "cover";
    }
    _d.reason = _d.mode;
    if (_d.protected && !arg0.commands.moving && !arg0.combat.committed && !arg0.combat.peek_return)
    {
        arg0.combat.cover = 
        {
            x: arg0.npc.x,
            y: arg0.npc.y
        };
    }
}

function __ai_human_defense_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _c = _e.profile.config.defensive_reposition;
    var _focus = ai_contact_focus(_e);
    _e.combat.committed = true;
    _d.threat = 
    {
        valid: _focus.valid,
        target: _focus.target,
        x: _focus.x,
        y: _focus.y,
        revision: _focus.revision,
        gain_px: _e.combat.defense.close ? _c.min_gain_px : 0,
        protected: __ai_human_defense_protected(_e, _e.npc.x, _e.npc.y, _focus)
    };
    _d.result = undefined;
    _d.phase = "query";
    _d.until = _e.now + _c.move_seconds;
    _e.combat.cooldowns.defensive_reposition = _e.now + _c.cooldown_seconds;
}

function __ai_human_defense_move(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    var _c = _e.profile.config.defensive_reposition;
    if (!_k.valid || _k.target != _d.threat.target || _e.now >= _d.until)
    {
        return UnknownEnum.Value_1;
    }
    var _focus = ai_contact_focus(_e);
    ai_commands_aim(_e, arg1.token, _focus.x, _focus.y);
    if (_k.visible && !__ai_human_defense_protected(_e, _e.npc.x, _e.npc.y, _k))
    {
        ai_commands_stop(_e, arg1.token);
        ai_commands_fire(_e, arg1.token, _k);
        _e.combat.defense.reason = "exposed_fight_back";
        return UnknownEnum.Value_1;
    }
    if (_d.phase == "settle")
    {
        ai_commands_stop(_e, arg1.token);
        ai_commands_fire(_e, arg1.token, _k);
        return UnknownEnum.Value_0;
    }
    if (is_undefined(_d.result))
    {
        ai_commands_stop(_e, arg1.token);
        var _result = ai_spatial_query(_e, "defensive_reposition", arg1.token, _d.threat);
        if (_result.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_result.status != "FOUND" || !ai_spatial_claim(_e, _result, arg1.token))
        {
            _e.combat.defense.reason = "no_safe_retreat";
            return UnknownEnum.Value_1;
        }
        _d.result = _result;
        _d.phase = "move";
        _d.until = _e.now + ai_commands_travel_seconds(_e, _result, true, _c.move_seconds);
    }
    var _valid = ai_spatial_progress(_e, arg1, _d.result);
    if (_valid == "waiting")
    {
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid" || (_d.threat.protected && __ai_spatial_clear_line(_e.npc.x, _e.npc.y, _d.threat.x, _d.threat.y)))
    {
        return UnknownEnum.Value_1;
    }
    var _move = ai_commands_move_position(_e, arg1.token, _d.result, ai_commands_transfer_speed(_e, _d.result));
    ai_commands_fire(_e, arg1.token, _k);
    if (_move == "failed")
    {
        return UnknownEnum.Value_1;
    }
    if (_move == "arrived")
    {
        _e.combat.cover = _d.result;
        ai_commands_stop(_e, arg1.token);
        _d.phase = "settle";
        _d.until = _e.now + _c.settle_seconds;
    }
    return UnknownEnum.Value_0;
}

function __ai_human_defense_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    var _c = _e.profile.config.defensive_reposition;
    _e.combat.committed = false;
    _e.combat.cooldowns.defensive_reposition = _e.now + _c.cooldown_seconds;
    if (arg1.data.phase == "settle")
    {
        _e.combat.movement_until = max(_e.combat.movement_until, arg1.data.until);
    }
    ai_spatial_release(_e);
    __ai_human_action_exit(arg0, arg1, (arg2 == "failure") ? "reselect" : arg2);
}

function __ai_human_memory(arg0)
{
    if (!variable_struct_exists(arg0, "combat") || !arg0.profile.config.relocation.enabled)
    {
        return undefined;
    }
    var _k = arg0.knowledge;
    if (!_k.valid)
    {
        arg0.combat.memory = undefined;
        return undefined;
    }
    var _m = variable_struct_exists(arg0.combat, "memory") ? arg0.combat.memory : undefined;
    if (!is_struct(_m) || _m.target != _k.target)
    {
        _m = 
        {
            target: _k.target,
            shot_at: -1000,
            shot_x: 0,
            shot_y: 0,
            pressure_at: -1000,
            pressure_x: 0,
            pressure_y: 0,
            pressure_reason: "",
            seen_at: -1000,
            seen_x: 0,
            seen_y: 0,
            peeks: 0,
            consumed_at: -1000,
            retired: [],
            cover_count: 0,
            probe_at: -1000,
            probe_x: arg0.npc.x,
            probe_y: arg0.npc.y
        };
        arg0.combat.memory = _m;
    }
    return _m;
}

function __ai_human_memory_sight(arg0, arg1, arg2)
{
    var _m = __ai_human_memory(arg0);
    if (!is_struct(_m))
    {
        exit;
    }
    var _c = arg0.profile.config.relocation;
    var _gap = arg0.now - _m.seen_at;
    if (_gap > _c.memory_seconds || point_distance(_m.seen_x, _m.seen_y, arg1.x, arg1.y) > _c.patch_radius_px)
    {
        _m.peeks = 0;
    }
    if (arg2 && _gap >= _c.repeat_peek_gap_seconds)
    {
        _m.peeks = min(3, _m.peeks + 1);
    }
    _m.seen_at = arg0.now;
    _m.seen_x = arg1.x;
    _m.seen_y = arg1.y;
    if (is_struct(arg0.combat.maneuver))
    {
        arg0.combat.maneuver.progress_at = arg0.now;
        arg0.combat.maneuver.stalled = false;
    }
}

function __ai_human_memory_shot(arg0)
{
    ai_team_note_fire(arg0);
    var _m = __ai_human_memory(arg0);
    if (!is_struct(_m))
    {
        exit;
    }
    _m.shot_at = arg0.now;
    _m.shot_x = arg0.npc.x;
    _m.shot_y = arg0.npc.y;
    if (is_struct(arg0.combat.maneuver))
    {
        arg0.combat.maneuver.progress_at = arg0.now;
        arg0.combat.maneuver.stalled = false;
    }
}

function __ai_human_memory_retire(arg0, arg1, arg2, arg3)
{
    var _m = __ai_human_memory(arg0);
    if (!is_struct(_m))
    {
        exit;
    }
    var _points = _m.retired;
    var _c = arg0.profile.config.relocation;
    var _i = array_length(_points) - 1;
    while (_i >= 0)
    {
        if ((arg0.now - _points[_i].at) > _c.memory_seconds)
        {
            array_delete(_points, _i, 1);
        }
        else if (point_distance(arg1, arg2, _points[_i].x, _points[_i].y) < _c.patch_radius_px)
        {
            _points[_i].at = max(_points[_i].at, arg3);
            _m.retired = _points;
            exit;
        }
        _i--;
    }
    if (array_length(_points) >= 3)
    {
        array_delete(_points, 0, 1);
    }
    array_push(_points, 
    {
        x: arg1,
        y: arg2,
        at: arg3
    });
    _m.retired = _points;
}

function __ai_human_memory_pressure(arg0, arg1, arg2 = 0)
{
    var _m = __ai_human_memory(arg0);
    if (!is_struct(_m))
    {
        exit;
    }
    _m.pressure_at = arg0.now - arg2;
    _m.pressure_x = arg0.npc.x;
    _m.pressure_y = arg0.npc.y;
    _m.pressure_reason = arg1;
    __ai_human_memory_retire(arg0, arg0.npc.x, arg0.npc.y, _m.pressure_at);
}

function __ai_human_memory_avoid(arg0, arg1, arg2)
{
    var _m = __ai_human_memory(arg0);
    if (!is_struct(_m))
    {
        return false;
    }
    var _c = arg0.profile.config.relocation;
    for (var _i = 0; _i < array_length(_m.retired); _i++)
    {
        var _p = _m.retired[_i];
        if ((arg0.now - _p.at) <= _c.memory_seconds && point_distance(arg1, arg2, _p.x, _p.y) < _c.patch_radius_px)
        {
            return true;
        }
    }
    return false;
}

function __ai_human_memory_reason(arg0)
{
    var _m = __ai_human_memory(arg0);
    if (!is_struct(_m))
    {
        return "";
    }
    var _c = arg0.profile.config.relocation;
    if ((arg0.now - arg0.knowledge.observed_at) > _c.contact_seconds)
    {
        return "";
    }
    if (_m.pressure_at > _m.consumed_at && (arg0.now - _m.pressure_at) <= _c.memory_seconds && point_distance(arg0.npc.x, arg0.npc.y, _m.pressure_x, _m.pressure_y) <= _c.min_move_px)
    {
        return _m.pressure_reason;
    }
    if (!arg0.knowledge.visible)
    {
        if (_m.peeks >= 2 && _m.seen_at > _m.consumed_at && (arg0.now - _m.seen_at) <= _c.memory_seconds)
        {
            return "repeated_enemy_peek";
        }
        if (_m.shot_at > _m.consumed_at && (arg0.now - _m.shot_at) <= _c.memory_seconds && point_distance(arg0.npc.x, arg0.npc.y, _m.shot_x, _m.shot_y) <= _c.min_move_px)
        {
            return "relocate_after_exchange";
        }
    }
    return "";
}

function __ai_human_maneuver_choose(arg0)
{
    var _c = arg0.profile.config.flank_opportunity;
    var _k = arg0.knowledge;
    if (!_c.enabled || !arg0.profile.config.relocation.enabled || !arg0.profile.config.relocation.route_enabled || !_k.valid)
    {
        arg0.combat.maneuver = undefined;
        exit;
    }
    __ai_human_memory(arg0);
    var _m = arg0.combat.maneuver;
    if (!is_struct(_m) || _m.target != _k.target)
    {
        _m = 
        {
            target: _k.target,
            progress_at: arg0.now,
            x: arg0.npc.x,
            y: arg0.npc.y,
            chosen_step: -1,
            stalled: false,
            bonus: 0,
            reason: "",
            ally: noone,
            wait_frame: 0
        };
        arg0.combat.maneuver = _m;
    }
    if (_m.chosen_step == arg0.step)
    {
        exit;
    }
    _m.chosen_step = arg0.step;
    _m.reason = "";
    _m.bonus = 0;
    var _fresh = (arg0.now - _k.observed_at) <= arg0.profile.config.relocation.contact_seconds;
    if (_k.visible || !_fresh || point_distance(_m.x, _m.y, arg0.npc.x, arg0.npc.y) >= 16)
    {
        _m.progress_at = arg0.now;
        _m.x = arg0.npc.x;
        _m.y = arg0.npc.y;
    }
    var _scale = variable_struct_get(_c, arg0.profile.config.training + "_scale");
    _m.stalled = _fresh && !_k.visible && (arg0.now - _m.progress_at) >= (_c.stall_seconds / max(0.5, _scale));
    _m.wait_frame = ai_team_relocation_wait_frame(arg0);
    var _fire = ai_team_covering_fire(arg0);
    var _cue = "";
    var _ally = -4;
    if (_fresh && ai_perception_aimed_at_ally(arg0))
    {
        _cue = "player_focused_on_ally";
        _ally = arg0.perception.aim_ally.ally;
    }
    else if (_fresh && is_struct(_fire))
    {
        _cue = "ally_covering_fire";
        _ally = _fire.npc;
    }
    var _since = (_cue == "player_focused_on_ally") ? arg0.perception.aim_ally.since : ((_cue == "ally_covering_fire") ? (arg0.now - (max(0, ai_world_get().frame - _fire.since_frame) / 60)) : arg0.now);
    _m.ally = _ally;
    if (_cue != "" && (arg0.now - _since) >= (_c.reaction_seconds / max(0.25, _scale)))
    {
        _m.reason = _cue;
        _m.bonus = ((_cue == "player_focused_on_ally") ? _c.distracted_bonus : _c.ally_fire_bonus) * _scale;
        if (_k.visible && (arg0.now - arg0.combat.memory.shot_at) <= _c.ally_fire_seconds)
        {
            _m.bonus *= _c.shooter_multiplier;
        }
    }
    if (_m.stalled)
    {
        _m.reason = "stalled_contact";
        _m.bonus = max(_m.bonus, _c.stalled_bonus * _scale);
    }
    _m.bonus = min(_c.max_bonus, _m.bonus);
    if (_m.bonus <= 0)
    {
        _m.reason = "";
    }
}

function __ai_human_maneuver_reason(arg0)
{
    var _c = arg0.profile.config.flank_opportunity;
    var _k = arg0.knowledge;
    var _m = struct_get_from_hash(arg0.combat, variable_get_hash("maneuver"));
    if (!_c.enabled || !arg0.profile.config.relocation.route_enabled || !is_struct(_m) || !_k.valid || _m.target != _k.target || (arg0.now - _k.observed_at) > arg0.profile.config.relocation.contact_seconds)
    {
        return "";
    }
    if (_m.reason == "stalled_contact")
    {
        return (_m.stalled && !_k.visible && point_distance(_m.x, _m.y, arg0.npc.x, arg0.npc.y) < 16) ? _m.reason : "";
    }
    if (_m.reason == "player_focused_on_ally")
    {
        return ai_perception_aimed_at_ally(arg0) ? _m.reason : "";
    }
    if (_m.reason != "ally_covering_fire")
    {
        return "";
    }
    var _other = __ai_team_execution(_m.ally);
    if (!is_struct(_other) || !__ai_team_members(arg0, _other) || !_other.knowledge.valid || _other.knowledge.target != _k.target || _other.npc.reloading || _other.npc.grenade_flash || _other.npc.ammo_now <= 0)
    {
        return "";
    }
    var _f = _other.team.fired;
    return (is_struct(_f) && _f.target == _k.target && (ai_world_get().frame - _f.frame) <= (_c.ally_fire_seconds * 60)) ? _m.reason : "";
}

function __ai_human_relocation_reason(arg0)
{
    if (__ai_hunter_enabled(arg0) && __ai_hunter_intel_fresh(arg0) && arg0.combat.hunter.intent == "relocate" && arg0.now < arg0.combat.hunter.intent_until)
    {
        return "hunter_change_angle";
    }
    var _opportunity = __ai_human_maneuver_reason(arg0);
    if (_opportunity != "")
    {
        return _opportunity;
    }
    var _reason = __ai_human_memory_reason(arg0);
    if (_reason != "")
    {
        return _reason;
    }
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.relocation;
    if (!_c.enabled || !_c.route_enabled || !_k.valid || _k.visible || (arg0.now - _k.observed_at) > _c.contact_seconds || (_k.source != "sight" && _k.source != "ally_report"))
    {
        return "";
    }
    var _a = arg0.combat.adaptation;
    if (_a.peek_target == _k.target && _a.peek_failures >= arg0.profile.config.peek_reposition.failed_attempts)
    {
        return "failed_peek";
    }
    if (arg0.combat.angle_failed)
    {
        return "failed_local_angle";
    }
    var _m = __ai_human_memory(arg0);
    return (is_struct(_m) && _k.observed_at > _m.consumed_at) ? "seek_new_angle" : "";
}

function __ai_human_relocation_weight(arg0, arg1 = true)
{
    var _c = arg0.profile.config.relocation;
    if (!arg0.knowledge.visible && arg0.investigation.engaged)
    {
        return 0;
    }
    var _reason = __ai_human_relocation_reason(arg0);
    if (!_c.enabled || _reason == "" || !__ai_human_adapt_ready(arg0, "relocation") || arg0.npc.reloading || arg0.npc.ammo_now <= 0)
    {
        return 0;
    }
    var _k = arg0.knowledge;
    var _m = __ai_human_memory(arg0);
    var _o = arg0.profile.config.flank_opportunity;
    var _maneuver = arg0.combat.maneuver;
    if (_o.enabled && is_struct(_maneuver) && ai_world_get().frame < _maneuver.wait_frame)
    {
        return 0;
    }
    if (point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y) > ((arg0.combat.weapon_range * arg0.profile.config.spacing.far_ratio) + _c.distance_px))
    {
        return 0;
    }
    var _moved = point_distance(arg0.npc.x, arg0.npc.y, _m.probe_x, _m.probe_y) >= _c.min_move_px;
    if (arg1 && ((arg0.now - _m.probe_at) >= _c.probe_seconds || _moved) && ai_world_take_candidate(arg0))
    {
        _m.cover_count = 0;
        _m.probe_at = arg0.now;
        _m.probe_x = arg0.npc.x;
        _m.probe_y = arg0.npc.y;
        _moved = false;
        for (var _i = 0; _i < 8; _i++)
        {
            if (!__ai_spatial_clear_line(arg0.npc.x, arg0.npc.y, arg0.npc.x + lengthdir_x(_c.probe_radius_px, _i * 45), arg0.npc.y + lengthdir_y(_c.probe_radius_px, _i * 45)))
            {
                _m.cover_count += 1;
            }
        }
    }
    if (!_c.route_enabled && (_m.cover_count == 0 || _moved || (arg0.now - _m.probe_at) > (_c.probe_seconds * 2)))
    {
        return 0;
    }
    if (_c.route_enabled && point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y) <= _c.route_close_px && (!_o.enabled || !_o.angle_route_enabled || _k.visible || point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y) <= _o.angle_close_px))
    {
        return 0;
    }
    var _cover_count = (!_moved && (arg0.now - _m.probe_at) <= (_c.probe_seconds * 2)) ? _m.cover_count : 0;
    var _weight = _c.weight * arg0.profile.personality.traits.reposition_preference * lerp(1, _c.cover_multiplier, min(1, _cover_count / 3));
    if (_m.peeks >= 2)
    {
        _weight *= _c.repeat_peek_multiplier;
    }
    if (_reason == "seek_new_angle")
    {
        _weight *= _c.lost_sight_multiplier;
    }
    if (_reason == "failed_local_angle" || _reason == "failed_peek")
    {
        _weight *= _c.failed_angle_multiplier;
    }
    var _opportunity = __ai_human_maneuver_reason(arg0) != "";
    if (_o.enabled)
    {
        _weight *= (_o.base_multiplier * (1 + (_opportunity ? _maneuver.bonus : 0)));
    }
    return _weight * ((_k.visible && !_opportunity) ? _c.exposed_multiplier : 1);
}

function __ai_human_relocation_enter(arg0, arg1, arg2 = false)
{
    if (arg0.user_data.combat.scatter.repeating)
    {
        arg0.user_data.combat.scatter.pending = false;
    }
    __ai_human_adapt_enter(arg0, arg1, "relocation", arg2);
    var _e = arg0.user_data;
    arg1.data.settled = false;
    __ai_human_pursuit_allowed(_e);
    if (_e.profile.config.relocation.route_enabled)
    {
        __ai_human_route_enter(arg0, arg1);
    }
    if (!arg1.data.skip)
    {
        ai_compat_callout(_e.npc, "relocate");
    }
}

function __ai_human_route_enter(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _c = _e.profile.config.relocation;
    _d.threat = ai_movement_snapshot(_e);
    _d.route_mode = true;
    _d.settled = false;
    _d.route_leg = 0;
    _d.route_phase = "plan";
    _e.combat.angle_failed = false;
    _e.combat.adaptation.peek_failures = 0;
    _d.route_speed = _d.config.sprint ? __ai_human_speed(_e) : ai_commands_walk_speed(_e);
    _d.route_plan = ai_spatial_route_create(_e, arg1.token, _d.threat, _d.route_speed);
    if (!ai_team_relocation_begin(_e, arg1.token))
    {
        _d.skip = true;
        _e.combat.decision_reason = "ally_relocating";
    }
    _d.until = _e.now + _e.profile.config.queries.max_defer_seconds;
}

function __ai_human_relocation_fight_enter(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    _d.fighting = true;
    _d.fight_at = _e.now;
    _d.fight_ready_at = -1;
    _d.until = _e.now + _e.profile.config.firing.burst_max_seconds;
    _e.combat.decision_reason = arg2;
    _e.combat.cover = undefined;
    _e.combat.angle_failed = false;
    ai_commands_stop(_e, arg1.token);
    ai_spatial_release(_e);
    ai_team_release(_e);
}

function __ai_human_relocation_fight(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    ai_commands_stop(_e, arg1.token);
    if (!_k.visible)
    {
        return UnknownEnum.Value_1;
    }
    var _aligned = ai_commands_aim(_e, arg1.token, _k.x, _k.y);
    if (_aligned && _d.fight_ready_at < 0)
    {
        _d.fight_ready_at = _e.now;
    }
    ai_commands_fire(_e, arg1.token, _k);
    var _f = _e.profile.config.firing;
    var _duration = min(_f.burst_max_seconds, max(_f.burst_min_seconds, ((_e.commands.reflex_required + 1) / 60) + _f.burst_extra_seconds));
    return (_d.fight_ready_at >= 0 && (_e.now - _d.fight_ready_at) >= _duration) ? UnknownEnum.Value_1 : UnknownEnum.Value_0;
}

function __ai_human_route_move(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    var _c = _e.profile.config.relocation;
    var _close = _k.visible && point_distance(_e.npc.x, _e.npc.y, _k.x, _k.y) <= _c.route_close_px;
    var _close_aim = ai_perception_close_aimed_at(_e);
    if (!_d.settled && _d.route_phase != "fight" && (_close || _close_aim || ai_perception_aimed_at(_e)))
    {
        _d.route_phase = "fight";
        __ai_human_relocation_fight_enter(arg0, arg1, _close_aim ? "close_player_aiming" : (_close ? "route_close_danger" : "visible_player_aiming"));
    }
    if (_d.route_phase == "fight")
    {
        return __ai_human_relocation_fight(arg0, arg1);
    }
    var _look = (_d.settled && variable_struct_exists(_d, "look_threat")) ? _d.look_threat : _d.threat;
    ai_commands_aim(_e, arg1.token, _k.visible ? _k.x : _look.x, _k.visible ? _k.y : _look.y);
    if (_d.settled)
    {
        ai_commands_stop(_e, arg1.token);
        ai_commands_fire(_e, arg1.token, _k);
        return (_e.now >= _d.settle_until) ? UnknownEnum.Value_1 : UnknownEnum.Value_0;
    }
    if (_d.route_phase == "plan")
    {
        var _status = ai_spatial_route_query(_e, _d.route_plan);
        if (_status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_status != "FOUND")
        {
            _e.combat.decision_reason = "no_useful_route";
            return UnknownEnum.Value_1;
        }
        _d.route_phase = "run";
        _d.until = _e.now + _d.route_plan.max_seconds + 0.15;
    }
    if (is_undefined(_d.result))
    {
        var _result = _d.route_plan.results[_d.route_leg];
        _result.expires = _e.now + _e.profile.config.queries.retry_seconds;
        if (!ai_spatial_claim(_e, _result, arg1.token))
        {
            return (ai_spatial_progress(_e, arg1, _result) == "waiting") ? UnknownEnum.Value_0 : UnknownEnum.Value_1;
        }
        _d.result = _result;
        _d.route_checked = false;
    }
    var _valid = ai_spatial_progress(_e, arg1, _d.result);
    if (_valid == "waiting")
    {
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid")
    {
        return UnknownEnum.Value_1;
    }
    var _move = ai_commands_move(_e, arg1.token, _d.result.x, _d.result.y, _d.config.sprint ? __ai_human_speed(_e) : ai_commands_walk_speed(_e), 2);
    if (!_d.route_checked && _e.commands.path_started)
    {
        var _path = _e.npc.path_to_target;
        if (!__ai_spatial_route_safe(_e, _path, _d.route_plan.request) || path_get_length(_path) > (_d.result.route_length + 8))
        {
            return UnknownEnum.Value_1;
        }
        _d.route_checked = true;
    }
    if (_move == "failed")
    {
        return UnknownEnum.Value_1;
    }
    if (_move == "arrived")
    {
        ai_spatial_release(_e);
        _d.route_leg++;
        if (_d.route_leg < array_length(_d.route_plan.results))
        {
            _d.result = undefined;
        }
        else
        {
            _d.settled = true;
            _d.route_phase = "look";
            _d.look_threat = ai_movement_snapshot(_e);
            _d.settle_until = _e.now + _d.config.pause_seconds;
            _d.until = _d.settle_until;
            _e.combat.cover = undefined;
            _e.combat.decision_reason = "route_complete";
        }
    }
    return UnknownEnum.Value_0;
}

function __ai_human_route_draw(arg0)
{
    if (arg0.route_phase == "plan")
    {
        exit;
    }
    var _colour = draw_get_color();
    var _alpha = draw_get_alpha();
    var _p = arg0.route_plan;
    var _px = _p.request.origin_x;
    var _py = _p.request.origin_y;
    for (var _i = 0; _i < array_length(_p.points); _i++)
    {
        var _point = _p.points[_i];
        draw_set_color((_i < arg0.route_leg) ? c_gray : c_aqua);
        draw_set_alpha(0.5);
        draw_line(_px, _py, _point[0], _point[1]);
        draw_set_alpha(1);
        draw_circle(_point[0], _point[1], 5, true);
        draw_text(_point[0] + 6, _point[1], string(_i + 1));
        _px = _point[0];
        _py = _point[1];
    }
    draw_set_color(c_yellow);
    draw_line(arg0.threat.x - 5, arg0.threat.y - 5, arg0.threat.x + 5, arg0.threat.y + 5);
    draw_line(arg0.threat.x - 5, arg0.threat.y + 5, arg0.threat.x + 5, arg0.threat.y - 5);
    draw_set_color(_colour);
    draw_set_alpha(_alpha);
}

function __ai_human_pressure(arg0)
{
    var _p = arg0.combat.pressure;
    var _c = arg0.profile.config.suppression;
    _p.value = (_c.enabled && _c.pressure_enabled) ? max(0, _p.value - (max(0, arg0.now - _p.at) * _c.decay_per_second)) : 0;
    _p.at = arg0.now;
    return _p.value;
}

function __ai_human_pressure_high(arg0)
{
    return __ai_human_pressure(arg0) >= arg0.profile.config.suppression.heavy_threshold;
}

function __ai_human_pressure_add(arg0, arg1, arg2, arg3)
{
    var _c = arg0.profile.config.suppression;
    var _p = arg0.combat.pressure;
    __ai_human_pressure(arg0);
    if (!_c.enabled || !_c.pressure_enabled || arg2 < 0 || arg2 > _c.window_seconds || !__ai_perception_hostile(arg0.npc, arg1.target) || _p.frame == arg1.frame)
    {
        exit;
    }
    _p.frame = arg1.frame;
    var _resistance = lerp(1.2, 0.8, arg0.profile.personality.traits.risk_tolerance);
    var _trained = __ai_profile_contains(["expert", "veteran", "master"], arg0.profile.config.training);
    if (_trained)
    {
        _resistance *= 0.85;
    }
    _p.value = clamp((_p.value + ((arg3 ? _c.hit_pressure : _c.near_miss_pressure) * _resistance)) - (arg2 * _c.decay_per_second), 0, 1);
}

function __ai_human_can_covering(arg0)
{
    var _c = arg0.profile.config.covering_fire;
    var _k = arg0.knowledge;
    return _c.enabled && arg0.combat.advanced && _k.valid && ai_commands_camera_step(arg0) && (_k.source == "sight" || _k.source == "ally_report") && (arg0.now - _k.observed_at) <= _c.memory_seconds && arg0.profile.personality.traits.teamwork >= _c.teamwork_min && !arg0.npc.reloading && !arg0.npc.grenade_flash && arg0.npc.ammo_now >= _c.min_rounds && !__ai_human_pressure_high(arg0) && arg0.now >= arg0.combat.covering_until && !ai_scene_assignments_force_shoot(arg0) && is_struct(ai_team_cover_recipient(arg0));
}

function __ai_human_covering_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _k = _e.knowledge;
    var _d = arg1.data;
    var _c = _e.profile.config.covering_fire;
    _d.ally = ai_team_cover_recipient(_e);
    _d.shots = 0;
    _d.candidate = 0;
    _d.point = undefined;
    _d.threat = 
    {
        target: _k.target,
        x: _k.x,
        y: _k.y,
        observed_at: _k.observed_at
    };
    _d.until = min(_e.now + _c.burst_seconds, _k.observed_at + _c.memory_seconds);
    _d.token = arg1.token;
    _e.combat.covering = _d;
    ai_commands_stop(_e, arg1.token);
    ai_compat_callout(_e.npc, "covering_fire");
}

function __ai_human_covering_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _c = _e.profile.config.covering_fire;
    if (_e.now >= _d.until || !ai_team_needs_cover(_e, _d.ally) || _e.knowledge.target != _d.threat.target || _e.npc.reloading || _e.npc.grenade_flash || _e.npc.ammo_now <= _c.reserve_rounds || _d.shots >= _c.max_shots || __ai_human_pressure_high(_e) || __ai_human_opening_ready(arg0))
    {
        return UnknownEnum.Value_1;
    }
    ai_commands_stop(_e, arg1.token);
    while (!is_struct(_d.point) && _d.candidate < 9)
    {
        if (!ai_world_take_candidate(_e))
        {
            return UnknownEnum.Value_0;
        }
        var _i = _d.candidate++;
        var _radius = (_i == 0) ? 0 : _c.opening_radius_px;
        var _x = _d.threat.x + lengthdir_x(_radius, (_i - 1) * 45);
        var _y = _d.threat.y + lengthdir_y(_radius, (_i - 1) * 45);
        if (point_distance(_e.npc.x, _e.npc.y, _x, _y) > (_e.combat.weapon_range * 1.3) || point_distance(_e.npc.x, _e.npc.y, _x, _y) < 48 || !__ai_spatial_clear_line(_e.npc.x, _e.npc.y, _x, _y))
        {
            continue;
        }
        _d.point = 
        {
            target: _d.threat.target,
            x: _x,
            y: _y,
            observed_at: _d.threat.observed_at
        };
    }
    if (!is_struct(_d.point))
    {
        return UnknownEnum.Value_1;
    }
    ai_commands_aim(_e, arg1.token, _d.point.x, _d.point.y);
    if ((_e.now - arg1.started_at) < _e.profile.config.firing.expected_prepare_seconds)
    {
        return UnknownEnum.Value_0;
    }
    var _visible = _e.knowledge.visible;
    var _fired = _visible ? (__ai_commands_cover_lane(_e, _e.knowledge) && ai_commands_fire(_e, arg1.token, _e.knowledge)) : ai_commands_cover_fire(_e, arg1.token, _d.point);
    if (_fired && _visible)
    {
        _d.shots++;
    }
    return UnknownEnum.Value_0;
}

function __ai_human_covering_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    _e.combat.covering = undefined;
    _e.combat.covering_until = _e.now + _e.profile.config.covering_fire.cooldown_seconds;
    __ai_human_action_exit(arg0, arg1, arg2);
}

function __ai_human_flash_close(arg0)
{
    var _f = arg0.perception.flash;
    var _k = arg0.knowledge;
    return arg0.profile.config.flash_push.enabled && _k.visible && is_struct(_f) && _f.active && _f.target == _k.target && ((ai_world_get().frame - _f.frame) / 60) < _f.remaining && point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y) <= (arg0.profile.config.flash_push.min_target_distance_px + 2);
}

function __ai_human_urgent_opening(arg0)
{
    var _ctx = arg0.tree_context;
    var _node = _ctx._active_action;
    if (_node < 0 || arg0.combat.peek_return || arg0.npc.reloading || arg0.npc.grenade_flash || arg0.npc.ammo_now <= 0)
    {
        return false;
    }
    var _name = _ctx.tree.nodes[_node].name;
    var _flash = __ai_human_can_flash_push(_ctx) || __ai_human_flash_close(arg0);
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.firing;
    var _close = _k.visible && point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y) <= _c.close_reflex_distance_px && abs(angle_difference(point_direction(arg0.npc.x, arg0.npc.y, _k.x, _k.y), arg0.npc.weapon_pointing_direction)) <= _c.close_reflex_angle_degrees;
    if ((_flash && __ai_profile_contains(["shoot", "hold_angle", "combat_move", "interception", "find_angle", "relocation", "flank", "chase", "investigate", "search", "hold_position", "prepare_advance"], _name) && !(_name == "shoot" && __ai_human_flash_close(arg0)) && !(_name == "prepare_advance" && arg0.combat.tactic == "flash_push")) || (_close && (__ai_profile_contains(["chase", "investigate"], _name) || (__ai_commands_heard_ready(arg0) && __ai_profile_contains(["hold_angle", "find_angle"], _name)))))
    {
        if (_close)
        {
            arg0.perception.close_ready_until = arg0.now + _c.heard_reflex_seconds;
        }
        ai_bt_abort(_ctx, _flash ? "confirmed_flash" : "close_threat");
        arg0.combat.blocked_until = 0;
        arg0.combat.movement_until = 0;
        return true;
    }
    return false;
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2
}
