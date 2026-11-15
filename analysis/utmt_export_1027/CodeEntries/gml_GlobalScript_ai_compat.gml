function ai_compat_create(arg0)
{
    arg0.compat = 
    {
        last_step: -1,
        mode: "none",
        grenade: noone,
        grenade_cursor: 0,
        checks: 0,
        emission_active: false,
        emission_moved: false,
        retry_at: 0,
        last_reason: "initial",
        barked_grenade: noone,
        flash_barked: false,
        reactions: [],
        shelter: undefined
    };
}

function __ai_compat_grenade_reaction(arg0, arg1)
{
    var _reactions = arg0.compat.reactions;
    var _i = array_length(_reactions) - 1;
    while (_i >= 0)
    {
        if (_reactions[_i].grenade == arg1)
        {
            return _reactions[_i];
        }
        if (!instance_exists(_reactions[_i].grenade))
        {
            array_delete(_reactions, _i, 1);
        }
        _i--;
    }
    var _config = arg0.profile.config.grenade_evasion;
    var _npc = arg0.npc;
    var _reaction = 
    {
        grenade: arg1,
        react_at: arg0.now,
        delay: 0,
        missed: false,
        panic: false
    };
    if (_config.enabled)
    {
        var _tier = arg0.profile.config.training;
        var _delay_min = _config.rookie_min_seconds;
        var _delay_max = _config.rookie_max_seconds;
        if (_tier == "master" || _tier == "veteran")
        {
            _delay_min = _config.master_min_seconds;
            _delay_max = _config.master_max_seconds;
        }
        else if (_tier == "skilled" || _tier == "expert")
        {
            _delay_min = _config.skilled_min_seconds;
            _delay_max = _config.skilled_max_seconds;
        }
        var _delay_roll = ai_profile_random(arg0.rng);
        var _miss_roll = ai_profile_random(arg0.rng);
        var _panic_roll = ai_profile_random(arg0.rng);
        _reaction.delay = lerp(_delay_min, _delay_max, _delay_roll) * _config.reaction_scale;
        _reaction.react_at = arg0.now + _reaction.delay;
        var _facing = variable_instance_exists(_npc, "weapon_pointing_direction") ? _npc.weapon_pointing_direction : 0;
        var _off_view = abs(angle_difference(_facing, point_direction(_npc.x, _npc.y, arg1.x, arg1.y))) > (_config.view_angle_degrees / 2);
        var _tier_miss = variable_struct_exists(_config, _tier + "_miss_chance") ? variable_struct_get(_config, _tier + "_miss_chance") : 0;
        var _tier_panic = variable_struct_exists(_config, _tier + "_panic_chance") ? variable_struct_get(_config, _tier + "_panic_chance") : 0;
        _reaction.missed = _off_view && _miss_roll < min(1, _tier_miss * _config.miss_scale);
        _reaction.panic = _panic_roll < min(1, _tier_panic * _config.panic_scale);
    }
    if (array_length(_reactions) >= 8)
    {
        array_delete(_reactions, 0, 1);
    }
    array_push(_reactions, _reaction);
    return _reaction;
}

function __ai_compat_grenade_reacting(arg0, arg1)
{
    var _config = arg0.profile.config.grenade_evasion;
    if (_config.enabled && __ai_compat_grenade_in_flight(arg1))
    {
        return false;
    }
    var _reaction = __ai_compat_grenade_reaction(arg0, arg1);
    if (_reaction.missed && _config.ally_warning && variable_instance_exists(arg1, "ai_danger_bark_count") && arg1.ai_danger_bark_count > 0)
    {
        _reaction.missed = false;
        _reaction.react_at = max(_reaction.react_at, arg0.now + (_config.warned_reaction_seconds * _config.reaction_scale) + (_reaction.delay * 0.5));
    }
    return !_reaction.missed && arg0.now >= _reaction.react_at;
}

function __ai_compat_grenade_finished(arg0)
{
    if (!instance_exists(arg0))
    {
        return true;
    }
    return (variable_instance_exists(arg0, "explode") && arg0.explode) || (variable_instance_exists(arg0, "detonation_done") && arg0.detonation_done);
}

function __ai_compat_shelter_active(arg0)
{
    var _shelter = arg0.compat.shelter;
    if (!is_struct(_shelter))
    {
        return false;
    }
    var _npc = arg0.npc;
    var _grenade = _shelter.grenade;
    var _active = arg0.now < _shelter.until && !__ai_compat_grenade_finished(_grenade) && collision_line(_npc.x, _npc.y, _grenade.x, _grenade.y, obj_solid, true, false) != -4;
    if (!_active)
    {
        arg0.compat.shelter = undefined;
    }
    return _active;
}

function __ai_compat_grenade_in_flight(arg0)
{
    if (!variable_instance_exists(arg0, "distance_travelled") || !variable_instance_exists(arg0, "detonation_point"))
    {
        return false;
    }
    if (variable_instance_exists(arg0, "throw_type") && arg0.throw_type == "GRENADE_throw_no_move")
    {
        return false;
    }
    if (variable_instance_exists(arg0, "explode") && arg0.explode)
    {
        return false;
    }
    return arg0.distance_travelled < arg0.detonation_point;
}

function __ai_compat_own_team_grenade(arg0, arg1)
{
    if (!variable_instance_exists(arg1, "ai_thrower"))
    {
        return false;
    }
    if (arg1.ai_thrower == arg0)
    {
        return true;
    }
    if (arg1.faction != arg0.faction || faction_get_rep_temp(arg0.faction, arg1.faction) < 250)
    {
        return false;
    }
    var _team_id = __ai_team_id(arg0);
    var _thrower_team_id = arg1.ai_thrower_team_id;
    var _npc_is_hunter = ai_human_migrated(arg0) && arg0.ai_execution.profile.config.profile == "hunter";
    if (_npc_is_hunter || arg1.ai_thrower_is_hunter)
    {
        return !is_undefined(_team_id) && _team_id == _thrower_team_id;
    }
    return is_undefined(_team_id) || is_undefined(_thrower_team_id) || _team_id == _thrower_team_id;
}

function __ai_compat_touching_mine(arg0, arg1)
{
    var _step_margin_px = 4;
    return (arg0.bbox_right + _step_margin_px) >= arg1.bbox_left && (arg0.bbox_left - _step_margin_px) <= arg1.bbox_right && (arg0.bbox_bottom + _step_margin_px) >= arg1.bbox_top && (arg0.bbox_top - _step_margin_px) <= arg1.bbox_bottom;
}

function __ai_compat_grenade_danger(arg0, arg1)
{
    if (!instance_exists(arg1) || !variable_instance_exists(arg1, "radius_min_damage"))
    {
        return false;
    }
    if (variable_instance_exists(arg1, "detonation_type") && arg1.detonation_type == "GRENADE_detonation_smoke")
    {
        return false;
    }
    var _radius = arg1.radius_min_damage;
    if (!__ai_profile_number(_radius) || _radius <= 0)
    {
        return false;
    }
    if (variable_instance_exists(arg1, "throw_type") && arg1.throw_type == "GRENADE_throw_no_move")
    {
        if (arg1.fuse_time_now >= arg1.fuse_time)
        {
            return false;
        }
        if (!__ai_compat_touching_mine(arg0, arg1))
        {
            return false;
        }
    }
    if (point_distance(arg0.x, arg0.y, arg1.x, arg1.y) > (_radius + 8))
    {
        return false;
    }
    if (__ai_compat_grenade_in_flight(arg1) && __ai_compat_own_team_grenade(arg0, arg1))
    {
        return false;
    }
    return collision_line(arg0.x, arg0.y, arg1.x, arg1.y, obj_solid, true, false) == -4;
}

function __ai_compat_emission(arg0)
{
    if (!variable_global_exists("is_emission_now") || !global.is_emission_now || !variable_global_exists("state_emission_now") || global.state_emission_now <= UnknownEnum.Value_16)
    {
        return false;
    }
    var _map = instance_find(obj_map_generator, 0);
    return instance_exists(_map) && variable_instance_exists(_map, "map_height") && arg0.y < _map.map_height;
}

function ai_compat_step(arg0)
{
    var _c = arg0.compat;
    if (_c.last_step == arg0.step)
    {
        exit;
    }
    _c.last_step = arg0.step;
    _c.checks = 0;
    var _npc = arg0.npc;
    if (_npc.grenade_flash)
    {
        if (!variable_instance_exists(_npc, "grenade_flash_timer"))
        {
            _npc.grenade_flash_timer = 0;
        }
        var _duration = variable_instance_exists(_npc, "grenade_flash_timer_max") ? _npc.grenade_flash_timer_max : 180;
        _npc.grenade_flash_timer += 1;
        if (_npc.grenade_flash_timer >= max(1, _duration))
        {
            _npc.grenade_flash = false;
            _npc.grenade_flash_timer = 0;
        }
    }
    if (!_npc.grenade_flash)
    {
        _c.flash_barked = false;
    }
    var _emission = __ai_compat_emission(_npc);
    if (!_emission)
    {
        _c.emission_moved = false;
    }
    _c.emission_active = _emission;
    if (!__ai_compat_grenade_danger(_npc, _c.grenade) || !__ai_compat_grenade_reacting(arg0, _c.grenade))
    {
        _c.grenade = -4;
    }
    var _count = instance_number(obj_grenade_parent);
    for (var _i = 0; _i < min(8, _count); _i++)
    {
        var _grenade = instance_find(obj_grenade_parent, _c.grenade_cursor % max(1, _count));
        _c.grenade_cursor = (_c.grenade_cursor + 1) % max(1, _count);
        _c.checks++;
        if (__ai_compat_grenade_danger(_npc, _grenade) && __ai_compat_grenade_reacting(arg0, _grenade))
        {
            if (_c.grenade == -4 || point_distance(_npc.x, _npc.y, _grenade.x, _grenade.y) < point_distance(_npc.x, _npc.y, _c.grenade.x, _c.grenade.y))
            {
                _c.grenade = _grenade;
            }
        }
    }
    var _sheltering = _c.grenade == -4 && __ai_compat_shelter_active(arg0);
    _c.mode = _npc.grenade_flash ? "flash" : ((_c.grenade != -4) ? "grenade" : (_sheltering ? "shelter" : (_emission ? "emission" : "none")));
}

function ai_compat_danger(arg0)
{
    return arg0.compat.mode != "none";
}

function ai_compat_danger_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    ai_spatial_release(_e);
    _e.combat.cover = undefined;
    _e.combat.peek_return = false;
    _e.combat.committed = false;
    arg1.data.mode = _e.compat.mode;
    arg1.data.hazard = _e.compat.grenade;
    var _evasion = _e.profile.config.grenade_evasion;
    var _cover_first = _e.compat.mode == "grenade" && _evasion.cover_enabled && !__ai_compat_grenade_reaction(_e, _e.compat.grenade).panic;
    arg1.data.cursor = _cover_first ? 0 : 24;
    arg1.data.destination_is_cover = false;
    arg1.data.destination = undefined;
    arg1.data.pending = undefined;
    arg1.data.late_run = undefined;
    arg1.data.ox = _e.npc.x;
    arg1.data.oy = _e.npc.y;
    arg1.data.since = _e.now;
    ai_commands_stop(_e, arg1.token);
    if (_e.compat.mode == "flash" && !_e.compat.flash_barked)
    {
        _e.compat.flash_barked = true;
        ai_compat_callout(_e.npc, "flash");
    }
    else if (_e.compat.mode == "grenade")
    {
        __ai_compat_grenade_callout(_e);
    }
}

function __ai_compat_grenade_callout(arg0)
{
    var _c = arg0.compat;
    var _grenade = _c.grenade;
    var _npc = arg0.npc;
    if (!instance_exists(_grenade) || _c.barked_grenade == _grenade)
    {
        exit;
    }
    _c.barked_grenade = _grenade;
    if (!variable_instance_exists(_grenade, "ai_danger_bark_count"))
    {
        _grenade.ai_danger_bark_count = 0;
    }
    var _faction_name = variable_instance_exists(_npc, "faction") ? _npc.faction : "";
    var _bark_limit = ai_barks_speaking_rule(_faction_name, "danger_barks_per_grenade");
    if (is_numeric(_bark_limit) && _bark_limit > 0 && _grenade.ai_danger_bark_count >= _bark_limit)
    {
        exit;
    }
    if (ai_compat_callout(_npc, "danger"))
    {
        _grenade.ai_danger_bark_count += 1;
    }
}

function __ai_compat_escape_safe(arg0, arg1, arg2)
{
    return point_distance(arg0, arg1, arg2.x, arg2.y) >= (arg2.radius_min_damage + 12) || collision_line(arg0, arg1, arg2.x, arg2.y, obj_solid, true, false) != -4;
}

function __ai_compat_escape_query(arg0, arg1)
{
    var _d = arg1.data;
    var _grenade = arg0.compat.grenade;
    var _emission = arg0.compat.mode == "emission";
    var _evasion = arg0.profile.config.grenade_evasion;
    while (_d.cursor < 56)
    {
        if (is_undefined(_d.pending))
        {
            if (!ai_world_take_candidate(arg0))
            {
                return "deferred";
            }
            var _cover_phase = _d.cursor < 24;
            var _index = _cover_phase ? _d.cursor : (_d.cursor - 24);
            _d.cursor++;
            var _away = _emission ? 0 : point_direction(_grenade.x, _grenade.y, _d.ox, _d.oy);
            var _angle = _away + ((_index % 8) * 45);
            var _distance = 0;
            if (_cover_phase)
            {
                _distance = (_evasion.cover_distance_px * (1 + (_index div 8))) / 3;
            }
            else
            {
                _distance = _emission ? (48 + ((_index div 8) * 16)) : (max(32, (_grenade.radius_min_damage + _evasion.fallback_margin_px) - point_distance(_d.ox, _d.oy, _grenade.x, _grenade.y)) + ((_index div 8) * 16));
            }
            var _x = _d.ox + lengthdir_x(_distance, _angle);
            var _y = _d.oy + lengthdir_y(_distance, _angle);
            if (!ai_world_position_valid(arg0, _x, _y))
            {
                continue;
            }
            if (_cover_phase && collision_line(_x, _y, _grenade.x, _grenade.y, obj_solid, true, false) == -4)
            {
                continue;
            }
            if (!_emission && !__ai_compat_escape_safe(_x, _y, _grenade))
            {
                continue;
            }
            _d.pending = 
            {
                x: _x,
                y: _y,
                cover: _cover_phase
            };
        }
        var _point = _d.pending;
        var _status = ai_world_path(arg0, arg0.spatial.probe, arg0.npc.x, arg0.npc.y, _point.x, _point.y);
        if (_status == "deferred")
        {
            return _status;
        }
        _d.pending = undefined;
        if (_status != "found")
        {
            continue;
        }
        if (!_emission)
        {
            var _remaining = max(0, _grenade.fuse_time - _grenade.fuse_time_now);
            var _speed = __ai_human_speed(arg0);
            if (_speed <= 0)
            {
                continue;
            }
            var _timed = !variable_instance_exists(_grenade, "throw_type") || _grenade.throw_type != "GRENADE_throw_no_move";
            var _too_slow = _timed && path_get_length(arg0.spatial.probe) > (max(0, _remaining - 2) * _speed);
            var _minimum = point_distance(arg0.npc.x, arg0.npc.y, _grenade.x, _grenade.y) - 4;
            var _safe_route = true;
            for (var _i = 0; _i < path_get_number(arg0.spatial.probe); _i++)
            {
                if (point_distance(path_get_point_x(arg0.spatial.probe, _i), path_get_point_y(arg0.spatial.probe, _i), _grenade.x, _grenade.y) < _minimum)
                {
                    _safe_route = false;
                    break;
                }
            }
            if (!_safe_route)
            {
                continue;
            }
            if (_too_slow)
            {
                if (is_undefined(_d.late_run))
                {
                    _d.late_run = _point;
                }
                continue;
            }
        }
        _d.destination = _point;
        _d.destination_is_cover = _point.cover;
        return "found";
    }
    if (!_emission && !is_undefined(_d.late_run) && _evasion.enabled && _grenade.fuse_time_now < _grenade.fuse_time)
    {
        _d.destination = _d.late_run;
        _d.destination_is_cover = _d.late_run.cover;
        arg0.compat.last_reason = "late_run";
        return "found";
    }
    return "no_result";
}

function __ai_compat_begin_shelter(arg0, arg1)
{
    if (arg1.mode != "grenade" || !arg1.destination_is_cover || !arg0.profile.config.grenade_evasion.shelter)
    {
        exit;
    }
    var _grenade = arg1.hazard;
    if (__ai_compat_grenade_finished(_grenade))
    {
        exit;
    }
    if (variable_instance_exists(_grenade, "throw_type") && _grenade.throw_type == "GRENADE_throw_no_move")
    {
        exit;
    }
    arg0.compat.shelter = 
    {
        grenade: _grenade,
        until: arg0.now + arg0.profile.config.grenade_evasion.shelter_max_seconds
    };
}

function ai_compat_danger_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _c = _e.compat;
    var _d = arg1.data;
    if (_c.mode == "none")
    {
        __ai_compat_begin_shelter(_e, _d);
        return UnknownEnum.Value_1;
    }
    if (_c.mode != _d.mode || (_c.mode == "grenade" && _c.grenade != _d.hazard))
    {
        ai_commands_stop(_e, arg1.token);
        return UnknownEnum.Value_1;
    }
    if (_c.mode == "flash" || _c.mode == "shelter" || (_c.mode == "emission" && _c.emission_moved))
    {
        ai_commands_stop(_e, arg1.token);
        return UnknownEnum.Value_0;
    }
    if (_e.now < _c.retry_at)
    {
        ai_commands_stop(_e, arg1.token);
        return UnknownEnum.Value_0;
    }
    if ((_e.now - _d.since) >= 3)
    {
        _c.last_reason = "escape_deadline";
        if (_c.mode == "emission")
        {
            _c.emission_moved = true;
        }
        return UnknownEnum.Value_2;
    }
    if (is_undefined(_d.destination))
    {
        ai_commands_stop(_e, arg1.token);
        var _query = __ai_compat_escape_query(_e, arg1);
        if (_query == "deferred")
        {
            if ((_e.now - _d.since) < _e.profile.config.queries.max_defer_seconds)
            {
                return UnknownEnum.Value_0;
            }
            _c.last_reason = "escape_deferred_timeout";
            return UnknownEnum.Value_2;
        }
        if (_query != "found")
        {
            _c.last_reason = "no_escape";
            if (_c.mode == "emission")
            {
                _c.emission_moved = true;
            }
            return UnknownEnum.Value_2;
        }
    }
    if (_c.mode == "grenade" && !__ai_compat_escape_safe(_d.destination.x, _d.destination.y, _c.grenade))
    {
        _c.last_reason = "hazard_moved";
        return UnknownEnum.Value_2;
    }
    var _move = ai_commands_move(_e, arg1.token, _d.destination.x, _d.destination.y, __ai_human_speed(_e), 1);
    if (_move == "arrived")
    {
        if (_c.mode == "emission")
        {
            _c.emission_moved = true;
        }
        __ai_compat_begin_shelter(_e, _d);
        _c.last_reason = "escape_arrived";
        return UnknownEnum.Value_1;
    }
    if (_move == "failed")
    {
        _c.last_reason = "escape_blocked";
        return UnknownEnum.Value_2;
    }
    return UnknownEnum.Value_0;
}

function ai_compat_danger_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    if (arg2 == "failure" || arg2 == "timeout")
    {
        _e.compat.retry_at = _e.now + _e.profile.config.queries.retry_seconds;
    }
    else if (!is_struct(_e.compat.shelter))
    {
        __ai_compat_begin_shelter(_e, arg1.data);
    }
    __ai_human_action_exit(arg0, arg1, arg2);
}

function ai_compat_callout(arg0, arg1)
{
    if (!instance_exists(arg0) || !variable_instance_exists(arg0, "state"))
    {
        return false;
    }
    var _uses_behaviour_tree = ai_human_migrated(arg0);
    var _legacy_contact = arg1 == "contact" && !_uses_behaviour_tree && (arg0.state == "human_alert" || arg0.state == "human_shoot");
    if (arg0.state != "human_general" && !_legacy_contact)
    {
        return false;
    }
    if (variable_instance_exists(arg0, "can_talk") && !arg0.can_talk)
    {
        return false;
    }
    var _faction_name = variable_instance_exists(arg0, "faction") ? arg0.faction : "";
    var _urgent = _uses_behaviour_tree && ai_barks_is_urgent(_faction_name, arg1);
    var _frame = ai_world_get().frame;
    if (!_urgent && variable_instance_exists(arg0, "ai_callout_at") && _frame < arg0.ai_callout_at)
    {
        return false;
    }
    var _bubble_taken = false;
    with (obj_npc_draw_text)
    {
        if (!variable_instance_exists(id, "id_npc") || id_npc != arg0)
        {
            continue;
        }
        var _bubble_is_bark = variable_instance_exists(id, "bark_kind") && bark_kind != "";
        if (!_urgent || !_bubble_is_bark)
        {
            _bubble_taken = true;
        }
    }
    if (_bubble_taken)
    {
        return false;
    }
    if (!_uses_behaviour_tree)
    {
        return __ai_compat_legacy_callout(arg0, arg1, _frame);
    }
    var _lines = ai_barks_lines(_faction_name, arg1);
    if (array_length(_lines) == 0)
    {
        return false;
    }
    if (!_urgent)
    {
        if (!variable_instance_exists(arg0, "ai_bark_kind_frames"))
        {
            arg0.ai_bark_kind_frames = {};
        }
        var _last_frame_of_kind = variable_struct_get(arg0.ai_bark_kind_frames, arg1);
        if (is_numeric(_last_frame_of_kind) && _frame < (_last_frame_of_kind + ceil(ai_barks_speaking_rule(_faction_name, "same_kind_repeat_seconds") * 60)))
        {
            return false;
        }
        var _echo_radius_px = ai_barks_speaking_rule(_faction_name, "squad_echo_radius_px");
        var _already_said_nearby = false;
        with (obj_npc_draw_text)
        {
            if (!variable_instance_exists(id, "bark_kind") || bark_kind != arg1)
            {
                continue;
            }
            if (point_distance(x, y, arg0.x, arg0.y) <= _echo_radius_px)
            {
                _already_said_nearby = true;
            }
        }
        if (_already_said_nearby)
        {
            return false;
        }
        variable_struct_set(arg0.ai_bark_kind_frames, arg1, _frame);
    }
    var _previous_line = variable_instance_exists(arg0, "ai_bark_last_line") ? arg0.ai_bark_last_line : "";
    var _line = ai_barks_pick_line(_lines, _previous_line);
    arg0.ai_bark_last_line = _line;
    var _cooldown_seconds = arg0.ai_execution.profile.config.communication.callout_cooldown_seconds * ai_barks_cooldown_scale(_faction_name);
    arg0.ai_callout_at = _frame + ceil(_cooldown_seconds * 60);
    __ai_compat_show_bark(arg0, arg1, _line, _faction_name);
    return true;
}

function __ai_compat_show_bark(arg0, arg1, arg2, arg3)
{
    scr_draw_npc_text(arg0, UnknownEnum.Value_6);
    var _is_shout = ai_barks_is_heard_through_walls(arg3, arg1);
    var _hearing_radius_px = ai_barks_speaking_rule(arg3, "hearing_radius_px");
    var _unseen_alpha = ai_barks_speaking_rule(arg3, "unseen_alpha");
    with (obj_npc_draw_text)
    {
        if (!variable_instance_exists(id, "id_npc") || id_npc != arg0)
        {
            continue;
        }
        alarm[1] = -1;
        t = language_get_string(arg2);
        bark_kind = arg1;
        x = arg0.x;
        y = arg0.y;
        bark_heard_through_walls = _is_shout;
        bark_hearing_radius_px = _hearing_radius_px;
        bark_unseen_alpha = _unseen_alpha;
    }
}

function __ai_compat_legacy_callout(arg0, arg1, arg2)
{
    var _text = -1;
    switch (arg1)
    {
        case "contact":
            _text = UnknownEnum.Value_12;
            break;
        case "reload_spotted":
            _text = UnknownEnum.Value_12;
            break;
        case "push":
            _text = UnknownEnum.Value_8;
            break;
        case "reload":
            _text = UnknownEnum.Value_6;
            break;
        case "danger":
            _text = UnknownEnum.Value_16;
            break;
        case "flash":
            _text = UnknownEnum.Value_17;
            break;
    }
    if (_text == -1)
    {
        return false;
    }
    var _legacy_cooldown_seconds = 3;
    arg0.ai_callout_at = arg2 + ceil(_legacy_cooldown_seconds * 60);
    scr_draw_npc_text(arg0, _text);
    return true;
}

function ai_compat_legacy_observation(arg0)
{
    if (!instance_exists(arg0) || !variable_instance_exists(arg0, "target"))
    {
        return undefined;
    }
    if ((variable_instance_exists(arg0, "hp") && arg0.hp <= 0) || (variable_instance_exists(arg0, "grenade_flash") && arg0.grenade_flash))
    {
        return undefined;
    }
    var _target = arg0.target;
    if (!__ai_perception_hostile(arg0, _target))
    {
        return undefined;
    }
    if (variable_instance_exists(_target, "mp_index") && (!variable_instance_exists(arg0, "target_visto") || !arg0.target_visto) && (!variable_instance_exists(arg0, "alert_player") || !variable_instance_exists(arg0, "alert_player_max") || arg0.alert_player < arg0.alert_player_max))
    {
        return undefined;
    }
    var _scratch = 
    {
        npc: arg0,
        knowledge: 
        {
            valid: false
        },
        perception: 
        {
            checks: 0,
            total_checks: 0,
            los_checks: 0,
            total_los: 0
        }
    };
    var _observed = __ai_perception_probe(_scratch, _target, __ai_perception_view(arg0));
    if (is_undefined(_observed))
    {
        return undefined;
    }
    return 
    {
        target: _target,
        x: _observed.x,
        y: _observed.y
    };
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_6 = 6,
    Value_8 = 8,
    Value_12 = 12,
    Value_16 = 16,
    Value_17
}
