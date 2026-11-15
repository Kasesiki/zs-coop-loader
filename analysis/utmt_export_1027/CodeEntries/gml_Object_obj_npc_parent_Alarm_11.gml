ds_grid_copy(grid_faction_my, global.grid_faction);
if (item_exists(arma_now))
{
    var _ammo_drop = item_weapon_get_ammo(arma_now);
    ammo_id_now = scr_npc_get_ammo_drop(_ammo_drop, npc_id);
}
if (npc_get_trader_id(npc_id) != "no_trader")
{
    var _savedata_name = npc_id + "_trader";
    db_open("general");
    var _load = db_section_exists(_savedata_name);
    db_close();
    if (npc_get_trader_id(npc_id) == "random_trader")
    {
        gamedata_trader_calculate_shared_money();
        _load = false;
    }
    if (_load)
    {
        db_open("general");
        if (is_in_hub())
        {
            money_trader = db_read("traders", "money", global.trader_money_all);
        }
        else
        {
            money_trader = db_read(_savedata_name, "money", 0);
        }
        loot_array = db_read(_savedata_name, "items", []);
        loot_array_update_to_zs32(loot_array, "trader inventory");
        db_close();
    }
    else
    {
        var _trader_id = npc_get_trader_id(npc_id);
        db_open("general");
        money_trader = floor(trader_get_money(_trader_id) * global.sk_k[UnknownEnum.Value_22]);
        db_write(_savedata_name, "money", money_trader);
        loot_array = trader_unpack_to_loot_array(_trader_id, false, true);
        db_write(_savedata_name, "items", loot_array);
        db_close();
    }
}

enum UnknownEnum
{
    Value_22 = 22
}
