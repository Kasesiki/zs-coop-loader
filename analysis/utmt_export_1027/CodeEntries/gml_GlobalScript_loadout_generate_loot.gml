function loadout_generate_loot(arg0, arg1, arg2)
{
    var _array = [];
    var _loot_grid = new class_loot_grid(arg1, arg2);
    var _i = 0;
    repeat (loadout_get_item_count(arg0))
    {
        var _item_id = loadout_get_item_id(arg0, _i);
        if (!loadout_item_is_suppressed(_item_id))
        {
            var _position = _loot_grid.TryPlace(_item_id);
            if (is_struct(_position))
            {
                var _loot = new class_loot(_item_id, loadout_get_item_stack(arg0, _i), 16 * _position.x, 16 * _position.y, 0, "preview inventory");
                loadout_loot_attach_mods(_loot);
                _loot_grid.Place(_position.x, _position.y, _loot);
                array_push(_array, _loot);
            }
        }
        _i++;
    }
    _loot_grid.Destroy();
    return _array;
}
