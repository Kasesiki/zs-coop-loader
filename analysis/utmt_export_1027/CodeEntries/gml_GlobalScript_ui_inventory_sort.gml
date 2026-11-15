function ui_inventory_sort(arg0, arg1 = "player inventory")
{
    var _root = uiLayerGetRoot("inventory layer");
    var _player_inventory = uiFind(_root, arg1);
    var _buy_array = _player_inventory.__children;
    var _number_of_items = array_length(_buy_array);
    var _buy_array_new = [];
    var _buy_array_old = [];
    array_copy(_buy_array_new, 0, _buy_array, 0, _number_of_items);
    array_copy(_buy_array_old, 0, _buy_array, 0, _number_of_items);
    var _old_rotations_array = [];
    var _pre_sort_loot = [];
    for (var i = 0; i < _number_of_items; i++)
    {
        ui_convert_element_to_loot(_buy_array_old[i]);
        _pre_sort_loot[i] = SnapDeepCopy(_buy_array_old[i].__lootStruct);
    }
    var _sorting_grid = ds_grid_create(3, _number_of_items);
    for (var i = 0; i < _number_of_items; i++)
    {
        _old_rotations_array[i] = _buy_array_old[i].__lootStruct.rotation;
        ds_grid_set(_sorting_grid, 0, i, _buy_array_new[i]);
        ds_grid_set(_sorting_grid, 2, i, (_buy_array_new[i].__worldBottom - _buy_array_new[i].__worldTop) * (_buy_array_new[i].__worldRight - _buy_array_new[i].__worldLeft));
        switch (arg0)
        {
            case 0:
                ds_grid_set(_sorting_grid, 1, i, irandom(999));
                break;
            case 1:
                ds_grid_set(_sorting_grid, 1, i, loot_get_value(_buy_array_new[i].__lootStruct));
                break;
            case 2:
                ds_grid_set(_sorting_grid, 1, i, loot_get_weight(_buy_array_new[i].__lootStruct));
                break;
            case 3:
                ds_grid_set(_sorting_grid, 1, i, loot_get_category(_buy_array_new[i].__lootStruct) + loot_get_name(_buy_array_new[i].__lootStruct));
                break;
            case 4:
                ds_grid_set(_sorting_grid, 1, i, (_buy_array_new[i].__worldBottom - _buy_array_new[i].__worldTop) * (_buy_array_new[i].__worldRight - _buy_array_new[i].__worldLeft));
                break;
            case 5:
                ds_grid_set(_sorting_grid, 1, i, loot_get_durability(_buy_array_new[i].__lootStruct));
                break;
            case 6:
                ds_grid_set(_sorting_grid, 1, i, loot_get_quantity(_buy_array_new[i].__lootStruct));
                break;
            default:
                show_debug_message("NO ORDER");
                ds_grid_set(_sorting_grid, 1, i, irandom(999));
                break;
        }
    }
    ds_grid_sort(_sorting_grid, 2, false);
    ds_grid_sort(_sorting_grid, 1, false);
    for (var i = 0; i < _number_of_items; i++)
    {
        _buy_array_new[i] = ds_grid_get(_sorting_grid, 0, i);
    }
    ds_grid_destroy(_sorting_grid);
    _player_inventory.ChildrenClear();
    var _i = 0;
    var _enough_room = true;
    repeat (array_length(_buy_array_new))
    {
        var _child = _buy_array_new[_i];
        _child.__lootStruct.rotation = 0;
        _enough_room &= ui_inventory_add_loot(_child.__lootStruct, arg1, class_ui_item, true);
        _i++;
    }
    _i = 0;
    if (!_enough_room)
    {
        var _refit_cx = _player_inventory.Get("cellCountX");
        var _refit_cy = _player_inventory.Get("cellCountY");
        var _plan_grid = new class_loot_grid(_refit_cx, _refit_cy);
        var _snap_count = array_length(_pre_sort_loot);
        var _order = [];
        var _area = [];
        for (var _oi = 0; _oi < _snap_count; _oi++)
        {
            var _spr = item_get_sprite_inv(_pre_sort_loot[_oi].item);
            _order[_oi] = _oi;
            _area[_oi] = (sprite_get_width(_spr) div 16) * (sprite_get_height(_spr) div 16);
        }
        for (var _si = 0; _si < (_snap_count - 1); _si++)
        {
            var _max_j = _si;
            var _sj = _si + 1;
            while (_sj < _snap_count)
            {
                if (_area[_order[_sj]] > _area[_order[_max_j]])
                {
                    _max_j = _sj;
                }
                _sj++;
            }
            if (_max_j != _si)
            {
                var _tmp = _order[_si];
                _order[_si] = _order[_max_j];
                _order[_max_j] = _tmp;
            }
        }
        var _plan = [];
        var _plan_failed = false;
        for (var _pi = 0; _pi < _snap_count; _pi++)
        {
            var _idx = _order[_pi];
            var _loot = _pre_sort_loot[_idx];
            var _pos = _plan_grid.TryPlace(_loot.item);
            if (_pos == undefined)
            {
                _plan_failed = true;
                break;
            }
            _plan_grid.Place(_pos.x, _pos.y, _loot);
            _plan[array_length(_plan)] = 
            {
                idx: _idx,
                x: _pos.x,
                y: _pos.y,
                rot: _pos.rot
            };
        }
        _plan_grid.Destroy();
        if (!_plan_failed && array_length(_plan) == _snap_count)
        {
            _player_inventory.ChildrenClear();
            for (var _ai = 0; _ai < _snap_count; _ai++)
            {
                var _entry = _plan[_ai];
                var _new_loot = SnapDeepCopy(_pre_sort_loot[_entry.idx]);
                _new_loot.x = _entry.x * 16;
                _new_loot.y = _entry.y * 16;
                _new_loot.rotation = _entry.rot;
                ui_convert_loot_to_element(_new_loot, class_ui_item, arg1);
            }
            var _refit_count = array_length(_player_inventory.__children);
            if (_refit_count != _snap_count)
            {
                trace("ui_inventory_sort: re-fit integrity FAILED - snapshot ", _snap_count, " != restored ", _refit_count);
            }
            ui_inventory_check_weight();
            return true;
        }
        _player_inventory.ChildrenClear();
        scr_draw_text_with_box("Not enough inventory space!");
        repeat (array_length(_pre_sort_loot))
        {
            ui_convert_loot_to_element(SnapDeepCopy(_pre_sort_loot[_i]), class_ui_item, arg1);
            _i++;
        }
        var _restored_count = array_length(_player_inventory.__children);
        if (_restored_count != array_length(_pre_sort_loot))
        {
            trace("ui_inventory_sort: rollback integrity FAILED - snapshot ", array_length(_pre_sort_loot), " != restored ", _restored_count);
        }
        ui_inventory_check_weight();
        return false;
    }
    return true;
}
