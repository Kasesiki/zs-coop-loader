function loot_decrement(arg0, arg1 = 1, arg2 = true)
{
    if (arg1 <= 0)
    {
        return undefined;
    }
    var _quantity_removed = min(arg1, max(0, arg0.quantity));
    arg0.quantity -= arg1;
    var _quantity_remaining = arg0.quantity;
    if (arg2 && _quantity_removed > 0)
    {
        mods_perform_event("item_removed", [arg0.item, _quantity_removed]);
        if (arg0.quantity <= 0 && variable_struct_exists(arg0, "placement") && mods_inventory_placement_is_equipment(arg0.placement))
        {
            mods_perform_event("equipment_changed", [player_get_local(), arg0.placement, arg0.item, "no_item"]);
        }
    }
    if (item_fits_category(arg0.item, "container"))
    {
        return true;
    }
    if (arg0.quantity <= 0)
    {
        arg0.quantity = 0;
        db_open(inventory_target_db());
        var _loot_array = db_read("Inventory", "items", []);
        var _i = 0;
        repeat (array_length(_loot_array))
        {
            if (_loot_array[_i] == arg0)
            {
                array_delete(_loot_array, _i, 1);
                break;
            }
            _i++;
        }
        db_write("Inventory", "items", _loot_array);
        db_close();
        if (__uiGlobal().__defaultOnion.LayerExists("inventory layer"))
        {
            var _ui_array = uiFindAllType(uiLayerGetRoot("inventory layer"), "class_ui_item");
            _i = 0;
            repeat (array_length(_ui_array))
            {
                if (_ui_array[_i].__lootStruct == arg0)
                {
                    uiDestroy(_ui_array[_i]);
                }
                else
                {
                    _i++;
                }
            }
        }
    }
    inventory_check_weight();
    if (arg0.quantity <= 0)
    {
        return false;
    }
    else
    {
        return true;
    }
}
