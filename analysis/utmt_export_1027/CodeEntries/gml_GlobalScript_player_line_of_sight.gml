function player_line_of_sight(arg0, arg1, arg2 = player_get_local_index())
{
    if (0 && !(variable_global_exists("dev_hide_npcs") && global.dev_hide_npcs))
    {
        return true;
    }
    var _player = player_get(arg2);
    if (!instance_exists(_player))
    {
        return undefined;
    }
    var _player_x = _player.x;
    var _player_y = _player.y;
    if (collision_line(arg0, arg1, _player_x, _player_y, obj_solid, true, true))
    {
        return false;
    }
    if (settings_get("FOG FOW") && !point_in_triangle(arg0, arg1, _player_x, _player_y, global.field_of_view_x1, global.field_of_view_y1, global.field_of_view_x2, global.field_of_view_y2) && point_distance(arg0, arg1, _player_x, _player_y) > global.fow_minimun_dis)
    {
        return false;
    }
    return true;
}

function player_npc_sight(arg0, arg1, arg2, arg3, arg4 = player_get_local_index())
{
    if (0 && !(variable_global_exists("dev_hide_npcs") && global.dev_hide_npcs))
    {
        return 2;
    }
    var _player = player_get(arg4);
    if (!instance_exists(_player))
    {
        return undefined;
    }
    var _player_x = _player.x;
    var _player_y = _player.y;
    var _reveal = global.fow_early_reveal;
    var _best = 2;
    if (settings_get("FOG FOW") && !point_in_triangle(arg0, arg1, _player_x, _player_y, global.field_of_view_x1, global.field_of_view_y1, global.field_of_view_x2, global.field_of_view_y2) && point_distance(arg0, arg1, _player_x, _player_y) > global.fow_minimun_dis)
    {
        var _band_edge = (global.angle_fow / 2) + (12 * _reveal);
        var _off_centre = abs(angle_difference(point_direction(_player_x, _player_y, arg0, arg1), global.fow_direction));
        if (_reveal <= 0 || _off_centre > _band_edge)
        {
            return 0;
        }
        _best = 1;
    }
    if (!collision_line(arg0, arg1, _player_x, _player_y, obj_solid, true, true))
    {
        return _best;
    }
    if (point_distance(arg0, arg1, _player_x, _player_y) > 320)
    {
        return 0;
    }
    var _side = point_direction(_player_x, _player_y, arg0, arg1) + 90;
    for (var _i = -1; _i <= 1; _i += 2)
    {
        var _edge_x = arg0 + lengthdir_x(5 * _i, _side);
        var _edge_y = arg1 + lengthdir_y(5 * _i, _side);
        if (!collision_line(_edge_x, _edge_y, _player_x, _player_y, obj_solid, true, true) && !collision_line(arg0, arg1, _edge_x, _edge_y, obj_solid, true, true))
        {
            return _best;
        }
    }
    if (_reveal <= 0)
    {
        return 0;
    }
    var _move = point_distance(0, 0, arg2, arg3);
    if (_move > 0)
    {
        var _lead = min(_move * 6, 10) * _reveal;
        var _lead_x = arg0 + ((arg2 / _move) * _lead);
        var _lead_y = arg1 + ((arg3 / _move) * _lead);
        if (!collision_line(_lead_x, _lead_y, _player_x, _player_y, obj_solid, true, true) && !collision_line(arg0, arg1, _lead_x, _lead_y, obj_solid, true, true))
        {
            return 1;
        }
    }
    var _player_move_x = global.fow_player_move_x;
    var _player_move_y = global.fow_player_move_y;
    var _player_move = point_distance(0, 0, _player_move_x, _player_move_y);
    if (_player_move > 0)
    {
        var _player_lead = min(_player_move * 10, 12) * _reveal;
        var _ahead_x = _player_x + ((_player_move_x / _player_move) * _player_lead);
        var _ahead_y = _player_y + ((_player_move_y / _player_move) * _player_lead);
        if (!collision_line(arg0, arg1, _ahead_x, _ahead_y, obj_solid, true, true) && !collision_line(_player_x, _player_y, _ahead_x, _ahead_y, obj_solid, true, true))
        {
            return 1;
        }
    }
    return 0;
}
