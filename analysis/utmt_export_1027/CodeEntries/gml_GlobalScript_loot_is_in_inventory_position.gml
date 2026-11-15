function loot_is_in_inventory_position(arg0, arg1)
{
    if (!is_struct(arg0))
    {
        return false;
    }
    if (is_undefined(struct_get_from_hash(arg0, variable_get_hash("placement"))))
    {
        return false;
    }
    return arg0.placement == arg1;
}
