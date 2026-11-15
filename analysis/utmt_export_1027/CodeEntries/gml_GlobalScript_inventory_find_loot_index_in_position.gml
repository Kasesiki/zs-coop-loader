function inventory_find_loot_index_in_position(arg0, arg1)
{
    for (var i = 0; i < array_length(arg0); i++)
    {
        if (loot_is_in_inventory_position(arg0[i], arg1))
        {
            return i;
        }
    }
    return -1;
}
