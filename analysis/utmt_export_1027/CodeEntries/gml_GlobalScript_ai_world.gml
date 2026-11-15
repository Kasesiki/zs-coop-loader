function ai_world_get()
{
    if (!variable_global_exists("ai_world") || global.ai_world.room_id != room)
    {
        global.ai_world = 
        {
            room_id: room,
            frame: 0,
            candidates: 0,
            paths: 0,
            claims: {}
        };
    }
    return global.ai_world;
}

function ai_world_begin_step()
{
    if (!variable_global_exists("ai_world"))
    {
        exit;
    }
    var _world = ai_world_get();
    _world.frame++;
    _world.candidates = 0;
    _world.paths = 0;
    _world.hearing_checks = 0;
}

function __ai_world_budget(arg0)
{
    var _world = ai_world_get();
    if (!variable_struct_exists(arg0, "query_frame") || arg0.query_frame != _world.frame)
    {
        arg0.query_frame = _world.frame;
        arg0.query_candidates = 0;
        arg0.query_paths = 0;
    }
    return _world;
}

function ai_world_take_candidate(arg0)
{
    var _world = __ai_world_budget(arg0);
    if (_world.candidates >= 64 || arg0.query_candidates >= arg0.profile.config.queries.candidate_limit)
    {
        return false;
    }
    _world.candidates++;
    arg0.query_candidates++;
    return true;
}

function ai_world_take_path(arg0)
{
    var _world = __ai_world_budget(arg0);
    if (_world.paths >= 8 || arg0.query_paths >= arg0.profile.config.queries.path_limit)
    {
        return false;
    }
    _world.paths++;
    arg0.query_paths++;
    return true;
}

function ai_world_position_valid(arg0, arg1, arg2)
{
    if (!is_numeric(arg1) || !is_numeric(arg2) || is_nan(arg1) || is_nan(arg2) || is_infinity(arg1) || is_infinity(arg2))
    {
        return false;
    }
    if (arg1 < 4 || arg2 < 4 || arg1 >= (room_width - 4) || arg2 >= (room_height - 4))
    {
        return false;
    }
    if (point_distance(arg0.assignment.x, arg0.assignment.y, arg1, arg2) > arg0.assignment.radius)
    {
        return false;
    }
    if (collision_circle(arg1, arg2, 4, obj_solid, false, true) || collision_circle(arg1, arg2, 4, obj_solid_can_see, false, true))
    {
        return false;
    }
    if (anomaly_hazard_near_point(arg1, arg2, 12))
    {
        return false;
    }
    return true;
}

function __ai_world_path_start(arg0, arg1)
{
    var _cell_x = arg0 div 16;
    var _cell_y = arg1 div 16;
    if (mp_grid_get_cell(global.grid_move, _cell_x, _cell_y) == 0 || !instance_exists(obj_controller))
    {
        return [arg0, arg1];
    }
    var _width = obj_controller.grid_move_w;
    var _height = obj_controller.grid_move_h;
    for (var _ring = 1; _ring <= 3; _ring++)
    {
        var _best = undefined;
        var _best_distance = 0;
        var _dx = -_ring;
        while (_dx <= _ring)
        {
            var _dy = -_ring;
            while (_dy <= _ring)
            {
                if (abs(_dx) != _ring && abs(_dy) != _ring)
                {
                }
                else
                {
                    var _cx = _cell_x + _dx;
                    var _cy = _cell_y + _dy;
                    if (_cx < 0 || _cy < 0 || _cx >= _width || _cy >= _height)
                    {
                    }
                    else if (mp_grid_get_cell(global.grid_move, _cx, _cy) != 0)
                    {
                    }
                    else
                    {
                        var _px = (_cx * 16) + 8;
                        var _py = (_cy * 16) + 8;
                        var _distance = point_distance(arg0, arg1, _px, _py);
                        if (is_undefined(_best) || _distance < _best_distance)
                        {
                            _best = [_px, _py];
                            _best_distance = _distance;
                        }
                    }
                }
                _dy++;
            }
            _dx++;
        }
        if (!is_undefined(_best))
        {
            return _best;
        }
    }
    return [arg0, arg1];
}

function ai_world_path(arg0, arg1, arg2, arg3, arg4, arg5)
{
    if (!ai_world_position_valid(arg0, arg4, arg5) || !variable_global_exists("grid_move") || is_undefined(global.grid_move))
    {
        return "no_result";
    }
    if (!ai_world_take_path(arg0))
    {
        return "deferred";
    }
    var _start = __ai_world_path_start(arg2, arg3);
    if (!mp_grid_path(global.grid_move, arg1, _start[0], _start[1], arg4, arg5, true))
    {
        return "no_result";
    }
    if (path_get_number(arg1) > 0)
    {
        path_change_point(arg1, 0, arg2, arg3, 100);
    }
    var _previous = point_distance(arg0.assignment.x, arg0.assignment.y, arg2, arg3);
    var _outside = _previous > arg0.assignment.radius;
    for (var _i = 0; _i < path_get_number(arg1); _i++)
    {
        var _distance = point_distance(arg0.assignment.x, arg0.assignment.y, path_get_point_x(arg1, _i), path_get_point_y(arg1, _i));
        if ((_outside && _distance > (_previous + 0.01)) || (!_outside && _distance > arg0.assignment.radius))
        {
            path_clear_points(arg1);
            return "no_result";
        }
        if (_distance <= arg0.assignment.radius)
        {
            _outside = false;
        }
        _previous = _distance;
    }
    return "found";
}

function ai_world_motion_clear(arg0, arg1, arg2, arg3)
{
    var _direction = point_direction(arg0, arg1, arg2, arg3) + 90;
    for (var _i = -1; _i <= 1; _i++)
    {
        var _dx = lengthdir_x(_i * 4, _direction);
        var _dy = lengthdir_y(_i * 4, _direction);
        if (collision_line(arg0 + _dx, arg1 + _dy, arg2 + _dx, arg3 + _dy, obj_solid, false, true) || collision_line(arg0 + _dx, arg1 + _dy, arg2 + _dx, arg3 + _dy, obj_solid_can_see, false, true))
        {
            return false;
        }
    }
    if (anomaly_hazard_on_line(arg0, arg1, arg2, arg3) && !anomaly_hazard_at_point(arg0, arg1))
    {
        return false;
    }
    return !collision_circle(arg2, arg3, 4, obj_solid, false, true) && !collision_circle(arg2, arg3, 4, obj_solid_can_see, false, true);
}

function ai_world_take_hearing()
{
    var _world = ai_world_get();
    if (!variable_struct_exists(_world, "hearing_checks"))
    {
        _world.hearing_checks = 0;
    }
    if (_world.hearing_checks >= 32)
    {
        return false;
    }
    _world.hearing_checks++;
    return true;
}
