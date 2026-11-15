function hotfix_remove_invalid_quantity_loot()
{
    var _chest_root = db_get_data("chest");
    if (is_struct(_chest_root))
    {
        var _section_array = variable_struct_get_names(_chest_root);
        var _s = 0;
        repeat (array_length(_section_array))
        {
            var _section = _section_array[_s];
            if (string_pos("chest_", _section) == 1)
            {
                __hotfix_remove_invalid_quantity_loot_from_array(db_read_ext("chest", _section, "items", []), _section);
            }
            _s++;
        }
    }
    __hotfix_remove_invalid_quantity_loot_from_array(db_read_ext(inventory_target_db(), "Inventory", "items", []), "Inventory");
}

function __hotfix_remove_invalid_quantity_loot_from_array(arg0, arg1)
{
    var _i = 0;
    repeat (array_length(arg0))
    {
        var _loot = arg0[_i];
        if (_loot.quantity <= 0)
        {
            trace("Removing loot with invalid quantity from \"", arg1, "\": item = ", _loot.item, ", quantity = ", _loot.quantity);
            array_delete(arg0, _i, 1);
            _i--;
        }
        _i++;
    }
}
