function mods_autoload_chests()
{
    var _required = ["always_seen", "chance_epic", "chance_legendary", "chance_rare", "chance_uncommon", "decay_items", "destroy_when_empty", "from_enemy", "is_drop", "item_max", "item_min", "items", "max_durability", "name", "sound_type", "special_items", "sprite"];
    var _m = 0;
    repeat (array_length(global.Mods_Order))
    {
        var _mod_name = global.Mods_Order[_m];
        _m++;
        var _mod = variable_struct_get(global.Mods_Data, _mod_name);
        if (!is_struct(_mod))
        {
            continue;
        }
        global.__Mods_Context_Current = _mod;
        global.__Mods_Path_Current = _mod.file_path + "/";
        try
        {
            var _path = _mod.file_path + "/gamedata/chest.json";
            if (!file_exists(_path))
            {
                continue;
            }
            var _json;
            try
            {
                _json = json_parse(SnapStringFromFile(_path));
            }
            catch (_error)
            {
                trace("mods_autoload_chests: mod \"", _mod_name, "\" has an unparseable \"gamedata/chest.json\"; skipping file");
                continue;
            }
            if (!is_struct(_json) || struct_get_from_hash(_json, variable_get_hash("version")) != 0 || struct_get_from_hash(_json, variable_get_hash("usage")) != "chests")
            {
                trace("mods_autoload_chests: mod \"", _mod_name, "\" chest.json has a bad header (need version 0, usage \"chests\"); skipping file");
                continue;
            }
            var _data = struct_get_from_hash(_json, variable_get_hash("data"));
            if (!is_struct(_data))
            {
                trace("mods_autoload_chests: mod \"", _mod_name, "\" chest.json has no \"data\" struct; skipping file");
                continue;
            }
            var _names = variable_struct_get_names(_data);
            var _n = 0;
            repeat (array_length(_names))
            {
                var _id = _names[_n];
                _n++;
                var _entry = variable_struct_get(_data, _id);
                if (!is_struct(_entry))
                {
                    trace("mods_autoload_chests: mod \"", _mod_name, "\" chest \"", _id, "\" is not a struct; skipping entry");
                }
                else
                {
                    var _missing = false;
                    var _f = 0;
                    repeat (array_length(_required))
                    {
                        var _field = _required[_f];
                        _f++;
                        if (!variable_struct_exists(_entry, _field))
                        {
                            trace("mods_autoload_chests: mod \"", _mod_name, "\" chest \"", _id, "\" missing required field \"", _field, "\"; skipping entry");
                            _missing = true;
                            break;
                        }
                    }
                    if (_missing)
                    {
                    }
                    else if (is_string(_entry.items) && _entry.items != "{hidden_stash}" && _entry.items != "{human_general}")
                    {
                        trace("mods_autoload_chests: mod \"", _mod_name, "\" chest \"", _id, "\" has unknown items preset \"", _entry.items, "\"; skipping entry");
                    }
                    else
                    {
                        if (is_string(_entry.sprite))
                        {
                            var _resolvable = variable_struct_exists(_mod.sprites, _entry.sprite) || asset_get_index(_entry.sprite) != -1;
                            if (!_resolvable)
                            {
                                trace("mods_autoload_chests: mod \"", _mod_name, "\" chest \"", _id, "\" has unresolvable sprite \"", _entry.sprite, "\"; falling back to s_vuoto");
                                _entry.sprite = asset_get_index("s_vuoto");
                            }
                        }
                        if (variable_struct_exists(global.chest_data, _id))
                        {
                            trace("mods_autoload_chests: mod \"", _mod_name, "\" is overwriting existing chest \"", _id, "\"");
                        }
                        else
                        {
                            array_push(global.chest_data_array, _id);
                        }
                        variable_struct_set(global.chest_data, _id, _entry);
                        chest_resolve_entry(_id);
                    }
                }
            }
        }
        catch (_error)
        {
            trace("mods_autoload_chests: mod \"", _mod_name, "\" failed during chest ingest; skipping mod");
            continue;
        }
    }
}
