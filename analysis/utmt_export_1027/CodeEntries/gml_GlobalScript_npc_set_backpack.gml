function npc_set_backpack(arg0)
{
    var _backpack_id = npc_get_backpack(arg0);
    var _backpack_chance = backpack_get_chance_to_drop(_backpack_id);
    if (scr_chance(_backpack_chance))
    {
        return _backpack_id;
    }
    return "no_item";
}
