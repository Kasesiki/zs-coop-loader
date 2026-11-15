function __ai_perception_interval(arg0)
{
    var _interval = arg0.profile.config.schedule.perception_steps;
    if (arg0.profile.config.awareness.enabled)
    {
        _interval = min(_interval, arg0.profile.config.awareness.perception_steps);
    }
    return (arg0.profile.config.training == "master") ? min(2, _interval) : _interval;
}

function ai_perception_create(arg0)
{
    arg0.perception = 
    {
        last_step: -1,
        previous: [],
        previous_room: room,
        resumed_step: -1,
        resumed_until: 0,
        next_probe: arg0.now + ((1 + (arg0.profile.seed % __ai_perception_interval(arg0))) / 60),
        hearing: 
        {
            room_id: room,
            ready: undefined,
            clue: undefined,
            last_serial: 0,
            next_at: arg0.now + ((arg0.profile.seed % 6) / 60),
            update_at: 0,
            reason: "none",
            action_target: noone,
            reload_active: false,
            medicine: undefined,
            action: "",
            sampled_frame: -1
        },
        tracking: __ai_tracking_create(),
        wound: undefined,
        flash: undefined,
        aim_threat: undefined,
        aim_ally: undefined,
        aim_ally_step: -1,
        last_probe: arg0.now,
        scan_cursor: 0,
        switch_at: -1000,
        return_fire: 
        {
            target: noone,
            until: -1000
        },
        last_direct_target: noone,
        last_direct_step: -1000,
        last_direct_at: -1000,
        last_direct_x: 0,
        last_direct_y: 0,
        sight_serial: 0,
        visible_steps: 0,
        lead_vx: 0,
        lead_vy: 0,
        expected: false,
        expected_until: 0,
        reaction_angle: 0,
        reaction_alerted: false,
        close_ready_until: 0,
        alert: 0,
        alert_target: noone,
        alert_visible: false,
        reload_target: noone,
        reload_seen: false,
        reload_frame: -1,
        heal_seen: false,
        checks: 0,
        los_checks: 0,
        total_checks: 0,
        total_los: 0,
        escape_valid: false,
        escape_direction: 0,
        motion_x: 0,
        motion_y: 0,
        motion_at: 0,
        revision_x: 0,
        revision_y: 0,
        search_until: 0,
        last_reason: "initial"
    };
    return 
    {
        valid: false,
        target: noone,
        x: 0,
        y: 0,
        visible: false,
        source: "none",
        observed_at: 0,
        uncertainty: 0,
        revision: 0,
        engagement_x: arg0.npc.x,
        engagement_y: arg0.npc.y
    };
}

function ai_perception_forget(arg0, arg1)
{
    if (arg1 != "observed_dead" && arg1 != "invalid_target" && arg1 != "memory_expired" && arg1 != "search_complete" && arg1 != "investigation_complete")
    {
        arg0.perception.previous = [];
    }
    ai_investigation_reset(arg0);
    if (variable_struct_exists(arg0, "team"))
    {
        arg0.team.support = undefined;
    }
    if (variable_struct_exists(arg0, "combat"))
    {
        __ai_human_adapt_reset(arg0);
        arg0.combat.hunter = __ai_hunter_create();
    }
    var _k = arg0.knowledge;
    if (_k.valid)
    {
        _k.revision++;
    }
    _k.valid = false;
    _k.target = -4;
    _k.visible = false;
    _k.source = "none";
    arg0.perception.search_until = 0;
    arg0.perception.resumed_until = 0;
    arg0.perception.escape_valid = false;
    arg0.perception.alert = 0;
    arg0.perception.alert_target = -4;
    arg0.perception.alert_visible = false;
    arg0.perception.last_reason = arg1;
    arg0.perception.last_direct_target = -4;
    arg0.perception.expected = false;
    arg0.perception.close_ready_until = 0;
    arg0.perception.wound = undefined;
    arg0.perception.flash = undefined;
    arg0.perception.aim_threat = undefined;
    arg0.perception.aim_ally = undefined;
    arg0.perception.aim_ally_step = -1;
    arg0.perception.hearing.clue = undefined;
    arg0.perception.hearing.ready = undefined;
    arg0.perception.hearing.action_target = -4;
    arg0.perception.hearing.medicine = undefined;
    arg0.perception.hearing.reload_active = false;
    arg0.perception.heal_seen = false;
    arg0.perception.tracking = __ai_tracking_create();
    if (variable_struct_exists(arg0, "commands"))
    {
        arg0.commands.reflex_target = -4;
        arg0.commands.watch_target = -4;
        arg0.commands.camera_fire = __ai_commands_camera_create();
    }
    if (variable_struct_exists(arg0, "cover_assessment"))
    {
        arg0.cover_assessment = undefined;
    }
}

function __ai_perception_previous_remove(arg0, arg1)
{
    var _p = arg0.perception;
    var _i = array_length(_p.previous) - 1;
    while (_i >= 0)
    {
        if (_p.previous[_i].target == arg1)
        {
            array_delete(_p.previous, _i, 1);
        }
        _i--;
    }
}

function __ai_perception_remember(arg0, arg1)
{
    var _p = arg0.perception;
    var _k = arg0.knowledge;
    if (_p.previous_room != room)
    {
        _p.previous = [];
        _p.previous_room = room;
        exit;
    }
    __ai_perception_previous_remove(arg0, arg1);
    __ai_perception_previous_remove(arg0, _k.target);
    var _i = array_length(_p.previous) - 1;
    while (_i >= 0)
    {
        if (arg0.now >= _p.previous[_i].until)
        {
            array_delete(_p.previous, _i, 1);
        }
        _i--;
    }
    if (!_k.valid || !__ai_perception_hostile(arg0.npc, _k.target))
    {
        exit;
    }
    var _c = arg0.profile.config.pursuit;
    var _until = max(_p.search_until, _k.observed_at + _c.lost_contact_seconds + _c.search_seconds);
    if (arg0.now >= _until)
    {
        exit;
    }
    if (array_length(_p.previous) >= 3)
    {
        array_delete(_p.previous, 0, 1);
    }
    array_push(_p.previous, 
    {
        target: _k.target,
        x: _k.x,
        y: _k.y,
        source: _k.source,
        observed_at: _k.observed_at,
        uncertainty: _k.uncertainty,
        until: _until,
        engagement_x: _k.engagement_x,
        engagement_y: _k.engagement_y,
        escape_valid: _p.escape_valid,
        escape_direction: _p.escape_direction
    });
}

function __ai_perception_resume_previous(arg0)
{
    var _p = arg0.perception;
    var _k = arg0.knowledge;
    if (_p.previous_room != room)
    {
        _p.previous = [];
        _p.previous_room = room;
        return false;
    }
    if (_k.valid)
    {
        return false;
    }
    while (array_length(_p.previous) > 0)
    {
        var _memory = array_pop(_p.previous);
        var _resume_until = min(_memory.until, _memory.observed_at + arg0.profile.config.pursuit.lost_contact_seconds);
        if (arg0.now >= _resume_until || !__ai_perception_hostile(arg0.npc, _memory.target))
        {
            continue;
        }
        _k.valid = true;
        _k.visible = false;
        _k.target = _memory.target;
        _k.x = _memory.x;
        _k.y = _memory.y;
        _k.source = _memory.source;
        _k.observed_at = _memory.observed_at;
        _k.uncertainty = _memory.uncertainty;
        _k.engagement_x = _memory.engagement_x;
        _k.engagement_y = _memory.engagement_y;
        _k.revision++;
        _p.revision_x = _memory.x;
        _p.revision_y = _memory.y;
        _p.search_until = _resume_until;
        _p.resumed_until = _resume_until;
        _p.escape_valid = _memory.escape_valid;
        _p.escape_direction = _memory.escape_direction;
        _p.motion_x = _memory.x;
        _p.motion_y = _memory.y;
        _p.motion_at = _memory.observed_at;
        _p.switch_at = arg0.now;
        _p.last_reason = "previous_target";
        _p.resumed_step = arg0.step;
        _p.next_probe = min(_p.next_probe, arg0.now + 0.016666666666666666);
        return true;
    }
    return false;
}

function ai_perception_observe(arg0, arg1, arg2, arg3, arg4, arg5, arg6 = 0)
{
    if (variable_global_exists("dev_player_invisible") && false && global.dev_player_invisible && instance_exists(arg1) && object_is_player(arg1))
    {
        return false;
    }
    if (!__ai_profile_number(arg2) || !__ai_profile_number(arg3) || !__ai_profile_number(arg5) || arg5 < 0 || arg5 > (arg0.now + 0.0000001) || !__ai_profile_number(arg6) || arg6 < 0)
    {
        return false;
    }
    if (arg4 != "sight" && arg4 != "ally_report" && arg4 != "damage" && arg4 != "near_miss" && arg4 != "legacy_shot")
    {
        return false;
    }
    var _k = arg0.knowledge;
    if (_k.valid && arg5 < _k.observed_at)
    {
        return false;
    }
    if (_k.valid && arg4 != "sight" && arg5 <= _k.observed_at && !(arg4 == "damage" && arg1 != _k.target))
    {
        return false;
    }
    var _p = arg0.perception;
    var _new_contact = !_k.valid || arg1 != _k.target;
    if (_k.valid && _new_contact && arg4 != "sight" && arg4 != "damage" && arg0.now < (_p.switch_at + arg0.profile.config.targeting.switch_cooldown_seconds))
    {
        return false;
    }
    if (_new_contact)
    {
        __ai_perception_remember(arg0, arg1);
    }
    if (_k.valid && _new_contact && arg4 == "sight")
    {
        _p.switch_at = arg0.now;
    }
    if (_new_contact)
    {
        _p.wound = undefined;
        _p.flash = undefined;
        _p.aim_threat = undefined;
        if (variable_struct_exists(arg0, "commands"))
        {
            arg0.commands.camera_fire = __ai_commands_camera_create();
        }
        _p.tracking = __ai_tracking_create();
        _p.aim_ally = undefined;
        _p.aim_ally_step = -1;
        _p.hearing.clue = undefined;
        _p.hearing.ready = undefined;
        _p.close_ready_until = 0;
    }
    if (_new_contact && variable_struct_exists(arg0, "team"))
    {
        arg0.team.support = undefined;
    }
    _p.resumed_until = 0;
    var _planned = variable_struct_exists(arg0, "investigation") && is_struct(arg0.investigation.plan) && arg0.investigation.plan.target == arg1 && arg0.now < _p.search_until;
    if (_new_contact || (arg4 == "sight" && !_planned))
    {
        ai_investigation_reset(arg0);
    }
    if ((arg4 == "sight" && !_planned) || _new_contact)
    {
        _p.search_until = 0;
    }
    if (arg4 != "sight" || _new_contact || _k.source != "sight")
    {
        _p.escape_valid = false;
        _p.motion_x = arg2;
        _p.motion_y = arg3;
        _p.motion_at = arg5;
    }
    else if (point_distance(_p.motion_x, _p.motion_y, arg2, arg3) >= 2)
    {
        _p.escape_valid = (arg5 - _p.motion_at) <= 0.75;
        _p.escape_direction = point_direction(_p.motion_x, _p.motion_y, arg2, arg3);
        _p.motion_x = arg2;
        _p.motion_y = arg3;
        _p.motion_at = arg5;
    }
    else if ((arg5 - _p.motion_at) > 0.75)
    {
        _p.escape_valid = false;
    }
    if (!_k.valid || arg1 != _k.target)
    {
        _k.engagement_x = arg0.npc.x;
        _k.engagement_y = arg0.npc.y;
    }
    if (!_k.valid || arg1 != _k.target || arg4 != _k.source || point_distance(arg2, arg3, _p.revision_x, _p.revision_y) >= 8)
    {
        _k.revision++;
        _p.revision_x = arg2;
        _p.revision_y = arg3;
    }
    _k.valid = true;
    _k.target = arg1;
    _k.x = arg2;
    _k.y = arg3;
    _k.source = arg4;
    _k.observed_at = arg5;
    _k.uncertainty = arg6;
    _k.visible = arg4 == "sight";
    return true;
}

function __ai_perception_hostile(arg0, arg1)
{
    if (!instance_exists(arg1) || arg1 == arg0)
    {
        return false;
    }
    if (!variable_instance_exists(arg1, "faction"))
    {
        return false;
    }
    if (!ai_roaming_npc_is_hostile_to(arg0, arg1) && faction_get_rep_temp(arg0.faction, arg1.faction) >= 250)
    {
        return false;
    }
    if (variable_instance_exists(arg1, "mp_index"))
    {
        if (player_state_is(arg1.mp_index, scr_player_state_start, scr_player_state_free_camera))
        {
            return false;
        }
    }
    return true;
}

function __ai_perception_view(arg0)
{
    var _distance = npc_get_alert_visual_distance(arg0.npc_id);
    var _angle = npc_get_alert_radius(arg0.npc_id);
    var _light = instance_find(obj_light_controller, 0);
    if (_light == -4)
    {
        return 
        {
            enabled: false,
            distance: 0,
            angle: 0,
            minimum: 0
        };
    }
    var _night_scale = 0.8;
    if (variable_instance_exists(arg0, "ai_execution") && is_struct(arg0.ai_execution))
    {
        _night_scale = arg0.ai_execution.profile.config.awareness.night_sight_multiplier;
    }
    var _scale = 1;
    if (_light.ciclo_now == UnknownEnum.Value_3)
    {
        _scale = _night_scale;
    }
    if (_light.ciclo_now == UnknownEnum.Value_0 || _light.ciclo_now == UnknownEnum.Value_2)
    {
        var _sunrise = _light.ciclo_now == UnknownEnum.Value_0;
        var _start = _light.ciclo_time[_sunrise ? UnknownEnum.Value_0 : UnknownEnum.Value_2];
        var _end = _light.ciclo_time[_sunrise ? UnknownEnum.Value_1 : UnknownEnum.Value_3];
        var _amount = clamp((time_get_hours_fraction() - _start) / max(0.00001, _end - _start), 0, 1);
        _scale = _sunrise ? lerp(_night_scale, 1, _amount) : lerp(1, _night_scale, _amount);
    }
    _distance *= _scale;
    return 
    {
        enabled: true,
        distance: _distance,
        angle: _angle * _scale,
        minimum: npc_get_alert_min_distance(arg0.npc_id)
    };
}

function __ai_perception_in_view(arg0, arg1, arg2, arg3, arg4, arg5)
{
    var _distance = point_distance(arg0, arg1, arg2, arg3);
    if (_distance <= arg5.minimum)
    {
        return true;
    }
    if (_distance > arg5.distance)
    {
        return false;
    }
    return abs(angle_difference(point_direction(arg0, arg1, arg2, arg3), arg4)) <= (arg5.angle / 2);
}

function __ai_perception_close_relocation(arg0, arg1, arg2, arg3)
{
    if (!arg0.knowledge.valid || arg0.knowledge.target != arg1 || !object_is_player(arg1) || point_distance(arg0.npc.x, arg0.npc.y, arg2, arg3) > arg0.profile.config.relocation.close_aim_stop_px || !variable_struct_exists(arg0, "tree_context") || !is_struct(arg0.tree_context))
    {
        return false;
    }
    var _ctx = arg0.tree_context;
    var _index = _ctx._active_action;
    if (_index < 0 || !_ctx._slots[_index].active)
    {
        return false;
    }
    var _d = _ctx._slots[_index].data;
    return variable_struct_exists(_d, "close_aim_watch") && _d.close_aim_watch;
}

function ai_perception_return_fire_mark(arg0, arg1, arg2)
{
    if (!object_is_player(arg1))
    {
        exit;
    }
    arg0.perception.return_fire = 
    {
        target: arg1,
        until: (arg0.now - arg2) + arg0.profile.config.firing.return_fire_seconds
    };
}

function ai_perception_return_fire_active(arg0, arg1)
{
    if (!variable_struct_exists(arg0, "perception") || !variable_struct_exists(arg0.perception, "return_fire"))
    {
        return false;
    }
    var _r = arg0.perception.return_fire;
    return _r.target == arg1 && arg0.now < _r.until && instance_exists(arg1);
}

function __ai_perception_probe(arg0, arg1, arg2)
{
    var _npc = arg0.npc;
    arg0.perception.checks++;
    arg0.perception.total_checks++;
    if (!arg2.enabled || !__ai_perception_hostile(_npc, arg1))
    {
        return undefined;
    }
    if (ai_perception_return_fire_active(arg0, arg1) && arg2.distance < arg0.profile.config.firing.return_fire_sight_px)
    {
        arg2 = 
        {
            enabled: true,
            distance: arg0.profile.config.firing.return_fire_sight_px,
            angle: arg2.angle,
            minimum: arg2.minimum
        };
    }
    var _tx = arg1.x;
    var _ty = arg1.y;
    if (!__ai_perception_in_view(_npc.x, _npc.y, _tx, _ty, _npc.weapon_pointing_direction, arg2) && !__ai_perception_close_relocation(arg0, arg1, _tx, _ty))
    {
        return undefined;
    }
    arg0.perception.los_checks++;
    arg0.perception.total_los++;
    if (collision_line(_npc.x, _npc.y, _tx, _ty, obj_solid, true, false) != -4)
    {
        return undefined;
    }
    if (variable_instance_exists(arg1, "hp") && arg1.hp <= 0)
    {
        __ai_perception_previous_remove(arg0, arg1);
        if (arg0.knowledge.valid && arg0.knowledge.target == arg1)
        {
            ai_compat_callout(_npc, "target_down");
            ai_perception_forget(arg0, "observed_dead");
        }
        return undefined;
    }
    return 
    {
        x: _tx,
        y: _ty,
        distance: point_distance(_npc.x, _npc.y, _tx, _ty)
    };
}

function __ai_perception_sight(arg0, arg1, arg2)
{
    var _p = arg0.perception;
    var _new_exposure = _p.last_direct_target != arg1 || _p.last_direct_step < (arg0.step - 1);
    var _expected = false;
    if (_new_exposure && variable_struct_exists(arg0, "commands"))
    {
        var _cmd = arg0.commands;
        var _c = arg0.profile.config.firing;
        var _radius = variable_instance_exists(arg0.npc, "reflex_min_distance_last_known") ? arg0.npc.reflex_min_distance_last_known : 30;
        _expected = _p.last_direct_target == arg1 && (arg0.now - _p.last_direct_at) <= _c.expected_memory_seconds && point_distance(_p.last_direct_x, _p.last_direct_y, arg2.x, arg2.y) <= _radius && _cmd.watch_target == arg1 && _cmd.watch_step >= (arg0.step - 1) && (arg0.now - _cmd.watch_since) >= _c.expected_prepare_seconds && abs(angle_difference(point_direction(arg0.npc.x, arg0.npc.y, arg2.x, arg2.y), arg0.npc.weapon_pointing_direction)) <= _c.expected_angle_degrees;
    }
    var _alerted = arg0.knowledge.valid && arg0.knowledge.target == arg1;
    var _accepted = ai_perception_observe(arg0, arg1, arg2.x, arg2.y, "sight", arg0.now);
    if (!_accepted)
    {
        return false;
    }
    __ai_human_memory_sight(arg0, arg2, _new_exposure);
    __ai_perception_wound_sight(arg0, arg1, arg2);
    __ai_perception_flash_sight(arg0, arg1, arg2);
    __ai_perception_aim_sight(arg0, arg1, arg2);
    __ai_perception_ally_aim_sight(arg0, arg1, arg2);
    if (_new_exposure)
    {
        _p.sight_serial++;
        _p.visible_steps = 0;
        _p.expected = _expected;
        _p.reaction_alerted = _alerted;
        _p.expected_until = _expected ? (arg0.now + max(0.35, (arg0.npc.reflexes_minimum / 60) + 0.15)) : 0;
        _p.reaction_angle = abs(angle_difference(point_direction(arg0.npc.x, arg0.npc.y, arg2.x, arg2.y), arg0.npc.weapon_pointing_direction));
        _p.lead_vx = 0;
        _p.lead_vy = 0;
    }
    else if (_p.last_direct_step == (arg0.step - 1))
    {
        var _smoothing = max(1, arg0.profile.config.firing.lead_smoothing_steps);
        _p.lead_vx += (arg2.x - _p.last_direct_x - _p.lead_vx) / _smoothing;
        _p.lead_vy += (arg2.y - _p.last_direct_y - _p.lead_vy) / _smoothing;
    }
    if (_new_exposure || _p.last_direct_step != arg0.step)
    {
        _p.visible_steps++;
    }
    _p.last_direct_step = arg0.step;
    _p.last_direct_at = arg0.now;
    _p.last_direct_target = arg1;
    _p.last_direct_x = arg2.x;
    _p.last_direct_y = arg2.y;
    ai_tracking_sighting(arg0, false);
    if (!variable_struct_exists(arg0, "combat") || !variable_struct_exists(arg0.combat, "adaptation"))
    {
        return true;
    }
    var _reloading = variable_instance_exists(arg1, "reloading") && arg1.reloading;
    if (_p.reload_target != arg1)
    {
        _p.reload_target = arg1;
        _p.reload_seen = false;
    }
    if (_reloading && !_p.reload_seen && (_p.hearing.action_target != arg1 || !_p.hearing.reload_active))
    {
        __ai_human_reload_notice(arg0, arg1, arg2.x, arg2.y, 0, false);
        ai_team_reload_report(arg0, arg1, arg2.x, arg2.y);
    }
    var _medicine = __ai_perception_medication(arg1);
    _p.heal_seen = is_struct(_medicine);
    var _h = _p.hearing;
    if (_h.action_target != arg1)
    {
        _h.action_target = arg1;
        _h.medicine = undefined;
    }
    if (_p.heal_seen && _medicine != _h.medicine)
    {
        __ai_human_opportunity_notice(arg0, "heal_push", arg1, arg2.x, arg2.y, 0, false);
    }
    if (!_p.heal_seen)
    {
        arg0.combat.adaptation.heal_cue = undefined;
    }
    _h.medicine = _medicine;
    _h.reload_active = _reloading;
    _h.action = _p.heal_seen ? "heal" : (_reloading ? "reload" : "");
    _h.sampled_frame = ai_world_get().frame;
    _p.reload_seen = _reloading;
    _p.reload_frame = ai_world_get().frame;
    if (!_reloading && is_struct(arg0.combat.adaptation.reload_cue) && arg0.combat.adaptation.reload_cue.target == arg1)
    {
        arg0.combat.adaptation.reload_cue = undefined;
    }
    return _accepted;
}

function __ai_perception_aim_sight(arg0, arg1, arg2)
{
    var _p = arg0.perception;
    var _c = arg0.profile.config.relocation;
    if (!object_is_player(arg1) || !variable_instance_exists(arg1, "weapon_pointing_direction") || !variable_instance_exists(arg1, "arma_now") || item_get_category(arg1.arma_now) != "weapon" || abs(angle_difference(arg1.weapon_pointing_direction, point_direction(arg2.x, arg2.y, arg0.npc.x, arg0.npc.y))) > _c.aim_cone_degrees)
    {
        _p.aim_threat = undefined;
        exit;
    }
    var _a = _p.aim_threat;
    if (!is_struct(_a) || _a.target != arg1 || _a.step < (arg0.step - 1))
    {
        _a = 
        {
            target: arg1,
            since: arg0.now,
            step: arg0.step
        };
    }
    _a.step = arg0.step;
    _p.aim_threat = _a;
}

function ai_perception_aimed_at(arg0)
{
    var _a = arg0.perception.aim_threat;
    return arg0.knowledge.visible && is_struct(_a) && _a.target == arg0.knowledge.target && _a.step == arg0.step && ((arg0.now - _a.since) + 0.0000001) >= arg0.profile.config.relocation.aim_confirm_seconds;
}

function ai_perception_close_aimed_at(arg0)
{
    var _k = arg0.knowledge;
    var _a = arg0.perception.aim_threat;
    return _k.visible && is_struct(_a) && _a.target == _k.target && _a.step == arg0.step && point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y) <= arg0.profile.config.relocation.close_aim_stop_px;
}

function __ai_perception_ally_aim_sight(arg0, arg1, arg2)
{
    var _p = arg0.perception;
    var _c = arg0.profile.config.flank_opportunity;
    if (!_c.enabled || !variable_struct_exists(arg0, "team") || _p.aim_ally_step == arg0.step)
    {
        exit;
    }
    _p.aim_ally_step = arg0.step;
    if (!arg0.profile.config.relocation.route_enabled || !object_is_player(arg1) || !variable_instance_exists(arg1, "weapon_pointing_direction") || !variable_instance_exists(arg1, "arma_now") || item_get_category(arg1.arma_now) != "weapon")
    {
        _p.aim_ally = undefined;
        exit;
    }
    var _ally = ai_team_observed_aim_ally(arg0, arg2.x, arg2.y, arg1.weapon_pointing_direction);
    if (_ally == -4)
    {
        _p.aim_ally = undefined;
        exit;
    }
    var _a = _p.aim_ally;
    if (!is_struct(_a) || _a.target != arg1 || _a.ally != _ally || _a.step < (arg0.step - 1))
    {
        _a = 
        {
            target: arg1,
            ally: _ally,
            since: arg0.now,
            step: arg0.step
        };
    }
    _a.step = arg0.step;
    _p.aim_ally = _a;
}

function ai_perception_aimed_at_ally(arg0)
{
    var _a = arg0.perception.aim_ally;
    if (!arg0.profile.config.flank_opportunity.enabled || !arg0.knowledge.visible || !is_struct(_a) || _a.target != arg0.knowledge.target || _a.step != arg0.step || (arg0.now - _a.since) < arg0.profile.config.flank_opportunity.aim_confirm_seconds)
    {
        return false;
    }
    var _ally = __ai_team_execution(_a.ally);
    return is_struct(_ally) && __ai_team_members(arg0, _ally) && _ally.knowledge.valid && _ally.knowledge.target == _a.target;
}

function __ai_perception_alert_gain(arg0, arg1, arg2, arg3)
{
    return arg3 * (arg1 / max(1, arg0)) * (arg2 ? 0.5 : 1);
}

function __ai_perception_prefer(arg0, arg1, arg2, arg3)
{
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.targeting;
    if (!_k.valid || _k.target == arg1)
    {
        return true;
    }
    if (!_c.enabled)
    {
        return false;
    }
    var _old = point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y);
    var _new = arg2.distance;
    if (_new <= arg3.minimum && (_old > arg3.minimum || !_k.visible))
    {
        return true;
    }
    if (arg0.now < (arg0.perception.switch_at + _c.switch_cooldown_seconds))
    {
        return false;
    }
    if (!_k.visible && (arg0.now - _k.observed_at) >= _c.unseen_switch_seconds)
    {
        return true;
    }
    return _new < (_old * _c.closer_ratio) && (_old - _new) >= _c.min_gain_px;
}

function ai_perception_step(arg0)
{
    var _p = arg0.perception;
    if (_p.last_step == arg0.step)
    {
        exit;
    }
    _p.last_step = arg0.step;
    _p.checks = 0;
    _p.los_checks = 0;
    var _npc = arg0.npc;
    var _k = arg0.knowledge;
    if (!_p.alert_visible)
    {
        _p.alert = max(0, _p.alert - 0.5);
    }
    _k.visible = false;
    if (_npc.grenade_flash)
    {
        _k.visible = false;
        _p.alert_visible = false;
        _p.tracking.armed = false;
        _p.tracking.active = false;
        _p.tracking.clue = undefined;
        exit;
    }
    if (is_in_hub())
    {
        ai_perception_forget(arg0, "hub");
        _npc.alert_player = 0;
        exit;
    }
    var _view = __ai_perception_view(_npc);
    if (_k.valid)
    {
        if (!__ai_perception_hostile(_npc, _k.target))
        {
            ai_perception_forget(arg0, "invalid_target");
        }
        else
        {
            var _observation = __ai_perception_probe(arg0, _k.target, _view);
            if (!is_undefined(_observation))
            {
                __ai_perception_sight(arg0, _k.target, _observation);
            }
        }
    }
    var _interval = __ai_perception_interval(arg0);
    if ((arg0.now + 0.0000001) >= _p.next_probe)
    {
        var _steps = min(_interval, max(1, round((arg0.now - _p.last_probe) * 60)));
        _p.last_probe = arg0.now;
        _p.next_probe = arg0.now + (_interval / 60);
        var _player = player_nearest_instance(_npc.x, _npc.y);
        var _player_observation = __ai_perception_probe(arg0, _player, _view);
        var _player_visible = !is_undefined(_player_observation);
        if (_player != _p.alert_target)
        {
            _p.alert = 0;
            _p.alert_visible = false;
            _p.alert_target = _player;
        }
        if (_player_visible)
        {
            var _credit_steps = _p.alert_visible ? _steps : 1;
            var _ghillie = _player.armor_now == "armor_ghillie";
            var _gain = __ai_perception_alert_gain(_player_observation.distance, _view.distance, _ghillie, _credit_steps);
            var _awareness = arg0.profile.config.awareness;
            if (_awareness.enabled)
            {
                _gain *= (_awareness.acquisition_multiplier * (__ai_profile_contains(["rookie", "intermediate"], arg0.profile.config.training) ? 1 : _awareness.trained_multiplier));
            }
            if (arg0.profile.config.training == "master" && abs(angle_difference(point_direction(_npc.x, _npc.y, _player_observation.x, _player_observation.y), _npc.weapon_pointing_direction)) <= (_view.angle / 2))
            {
                _gain = max(_gain, _npc.alert_player_max * (_ghillie ? 0.5 : 1));
            }
            _p.alert += _gain;
            if ((_p.alert >= _npc.alert_player_max || _player_observation.distance <= _view.minimum) && __ai_perception_prefer(arg0, _player, _player_observation, _view))
            {
                __ai_perception_sight(arg0, _player, _player_observation);
            }
        }
        _p.alert_visible = _player_visible;
        _p.alert = clamp(_p.alert, 0, _npc.alert_player_max);
        if (!_k.valid || arg0.profile.config.targeting.enabled)
        {
            var _count = instance_number(obj_npc_parent);
            var _limit = min(_k.valid ? 4 : 12, _count);
            var _best = -4;
            var _best_observation = undefined;
            for (var _i = 0; _i < _limit; _i++)
            {
                var _candidate = instance_find(obj_npc_parent, _p.scan_cursor % max(1, _count));
                _p.scan_cursor = (_p.scan_cursor + 1) % max(1, _count);
                if (_candidate == _k.target)
                {
                    continue;
                }
                var _observation = __ai_perception_probe(arg0, _candidate, _view);
                if (!is_undefined(_observation) && __ai_perception_prefer(arg0, _candidate, _observation, _view) && (is_undefined(_best_observation) || _observation.distance < _best_observation.distance))
                {
                    _best = _candidate;
                    _best_observation = _observation;
                }
            }
            if (!is_undefined(_best_observation))
            {
                __ai_perception_sight(arg0, _best, _best_observation);
            }
        }
    }
    _npc.alert_player = _p.alert;
    if (_k.valid && !_k.visible && arg0.now >= _p.search_until && (arg0.now - _k.observed_at) >= (arg0.profile.config.pursuit.lost_contact_seconds + arg0.profile.config.pursuit.search_seconds))
    {
        ai_perception_forget(arg0, "memory_expired");
    }
    else if (_k.valid && !_k.visible && _p.resumed_until > 0 && arg0.now >= _p.resumed_until)
    {
        ai_perception_forget(arg0, "memory_expired");
    }
    if (!_k.valid)
    {
        __ai_perception_resume_previous(arg0);
    }
    ai_tracking_step(arg0);
}

function __ai_tracking_create()
{
    return 
    {
        room_id: room,
        armed: false,
        active: false,
        serial: 0,
        until: 0,
        last_step: -1,
        clue: undefined,
        seen_at: -1000,
        seen_x: 0,
        seen_y: 0,
        from_ally: false,
        offset_x: undefined,
        offset_y: undefined
    };
}

function ai_tracking_sighting(arg0, arg1)
{
    var _k = arg0.knowledge;
    var _t = arg0.perception.tracking;
    var _c = arg0.profile.config.pursuit;
    if (_c.tracking_seconds <= 0 || !_k.valid || !instance_exists(_k.target) || !object_is_player(_k.target) || arg0.npc.grenade_flash || (_k.observed_at + _c.tracking_seconds) <= arg0.now || _k.observed_at < _t.seen_at)
    {
        exit;
    }
    _t.armed = true;
    _t.active = false;
    _t.clue = undefined;
    _t.seen_at = _k.observed_at;
    _t.seen_x = _k.x;
    _t.seen_y = _k.y;
    _t.from_ally = arg1;
    _t.until = _t.seen_at + _c.tracking_seconds;
}

function ai_tracking_step(arg0)
{
    var _p = arg0.perception;
    var _t = _p.tracking;
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.pursuit;
    if (_t.last_step == arg0.step)
    {
        exit;
    }
    _t.last_step = arg0.step;
    if (_t.room_id != room || !_k.valid || !instance_exists(_k.target) || !object_is_player(_k.target) || _c.tracking_seconds <= 0 || arg0.npc.grenade_flash)
    {
        if (_t.room_id != room || _t.armed || _t.active || is_struct(_t.clue) || _t.seen_at > -1000)
        {
            _p.tracking = __ai_tracking_create();
        }
        exit;
    }
    if (_k.visible)
    {
        exit;
    }
    if (_t.armed)
    {
        _t.armed = false;
        if (arg0.now >= _t.until)
        {
            exit;
        }
        _t.serial++;
        _t.active = true;
        if (is_undefined(_t.offset_x))
        {
            var _angle = ai_profile_random(arg0.rng) * 360;
            var _radius = _c.tracking_uncertainty_px * sqrt(ai_profile_random(arg0.rng));
            _t.offset_x = lengthdir_x(_radius, _angle);
            _t.offset_y = lengthdir_y(_radius, _angle);
        }
        _t.clue = 
        {
            valid: true,
            target: _k.target,
            source: "delayed_track",
            visible: false,
            from_ally: _t.from_ally,
            x: _t.seen_x,
            y: _t.seen_y,
            observed_at: _t.seen_at,
            sampled_at: _t.seen_at,
            expires: _t.seen_at + _c.lost_contact_seconds + _c.search_seconds,
            uncertainty: _c.tracking_uncertainty_px,
            revision: _t.serial,
            settled: false,
            corrected: false,
            offset_x: _t.offset_x,
            offset_y: _t.offset_y,
            escape_direction: ai_contact_direction(arg0, _k)
        };
    }
    if (!_t.active)
    {
        exit;
    }
    if (arg0.now >= _t.until)
    {
        _t.active = false;
        _t.clue.settled = true;
        exit;
    }
    _t.clue.x = _k.target.x + _t.clue.offset_x;
    _t.clue.y = _k.target.y + _t.clue.offset_y;
    _t.clue.sampled_at = arg0.now;
}

function ai_contact_focus(arg0)
{
    var _k = arg0.knowledge;
    var _t = arg0.perception.tracking;
    var _clue = _t.clue;
    if (_k.visible)
    {
        return _k;
    }
    if (_k.valid && !arg0.npc.grenade_flash && _t.room_id == room && arg0.profile.config.pursuit.tracking_seconds > 0 && (_t.armed || _t.active) && arg0.now < _t.until)
    {
        return _k;
    }
    var _heard = arg0.perception.hearing.clue;
    var _focus = __ai_hearing_fresh(arg0, _heard) ? _heard : _k;
    if (arg0.npc.grenade_flash || _t.room_id != room || !is_struct(_clue) || !_clue.settled || !_k.valid || _clue.target != _k.target || arg0.now >= _clue.expires || arg0.profile.config.pursuit.tracking_seconds <= 0 || (arg0.perception.search_until > 0 && arg0.now >= arg0.perception.search_until))
    {
        return _focus;
    }
    var _at = (_focus == _k) ? _focus.observed_at : (arg0.now - (max(0, ai_world_get().frame - _focus.frame) / 60));
    return (_at > (_clue.sampled_at + 0.000001)) ? _focus : _clue;
}

function ai_movement_snapshot(arg0)
{
    var _f = ai_contact_focus(arg0);
    return 
    {
        valid: _f.valid,
        target: _f.target,
        x: _f.x,
        y: _f.y,
        revision: _f.revision,
        escape_direction: ai_contact_direction(arg0, _f),
        tracking_serial: (_f == arg0.perception.tracking.clue) ? _f.revision : 0
    };
}

function ai_tracking_draw(arg0)
{
    var _t = arg0.perception.tracking;
    var _c = _t.clue;
    if (!is_struct(_c) || (!_t.active && ai_contact_focus(arg0) != _c))
    {
        exit;
    }
    var _colour = draw_get_color();
    var _alpha = draw_get_alpha();
    draw_set_color(c_orange);
    draw_set_alpha(0.65);
    draw_circle(_c.x, _c.y, max(4, _c.uncertainty), true);
    draw_text(_c.x + 5, _c.y, (_c.from_ally ? "ally " : "") + (_t.active ? ("tracking " + string_format(max(0, _t.until - arg0.now), 1, 1)) : "movement clue (frozen)"));
    draw_set_color(_colour);
    draw_set_alpha(_alpha);
}

function ai_perception_can_fire(arg0)
{
    var _k = arg0.knowledge;
    if (!_k.valid || is_in_hub() || arg0.npc.grenade_flash)
    {
        return false;
    }
    var _observation = __ai_perception_probe(arg0, _k.target, __ai_perception_view(arg0.npc));
    _k.visible = !is_undefined(_observation);
    if (!_k.visible)
    {
        return false;
    }
    return __ai_perception_sight(arg0, _k.target, _observation);
}

function ai_perception_bind_player_flash(arg0, arg1)
{
    if (!instance_exists(arg0) || !instance_exists(arg1) || arg1.alarm[0] <= 0)
    {
        exit;
    }
    arg1.affected_player = arg0;
    var _old = variable_instance_exists(arg0, "ai_flash_effect") ? arg0.ai_flash_effect : -4;
    if (!instance_exists(_old) || _old.object_index != obj_hud_effect_flash || _old.stop || _old.alarm[0] <= arg1.alarm[0])
    {
        arg0.ai_flash_effect = arg1;
    }
}

function __ai_perception_flash_sight(arg0, arg1, arg2)
{
    if (!variable_struct_exists(arg0, "combat") || !variable_struct_exists(arg0.combat, "adaptation") || !arg0.profile.config.flash_push.enabled || !instance_exists(arg1) || (arg1.object_index != obj_player_parent && !object_is_ancestor(arg1.object_index, obj_player_parent)))
    {
        exit;
    }
    var _p = arg0.perception;
    var _previous = _p.flash;
    var _effect = variable_instance_exists(arg1, "ai_flash_effect") ? arg1.ai_flash_effect : -4;
    var _remaining = 0;
    if (instance_exists(_effect) && _effect.object_index == obj_hud_effect_flash && variable_instance_exists(_effect, "affected_player") && _effect.affected_player == arg1 && !_effect.stop && _effect.a > 0)
    {
        _remaining = max(0, _effect.alarm[0]) / 60;
    }
    _p.flash = 
    {
        target: arg1,
        effect: _effect,
        active: _remaining > 0,
        shared: false,
        x: arg2.x,
        y: arg2.y,
        frame: ai_world_get().frame,
        remaining: min(_remaining, arg0.profile.config.flash_push.opportunity_seconds)
    };
    if (_remaining <= 0)
    {
        arg0.combat.adaptation.flash_cue = undefined;
        exit;
    }
    if (!is_struct(_previous) || !_previous.active || _previous.target != arg1 || _previous.effect != _effect)
    {
        __ai_human_opportunity_notice(arg0, "flash_push", arg1, arg2.x, arg2.y, 0, false, _remaining);
    }
}

function __ai_perception_wound_sight(arg0, arg1, arg2)
{
    var _c = arg0.profile.config.vulnerability;
    if (!_c.enabled || !instance_exists(arg1) || (arg1.object_index != obj_player_parent && !object_is_ancestor(arg1.object_index, obj_player_parent)) || !variable_instance_exists(arg1, "hp") || !variable_instance_exists(arg1, "hp_max"))
    {
        exit;
    }
    var _p = arg0.perception;
    var _w = _p.wound;
    var _continuous = is_struct(_w) && _w.target == arg1 && (arg0.now - _w.at) <= _c.retreat_window_seconds && _p.last_direct_step >= (arg0.step - __ai_perception_interval(arg0) - 1);
    if (!_continuous)
    {
        _w = 
        {
            target: arg1,
            at: arg0.now,
            hp: arg1.hp,
            low: false,
            bleeding: false,
            hit_at: -1000,
            retreat_at: -1000,
            sample_at: arg0.now,
            ox: arg0.npc.x,
            oy: arg0.npc.y,
            x: arg2.x,
            y: arg2.y
        };
        _p.wound = _w;
    }
    if (_continuous && arg1.hp < _w.hp)
    {
        _w.hit_at = arg0.now;
    }
    _w.hp = arg1.hp;
    _w.at = arg0.now;
    _w.low = (arg1.hp / max(1, arg1.hp_max)) <= _c.low_health_ratio;
    _w.bleeding = variable_instance_exists(arg1, "bleed") && arg1.bleed > 0;
    var _wounded = _w.low || _w.bleeding || (arg0.now - _w.hit_at) <= _c.hit_memory_seconds;
    if (_continuous && _wounded && (arg0.now - _w.sample_at) <= _c.retreat_window_seconds && (point_distance(_w.ox, _w.oy, arg2.x, arg2.y) - point_distance(_w.ox, _w.oy, _w.x, _w.y)) >= _c.retreat_distance_px)
    {
        _w.retreat_at = arg0.now;
        _w.sample_at = -1000;
    }
    if ((arg0.now - _w.sample_at) > _c.retreat_window_seconds)
    {
        _w.sample_at = arg0.now;
        _w.x = arg2.x;
        _w.y = arg2.y;
        _w.ox = arg0.npc.x;
        _w.oy = arg0.npc.y;
    }
}

function ai_perception_vulnerability(arg0)
{
    var _c = arg0.profile.config.vulnerability;
    var _w = arg0.perception.wound;
    if (!_c.enabled || !arg0.knowledge.valid || !is_struct(_w) || _w.target != arg0.knowledge.target || (arg0.now - _w.at) > _c.memory_seconds)
    {
        return 0;
    }
    var _strength = (_w.low || _w.bleeding || (arg0.now - _w.hit_at) <= _c.hit_memory_seconds) ? _c.wounded_strength : 0;
    if ((arg0.now - _w.retreat_at) <= _c.memory_seconds)
    {
        _strength = max(_strength, _c.retreat_strength);
    }
    return _strength * variable_struct_get(_c, arg0.profile.config.training + "_scale");
}

function ai_hearing_emit(arg0, arg1)
{
    if (!instance_exists(arg0) || is_in_hub() || (arg0.object_index != obj_player_parent && !object_is_ancestor(arg0.object_index, obj_player_parent)) || !variable_instance_exists(arg0, "hp") || arg0.hp <= 0 || !variable_instance_exists(arg0, "hspd") || !variable_instance_exists(arg0, "vspd") || (arg0.hspd == 0 && arg0.vspd == 0) || (variable_instance_exists(arg0, "mp_index") && player_state_is(arg0.mp_index, scr_player_state_start, scr_player_state_free_camera)))
    {
        return false;
    }
    var _world = ai_world_get();
    if (!variable_struct_exists(_world, "footsteps"))
    {
        _world.footsteps = array_create(16, undefined);
        _world.footstep_cursor = 0;
        _world.footstep_serial = 0;
    }
    for (var _i = 0; _i < 16; _i++)
    {
        var _old = _world.footsteps[_i];
        if (is_struct(_old) && _old.target == arg0 && _old.frame == _world.frame)
        {
            return false;
        }
    }
    _world.footsteps[_world.footstep_cursor] = 
    {
        target: arg0,
        x: arg0.x,
        y: arg0.y,
        running: arg1,
        frame: _world.frame,
        serial: ++_world.footstep_serial
    };
    _world.footstep_cursor = (_world.footstep_cursor + 1) % 16;
    return true;
}

function __ai_hearing_target(arg0)
{
    if (arg0.knowledge.valid)
    {
        return arg0.knowledge.target;
    }
    if (variable_struct_exists(arg0, "withdrawal") && arg0.withdrawal.active && arg0.withdrawal.room_id == room && __ai_withdrawal_enabled(arg0))
    {
        return arg0.withdrawal.target;
    }
    return -4;
}

function __ai_hearing_eligible(arg0, arg1 = false)
{
    var _target = __ai_hearing_target(arg0);
    return arg0.profile.config.hearing.enabled && (arg1 || !arg0.knowledge.visible) && !arg0.npc.grenade_flash && !is_in_hub() && instance_exists(_target) && object_is_player(_target) && __ai_perception_hostile(arg0.npc, _target);
}

function __ai_hearing_fresh(arg0, arg1)
{
    if (!is_struct(arg1) || !__ai_hearing_eligible(arg0) || arg1.target != __ai_hearing_target(arg0) || arg0.perception.hearing.room_id != room || (arg0.perception.search_until > 0 && arg0.now >= arg0.perception.search_until))
    {
        return false;
    }
    var _age = max(0, ai_world_get().frame - arg1.frame) / 60;
    return _age <= min(arg1.lifetime, arg0.profile.config.hearing.memory_seconds) && (arg0.now - _age) > (arg0.knowledge.observed_at + arg0.profile.config.hearing.sight_priority_seconds) && ((!arg0.knowledge.valid && variable_struct_exists(arg0, "withdrawal") && arg0.withdrawal.active) || (arg0.now - arg0.knowledge.observed_at) < (arg0.profile.config.pursuit.lost_contact_seconds + arg0.profile.config.pursuit.search_seconds));
}

function __ai_hearing_source(arg0)
{
    return arg0.source == "footstep" || arg0.source == "heard_action";
}

function ai_hearing_active(arg0)
{
    return __ai_hearing_source(ai_contact_focus(arg0));
}

function __ai_perception_medication(arg0)
{
    if (!variable_instance_exists(arg0, "arms_holder"))
    {
        return undefined;
    }
    var _arms = arg0.arms_holder;
    return (is_struct(_arms) && variable_struct_exists(_arms, "item_id") && (!variable_struct_exists(_arms, "destroyed") || !_arms.destroyed) && item_get_category(_arms.item_id) == "medication") ? _arms : undefined;
}

function __ai_hearing_actions(arg0)
{
    var _h = arg0.perception.hearing;
    var _c = arg0.profile.config.hearing;
    var _target = arg0.knowledge.target;
    if (!_c.actions_enabled || (arg0.perception.search_until > 0 && arg0.now >= arg0.perception.search_until) || (arg0.now - arg0.knowledge.observed_at) >= (arg0.profile.config.pursuit.lost_contact_seconds + arg0.profile.config.pursuit.search_seconds))
    {
        exit;
    }
    var _distance = point_distance(arg0.npc.x, arg0.npc.y, _target.x, _target.y);
    if (_distance > _c.action_radius_px)
    {
        exit;
    }
    if (!ai_world_take_hearing())
    {
        _h.next_at = arg0.now + 0.016666666666666666;
        _h.reason = "deferred";
        exit;
    }
    var _blocked = collision_line(arg0.npc.x, arg0.npc.y, _target.x, _target.y, obj_solid, true, false) != -4;
    if (_blocked && _distance > (_c.action_radius_px * _c.wall_range_multiplier))
    {
        exit;
    }
    if (_h.action_target != _target)
    {
        _h.action_target = _target;
        _h.reload_active = false;
        _h.medicine = undefined;
    }
    var _reload = variable_instance_exists(_target, "reloading") && _target.reloading;
    var _medicine = __ai_perception_medication(_target);
    var _action = (is_struct(_medicine) && _medicine != _h.medicine) ? "heal" : ((_reload && !_h.reload_active) ? "reload" : "");
    _h.reload_active = _reload;
    _h.medicine = _medicine;
    _h.action = is_struct(_medicine) ? "heal" : (_reload ? "reload" : "");
    _h.sampled_frame = ai_world_get().frame;
    if (!_reload)
    {
        arg0.combat.adaptation.reload_cue = undefined;
    }
    if (!is_struct(_medicine))
    {
        arg0.combat.adaptation.heal_cue = undefined;
    }
    if (_action == "")
    {
        exit;
    }
    var _uncertainty = _c.walk_uncertainty_px + (_blocked ? _c.wall_uncertainty_px : 0);
    var _angle = ai_profile_random(arg0.rng) * 360;
    var _offset = lerp(0.35, 1, ai_profile_random(arg0.rng)) * _uncertainty;
    var _x = clamp(_target.x + lengthdir_x(_offset, _angle), 4, room_width - 5);
    var _y = clamp(_target.y + lengthdir_y(_offset, _angle), 4, room_height - 5);
    var _frame = ai_world_get().frame;
    var _kind = _action + "_push";
    var _life = min(_c.memory_seconds, variable_struct_get(arg0.profile.config, _kind).opportunity_seconds);
    _h.clue = 
    {
        valid: true,
        visible: false,
        source: "heard_action",
        action: _action,
        target: _target,
        x: _x,
        y: _y,
        frame: _frame,
        serial: _frame,
        revision: -1000000 - _frame,
        shared: false,
        uncertainty: _uncertainty,
        lifetime: _life,
        running: false,
        escape_direction: point_direction(arg0.knowledge.x, arg0.knowledge.y, _x, _y)
    };
    _h.update_at = arg0.now + _c.update_seconds;
    _h.reason = "heard_" + _action;
    __ai_human_opportunity_notice(arg0, _kind, _target, _x, _y, 0, false, _life, true);
}

function ai_hearing_step(arg0)
{
    var _h = arg0.perception.hearing;
    var _c = arg0.profile.config.hearing;
    if (_h.room_id != room)
    {
        _h.action_target = -4;
        _h.reload_active = false;
        _h.medicine = undefined;
        _h.room_id = room;
        _h.ready = undefined;
        _h.clue = undefined;
        _h.last_serial = 0;
        _h.next_at = 0;
        _h.update_at = 0;
    }
    if (arg0.now < _h.next_at || !__ai_hearing_eligible(arg0, true))
    {
        exit;
    }
    var _world = ai_world_get();
    _h.next_at = arg0.now + _c.listen_seconds;
    if (arg0.knowledge.valid && !arg0.knowledge.visible)
    {
        __ai_hearing_actions(arg0);
    }
    if (!variable_struct_exists(_world, "footsteps"))
    {
        exit;
    }
    var _event = undefined;
    for (var _i = 0; _i < 16; _i++)
    {
        var _candidate = _world.footsteps[_i];
        if (is_struct(_candidate) && _candidate.target == __ai_hearing_target(arg0) && _candidate.serial > _h.last_serial && (!is_struct(_event) || _candidate.serial > _event.serial))
        {
            _event = _candidate;
        }
    }
    if (!is_struct(_event))
    {
        exit;
    }
    var _age = max(0, _world.frame - _event.frame) / 60;
    if (_age > _c.event_max_age_seconds)
    {
        _h.last_serial = _event.serial;
        _h.reason = "old_or_visual";
        exit;
    }
    var _radius = _event.running ? _c.run_radius_px : _c.walk_radius_px;
    var _distance = point_distance(arg0.npc.x, arg0.npc.y, _event.x, _event.y);
    if (_distance > _radius)
    {
        _h.last_serial = _event.serial;
        _h.reason = "too_far";
        exit;
    }
    if (!ai_world_take_hearing())
    {
        _h.next_at = arg0.now + 0.016666666666666666;
        _h.reason = "deferred";
        exit;
    }
    _h.last_serial = _event.serial;
    var _blocked = collision_line(arg0.npc.x, arg0.npc.y, _event.x, _event.y, obj_solid, true, false) != -4;
    if (_blocked && _distance > (_radius * _c.wall_range_multiplier))
    {
        _h.reason = "muffled";
        exit;
    }
    var _uncertainty = (_event.running ? _c.run_uncertainty_px : _c.walk_uncertainty_px) + (_blocked ? _c.wall_uncertainty_px : 0);
    _h.ready = 
    {
        target: _event.target,
        x: _event.x,
        y: _event.y,
        frame: _event.frame
    };
    if (arg0.knowledge.visible || (arg0.now - _age) <= (arg0.knowledge.observed_at + _c.sight_priority_seconds))
    {
        _h.reason = "audible_visual";
        exit;
    }
    var _old = _h.clue;
    if (__ai_hearing_fresh(arg0, _old) && _old.source == "footstep" && !_old.shared && point_distance(_old.x, _old.y, _event.x, _event.y) <= max(_c.update_distance_px, _old.uncertainty))
    {
        _old.frame = _event.frame;
        _old.serial = _event.serial;
        _old.uncertainty = max(_uncertainty, point_distance(_old.x, _old.y, _event.x, _event.y));
        _h.reason = "reinforced";
        exit;
    }
    if (arg0.now < _h.update_at)
    {
        exit;
    }
    _h.update_at = arg0.now + _c.update_seconds;
    var _angle = ai_profile_random(arg0.rng) * 360;
    var _offset = lerp(0.35, 1, ai_profile_random(arg0.rng)) * _uncertainty;
    var _x = clamp(_event.x + lengthdir_x(_offset, _angle), 4, room_width - 5);
    var _y = clamp(_event.y + lengthdir_y(_offset, _angle), 4, room_height - 5);
    _h.clue = 
    {
        valid: true,
        visible: false,
        source: "footstep",
        target: _event.target,
        x: _x,
        y: _y,
        frame: _event.frame,
        serial: _event.serial,
        revision: -2 - _event.serial,
        shared: false,
        uncertainty: _uncertainty,
        lifetime: _c.memory_seconds,
        running: _event.running,
        escape_direction: point_direction(arg0.knowledge.x, arg0.knowledge.y, _x, _y)
    };
    _h.reason = _blocked ? "heard_muffled" : "heard";
}

function ai_hearing_share(arg0, arg1)
{
    if (!__ai_team_members(arg0, arg1) || !__ai_hearing_eligible(arg1) || !arg0.profile.config.hearing.enabled || (variable_instance_exists(arg0.npc, "can_talk") && !arg0.npc.can_talk))
    {
        return false;
    }
    var _c = arg1.profile.config.hearing;
    var _clue = arg0.perception.hearing.clue;
    if (is_struct(_clue) && _clue.source == "heard_action" && (!_c.actions_enabled || !arg0.profile.config.hearing.actions_enabled))
    {
        return false;
    }
    var _threshold = max(_c.share_teamwork_min, arg0.profile.config.hearing.share_teamwork_min);
    if (arg0.profile.personality.traits.teamwork < _threshold || arg1.profile.personality.traits.teamwork < _threshold || !is_struct(_clue) || _clue.shared || !__ai_hearing_fresh(arg0, _clue) || !__ai_hearing_fresh(arg1, _clue))
    {
        return false;
    }
    var _h = arg1.perception.hearing;
    var _old = _h.clue;
    if (is_struct(_old) && _old.frame >= _clue.frame)
    {
        return false;
    }
    if (arg1.now < _h.update_at)
    {
        return false;
    }
    if (_clue.source == "heard_action" && _h.action_target == _clue.target && _h.sampled_frame >= _clue.frame && _h.action != _clue.action)
    {
        return false;
    }
    _h.clue = variable_clone(_clue);
    _h.clue.shared = true;
    _h.update_at = arg1.now + _c.update_seconds;
    _h.reason = "ally_sound";
    var _sender_hearing = arg0.perception.hearing;
    var _ended = _sender_hearing.action_target == _clue.target && _sender_hearing.sampled_frame > _clue.frame && variable_struct_exists(_clue, "action") && _sender_hearing.action != _clue.action;
    if (_clue.source == "heard_action" && !_ended)
    {
        var _age = max(0, ai_world_get().frame - _clue.frame) / 60;
        __ai_human_opportunity_notice(arg1, _clue.action + "_push", _clue.target, _clue.x, _clue.y, _age, true, _clue.lifetime, true);
    }
    return true;
}

function ai_hearing_draw(arg0)
{
    var _clue = ai_contact_focus(arg0);
    if (!__ai_hearing_source(_clue))
    {
        exit;
    }
    var _colour = draw_get_color();
    var _alpha = draw_get_alpha();
    draw_set_color(c_aqua);
    draw_set_alpha(0.5);
    draw_circle(_clue.x, _clue.y, _clue.uncertainty, true);
    draw_circle(_clue.x, _clue.y, 3, false);
    draw_set_alpha(1);
    draw_text(_clue.x + 5, _clue.y, (_clue.shared ? "heard (ally)" : "heard") + ((_clue.source == "heard_action") ? (" " + _clue.action) : ""));
    draw_set_color(_colour);
    draw_set_alpha(_alpha);
}

function ai_contact_direction(arg0, arg1)
{
    if (arg1 != arg0.knowledge)
    {
        return arg1.escape_direction;
    }
    return arg0.perception.escape_valid ? arg0.perception.escape_direction : point_direction(arg0.knowledge.engagement_x, arg0.knowledge.engagement_y, arg1.x, arg1.y);
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3
}
