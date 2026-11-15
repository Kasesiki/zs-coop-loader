function stash_get_total_of_item(arg0)
{
    var _total = 0;
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
                if (_loot.item == arg0)
                {
                    _total += _loot.quantity;
                }
                if (item_fits_category(_loot.item, "container") && item_container_get_item_id(_loot.item) == arg0)
                {
                    _total += _loot.container_amount;
                }
                _i++;
            }
            _c++;
        }
    }
    return _total;
}
