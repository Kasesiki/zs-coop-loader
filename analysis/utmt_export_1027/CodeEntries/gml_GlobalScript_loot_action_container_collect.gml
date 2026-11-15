function loot_action_container_collect(arg0)
{
    if (!is_in_hub())
    {
        scr_draw_text_with_box("You can Auto Collect only in the bunker");
        exit;
    }
    var _item = arg0.item;
    var _contained_item = item_container_get_item_id(_item);
    if (__uiGlobal().__defaultOnion.LayerExists("inventory layer"))
    {
        var _ui_array = uiFindAllType(uiLayerGetRoot("inventory layer"), "class_ui_item");
        var _i = 0;
        repeat (array_length(_ui_array))
        {
            var _loot = _ui_array[_i].__lootStruct;
            if (_loot.item == _contained_item)
            {
                arg0.container_amount += _loot.quantity;
                _loot.quantity = 0;
                uiDestroy(_ui_array[_i]);
            }
            _i++;
        }
    }
    var _c = 0;
    if (global.storage_slot_unlocked > 0)
    {
        repeat (global.storage_slot_unlocked)
        {
            var _loot_array = db_read_ext("chest", "chest_" + string(_c), "items", []);
            var _i = 0;
            repeat (array_length(_loot_array))
            {
                var _loot = _loot_array[_i];
                if (_loot.item == _contained_item)
                {
                    arg0.container_amount += _loot.quantity;
                    _loot.quantity = 0;
                }
                _i++;
            }
            _c++;
        }
    }
}
