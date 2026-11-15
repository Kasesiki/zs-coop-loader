function item_get_weight(arg0, arg1 = undefined)
{
    var _struct = variable_struct_get(global.item_data, arg0);
    if (!is_struct(_struct))
    {
        trace_error("Item \"", arg0, "\" not recognised");
    }
    _struct = struct_get_from_hash(_struct, variable_get_hash("basic"));
    if (!is_struct(_struct))
    {
        trace_error("Item \"", arg0, "\" has no .basic data");
    }
    var _add_weight = 0;
    if (item_fits_category(arg0, "container"))
    {
        var _ammo_id = item_container_get_item_id(arg0);
        _add_weight = item_get_weight(_ammo_id) * item_get_stack_max(_ammo_id);
    }
    if (arg1 == undefined)
    {
        return _struct.weight;
    }
    else
    {
        var _loot_weight_multiplier = 1;
        if (skill_hunter_obtained("bigboned"))
        {
            if (item_get_category(arg1.item) == "armor")
            {
                if (arg1 != undefined && arg1.placement == "armor slot")
                {
                    _loot_weight_multiplier = 1 - struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("bigboned")), variable_get_hash("weight_reduction"));
                }
            }
        }
        return (_struct.weight * _loot_weight_multiplier) + _add_weight;
    }
}
