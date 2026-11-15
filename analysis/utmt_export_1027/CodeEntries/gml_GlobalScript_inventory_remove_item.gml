function inventory_remove_item(arg0, arg1)
{
    var _quantity_removed = 0;
    db_open(inventory_target_db());
    var _loot_array = db_read("Inventory", "items", []);
    db_close();
    var _dirty = false;
    var _i = 0;
    repeat (array_length(_loot_array))
    {
        var _loot = _loot_array[_i];
        if (_loot.item == arg0)
        {
            _dirty = true;
            var _amount_to_remove = min(arg1, _loot.quantity);
            _loot.quantity -= _amount_to_remove;
            _quantity_removed += _amount_to_remove;
            arg1 -= _amount_to_remove;
            if (_loot.quantity <= 0 && mods_inventory_placement_is_equipment(_loot.placement))
            {
                mods_perform_event("equipment_changed", [player_get_local(), _loot.placement, arg0, "no_item"]);
            }
            if (arg1 <= 0)
            {
                break;
            }
        }
        _i++;
    }
    if (_dirty && is_in_hub())
    {
        db_force_save_soft("pre_raid");
    }
    if (_quantity_removed > 0)
    {
        mods_perform_event("item_removed", [arg0, _quantity_removed]);
    }
}
