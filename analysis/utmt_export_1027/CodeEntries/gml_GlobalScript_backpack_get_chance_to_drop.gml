function backpack_get_chance_to_drop(arg0)
{
    var _backpack_tier = item_backpack_get_tier(arg0);
    switch (_backpack_tier)
    {
        case 1:
            return difficulty_get("loot_backpack_tier1");
            break;
        case 2:
            return difficulty_get("loot_backpack_tier2");
            break;
        case 3:
            return difficulty_get("loot_backpack_tier3");
            break;
    }
    return 100;
}
