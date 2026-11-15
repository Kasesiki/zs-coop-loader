function prevent_spawn_ind_horizon()
{
    if (area == UnknownEnum.Value_3)
    {
        ds_grid_set_region(grid_building, 183, 31, 288, 74, UnknownEnum.Value_1);
        ds_grid_set_region(grid_prevent_spawn, 183, 31, 288, 74, true);
    }
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_3 = 3
}
