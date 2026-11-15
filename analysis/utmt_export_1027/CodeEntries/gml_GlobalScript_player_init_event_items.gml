function player_init_event_items()
{
    var _item_array = [];
    db_open("shared settings");
    if (db_read("Christmas event items", "santa ak", false))
    {
        array_push(_item_array, "santa_ak");
    }
    if (db_read("Christmas event items", "santa armor", false))
    {
        array_push(_item_array, "armor_natale");
    }
    if (db_read("Christmas event items", "santa backpack", false))
    {
        array_push(_item_array, "backpack_santa");
    }
    if (db_read("Christmas event items", "santa grenade", false))
    {
        repeat (5)
        {
            array_push(_item_array, "grenade_christmas");
        }
    }
    db_close();
    if (array_length(_item_array) > 0)
    {
        var _loot_grid = new class_loot_grid(8, 11);
        var _loot_array = [];
        var _i = 0;
        repeat (array_length(_item_array))
        {
            var _item = _item_array[_i];
            var _position = _loot_grid.TryPlace(_item);
            if (is_struct(_position))
            {
                var _loot = new class_loot(_item, 1, _position.x * 16, _position.y * 16, 0, "other inventory");
                loot_set_from_chest(_loot, true, 100, true);
                array_push(_loot_array, _loot);
                _loot_grid.Place(_position.x, _position.y, _loot);
            }
            _i++;
        }
        _loot_grid.Destroy();
        db_open("chest");
        db_write("chest_0", "items", _loot_array);
        db_close();
    }
}
