function hotfix_quarantine_unknown_items()
{
    var _database = struct_get_from_hash(global.database_struct, variable_get_hash("shared"));
    if (!is_struct(_database))
    {
        return 0;
    }
    var _root = _database.data;
    if (!is_struct(_root))
    {
        trace("Save hotfix: \"shared\" has no data, unknown item check skipped");
        return 0;
    }
    var _general = struct_get_from_hash(_root, variable_get_hash("general"));
    if (!is_struct(_general))
    {
        _general = {};
        _root.general = _general;
    }
    var _section = variable_struct_get(_general, "Unknown items quarantine");
    if (!is_struct(_section))
    {
        _section = {};
        variable_struct_set(_general, "Unknown items quarantine", _section);
    }
    var _quarantine = struct_get_from_hash(_section, variable_get_hash("entries"));
    if (!is_array(_quarantine))
    {
        _quarantine = [];
        _section.entries = _quarantine;
    }
    var _count_before = array_length(_quarantine);
    __hotfix_quarantine_walk(_root, "", _quarantine, _section);
    var _count = array_length(_quarantine) - _count_before;
    if (_count > 0)
    {
        trace("Save hotfix: quarantined ", _count, " unknown item(s) from a newer build or a removed mod");
    }
    return _count;
}

function __hotfix_quarantine_is_unknown(arg0)
{
    if (!item_exists(arg0))
    {
        return false;
    }
    return !is_struct(variable_struct_get(global.item_data, arg0));
}

function __hotfix_quarantine_is_loot(arg0)
{
    return is_struct(arg0) && is_string(struct_get_from_hash(arg0, variable_get_hash("item"))) && variable_struct_exists(arg0, "quantity");
}

function __hotfix_quarantine_walk(arg0, arg1, arg2, arg3)
{
    if (is_array(arg0))
    {
        var _i = array_length(arg0) - 1;
        while (_i >= 0)
        {
            var _value = arg0[_i];
            if (__hotfix_quarantine_is_loot(_value))
            {
                if (__hotfix_quarantine_is_unknown(_value.item))
                {
                    array_push(arg2, 
                    {
                        source: arg1,
                        kind: "loot",
                        loot: _value
                    });
                    array_delete(arg0, _i, 1);
                    trace("Save hotfix: quarantined unknown item \"", _value.item, "\" x", _value.quantity, " from ", arg1);
                }
                else
                {
                    __hotfix_quarantine_clean_weapon(_value, arg1, arg2);
                    __hotfix_quarantine_walk(_value, arg1 + "[" + string(_i) + "]", arg2, arg3);
                }
            }
            else if (is_struct(_value) || is_array(_value))
            {
                __hotfix_quarantine_walk(_value, arg1 + "[" + string(_i) + "]", arg2, arg3);
            }
            _i--;
        }
    }
    else if (is_struct(arg0))
    {
        if (arg0 == arg3)
        {
            exit;
        }
        var _names = variable_struct_get_names(arg0);
        var _n = 0;
        repeat (array_length(_names))
        {
            var _name = _names[_n];
            var _value = variable_struct_get(arg0, _name);
            if (is_struct(_value) || is_array(_value))
            {
                __hotfix_quarantine_walk(_value, (arg1 == "") ? _name : (arg1 + "/" + _name), arg2, arg3);
            }
            _n++;
        }
    }
}

function __hotfix_quarantine_clean_weapon(arg0, arg1, arg2)
{
    var _mods = struct_get_from_hash(arg0, variable_get_hash("mods"));
    if (is_struct(_mods))
    {
        var _i = 0;
        repeat (array_length(global.mod_pos_data_array))
        {
            var _mod_pos = global.mod_pos_data_array[_i];
            var _mod = variable_struct_get(_mods, _mod_pos);
            if (__hotfix_quarantine_is_unknown(_mod))
            {
                array_push(arg2, 
                {
                    source: arg1,
                    kind: "mod",
                    weapon: arg0.item,
                    mod_pos: _mod_pos,
                    loot: 
                    {
                        item: _mod,
                        quantity: 1
                    }
                });
                variable_struct_set(_mods, _mod_pos, "no_item");
                trace("Save hotfix: removed unknown mod \"", _mod, "\" from ", arg0.item, " in ", arg1);
            }
            _i++;
        }
    }
    var _ammo_id = struct_get_from_hash(arg0, variable_get_hash("ammo_id"));
    if (__hotfix_quarantine_is_unknown(_ammo_id))
    {
        var _ammo_quantity = struct_get_from_hash(arg0, variable_get_hash("ammo_quantity"));
        if (is_numeric(_ammo_quantity) && _ammo_quantity > 0)
        {
            array_push(arg2, 
            {
                source: arg1,
                kind: "ammo",
                weapon: arg0.item,
                loot: 
                {
                    item: _ammo_id,
                    quantity: _ammo_quantity
                }
            });
        }
        arg0.ammo_id = item_weapon_get_ammo(arg0.item);
        arg0.ammo_quantity = 0;
        trace("Save hotfix: unloaded unknown ammo \"", _ammo_id, "\" from ", arg0.item, " in ", arg1);
    }
}
