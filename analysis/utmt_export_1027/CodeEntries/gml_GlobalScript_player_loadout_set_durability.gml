function player_loadout_set_durability(arg0, arg1)
{
    var _player = player_get_local();
    var _loot = player_loadout_get_loot(_player, arg0);
    if (!item_exists(loot_get_item(_loot)))
    {
        exit;
    }
    if (!variable_struct_exists(_loot, "durability"))
    {
        _loot.durability = 100;
        exit;
    }
    var _durability_previous = _loot.durability;
    _loot.durability = clamp(arg1, 0, 100);
    if (arg0 == "armor slot" && _durability_previous > 0 && _loot.durability <= 0)
    {
        mods_perform_event("armor_broken", [_player, loot_get_item(_loot)]);
    }
}
