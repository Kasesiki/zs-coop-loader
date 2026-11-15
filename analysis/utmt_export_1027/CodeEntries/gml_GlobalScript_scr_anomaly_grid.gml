function npc_motion_grid()
{
    if (variable_instance_exists(id, "faction") && faction == "Mutants" && variable_global_exists("grid_move_world") && !is_undefined(global.grid_move_world))
    {
        return global.grid_move_world;
    }
    return global.grid_move;
}

function anomaly_grid_available()
{
    return instance_exists(obj_controller) && variable_global_exists("grid_move") && !is_undefined(global.grid_move);
}

function anomaly_grid_cell_blocked_by_world(arg0, arg1)
{
    var _x1 = arg0 * 16;
    var _y1 = arg1 * 16;
    var _x2 = (_x1 + 16) - 1;
    var _y2 = (_y1 + 16) - 1;
    if (collision_rectangle(_x1, _y1, _x2, _y2, obj_solid, false, false) != -4 || collision_rectangle(_x1, _y1, _x2, _y2, obj_solid_can_see, false, false) != -4)
    {
        return true;
    }
    if (!is_in_raid() || !instance_exists(obj_map_generator))
    {
        return false;
    }
    var _m = obj_map_generator;
    var _tile_x = _x1 div 16;
    var _tile_y = _y1 div 16;
    if (_tile_x < 0 || _tile_y < 0)
    {
        return false;
    }
    if (_tile_y < _m.grid_tile_h)
    {
        return _tile_x < _m.grid_tile_w && ds_exists(_m.grid_tile, ds_type_grid) && ds_grid_get(_m.grid_tile, _tile_x, _tile_y) == -7;
    }
    return _tile_x < _m.g_indoor_w && _tile_y < _m.g_indoor_h && tilemap_get(_m.layer_tileset_floor_indoor, _tile_x, _tile_y) == 32;
}

function anomaly_grid_block()
{
    grid_blocked_cells = [];
    if (!anomaly_grid_available())
    {
        exit;
    }
    var _o = obj_controller;
    var _first_x = max(0, floor((bbox_left - 8) / 16));
    var _first_y = max(0, floor((bbox_top - 8) / 16));
    var _last_x = min(_o.grid_move_w - 1, floor((bbox_right + 8) / 16));
    var _last_y = min(_o.grid_move_h - 1, floor((bbox_bottom + 8) / 16));
    for (var _cell_x = _first_x; _cell_x <= _last_x; _cell_x++)
    {
        for (var _cell_y = _first_y; _cell_y <= _last_y; _cell_y++)
        {
            if (anomaly_grid_cell_blocked_by_world(_cell_x, _cell_y))
            {
                continue;
            }
            mp_grid_add_cell(global.grid_move, _cell_x, _cell_y);
            if (ds_exists(_o.grid_motion, ds_type_grid))
            {
                ds_grid_set(_o.grid_motion, _cell_x, _cell_y, -1);
            }
            array_push(grid_blocked_cells, [_cell_x, _cell_y]);
        }
    }
}

function anomaly_grid_other_emitter_covers(arg0, arg1)
{
    var _x1 = (arg0 * 16) - 8;
    var _y1 = (arg1 * 16) - 8;
    var _x2 = ((_x1 + 16) - 1) + 16;
    var _y2 = ((_y1 + 16) - 1) + 16;
    var _hits = ds_list_create();
    var _covered = false;
    collision_rectangle_list(_x1, _y1, _x2, _y2, obj_anomaly_fire, false, true, _hits, false);
    collision_rectangle_list(_x1, _y1, _x2, _y2, obj_anomaly_gas, false, true, _hits, false);
    for (var _i = 0; _i < ds_list_size(_hits) && !_covered; _i++)
    {
        _covered = instance_exists(ds_list_find_value(_hits, _i));
    }
    ds_list_destroy(_hits);
    return _covered;
}

function anomaly_grid_unblock()
{
    if (!variable_instance_exists(id, "grid_blocked_cells") || !anomaly_grid_available())
    {
        exit;
    }
    var _o = obj_controller;
    for (var _i = 0; _i < array_length(grid_blocked_cells); _i++)
    {
        var _cell_x = grid_blocked_cells[_i][0];
        var _cell_y = grid_blocked_cells[_i][1];
        if (anomaly_grid_cell_blocked_by_world(_cell_x, _cell_y))
        {
            continue;
        }
        if (anomaly_grid_other_emitter_covers(_cell_x, _cell_y))
        {
            continue;
        }
        mp_grid_clear_cell(global.grid_move, _cell_x, _cell_y);
        if (ds_exists(_o.grid_motion, ds_type_grid))
        {
            ds_grid_set(_o.grid_motion, _cell_x, _cell_y, 0);
        }
    }
    grid_blocked_cells = [];
}

function anomaly_hazard_at_point(arg0, arg1)
{
    return collision_point(arg0, arg1, obj_anomaly_fire, false, false) != -4 || collision_point(arg0, arg1, obj_anomaly_gas, false, false) != -4;
}

function anomaly_hazard_near_point(arg0, arg1, arg2)
{
    return collision_circle(arg0, arg1, arg2, obj_anomaly_fire, false, false) != -4 || collision_circle(arg0, arg1, arg2, obj_anomaly_gas, false, false) != -4;
}

function anomaly_hazard_on_line(arg0, arg1, arg2, arg3)
{
    return collision_line(arg0, arg1, arg2, arg3, obj_anomaly_fire, false, false) != -4 || collision_line(arg0, arg1, arg2, arg3, obj_anomaly_gas, false, false) != -4;
}
