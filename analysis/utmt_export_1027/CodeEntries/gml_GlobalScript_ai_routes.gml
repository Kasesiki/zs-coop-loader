function ai_routes_create(arg0)
{
    arg0.route = 
    {
        active: false,
        authored: arg0.npc.follow_path,
        suspended: false,
        failures: 0,
        retry_at: 0,
        offscreen_retry_frame: 0,
        goal_index: -1,
        last_reason: "initial",
        roster_index: variable_instance_exists(arg0.npc, "ai_roster_index") ? arg0.npc.ai_roster_index : -1,
        has_route_fields: variable_instance_exists(arg0.npc, "lista_path_x") && variable_instance_exists(arg0.npc, "lista_path_y") && variable_instance_exists(arg0.npc, "path_position_now"),
        base_radius: arg0.assignment.radius,
        hard_leash: variable_instance_exists(arg0.npc, "leash_to_spawn") && arg0.npc.leash_to_spawn,
        leash_origin_x: arg0.assignment.x,
        leash_origin_y: arg0.assignment.y,
        waypoints_reached: 0,
        offscreen_distance: 0
    };
    __ai_routes_anchor(arg0, false);
}

function ai_routes_sync(arg0)
{
    var _npc = arg0.npc;
    if (instance_exists(_npc) && variable_instance_exists(_npc, "ai_roster_index"))
    {
        arg0.route.roster_index = _npc.ai_roster_index;
    }
    if (!variable_global_exists("list_n_id") || !is_array(global.list_n_id))
    {
        return false;
    }
    var _index = arg0.route.roster_index;
    if (!__ai_profile_number(_index) || _index != floor(_index) || _index < 0 || _index >= array_length(global.list_n_id) || global.list_n_id[_index] != _npc)
    {
        return false;
    }
    if (!variable_global_exists("list_n_x") || !is_array(global.list_n_x) || !variable_global_exists("list_n_y") || !is_array(global.list_n_y) || !variable_global_exists("list_n_follow_path") || !is_array(global.list_n_follow_path) || _index >= min(array_length(global.list_n_x), array_length(global.list_n_y), array_length(global.list_n_follow_path)))
    {
        return false;
    }
    global.list_n_x[_index] = _npc.x;
    global.list_n_y[_index] = _npc.y;
    global.list_n_follow_path[_index] = _npc.follow_path;
    if (variable_global_exists("list_n_hp") && is_array(global.list_n_hp) && _index < array_length(global.list_n_hp))
    {
        global.list_n_hp[_index] = _npc.hp;
    }
    return true;
}

function __ai_routes_anchor(arg0, arg1)
{
    var _r = arg0.route;
    if (!_r.authored && !arg0.npc.follow_path)
    {
        exit;
    }
    if (_r.hard_leash)
    {
        arg0.assignment = 
        {
            x: _r.leash_origin_x,
            y: _r.leash_origin_y,
            radius: _r.base_radius
        };
    }
    else
    {
        arg0.assignment = 
        {
            x: arg0.npc.x,
            y: arg0.npc.y,
            radius: arg1 ? point_distance(0, 0, room_width, room_height) : _r.base_radius
        };
    }
}

function __ai_routes_finish(arg0, arg1)
{
    arg0.npc.follow_path = false;
    arg0.route.last_reason = arg1;
    arg0.route.failures = 0;
    __ai_routes_anchor(arg0, false);
    arg0.route.authored = false;
    ai_routes_sync(arg0);
}

function __ai_routes_goal(arg0)
{
    var _npc = arg0.npc;
    if (!_npc.follow_path)
    {
        return undefined;
    }
    arg0.route.authored = true;
    if (instance_exists(_npc))
    {
        arg0.route.has_route_fields = variable_instance_exists(_npc, "lista_path_x") && variable_instance_exists(_npc, "lista_path_y") && variable_instance_exists(_npc, "path_position_now");
    }
    if (!arg0.route.has_route_fields || !__ai_profile_number(_npc.lista_path_x) || !__ai_profile_number(_npc.lista_path_y) || !ds_exists(_npc.lista_path_x, ds_type_list) || !ds_exists(_npc.lista_path_y, ds_type_list))
    {
        __ai_routes_finish(arg0, "invalid_route");
        return undefined;
    }
    var _size = ds_list_size(_npc.lista_path_x);
    if (_size != ds_list_size(_npc.lista_path_y))
    {
        __ai_routes_finish(arg0, "mismatched_route");
        return undefined;
    }
    var _cursor = _npc.path_position_now;
    if (!__ai_profile_number(_cursor) || _cursor != floor(_cursor) || _cursor < -1)
    {
        __ai_routes_finish(arg0, "invalid_cursor");
        return undefined;
    }
    if (_size <= 1 || _cursor >= (_size - 1))
    {
        __ai_routes_finish(arg0, "complete");
        return undefined;
    }
    var _x = ds_list_find_value(_npc.lista_path_x, _cursor + 1);
    var _y = ds_list_find_value(_npc.lista_path_y, _cursor + 1);
    if (!__ai_profile_number(_x) || !__ai_profile_number(_y) || _x < 4 || _y < 4 || _x >= (room_width - 4) || _y >= (room_height - 4))
    {
        __ai_routes_finish(arg0, "invalid_waypoint");
        return undefined;
    }
    if (arg0.route.hard_leash && point_distance(arg0.route.leash_origin_x, arg0.route.leash_origin_y, _x, _y) > arg0.route.base_radius)
    {
        __ai_routes_finish(arg0, "outside_leash");
        return undefined;
    }
    return 
    {
        index: _cursor + 1,
        x: _x,
        y: _y
    };
}

function ai_routes_pending(arg0)
{
    var _e = arg0.user_data;
    return !_e.knowledge.valid && !_e.route.suspended && !is_undefined(__ai_routes_goal(_e));
}

function ai_routes_enter(arg0, arg1)
{
    var _e = arg0.user_data;
    __ai_human_action_enter(arg0, arg1);
    _e.route.active = true;
    arg1.data.goal = __ai_routes_goal(_e);
    arg1.data.deadline = _e.now + 30;
    if (!is_undefined(arg1.data.goal))
    {
        var _goal = arg1.data.goal;
        if (_goal.index != _e.route.goal_index)
        {
            _e.route.failures = 0;
            _e.route.goal_index = _goal.index;
        }
        __ai_routes_anchor(_e, true);
    }
}

function __ai_routes_failed(arg0, arg1)
{
    arg0.route.failures++;
    arg0.route.last_reason = arg1;
    arg0.route.retry_at = arg0.now + 1;
    arg0.route.offscreen_retry_frame = ai_world_get().frame + 60;
    if (arg0.route.failures >= 3)
    {
        __ai_routes_finish(arg0, "blocked_route");
    }
}

function __ai_routes_arrived(arg0, arg1)
{
    arg0.npc.path_position_now = arg1.index;
    arg0.route.failures = 0;
    arg0.route.waypoints_reached++;
    arg0.route.last_reason = "waypoint_reached";
    __ai_routes_goal(arg0);
    ai_routes_sync(arg0);
}

function __ai_routes_blocked_cells(arg0, arg1, arg2)
{
    var _cell_x = floor(arg0 / 16);
    var _cell_y = floor(arg1 / 16);
    var _reach = ceil(arg2 / 16);
    var _blocked = 0;
    var _dx = -_reach;
    while (_dx <= _reach)
    {
        var _dy = -_reach;
        while (_dy <= _reach)
        {
            if (mp_grid_get_cell(global.grid_move, _cell_x + _dx, _cell_y + _dy) < 0)
            {
                _blocked += 1;
            }
            _dy++;
        }
        _dx++;
    }
    return _blocked;
}

function ai_routes_ground_open(arg0, arg1)
{
    if (!variable_global_exists("grid_move") || is_undefined(global.grid_move))
    {
        return false;
    }
    var _npc = arg0.npc;
    if (__ai_routes_blocked_cells(_npc.x, _npc.y, arg1.open_radius_px) > arg1.open_blocked_cells_max)
    {
        return false;
    }
    var _last = ds_list_size(_npc.lista_path_x) - 1;
    for (var _sample = 1; _sample <= 3; _sample++)
    {
        var _index = min(_last, _npc.path_position_now + max(1, round((arg1.lookahead_waypoints * _sample) / 3)));
        if (__ai_routes_blocked_cells(ds_list_find_value(_npc.lista_path_x, _index), ds_list_find_value(_npc.lista_path_y, _index), arg1.open_radius_px) > arg1.open_blocked_cells_max)
        {
            return false;
        }
    }
    return true;
}

function ai_routes_pace(arg0)
{
    var _config = arg0.profile.config.roaming_movement;
    if (!_config.enabled)
    {
        return "walk";
    }
    var _group = ai_roaming_group_of(arg0.npc);
    var _holder = is_struct(_group) ? _group : arg0.route;
    if (!variable_struct_exists(_holder, "pace_decision"))
    {
        _holder.pace_decision = 
        {
            kind: "walk",
            until_frame: -1,
            sprint_ready_frame: 0
        };
    }
    var _pace = _holder.pace_decision;
    var _frame = ai_world_get().frame;
    if (_frame < _pace.until_frame)
    {
        return _pace.kind;
    }
    var _open = ai_routes_ground_open(arg0, _config);
    var _run_roll = ai_profile_random(arg0.rng);
    var _sprint_roll = ai_profile_random(arg0.rng);
    _pace.kind = "walk";
    _pace.until_frame = _frame + max(1, round(_config.decide_seconds * 60));
    if (_open && _run_roll < _config.open_run_chance)
    {
        _pace.kind = "run";
        if (_frame >= _pace.sprint_ready_frame && _sprint_roll < _config.sprint_chance)
        {
            _pace.kind = "sprint";
            _pace.until_frame = _frame + max(1, round(_config.sprint_seconds * 60));
            _pace.sprint_ready_frame = _pace.until_frame + round(_config.sprint_cooldown_seconds * 60);
        }
    }
    else if (!_open && _run_roll < _config.covered_run_chance)
    {
        _pace.kind = "run";
    }
    return _pace.kind;
}

function __ai_routes_pace_speed(arg0, arg1, arg2)
{
    if (arg1 == "walk")
    {
        return arg2;
    }
    var _alerted = 0;
    with (arg0.npc)
    {
        _alerted = npc_get_spd_alerted(npc_id);
    }
    var _speed = (arg1 == "sprint") ? (_alerted * arg0.profile.config.hunter.sprint_multiplier) : _alerted;
    return max(arg2, _speed);
}

function ai_routes_update(arg0, arg1)
{
    var _e = arg0.user_data;
    if (_e.knowledge.valid || _e.route.suspended)
    {
        return UnknownEnum.Value_1;
    }
    var _goal = __ai_routes_goal(_e);
    if (is_undefined(_goal))
    {
        return UnknownEnum.Value_1;
    }
    if (is_undefined(arg1.data.goal) || _goal.index != arg1.data.goal.index || _goal.x != arg1.data.goal.x || _goal.y != arg1.data.goal.y)
    {
        return UnknownEnum.Value_1;
    }
    if (_e.now < _e.route.retry_at)
    {
        ai_commands_stop(_e, arg1.token);
        return UnknownEnum.Value_0;
    }
    if (_e.now >= arg1.data.deadline)
    {
        __ai_routes_failed(_e, "leg_deadline");
        return UnknownEnum.Value_2;
    }
    var _speed = 0;
    with (_e.npc)
    {
        _speed = npc_get_spd_not_alerted(npc_id);
    }
    _speed = ai_roaming_route_speed(_e.npc, _speed);
    var _pace = ai_routes_pace(_e);
    _speed = __ai_routes_pace_speed(_e, _pace, _speed);
    _e.route.pace_kind = _pace;
    var _heading = point_direction(_e.npc.x, _e.npc.y, _goal.x, _goal.y);
    if (_pace == "walk")
    {
        ai_routines_scan(_e, arg1.token, _heading);
    }
    else
    {
        ai_commands_aim(_e, arg1.token, _e.npc.x + lengthdir_x(100, _heading), _e.npc.y + lengthdir_y(100, _heading));
    }
    var _move = ai_commands_move(_e, arg1.token, _goal.x, _goal.y, _speed, 1);
    if (_move == "failed")
    {
        __ai_routes_failed(_e, "leg_unreachable");
        return UnknownEnum.Value_2;
    }
    if (_move == "arrived")
    {
        __ai_routes_arrived(_e, _goal);
        return UnknownEnum.Value_1;
    }
    ai_routes_sync(_e);
    return UnknownEnum.Value_0;
}

function ai_routes_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    _e.route.active = false;
    _e.route.pace_kind = "walk";
    __ai_human_action_exit(arg0, arg1, arg2);
    __ai_routes_anchor(_e, false);
    ai_routes_sync(_e);
}

function ai_routes_suspend(arg0)
{
    if (!variable_struct_exists(arg0, "route"))
    {
        exit;
    }
    arg0.route.suspended = true;
    __ai_routes_anchor(arg0, false);
    ai_routes_sync(arg0);
}

function ai_routes_resume(arg0)
{
    if (!arg0.route.suspended)
    {
        exit;
    }
    arg0.route.suspended = false;
    __ai_routes_anchor(arg0, false);
    ai_routes_sync(arg0);
}

function __ai_routes_offscreen_clear(arg0, arg1, arg2)
{
    if (arg1 < 4 || arg2 < 4 || arg1 >= (room_width - 4) || arg2 >= (room_height - 4))
    {
        return false;
    }
    if (arg0.route.hard_leash && point_distance(arg0.route.leash_origin_x, arg0.route.leash_origin_y, arg1, arg2) > arg0.route.base_radius)
    {
        return false;
    }
    if (!variable_global_exists("grid_move") || is_undefined(global.grid_move))
    {
        return false;
    }
    for (var _dx = -4; _dx <= 4; _dx += 4)
    {
        for (var _dy = -4; _dy <= 4; _dy += 4)
        {
            if (mp_grid_get_cell(global.grid_move, floor((arg1 + _dx) / 16), floor((arg2 + _dy) / 16)) < 0)
            {
                return false;
            }
        }
    }
    return true;
}

function ai_routes_offscreen(arg0, arg1, arg2)
{
    if (!is_struct(arg0) || arg0.profile.config.tree != "human_basic" || !variable_struct_exists(arg0, "route"))
    {
        return false;
    }
    var _npc = arg0.npc;
    var _r = arg0.route;
    _npc.ai_roster_index = arg1;
    _r.roster_index = arg1;
    if (instance_exists(_npc) || !_r.suspended || _npc.hp <= 0)
    {
        ai_routes_sync(arg0);
        return true;
    }
    if (!_npc.follow_path || _npc.state != "human_general" || _npc.force_moving_towards_player || arg0.knowledge.valid || arg0.withdrawal.active || ai_world_get().frame < _r.offscreen_retry_frame)
    {
        return true;
    }
    if (!__ai_profile_number(arg2) || arg2 <= 0)
    {
        return true;
    }
    var _remaining = min(128, arg2);
    var _crossings = 0;
    var _samples = 0;
    while (_remaining > 0 && _crossings < 16 && _samples < 32)
    {
        var _goal = __ai_routes_goal(arg0);
        if (is_undefined(_goal))
        {
            break;
        }
        if (_goal.index != _r.goal_index)
        {
            _r.failures = 0;
            _r.goal_index = _goal.index;
        }
        var _gap = point_distance(_npc.x, _npc.y, _goal.x, _goal.y);
        if (_gap <= 0.01)
        {
            __ai_routes_arrived(arg0, _goal);
            _crossings++;
            continue;
        }
        var _move = min(4, _remaining, _gap);
        var _direction = point_direction(_npc.x, _npc.y, _goal.x, _goal.y);
        var _x = _npc.x + lengthdir_x(_move, _direction);
        var _y = _npc.y + lengthdir_y(_move, _direction);
        _samples++;
        if (!__ai_routes_offscreen_clear(arg0, _x, _y))
        {
            __ai_routes_failed(arg0, "offscreen_blocked");
            break;
        }
        _npc.x = _x;
        _npc.y = _y;
        _remaining -= _move;
        _r.offscreen_distance += _move;
        if (_gap <= (_move + 0.01))
        {
            __ai_routes_arrived(arg0, _goal);
            _crossings++;
        }
    }
    __ai_routes_anchor(arg0, false);
    ai_routes_sync(arg0);
    return true;
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2
}
