function ai_commands_init(arg0)
{
    arg0.commands = 
    {
        token: undefined,
        moving: false,
        aim: false,
        aim_x: 0,
        aim_y: 0,
        goal_x: 0,
        goal_y: 0,
        path_started: false,
        path_status: "idle",
        crowd_wait_at: undefined,
        progress_x: 0,
        progress_y: 0,
        progress_at: 0,
        retry_at: 0,
        deferred_at: undefined,
        reflex_target: noone,
        reflex_steps: 0,
        reflex_required: 0,
        reflex_serial: -1,
        reflex_reason: "none",
        settle_x: 0,
        settle_y: 0,
        settle_steps: 0,
        trigger_rounds: 0,
        trigger_pause_until: -1,
        trigger_outranged: false,
        lead_x: 0,
        lead_y: 0,
        watch_target: noone,
        watch_since: 0,
        watch_step: -1000,
        camera_fire: __ai_commands_camera_create(),
        motion_step: -1,
        sampled_x: arg0.npc.x,
        sampled_y: arg0.npc.y,
        displaced: false,
        motion_distance: 0,
        area_shots: 0,
        last_fire_kind: "none",
        last_fire_step: -1,
        last_fire_check: -1,
        last_aim_step: -1,
        reload_serial: 0
    };
}

function __ai_commands_camera_create()
{
    return 
    {
        target: noone,
        room_id: room,
        first_seen_at: undefined,
        in_view: false,
        fired_in_view: false,
        until: -1,
        allowed: true,
        reason: "not_player"
    };
}

function ai_commands_camera_step(arg0)
{
    var _s = arg0.commands.camera_fire;
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.firing;
    var _target = _k.valid ? _k.target : -4;
    if (_s.target != _target || _s.room_id != room)
    {
        _s = __ai_commands_camera_create();
        _s.target = _target;
        arg0.commands.camera_fire = _s;
    }
    if (!_c.camera_enabled || !object_is_player(_target) || !player_exists_local() || _target != player_get_local())
    {
        _s.allowed = true;
        _s.reason = _c.camera_enabled ? "not_player" : "disabled";
        return true;
    }
    var _camera = view_camera[0];
    if (_camera < 0 || camera_get_view_width(_camera) <= 0 || camera_get_view_height(_camera) <= 0)
    {
        _s.in_view = false;
        _s.fired_in_view = false;
        _s.until = -1;
        _s.allowed = false;
        _s.reason = "no_camera";
        return false;
    }
    var _x = camera_get_view_x(_camera);
    var _y = camera_get_view_y(_camera);
    var _inside = arg0.npc.x >= _x && arg0.npc.x < (_x + camera_get_view_width(_camera)) && arg0.npc.y >= _y && arg0.npc.y < (_y + camera_get_view_height(_camera));
    if (_inside)
    {
        if (is_undefined(_s.first_seen_at))
        {
            _s.first_seen_at = arg0.now;
        }
    }
    else if (_s.in_view)
    {
        _s.until = _s.fired_in_view ? (arg0.now + _c.camera_continue_seconds) : -1;
        _s.fired_in_view = false;
    }
    _s.in_view = _inside;
    var _ready = !is_undefined(_s.first_seen_at) && (arg0.now + 0.0000001) >= (_s.first_seen_at + _c.camera_opening_seconds);
    _s.allowed = _ready && (_inside || arg0.now < (_s.until - 0.0000001));
    _s.reason = _inside ? (_ready ? "in_view" : "opening_delay") : (_s.allowed ? "continuing" : "offscreen");
    return _s.allowed;
}

function ai_commands_sample_motion(arg0)
{
    var _commands = arg0.commands;
    if (_commands.motion_step == arg0.step)
    {
        exit;
    }
    var _npc = arg0.npc;
    _commands.motion_distance = point_distance(_npc.x, _npc.y, _commands.sampled_x, _commands.sampled_y);
    _commands.displaced = _commands.motion_distance > 0.001;
    _commands.sampled_x = _npc.x;
    _commands.sampled_y = _npc.y;
    _commands.motion_step = arg0.step;
}

function ai_commands_walk_speed(arg0)
{
    var _speed = 0;
    with (arg0.npc)
    {
        _speed = npc_get_spd_not_alerted(npc_id);
    }
    return max(0, _speed);
}

function ai_commands_transfer_speed(arg0, arg1, arg2 = true)
{
    var _walk = ai_commands_walk_speed(arg0);
    if (!arg2 || (arg0.npc.reloading && !__ai_hunter_sprint_reload(arg0)) || arg1.route_length < 32)
    {
        return _walk;
    }
    if (point_distance(arg0.npc.x, arg0.npc.y, arg1.x, arg1.y) <= 12 && (!variable_struct_exists(arg1, "via_x") || arg1.via_done))
    {
        return _walk;
    }
    return max(_walk, __ai_human_speed(arg0));
}

function ai_commands_travel_seconds(arg0, arg1, arg2 = true, arg3 = 0, arg4 = 0.75)
{
    var _walk = max(0.1, ai_commands_walk_speed(arg0) * 60);
    var _speed = (arg2 && (!arg0.npc.reloading || __ai_hunter_sprint_reload(arg0)) && arg1.route_length >= 32) ? max(_walk, __ai_human_speed(arg0) * 60) : _walk;
    var _slow = min(12, arg1.route_length);
    return max(arg3, (max(0, arg1.route_length - _slow) / _speed) + (_slow / _walk) + arg4);
}

function ai_commands_move_position(arg0, arg1, arg2, arg3, arg4 = 4)
{
    if (variable_struct_exists(arg2, "via_x") && !arg2.via_done)
    {
        var _move = ai_commands_move(arg0, arg1, arg2.via_x, arg2.via_y, arg3, 4);
        if (_move != "arrived")
        {
            return _move;
        }
        arg2.via_done = true;
    }
    return ai_commands_move(arg0, arg1, arg2.x, arg2.y, arg3, arg4);
}

function __ai_commands_motion_speed(arg0)
{
    ai_commands_sample_motion(arg0);
    var _npc = arg0.npc;
    return max(arg0.commands.motion_distance, point_distance(_npc.x, _npc.y, _npc.xprevious, _npc.yprevious), abs(_npc.speed), point_distance(0, 0, _npc.hspd, _npc.vspd), (_npc.path_index >= 0) ? abs(_npc.path_speed) : 0);
}

function __ai_commands_active(arg0, arg1)
{
    if (!instance_exists(arg0.npc) || arg0.npc.hp <= 0)
    {
        return false;
    }
    var _context = arg0.tree_context;
    var _index = _context._active_action;
    return _index >= 0 && __ai_bt_integer(arg1) && _context._slots[_index].active && _context._slots[_index].token == arg1;
}

function __ai_commands_owned(arg0, arg1)
{
    return __ai_commands_active(arg0, arg1) && arg0.commands.token == arg1;
}

function ai_commands_begin(arg0, arg1)
{
    if (!__ai_commands_active(arg0, arg1))
    {
        return false;
    }
    if (arg0.commands.token == arg1)
    {
        return true;
    }
    if (!is_undefined(arg0.commands.token))
    {
        ai_commands_release(arg0, arg0.commands.token);
    }
    var _commands = arg0.commands;
    _commands.token = arg1;
    ai_commands_stop(arg0, arg1);
    return true;
}

function __ai_commands_stop_native(arg0)
{
    with (arg0.npc)
    {
        path_end();
        speed = 0;
        hspd = 0;
        vspd = 0;
    }
    arg0.commands.moving = false;
    arg0.commands.path_started = false;
    arg0.commands.crowd_wait_at = undefined;
}

function ai_commands_stop(arg0, arg1)
{
    if (!__ai_commands_owned(arg0, arg1))
    {
        return false;
    }
    __ai_commands_stop_native(arg0);
    arg0.commands.path_status = "idle";
    arg0.commands.deferred_at = undefined;
    return true;
}

function ai_commands_release(arg0, arg1)
{
    var _commands = arg0.commands;
    if (is_undefined(arg1) || _commands.token != arg1)
    {
        return false;
    }
    if (instance_exists(arg0.npc))
    {
        __ai_commands_stop_native(arg0);
    }
    _commands.token = undefined;
    _commands.aim = false;
    _commands.path_status = "idle";
    _commands.deferred_at = undefined;
    return true;
}

function ai_commands_cancel(arg0)
{
    ai_commands_release(arg0, arg0.commands.token);
    arg0.commands.reflex_target = -4;
    arg0.commands.trigger_rounds = 0;
    arg0.commands.trigger_pause_until = -1;
    arg0.commands.trigger_outranged = false;
    arg0.commands.watch_target = -4;
    arg0.commands.camera_fire = __ai_commands_camera_create();
    var _npc = arg0.npc;
    if (!instance_exists(_npc) || !variable_instance_exists(_npc, "ai_reload_operation"))
    {
        exit;
    }
    var _operation = _npc.ai_reload_operation;
    if (is_struct(_operation) && _operation.execution == arg0)
    {
        if (_operation.active)
        {
            _operation.active = false;
            _npc.alarm[0] = -1;
            _npc.reloading = false;
        }
        _operation.cancelled = true;
    }
}

function ai_commands_move(arg0, arg1, arg2, arg3, arg4, arg5 = 4)
{
    if (!__ai_commands_owned(arg0, arg1))
    {
        return "failed";
    }
    var _npc = arg0.npc;
    var _commands = arg0.commands;
    if (!is_numeric(arg2) || !is_numeric(arg3) || is_nan(arg2) || is_nan(arg3) || is_infinity(arg2) || is_infinity(arg3) || !is_numeric(arg4) || is_nan(arg4) || is_infinity(arg4) || arg4 <= 0)
    {
        ai_commands_stop(arg0, arg1);
        return "failed";
    }
    var _walk = ai_commands_walk_speed(arg0);
    if ((_npc.reloading && !__ai_hunter_sprint_reload(arg0)) || _commands.last_fire_step == arg0.step)
    {
        arg4 = min(arg4, _walk);
    }
    if (arg4 <= 0)
    {
        ai_commands_stop(arg0, arg1);
        return "failed";
    }
    if (point_distance(_npc.x, _npc.y, arg2, arg3) <= arg5)
    {
        ai_commands_stop(arg0, arg1);
        _commands.path_status = "arrived";
        return "arrived";
    }
    var _changed = point_distance(_commands.goal_x, _commands.goal_y, arg2, arg3) > 4;
    if (_changed)
    {
        __ai_commands_stop_native(arg0);
        _commands.retry_at = 0;
        _commands.deferred_at = undefined;
    }
    if (!_commands.path_started)
    {
        if (arg0.now < _commands.retry_at)
        {
            return _commands.path_status;
        }
        if (!is_undefined(_commands.deferred_at) && __ai_bt_due(arg0.now, _commands.deferred_at + arg0.profile.config.queries.max_defer_seconds))
        {
            _commands.path_status = "failed";
            _commands.retry_at = arg0.now + arg0.profile.config.queries.retry_seconds;
            _commands.deferred_at = undefined;
            return "failed";
        }
        _commands.goal_x = arg2;
        _commands.goal_y = arg3;
        var _result = ai_world_path(arg0, _npc.path_to_target, _npc.x, _npc.y, arg2, arg3);
        if (_result != "found")
        {
            __ai_commands_stop_native(arg0);
            _commands.path_status = (_result == "deferred") ? "deferred" : "failed";
            if (_result == "deferred")
            {
                if (is_undefined(_commands.deferred_at))
                {
                    _commands.deferred_at = arg0.now;
                }
            }
            else
            {
                _commands.retry_at = arg0.now + arg0.profile.config.queries.retry_seconds;
                _commands.deferred_at = undefined;
            }
            return _commands.path_status;
        }
        with (_npc)
        {
            path_start(path_to_target, arg4, path_action_stop, true);
        }
        _commands.path_started = true;
        _commands.deferred_at = undefined;
        _commands.progress_x = _npc.x;
        _commands.progress_y = _npc.y;
        _commands.progress_at = arg0.now;
    }
    if (point_distance(_npc.x, _npc.y, _commands.progress_x, _commands.progress_y) >= 1)
    {
        _commands.progress_x = _npc.x;
        _commands.progress_y = _npc.y;
        _commands.progress_at = arg0.now;
    }
    else if ((arg0.now - _commands.progress_at) >= 1 || _npc.path_index < 0)
    {
        __ai_commands_stop_native(arg0);
        _commands.path_status = "failed";
        _commands.retry_at = arg0.now + arg0.profile.config.queries.retry_seconds;
        return "failed";
    }
    var _length = path_get_length(_npc.path_to_target);
    var _next = min(1, _npc.path_position + (arg4 / max(1, _length)));
    var _nx = path_get_x(_npc.path_to_target, _next);
    var _ny = path_get_y(_npc.path_to_target, _next);
    var _blocker = -4;
    with (_npc)
    {
        _blocker = collision_circle(_nx, _ny, 8, obj_npc_parent, false, true);
    }
    if (instance_exists(_blocker) && _blocker.hp > 0 && point_distance(_nx, _ny, _blocker.x, _blocker.y) < (point_distance(_npc.x, _npc.y, _blocker.x, _blocker.y) - 0.001))
    {
        if (is_undefined(_commands.crowd_wait_at))
        {
            _commands.crowd_wait_at = arg0.now;
        }
        if ((arg0.now - _commands.crowd_wait_at) >= 0.35)
        {
            __ai_commands_stop_native(arg0);
            _commands.path_status = "failed";
            return "failed";
        }
        _npc.path_speed = 0;
        _commands.moving = false;
        _commands.progress_at = arg0.now;
        _commands.path_status = "yielding";
        return "yielding";
    }
    _commands.crowd_wait_at = undefined;
    if (!ai_world_motion_clear(_npc.x, _npc.y, path_get_x(_npc.path_to_target, _next), path_get_y(_npc.path_to_target, _next)))
    {
        __ai_commands_stop_native(arg0);
        _commands.path_status = "failed";
        _commands.retry_at = arg0.now + arg0.profile.config.queries.retry_seconds;
        return "failed";
    }
    _commands.moving = true;
    _commands.path_status = "moving";
    _npc.path_speed = arg4;
    if (!_commands.aim || _commands.last_aim_step != arg0.step)
    {
        _commands.aim = false;
        __ai_commands_turn(arg0, arg2, arg3);
    }
    return "moving";
}

function ai_commands_aim(arg0, arg1, arg2, arg3)
{
    if (!__ai_commands_owned(arg0, arg1))
    {
        return false;
    }
    if (!is_numeric(arg2) || !is_numeric(arg3) || is_nan(arg2) || is_nan(arg3) || is_infinity(arg2) || is_infinity(arg3))
    {
        return false;
    }
    var _npc = arg0.npc;
    var _commands = arg0.commands;
    _commands.aim = true;
    _commands.aim_x = arg2;
    _commands.aim_y = arg3;
    var _aligned = __ai_commands_turn(arg0, arg2, arg3);
    var _p = arg0.perception;
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.firing;
    var _radius = variable_instance_exists(_npc, "reflex_min_distance_last_known") ? _npc.reflex_min_distance_last_known : 30;
    if (_k.valid && !_k.visible && _p.last_direct_target == _k.target && (arg0.now - _p.last_direct_at) <= _c.expected_memory_seconds && point_distance(arg2, arg3, _p.last_direct_x, _p.last_direct_y) <= _radius && abs(angle_difference(point_direction(_npc.x, _npc.y, _p.last_direct_x, _p.last_direct_y), _npc.weapon_pointing_direction)) <= _c.expected_angle_degrees && __ai_commands_motion_speed(arg0) <= (ai_commands_walk_speed(arg0) + 0.001))
    {
        if (_commands.watch_target != _k.target || _commands.watch_step < (arg0.step - 1))
        {
            _commands.watch_since = arg0.now;
        }
        _commands.watch_target = _k.target;
        _commands.watch_step = arg0.step;
    }
    return _aligned;
}

function __ai_commands_turn(arg0, arg1, arg2)
{
    var _npc = arg0.npc;
    var _commands = arg0.commands;
    if (variable_struct_exists(arg0, "bridge"))
    {
        var _hit = arg0.bridge.hit;
        if (_hit.pending && _hit.surprised && arg0.now < _hit.ready_at)
        {
            return false;
        }
    }
    if (point_distance(_npc.x, _npc.y, arg1, arg2) < 0.5)
    {
        return false;
    }
    var _direction = point_direction(_npc.x, _npc.y, arg1, arg2);
    var _difference = angle_difference(_direction, _npc.weapon_pointing_direction);
    if (_commands.last_aim_step != arg0.step)
    {
        _commands.last_aim_step = arg0.step;
        _npc.weapon_pointing_direction += clamp(_difference, -_npc.angle_increase_for_target, _npc.angle_increase_for_target);
    }
    _npc.target_for_image_scale = _npc.x + lengthdir_x(16, _npc.weapon_pointing_direction);
    return abs(angle_difference(_direction, _npc.weapon_pointing_direction)) <= 8;
}

function __ai_commands_heard_ready(arg0)
{
    var _r = arg0.perception.hearing.ready;
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.firing;
    if (!_k.visible || !arg0.profile.config.hearing.enabled || !is_struct(_r) || _r.target != _k.target)
    {
        return false;
    }
    var _age = (ai_world_get().frame - _r.frame) / 60;
    return _age >= 0 && _age <= _c.heard_reflex_seconds && point_distance(_r.x, _r.y, _k.x, _k.y) <= _c.heard_reflex_distance_px;
}

function __ai_commands_reflex_required(arg0)
{
    var _n = arg0.npc;
    var _p = arg0.perception;
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.firing;
    var _distance = point_distance(_n.x, _n.y, _k.x, _k.y);
    var _normal = _n.reflexes_minimum + lerp(_n.reflexes_distance_min, _n.reflexes_distance_max, clamp(_distance / 180, 0, 1)) + lerp(_n.reflexes_angle_min, _n.reflexes_angle_max, clamp(_p.reaction_angle / 180, 0, 1));
    if (_p.expected)
    {
        _normal = _n.reflexes_minimum * _c.expected_reflex_multiplier;
    }
    _normal += (60 * _c.distant_reflex_extra_seconds * clamp((_distance - _c.distant_reflex_start_px) / max(1, _c.distant_reflex_span_px), 0, 1));
    arg0.commands.reflex_reason = "normal";
    var _heard = __ai_commands_heard_ready(arg0);
    var _tier = clamp(_n.reflexes_minimum / 20, 0, 1);
    if (_p.expected && _heard)
    {
        arg0.commands.reflex_reason = "heard_repeek";
        return min(_normal, 60 * lerp(_c.heard_peek_min_seconds, _c.heard_peek_max_seconds, _tier));
    }
    var _chasing = arg0.now < _p.close_ready_until || (variable_struct_exists(arg0, "investigation") && ai_investigation_committed(arg0));
    var _flash = _p.flash;
    var _blind = is_struct(_flash) && _flash.active && _flash.target == _k.target && ((ai_world_get().frame - _flash.frame) / 60) < _flash.remaining;
    if ((_p.reaction_alerted || _p.visible_steps >= 30 || _blind) && (_distance <= _c.close_reflex_distance_px || (_blind && _distance <= (arg0.profile.config.flash_push.min_target_distance_px + 2))) && _p.reaction_angle <= _c.close_reflex_angle_degrees && (_heard || _chasing || _blind))
    {
        arg0.commands.reflex_reason = _blind ? "flash" : "close_rush";
        return min(_normal, 60 * lerp(_c.close_reflex_min_seconds, _c.close_reflex_max_seconds, _tier));
    }
    return _normal;
}

function __ai_commands_settle_begin(arg0, arg1)
{
    var _commands = arg0.commands;
    var _c = arg0.profile.config.firing;
    var _n = arg0.npc;
    _commands.settle_x = 0;
    _commands.settle_y = 0;
    _commands.settle_steps = 0;
    if (!_c.settle_enabled || _c.settle_offset_px <= 0 || !object_is_player(arg1.target) || point_distance(_n.x, _n.y, arg1.x, arg1.y) <= _c.settle_min_distance_px)
    {
        exit;
    }
    var _direction = point_direction(_n.x, _n.y, arg1.x, arg1.y);
    var _swing = angle_difference(_n.weapon_pointing_direction, _direction);
    var _side = (abs(_swing) >= 3) ? sign(_swing) : choose(-1, 1);
    var _offset = _c.settle_offset_px * (arg0.perception.expected ? _c.settle_expected_multiplier : 1);
    _commands.settle_x = lengthdir_x(_offset, _direction + (90 * _side));
    _commands.settle_y = lengthdir_y(_offset, _direction + (90 * _side));
    _commands.settle_steps = 60 * lerp(_c.settle_min_seconds, _c.settle_max_seconds, clamp(_n.reflexes_minimum / 20, 0, 1));
}

function __ai_commands_settle_remaining(arg0)
{
    var _commands = arg0.commands;
    if (_commands.settle_x == 0 && _commands.settle_y == 0)
    {
        return 0;
    }
    if (_commands.settle_steps <= 0)
    {
        return 0;
    }
    return 1 - clamp((_commands.reflex_steps - _commands.reflex_required) / _commands.settle_steps, 0, 1);
}

function __ai_commands_lead_update(arg0, arg1)
{
    var _commands = arg0.commands;
    var _c = arg0.profile.config.firing;
    var _n = arg0.npc;
    _commands.lead_x = 0;
    _commands.lead_y = 0;
    if (!_c.lead_enabled || !object_is_player(arg1.target))
    {
        exit;
    }
    var _tiers = __ai_profile_training_tiers();
    var _tier = 0;
    for (var _i = 0; _i < array_length(_tiers); _i++)
    {
        if (_tiers[_i] == arg0.profile.config.training)
        {
            _tier = _i;
        }
    }
    var _fraction = lerp(_c.lead_min_fraction, _c.lead_max_fraction, _tier / max(1, array_length(_tiers) - 1));
    var _bullet_speed = max(1, item_weapon_get_bullet_speed(_n.arma_now));
    var _flight_steps = point_distance(_n.x, _n.y, arg1.x, arg1.y) / _bullet_speed;
    var _lead_x = arg0.perception.lead_vx * _flight_steps * _fraction;
    var _lead_y = arg0.perception.lead_vy * _flight_steps * _fraction;
    var _length = point_distance(0, 0, _lead_x, _lead_y);
    if (_length > _c.lead_max_px)
    {
        var _scale = _c.lead_max_px / _length;
        _lead_x *= _scale;
        _lead_y *= _scale;
    }
    _commands.lead_x = _lead_x;
    _commands.lead_y = _lead_y;
}

function ai_commands_outranged_fire_allowed(arg0, arg1)
{
    return arg0.profile.config.firing.outranged_fire_enabled && object_is_player(arg1);
}

function ai_commands_returning_fire(arg0)
{
    return arg0.knowledge.valid && ai_commands_outranged_fire_allowed(arg0, arg0.knowledge.target) && ai_perception_return_fire_active(arg0, arg0.knowledge.target);
}

function __ai_commands_trigger_after_shot(arg0, arg1, arg2 = false)
{
    var _commands = arg0.commands;
    var _c = arg0.profile.config.firing;
    var _n = arg0.npc;
    if (_commands.trigger_outranged != arg2)
    {
        _commands.trigger_outranged = arg2;
        _commands.trigger_rounds = 0;
    }
    if (arg2)
    {
        if (_commands.trigger_rounds <= 0)
        {
            _commands.trigger_rounds = irandom_range(_c.outranged_rounds_min, _c.outranged_rounds_max);
        }
        _commands.trigger_rounds -= 1;
        if (_commands.trigger_rounds > 0)
        {
            exit;
        }
        _commands.trigger_pause_until = arg0.now + random_range(_c.outranged_pause_min_seconds, _c.outranged_pause_max_seconds);
        exit;
    }
    if (!_c.trigger_enabled || !object_is_player(arg1.target) || item_weapon_get_fire_mode(_n.arma_now) != "automatic" || point_distance(_n.x, _n.y, arg1.x, arg1.y) <= _c.trigger_full_auto_px)
    {
        _commands.trigger_rounds = 0;
        exit;
    }
    var _threatened = variable_struct_exists(arg0, "combat") && variable_struct_exists(arg0.combat, "pressure") && __ai_human_pressure(arg0) >= _c.trigger_threat_pressure;
    if (_commands.trigger_rounds <= 0)
    {
        var _rounds = irandom_range(_c.trigger_rounds_min, _c.trigger_rounds_max);
        if (_threatened)
        {
            _rounds = max(2, round(_rounds * _c.trigger_threat_rounds_multiplier));
        }
        _commands.trigger_rounds = _rounds;
    }
    _commands.trigger_rounds -= 1;
    if (_commands.trigger_rounds > 0)
    {
        exit;
    }
    var _pause = random_range(_c.trigger_pause_min_seconds, _c.trigger_pause_max_seconds);
    if (_threatened)
    {
        _pause *= _c.trigger_threat_pause_multiplier;
    }
    _commands.trigger_pause_until = arg0.now + _pause;
}

function ai_commands_fire(arg0, arg1, arg2)
{
    if (!__ai_commands_owned(arg0, arg1))
    {
        return false;
    }
    ai_commands_sample_motion(arg0);
    var _npc = arg0.npc;
    var _commands = arg0.commands;
    var _motion_speed = __ai_commands_motion_speed(arg0);
    if (_motion_speed > (ai_commands_walk_speed(arg0) + 0.001) || !_commands.aim || _npc.reloading || _npc.ammo_now <= 0 || _npc.grenade_flash || _commands.last_fire_check == arg0.step)
    {
        return false;
    }
    _commands.last_fire_check = arg0.step;
    if (!ai_perception_can_fire(arg0))
    {
        return false;
    }
    arg2 = arg0.knowledge;
    if (!ai_commands_aim(arg0, arg1, arg2.x, arg2.y))
    {
        return false;
    }
    if (_commands.reflex_target != arg2.target || _commands.reflex_serial != arg0.perception.sight_serial)
    {
        _commands.reflex_target = arg2.target;
        _commands.reflex_steps = 0;
        _commands.reflex_serial = arg0.perception.sight_serial;
        __ai_commands_settle_begin(arg0, arg2);
        _commands.trigger_rounds = 0;
        _npc.NPCrecoil.cross_center_x = arg2.x + _commands.settle_x;
        _npc.NPCrecoil.cross_center_y = arg2.y + _commands.settle_y;
    }
    _commands.reflex_required = __ai_commands_reflex_required(arg0);
    _commands.reflex_steps = arg0.perception.visible_steps;
    var _settle = __ai_commands_settle_remaining(arg0);
    __ai_commands_lead_update(arg0, arg2);
    var _aim_x = arg2.x + (_commands.settle_x * _settle) + _commands.lead_x;
    var _aim_y = arg2.y + (_commands.settle_y * _settle) + _commands.lead_y;
    with (_npc)
    {
        var _recoil = NPCrecoil;
        _recoil.cross_center_x = lerp(_recoil.cross_center_x, _aim_x, _recoil.cross_delay);
        _recoil.cross_center_y = lerp(_recoil.cross_center_y, _aim_y, _recoil.cross_delay);
        var _radius_multiplier = glance_get_npc_recoil_radius_multiplier(item_weapon_get_type_effective_range(arma_now));
        _recoil.radius_min = _recoil.base_radius_min * _radius_multiplier;
        _recoil.radius_max = _recoil.base_radius_max * _radius_multiplier;
        _recoil.MoveCrosshair();
        _recoil.StuckCheck();
        _recoil.SetAimDirection();
    }
    var _outranged = !ai_commands_in_effective_range(arg0, arg2.x, arg2.y);
    if (_commands.reflex_steps < _commands.reflex_required || _npc.shooting || (_outranged && !ai_commands_outranged_fire_allowed(arg0, arg2.target)) || !ai_commands_camera_step(arg0) || arg0.now < _commands.trigger_pause_until)
    {
        return false;
    }
    _commands.last_fire_kind = _outranged ? "outranged" : "sight";
    __ai_commands_emit_shot(arg0, arg2, _motion_speed, _npc.NPCrecoil.direction_aim);
    __ai_commands_trigger_after_shot(arg0, arg2, _outranged);
    if (variable_struct_exists(arg0, "investigation") && is_struct(arg0.investigation.plan) && !arg0.investigation.active)
    {
        ai_investigation_reset(arg0);
        arg0.perception.search_until = 0;
    }
    __ai_human_memory_shot(arg0);
    return true;
}

function __ai_commands_sound_steps(arg0)
{
    if (is_undefined(arg0) || !is_numeric(arg0) || arg0 < 0 || !audio_exists(arg0))
    {
        return 0;
    }
    return max(0, audio_sound_length(arg0)) * 60;
}

function ai_commands_reload_timing(arg0, arg1)
{
    var _type = item_weapon_get_reload_type(arg0);
    var _shell_sound_name = "snd_estrarre_caricatore";
    if (_type == "sniper_single")
    {
        _shell_sound_name = "snd_sniper_shell_in";
    }
    else if (_type == "shotgun_single")
    {
        _shell_sound_name = "snd_shotgun_shell_in";
    }
    return 
    {
        per_round: _type == "sniper_single" || _type == "shotgun_single",
        mag_out: __ai_commands_sound_steps(item_weapon_get_sound_mag_out(arg0)),
        reload: max(0, item_weapon_get_modded_stats(arg0, arg1).reload_time),
        shell: __ai_commands_sound_steps(asset_get_index(_shell_sound_name)),
        mag_in: __ai_commands_sound_steps(item_weapon_get_sound_mag_in(arg0)),
        cocking: __ai_commands_sound_steps(item_weapon_get_sound_cocking(arg0))
    };
}

function ai_commands_reload_total_steps(arg0, arg1, arg2)
{
    var _missing = max(0, arg2 - arg1);
    if (arg0.per_round)
    {
        return arg0.mag_out + ((_missing + 1) * (arg0.reload + arg0.shell)) + arg0.mag_in + 1;
    }
    return arg0.mag_out + arg0.reload + arg0.shell + arg0.mag_in + ((arg1 <= 0) ? arg0.cocking : 1);
}

function __ai_commands_reload_closing_steps(arg0)
{
    return (2 * arg0.shell) + arg0.reload + arg0.mag_in + 1;
}

function ai_commands_reload_stop_early(arg0)
{
    var _npc = arg0.npc;
    if (!variable_instance_exists(_npc, "ai_reload_operation") || !is_struct(_npc.ai_reload_operation))
    {
        return false;
    }
    var _operation = _npc.ai_reload_operation;
    if (!_operation.active || _operation.execution != arg0 || !_operation.timing.per_round || _operation.phase != "rounds" || _npc.ammo_now <= 0 || _npc.ammo_now <= _operation.start_ammo)
    {
        return false;
    }
    _operation.phase = "closing";
    _npc.alarm[0] = max(1, ceil(min(max(0, _npc.alarm[0]), _operation.timing.shell) + _operation.timing.mag_in + 1));
    return true;
}

function ai_commands_reload(arg0, arg1, arg2 = true)
{
    if (!__ai_commands_owned(arg0, arg1))
    {
        return "failed";
    }
    var _npc = arg0.npc;
    var _walk = ai_commands_walk_speed(arg0);
    if (!__ai_hunter_sprint_reload(arg0))
    {
        if (_npc.path_index >= 0 && _walk > 0)
        {
            _npc.path_speed = min(abs(_npc.path_speed), _walk);
        }
        else if (arg0.commands.moving)
        {
            ai_commands_stop(arg0, arg1);
        }
    }
    var _operation = variable_instance_exists(_npc, "ai_reload_operation") ? _npc.ai_reload_operation : undefined;
    if (is_struct(_operation) && _operation.active)
    {
        if (_operation.execution != arg0 || _operation.weapon != _npc.arma_now || _operation.mods != _npc.mod_container)
        {
            return "failed";
        }
        return "running";
    }
    if (_npc.ammo_now >= item_weapon_get_modded_magazine_size(_npc.arma_now, _npc.mod_container))
    {
        return "complete";
    }
    if (_npc.reloading)
    {
        return "failed";
    }
    var _timing = ai_commands_reload_timing(_npc.arma_now, _npc.mod_container);
    _npc.ai_reload_operation = 
    {
        execution: arg0,
        serial: ++arg0.commands.reload_serial,
        token: arg1,
        weapon: _npc.arma_now,
        mods: _npc.mod_container,
        active: true,
        cancelled: false,
        complete_action: arg2,
        timing: _timing,
        phase: _timing.per_round ? "rounds" : "magazine",
        start_ammo: _npc.ammo_now
    };
    _npc.reloading = true;
    _npc.have_to_reload = false;
    var _first_wait = _timing.per_round ? (_timing.mag_out + _timing.reload) : ai_commands_reload_total_steps(_timing, _npc.ammo_now, item_weapon_get_modded_magazine_size(_npc.arma_now, _npc.mod_container));
    _npc.alarm[0] = max(1, ceil(_first_wait));
    return "running";
}

function ai_commands_reload_complete(arg0)
{
    if (!variable_instance_exists(arg0, "ai_reload_operation") || !is_struct(arg0.ai_reload_operation))
    {
        return false;
    }
    var _operation = arg0.ai_reload_operation;
    if (!_operation.active)
    {
        if (_operation.cancelled && arg0.reloading)
        {
            arg0.ai_reload_operation = undefined;
            return false;
        }
        return true;
    }
    var _valid = arg0.hp > 0 && arg0.arma_now == _operation.weapon && arg0.mod_container == _operation.mods && arg0.ai_execution == _operation.execution && arg0.state == "human_general" && !arg0.force_moving_towards_player;
    var _magazine = item_weapon_get_modded_magazine_size(arg0.arma_now, arg0.mod_container);
    var _phase = variable_struct_exists(_operation, "phase") ? _operation.phase : "magazine";
    if (_valid && _phase == "rounds")
    {
        arg0.ammo_now = min(_magazine, arg0.ammo_now + 1);
        var _timing = _operation.timing;
        if (arg0.ammo_now >= _magazine)
        {
            _operation.phase = "closing";
            arg0.alarm[0] = max(1, ceil(__ai_commands_reload_closing_steps(_timing)));
        }
        else
        {
            arg0.alarm[0] = max(1, ceil(_timing.shell + _timing.reload));
        }
        return true;
    }
    _operation.active = false;
    arg0.reloading = false;
    if (_valid)
    {
        if (_phase == "magazine")
        {
            arg0.ammo_now = _magazine;
        }
        arg0.have_to_reload = false;
    }
    if (!_valid || !variable_struct_exists(_operation, "complete_action") || _operation.complete_action)
    {
        ai_bt_complete(_operation.execution.tree_context, _operation.token, _valid ? UnknownEnum.Value_1 : UnknownEnum.Value_2, _valid ? "reload_complete" : "reload_invalidated");
    }
    return true;
}

function ai_commands_in_effective_range(arg0, arg1, arg2)
{
    var _ammo = variable_instance_exists(arg0.npc, "ammo_id_now") ? arg0.npc.ammo_id_now : undefined;
    var _cache = variable_struct_exists(arg0.commands, "range_gate") ? arg0.commands.range_gate : undefined;
    if (!is_struct(_cache) || _cache.weapon != arg0.npc.arma_now || _cache.ammo != _ammo)
    {
        var _type = item_weapon_get_type_effective_range(arg0.npc.arma_now);
        var _ammo_type = item_exists(_ammo) ? item_ammo_get_eff_range(_ammo) : "{use_weapon}";
        if (is_string(_ammo_type) && _ammo_type != "{use_weapon}")
        {
            _type = _ammo_type;
        }
        var _raw = glance_get_eff_range(_type);
        var _clean = [];
        var _full_damage_end = -1;
        if (is_array(_raw))
        {
            for (var _i = 0; _i < array_length(_raw); _i++)
            {
                var _point = _raw[_i];
                if (!is_array(_point) || array_length(_point) < 2 || !__ai_profile_number(_point[0]) || !__ai_profile_number(_point[1]) || _point[0] < 0)
                {
                    continue;
                }
                array_push(_clean, _point);
                if (_point[1] >= 1)
                {
                    _full_damage_end = _point[0];
                }
            }
        }
        _cache = 
        {
            weapon: arg0.npc.arma_now,
            ammo: _ammo,
            points: _clean,
            full_damage_end: _full_damage_end
        };
        arg0.commands.range_gate = _cache;
    }
    var _points = _cache.points;
    if (array_length(_points) == 0)
    {
        return true;
    }
    var _distance = point_distance(arg0.npc.x, arg0.npc.y, arg1, arg2);
    if (_distance <= _cache.full_damage_end)
    {
        return true;
    }
    var _effectiveness = _points[array_length(_points) - 1][1];
    for (var _i = 0; _i < (array_length(_points) - 1); _i++)
    {
        var _from = _points[_i];
        var _to = _points[_i + 1];
        if (_distance >= _from[0] && _distance < _to[0])
        {
            _effectiveness = lerp(_from[1], _to[1], (_distance - _from[0]) / max(1, _to[0] - _from[0]));
            break;
        }
    }
    return _effectiveness >= arg0.profile.config.firing.min_far_effectiveness;
}

function __ai_commands_emit_shot(arg0, arg1, arg2, arg3)
{
    var _npc = arg0.npc;
    if (arg0.commands.camera_fire.in_view)
    {
        arg0.commands.camera_fire.fired_in_view = true;
    }
    arg0.commands.last_fire_step = arg0.step;
    with (_npc)
    {
        var _recoil = NPCrecoil;
        weapon_pointing_direction = arg3;
        recoil_total = item_weapon_get_precisione(arma_now) * npc_get_aim_factor(npc_id);
        var _damage = item_weapon_get_damage(arma_now);
        var _spread = (100 - item_weapon_get_precisione(arma_now)) * 0.04 * npc_get_aim_factor(npc_id) * difficulty_get("enemy_human_aim_spread");
        if (arg2 > 0.001)
        {
            _spread *= arg0.profile.config.firing.walking_spread_multiplier;
        }
        if (object_is_player(arg1.target) && (abs(x - arg1.x) > 240 || abs(y - arg1.y) > 135))
        {
            _spread *= 2.5;
        }
        scr_shoot(weapon_pointing_direction, UnknownEnum.Value_0, _damage, _spread);
        _recoil.IncreaseRadius(recoil_arma * glance_get_npc_recoil_value_multiplier(item_weapon_get_type_effective_range(arma_now)));
        shooting = true;
        ammo_now--;
        recoil_shooting += recoil_arma;
        alarm[1] = (item_weapon_get_fire_mode(arma_now) == "semi_automatic") ? (item_weapon_get_rate_of_fire(arma_now) + irandom(15) + 15) : (item_weapon_get_rate_of_fire(arma_now) * npc_get_prob_attack(npc_id));
        have_to_reload = ammo_now <= 0;
    }
}

function __ai_commands_cover_lane(arg0, arg1, arg2 = false)
{
    var _n = arg0.npc;
    var _c = arg0.profile.config.covering_fire;
    var _dx = arg1.x - _n.x;
    var _dy = arg1.y - _n.y;
    var _len = max(1, point_distance(_n.x, _n.y, arg1.x, arg1.y));
    var _spread = (100 - item_weapon_get_precisione(_n.arma_now)) * 0.04 * npc_get_aim_factor(_n.npc_id) * difficulty_get("enemy_human_aim_spread") * 2.5;
    if (arg2)
    {
        _spread *= arg0.profile.config.firing.walking_spread_multiplier;
    }
    var _width = _c.ally_clearance_px + (_len * dtan(min(45, abs(_spread))));
    var _hits = ds_list_create();
    var _clear = true;
    collision_rectangle_list(min(_n.x, arg1.x) - _width, min(_n.y, arg1.y) - _width, max(_n.x, arg1.x) + _width, max(_n.y, arg1.y) + _width, obj_npc_parent, false, false, _hits, false);
    collision_rectangle_list(min(_n.x, arg1.x) - _width, min(_n.y, arg1.y) - _width, max(_n.x, arg1.x) + _width, max(_n.y, arg1.y) + _width, obj_player_parent, false, false, _hits, false);
    if (ds_list_size(_hits) > 32)
    {
        _clear = false;
    }
    for (var _i = 0; _clear && _i < ds_list_size(_hits); _i++)
    {
        var _actor = ds_list_find_value(_hits, _i);
        if (_actor == _n || !variable_instance_exists(_actor, "faction") || faction_get_rep_temp(_n.faction, _actor.faction) < 250)
        {
            continue;
        }
        var _t = clamp((((_actor.x - _n.x) * _dx) + ((_actor.y - _n.y) * _dy)) / (_len * _len), 0, 1);
        var _body = max(abs(_actor.bbox_right - _actor.bbox_left), abs(_actor.bbox_bottom - _actor.bbox_top)) * 0.5;
        if (point_distance(_actor.x, _actor.y, _n.x + (_dx * _t), _n.y + (_dy * _t)) <= (_width + _body))
        {
            _clear = false;
        }
    }
    ds_list_destroy(_hits);
    return _clear;
}

function ai_commands_cover_fire(arg0, arg1, arg2)
{
    if (!__ai_commands_owned(arg0, arg1) || !is_struct(arg2))
    {
        return false;
    }
    var _role = arg0.combat.covering;
    var _c = arg0.profile.config.covering_fire;
    var _n = arg0.npc;
    if (!_c.enabled || !is_struct(_role) || _role.token != arg1 || _role.point != arg2 || _role.shots >= _c.max_shots || arg0.now >= _role.until || (arg0.now - arg2.observed_at) > _c.memory_seconds || !arg0.knowledge.valid || arg2.target != arg0.knowledge.target || !__ai_perception_hostile(_n, arg2.target) || !ai_team_needs_cover(arg0, _role.ally) || _n.reloading || _n.grenade_flash || _n.shooting || _n.ammo_now <= _c.reserve_rounds || is_in_hub() || arg0.commands.last_fire_check == arg0.step)
    {
        return false;
    }
    ai_commands_sample_motion(arg0);
    if (arg0.commands.moving || __ai_commands_motion_speed(arg0) > 0.001 || !__ai_spatial_clear_line(_n.x, _n.y, arg2.x, arg2.y) || !__ai_commands_cover_lane(arg0, arg2) || !ai_commands_aim(arg0, arg1, arg2.x, arg2.y) || !ai_commands_in_effective_range(arg0, arg2.x, arg2.y) || !ai_commands_camera_step(arg0))
    {
        return false;
    }
    arg0.commands.last_fire_check = arg0.step;
    arg0.commands.last_fire_kind = "cover";
    arg0.commands.area_shots++;
    _role.shots++;
    __ai_commands_emit_shot(arg0, arg2, 0, point_direction(_n.x, _n.y, arg2.x, arg2.y));
    ai_team_note_fire(arg0);
    return true;
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2
}
