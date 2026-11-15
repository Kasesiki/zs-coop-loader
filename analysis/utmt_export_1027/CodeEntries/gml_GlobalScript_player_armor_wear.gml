function player_armor_wear(arg0, arg1 = 1)
{
    if (arg0 <= 0)
    {
        exit;
    }
    var _loss = arg0 * 0.5 * arg1;
    if (skill_hunter_obtained("gearlover"))
    {
        _loss *= (1 - struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("gearlover")), variable_get_hash("durability_decrease_rate")));
    }
    var _condition = player_loadout_get_durability(player_get_local(), "armor slot");
    player_loadout_set_durability("armor slot", _condition - _loss);
}
