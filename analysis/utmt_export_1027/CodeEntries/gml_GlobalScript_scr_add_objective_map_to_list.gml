function scr_add_objective_map_to_list(arg0, arg1, arg2, arg3, arg4, arg5 = 0)
{
    var xx = arg0 div 16;
    var yy = arg1 div 16;
    var pos_quest = arg2;
    var id_quest = arg3;
    var _sub = arg4;
    var _obj_index = arg5;
    var rr = _sub * 1.5;
    var dis = irandom(rr div 2);
    var dir = irandom(360);
    var x1 = xx + lengthdir_x(dis, dir);
    var y1 = yy + lengthdir_y(dis, dir);
    if (instance_exists(obj_map_generator))
    {
        var _found = false;
        repeat (32)
        {
            var _cx = floor(x1);
            var _cy = floor(y1);
            if (_cx >= 0 && _cy >= 0 && _cx < obj_map_generator.grid_tile_w && _cy < obj_map_generator.grid_tile_h && ds_grid_get(obj_map_generator.grid_tile, _cx, _cy) == -1)
            {
                _found = true;
                break;
            }
            dis = irandom(rr div 2);
            dir = irandom(360);
            x1 = xx + lengthdir_x(dis, dir);
            y1 = yy + lengthdir_y(dis, dir);
        }
        if (!_found)
        {
            x1 = xx;
            y1 = yy;
        }
    }
    minimap_add_quest_marker(16 * x1, 16 * y1, pos_quest, id_quest, _sub, _obj_index);
}
