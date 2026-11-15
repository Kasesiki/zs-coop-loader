function get_map_now()
{
    if (!is_in_raid())
    {
        exit;
    }
    if (!instance_exists(obj_map_generator))
    {
        exit;
    }
    return obj_map_generator.area;
}
