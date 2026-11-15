function stash_item_exists(arg0)
{
    for (var _c = 0; _c < global.storage_slot_unlocked; _c++)
    {
        var _loot_array = db_read_ext("chest", "chest_" + string(_c), "items", []);
        for (var _i = 0; _i < array_length(_loot_array); _i++)
        {
            var _loot = _loot_array[_i];
            if (_loot.quantity > 0 && _loot.item == arg0)
            {
                return true;
            }
        }
    }
    return false;
}
