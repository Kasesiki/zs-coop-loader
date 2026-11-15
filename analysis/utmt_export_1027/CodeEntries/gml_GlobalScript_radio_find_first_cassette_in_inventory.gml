function radio_find_first_cassette_in_inventory()
{
    db_open(inventory_target_db());
    var _loot_array = db_read("Inventory", "items", []);
    var _i = 0;
    repeat (array_length(_loot_array))
    {
        var _loot = _loot_array[_i];
        if (_loot.quantity > 0 && item_get_category(_loot.item) == "cassette")
        {
            db_close();
            return _loot.item;
        }
        _i++;
    }
    db_close();
    return "no_item";
}
