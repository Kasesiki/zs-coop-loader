function loot_get_value_sell_per_unit(arg0)
{
    var _value = 0;
    var _item = loot_get_item(arg0);
    if (room == r_menu)
    {
        _value = loot_get_value_per_unit(arg0) * difficulty_get("trade_sell_mult");
    }
    else
    {
        var _sell_price_multi = 1;
        if (skill_hunter_obtained("eyeforvalue"))
        {
            _sell_price_multi += struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("eyeforvalue")), variable_get_hash("sell_multiplier"));
        }
        _value = loot_get_value_per_unit(arg0) * difficulty_get("trade_sell_mult") * global.sk_k[UnknownEnum.Value_21] * _sell_price_multi;
    }
    if (item_fits_category(_item, "backpack"))
    {
        _value *= 0.2;
    }
    return _value;
}

enum UnknownEnum
{
    Value_21 = 21
}
