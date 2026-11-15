function ai_routines_create(arg0)
{
    arg0.routines = 
    {
        active: false,
        token: undefined,
        arms: noone,
        kind: "idle",
        next_leisure: 5,
        next_warning: 0,
        corpse_cursor: 0,
        seen_corpses: [],
        aim_player: noone,
        aim_until: 0,
        aim_next_line_at: 0,
        aim_line_pending: false,
        aim_line_kind: "aimed_at_neutral",
        aim_checked_step: -1000,
        seen_cursor: 0,
        last_reason: "initial",
        scan_next: 0.25 + ((arg0.profile.seed % 60) / 60),
        scan_until: 0,
        scan_count: 0,
        scan_home: arg0.npc.weapon_pointing_direction,
        scan_direction: arg0.npc.weapon_pointing_direction
    };
}

function ai_routines_scan(arg0, arg1, arg2)
{
    var _c = arg0.profile.config.awareness;
    if (!_c.enabled || arg0.knowledge.valid || arg0.npc.grenade_flash || is_in_hub())
    {
        exit;
    }
    var _r = arg0.routines;
    _r.scan_home = arg2;
    if (arg0.now >= _r.scan_next && arg0.now >= _r.scan_until)
    {
        _r.scan_count++;
        var _side = (((_r.scan_count + arg0.profile.seed) % 2) == 0) ? 1 : -1;
        var _angle = ((_r.scan_count % _c.rear_scan_every) == 0) ? 170 : _c.scan_angle_degrees;
        _r.scan_direction = arg2 + (_side * _angle);
        var _turn = abs(angle_difference(_r.scan_direction, arg0.npc.weapon_pointing_direction)) / max(1, arg0.npc.angle_increase_for_target) / 60;
        _r.scan_until = arg0.now + _turn + _c.scan_hold_seconds;
        _r.scan_next = _r.scan_until + lerp(_c.scan_min_seconds, _c.scan_max_seconds, ai_profile_random(arg0.rng));
    }
    var _direction = (arg0.now < _r.scan_until) ? _r.scan_direction : arg2;
    ai_commands_aim(arg0, arg1, arg0.npc.x + lengthdir_x(100, _direction), arg0.npc.y + lengthdir_y(100, _direction));
}

function __ai_routines_visible(arg0, arg1, arg2)
{
    if (!instance_exists(arg1))
    {
        return false;
    }
    var _npc = arg0.npc;
    if (point_distance(_npc.x, _npc.y, arg1.x, arg1.y) > arg2)
    {
        return false;
    }
    var _view = __ai_perception_view(_npc);
    return _view.enabled && __ai_perception_in_view(_npc.x, _npc.y, arg1.x, arg1.y, _npc.weapon_pointing_direction, _view) && !collision_line(_npc.x, _npc.y, arg1.x, arg1.y, obj_solid, false, true);
}

function __ai_routines_text(arg0, arg1)
{
    var _npc = arg0.npc;
    if (variable_instance_exists(_npc, "can_talk") && !_npc.can_talk)
    {
        exit;
    }
    var _bubble_asset = asset_get_index("obj_npc_draw_text");
    if (_bubble_asset >= 0)
    {
        for (var _i = 0; _i < instance_number(_bubble_asset); _i++)
        {
            var _bubble = instance_find(_bubble_asset, _i);
            if (variable_instance_exists(_bubble, "id_npc") && _bubble.id_npc == _npc)
            {
                exit;
            }
        }
    }
    scr_draw_npc_text(_npc, arg1);
}

function ai_routines_player_relation(arg0, arg1)
{
    if (ai_roaming_npc_is_hostile_to(arg0, arg1))
    {
        return "hostile";
    }
    var _reputation = faction_get_rep_temp(arg0.faction, arg1.faction);
    if (_reputation < 250)
    {
        return "hostile";
    }
    if (_reputation > 600 || arg0.faction == arg1.faction)
    {
        return "ally";
    }
    return "neutral";
}

function __ai_routines_aiming_player(arg0)
{
    var _npc = arg0.npc;
    var _player = player_nearest_instance(_npc.x, _npc.y);
    if (!instance_exists(_player) || !variable_instance_exists(_player, "faction"))
    {
        return -4;
    }
    if (variable_instance_exists(_player, "mp_index") && player_state_is(_player.mp_index, scr_player_state_start, scr_player_state_free_camera))
    {
        return -4;
    }
    if (!variable_instance_exists(_player, "aim_point_x") || !variable_instance_exists(_player, "arma_now") || !item_exists(_player.arma_now))
    {
        return -4;
    }
    var _cursor_x = _player.aim_point_x;
    var _cursor_y = _player.aim_point_y;
    var _cursor_on_npc = point_distance(_cursor_x, _cursor_y, _npc.x, _npc.y) <= arg0.profile.config.routines.aim_cursor_radius_px || point_in_rectangle(_cursor_x, _cursor_y, _npc.bbox_left - 2, _npc.bbox_top - 2, _npc.bbox_right + 2, _npc.bbox_bottom + 2);
    if (!_cursor_on_npc)
    {
        return -4;
    }
    if (point_distance(_npc.x, _npc.y, _player.x, _player.y) > arg0.profile.config.routines.aim_notice_distance_px)
    {
        return -4;
    }
    if (collision_line(_npc.x, _npc.y, _player.x, _player.y, obj_solid, false, true))
    {
        return -4;
    }
    return _player;
}

function __ai_routines_peaceful_aiming_player(arg0)
{
    var _player = __ai_routines_aiming_player(arg0);
    if (_player == -4)
    {
        return -4;
    }
    return (ai_routines_player_relation(arg0.npc, _player) == "hostile") ? -4 : _player;
}

function __ai_aim_reaction_keep(arg0, arg1)
{
    var _reaction = arg0.routines;
    var _already_reacting = arg0.now < _reaction.aim_until;
    _reaction.aim_player = arg1;
    _reaction.aim_until = _already_reacting ? max(_reaction.aim_until, arg0.now + arg0.profile.config.routines.aim_linger_seconds) : (arg0.now + arg0.profile.config.routines.aim_min_seconds);
}

function ai_aim_reaction_refresh(arg0)
{
    var _reaction = arg0.routines;
    var _npc = arg0.npc;
    if ((arg0.step - _reaction.aim_checked_step) < 4)
    {
        return arg0.now < _reaction.aim_until;
    }
    _reaction.aim_checked_step = arg0.step;
    var _aiming_player = __ai_routines_peaceful_aiming_player(arg0);
    if (_aiming_player != -4)
    {
        __ai_aim_reaction_keep(arg0, _aiming_player);
        if (arg0.now >= _reaction.aim_next_line_at)
        {
            _reaction.aim_line_pending = true;
            _reaction.aim_line_kind = (ai_routines_player_relation(_npc, _aiming_player) == "ally") ? "aimed_at_ally" : "aimed_at_neutral";
            _reaction.aim_next_line_at = arg0.now + arg0.profile.config.routines.aim_line_repeat_seconds;
        }
        ai_roaming_group_report_aiming_player(_npc, _aiming_player);
    }
    else
    {
        var _player_aiming_at_group = ai_roaming_group_aiming_player(_npc);
        if (_player_aiming_at_group != -4 && ai_routines_player_relation(_npc, _player_aiming_at_group) != "hostile" && point_distance(_npc.x, _npc.y, _player_aiming_at_group.x, _player_aiming_at_group.y) <= arg0.profile.config.routines.aim_group_distance_px && !collision_line(_npc.x, _npc.y, _player_aiming_at_group.x, _player_aiming_at_group.y, obj_solid, false, true))
        {
            __ai_aim_reaction_keep(arg0, _player_aiming_at_group);
        }
    }
    return arg0.now < _reaction.aim_until;
}

function ai_aim_reaction_ready(arg0)
{
    var _e = arg0.user_data;
    if (_e.knowledge.valid || !__ai_human_ready(_e))
    {
        return false;
    }
    return ai_aim_reaction_refresh(_e);
}

function ai_aim_reaction_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _reaction = _e.routines;
    if (_e.knowledge.valid || !ai_aim_reaction_refresh(_e) || !instance_exists(_reaction.aim_player))
    {
        return UnknownEnum.Value_1;
    }
    ai_commands_stop(_e, arg1.token);
    ai_commands_aim(_e, arg1.token, _reaction.aim_player.x, _reaction.aim_player.y);
    if (_reaction.aim_line_pending)
    {
        _reaction.aim_line_pending = false;
        ai_compat_callout(_e.npc, _reaction.aim_line_kind);
    }
    return UnknownEnum.Value_0;
}

function __ai_routines_seen(arg0, arg1)
{
    var _seen = arg0.routines.seen_corpses;
    for (var _i = 0; _i < array_length(_seen); _i++)
    {
        if (_seen[_i] == arg1)
        {
            return true;
        }
    }
    return false;
}

function __ai_routines_remember_body(arg0, arg1)
{
    if (__ai_routines_seen(arg0, arg1))
    {
        exit;
    }
    var _r = arg0.routines;
    if (array_length(_r.seen_corpses) < 32)
    {
        array_push(_r.seen_corpses, arg1);
    }
    else
    {
        _r.seen_corpses[_r.seen_cursor] = arg1;
        _r.seen_cursor = (_r.seen_cursor + 1) % 32;
    }
}

function __ai_routines_body(arg0)
{
    var _asset = asset_get_index("obj_chest_general");
    if (_asset < 0)
    {
        return -4;
    }
    var _count = instance_number(_asset);
    var _r = arg0.routines;
    repeat (min(8, _count))
    {
        if (!ai_world_take_candidate(arg0))
        {
            return -4;
        }
        var _body = instance_find(_asset, _r.corpse_cursor % _count);
        _r.corpse_cursor++;
        if (!instance_exists(_body) || __ai_routines_seen(arg0, _body) || !variable_instance_exists(_body, "chest_faction") || _body.chest_faction != arg0.npc.faction || !variable_instance_exists(_body, "chest_npc_id") || !is_string(_body.chest_npc_id))
        {
            continue;
        }
        if (__ai_routines_visible(arg0, _body, arg0.profile.config.routines.body_notice_distance_px))
        {
            return _body;
        }
    }
    return -4;
}

function __ai_routines_destination(arg0, arg1, arg2, arg3, arg4 = false)
{
    repeat (3)
    {
        if (!ai_world_take_candidate(arg0))
        {
            return undefined;
        }
        var _angle = ai_profile_random(arg0.rng) * 360;
        var _distance = arg4 ? arg3 : (arg3 * (0.35 + (0.65 * ai_profile_random(arg0.rng))));
        var _x = arg1 + lengthdir_x(_distance, _angle);
        var _y = arg2 + lengthdir_y(_distance, _angle);
        if (ai_world_position_valid(arg0, _x, _y))
        {
            return 
            {
                x: _x,
                y: _y
            };
        }
    }
    return undefined;
}

function __ai_routines_start_arms(arg0, arg1, arg2)
{
    var _asset = asset_get_index("obj_arms_" + arg1);
    if (_asset < 0 || !__ai_commands_active(arg0, arg2))
    {
        return false;
    }
    if (arg1 == "guitar" && instance_number(_asset) > 0)
    {
        return false;
    }
    var _npc = arg0.npc;
    var _arms = instance_create_depth(_npc.x, _npc.y, _npc.depth - 2, _asset);
    _arms.linked_id = _npc;
    _arms.image_xscale = _npc.image_xscale;
    _arms.ai_routine_execution = arg0;
    _arms.ai_routine_token = arg2;
    arg0.routines.arms = _arms;
    _npc.draw_weapon = false;
    return true;
}

function __ai_routines_destroy_arms(arg0)
{
    if (!instance_exists(arg0))
    {
        exit;
    }
    if (variable_instance_exists(arg0, "emitter_sound"))
    {
        audio_emitter_free(arg0.emitter_sound);
    }
    instance_destroy(arg0);
}

function ai_routines_animation_step(arg0)
{
    if (!variable_instance_exists(arg0, "ai_routine_execution"))
    {
        return false;
    }
    var _e = arg0.ai_routine_execution;
    if (!is_struct(_e) || !instance_exists(_e.npc) || _e.npc.hp <= 0 || !_e.routines.active || _e.routines.arms != arg0 || !__ai_commands_active(_e, arg0.ai_routine_token))
    {
        __ai_routines_destroy_arms(arg0);
        return true;
    }
    arg0.x = _e.npc.x;
    arg0.y = _e.npc.y;
    arg0.depth = _e.npc.depth - 2;
    arg0.image_xscale = _e.npc.image_xscale;
    return true;
}

function ai_routines_cancel(arg0)
{
    if (!variable_struct_exists(arg0, "routines"))
    {
        exit;
    }
    var _r = arg0.routines;
    if (instance_exists(_r.arms))
    {
        __ai_routines_destroy_arms(_r.arms);
    }
    _r.arms = -4;
    if (_r.active && instance_exists(arg0.npc))
    {
        arg0.npc.draw_weapon = true;
    }
    _r.active = false;
    _r.token = undefined;
}

function ai_routines_enter(arg0, arg1)
{
    var _e = arg0.user_data;
    __ai_human_action_enter(arg0, arg1);
    var _r = _e.routines;
    _r.active = true;
    _r.token = arg1.token;
    _r.kind = "idle";
    var _routine_config = _e.profile.config.routines;
    arg1.data = 
    {
        started: _e.now,
        deadline: _e.now + _routine_config.activity_limit_seconds,
        destination: undefined,
        arrived: -1,
        subject: noone
    };
    if (_e.knowledge.valid)
    {
        exit;
    }
    var _body = __ai_routines_body(_e);
    if (_body != -4)
    {
        __ai_routines_remember_body(_e, _body);
        _r.kind = "investigate_body";
        arg1.data.subject = _body;
        arg1.data.destination = __ai_routines_destination(_e, _body.x, _body.y, 12, true);
        exit;
    }
    var _ally = -4;
    var _count = instance_number(obj_npc_parent);
    for (var _i = 0; _i < min(8, _count); _i++)
    {
        _ally = instance_find(obj_npc_parent, (_i + _e.profile.seed) % _count);
        if (_ally == _e.npc || !instance_exists(_ally) || !variable_instance_exists(_ally, "faction") || _ally.faction != _e.npc.faction || point_distance(_ally.x, _ally.y, _e.npc.x, _e.npc.y) >= 14)
        {
            continue;
        }
        var _away = point_direction(_ally.x, _ally.y, _e.npc.x, _e.npc.y);
        var _sx = _e.npc.x + lengthdir_x(24, _away);
        var _sy = _e.npc.y + lengthdir_y(24, _away);
        if (ai_world_take_candidate(_e) && ai_world_position_valid(_e, _sx, _sy))
        {
            _r.kind = "separate";
            arg1.data.destination = 
            {
                x: _sx,
                y: _sy
            };
            arg1.data.deadline = _e.now + 2;
            exit;
        }
    }
    if (_e.now >= _r.next_leisure && ai_profile_random(_e.rng) < _routine_config.leisure_chance)
    {
        _r.next_leisure = _e.now + _routine_config.leisure_interval_seconds;
        var _fire_asset = asset_get_index("obj_barrel_acciaio_fire");
        var _guitar_asset = asset_get_index("obj_arms_guitar");
        if (_e.npc.faction == "Loners" && _fire_asset >= 0 && _guitar_asset >= 0 && instance_number(_guitar_asset) == 0)
        {
            var _fire = instance_nearest(_e.npc.x, _e.npc.y, _fire_asset);
            if (__ai_routines_visible(_e, _fire, _routine_config.campfire_notice_distance_px))
            {
                _r.kind = "campfire";
                arg1.data.subject = _fire;
                arg1.data.destination = __ai_routines_destination(_e, _fire.x, _fire.y, 24, true);
                exit;
            }
        }
        var _types = ["drink", "smoke", "eat"];
        _r.kind = _types[min(2, floor(ai_profile_random(_e.rng) * 3))];
        arg1.data.deadline = _e.now + _routine_config.leisure_seconds;
        if (!__ai_routines_start_arms(_e, _r.kind, arg1.token))
        {
            _r.kind = "idle";
        }
        exit;
    }
    if (ai_profile_random(_e.rng) < _routine_config.wander_chance)
    {
        _r.kind = "patrol";
        arg1.data.destination = __ai_routines_destination(_e, _e.assignment.x, _e.assignment.y, min(_routine_config.wander_radius_px, _e.assignment.radius));
    }
    else
    {
        arg1.data.deadline = _e.now + 1 + (2 * ai_profile_random(_e.rng));
    }
}

function ai_routines_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _r = _e.routines;
    if (_e.knowledge.valid || !__ai_commands_active(_e, arg1.token))
    {
        ai_commands_stop(_e, arg1.token);
        return UnknownEnum.Value_2;
    }
    if (_e.now >= arg1.data.deadline)
    {
        return UnknownEnum.Value_1;
    }
    if (_r.kind == "investigate_body" && !instance_exists(arg1.data.subject))
    {
        return UnknownEnum.Value_2;
    }
    if (_r.kind == "campfire" && !instance_exists(arg1.data.subject))
    {
        return UnknownEnum.Value_2;
    }
    var _destination = arg1.data.destination;
    if (_r.kind == "patrol" || _r.kind == "idle")
    {
        var _heading = (is_struct(_destination) && arg1.data.arrived < 0) ? point_direction(_e.npc.x, _e.npc.y, _destination.x, _destination.y) : _r.scan_home;
        ai_routines_scan(_e, arg1.token, _heading);
    }
    if (is_struct(_destination))
    {
        var _speed = 0;
        with (_e.npc)
        {
            _speed = npc_get_spd_not_alerted(npc_id);
        }
        var _move = ai_commands_move(_e, arg1.token, _destination.x, _destination.y, _speed, 4);
        if (_move == "failed")
        {
            return UnknownEnum.Value_2;
        }
        if (_move != "arrived")
        {
            return UnknownEnum.Value_0;
        }
        if (arg1.data.arrived < 0)
        {
            arg1.data.arrived = _e.now;
            if (_r.kind == "investigate_body")
            {
                __ai_routines_text(_e, UnknownEnum.Value_15);
            }
            if (_r.kind == "campfire")
            {
                if (!__ai_routines_start_arms(_e, "guitar", arg1.token))
                {
                    return UnknownEnum.Value_1;
                }
                arg1.data.destination = undefined;
                arg1.data.deadline = _e.now + _e.profile.config.routines.campfire_seconds;
            }
        }
        if (_r.kind != "campfire" && (_e.now - arg1.data.arrived) >= 0.5)
        {
            return UnknownEnum.Value_1;
        }
    }
    ai_commands_stop(_e, arg1.token);
    return UnknownEnum.Value_0;
}

function ai_routines_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    _e.routines.last_reason = arg2;
    ai_routines_cancel(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_15 = 15
}
