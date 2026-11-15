function stash_clean_up_empty_items()
{
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
                if (_loot.quantity <= 0)
                {
                    _dirty = true;
                    array_delete(_loot_array, _i, 1);
                }
                else
                {
                    _i++;
                }
            }
            _c++;
        }
    }
    if (_dirty && is_in_hub())
    {
        db_force_save_soft("chest");
    }
}
