function get_random_free_spot()
{
    if (!instance_exists(obj_map_generator))
    {
        trace_error("get_random_free_spot() called when obj_map_generator doesn't exist.");
    }
    repeat (50000)
    {
        var xx = irandom_range(10, obj_map_generator.grid_tile_w - 10);
        var yy = irandom_range(10, obj_map_generator.grid_tile_h - 10);
        if (ds_grid_get(obj_map_generator.grid_tile, xx, yy) == -1 && ds_grid_get(obj_map_generator.grid_building, xx, yy) != UnknownEnum.Value_1 && ds_grid_get(obj_map_generator.grid_building, xx, yy) != UnknownEnum.Value_2 && ds_grid_get(obj_map_generator.grid_prevent_spawn, xx, yy) == false)
        {
            if (!collision_rectangle(xx * 16, yy * 16, (xx * 16) + 16, (yy * 16) + 16, obj_decor_parent, true, true))
            {
                var tx = (xx * 16) + 8;
                var ty = (yy * 16) + 8;
                var _struct = 
                {
                    x: tx,
                    y: ty,
                    gx: xx,
                    gy: yy
                };
                return _struct;
            }
        }
    }
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_2
}
