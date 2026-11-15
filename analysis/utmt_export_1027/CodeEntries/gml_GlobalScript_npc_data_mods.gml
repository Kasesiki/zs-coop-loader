function npc_data_mod_merge(arg0, arg1)
{
    var _field_names = variable_struct_get_names(arg1);
    for (var _field_index = 0; _field_index < array_length(_field_names); _field_index++)
    {
        var _field_name = _field_names[_field_index];
        var _patch_value = variable_struct_get(arg1, _field_name);
        var _target_value = variable_struct_get(arg0, _field_name);
        if (is_struct(_patch_value) && is_struct(_target_value))
        {
            npc_data_mod_merge(_target_value, _patch_value);
        }
        else
        {
            variable_struct_set(arg0, _field_name, SnapDeepCopy(_patch_value));
        }
    }
}

function npc_data_mod_build_entry(arg0, arg1, arg2, arg3)
{
    var _database = (arg0 == "npc") ? global.npc_data : global.npc_preset;
    if (!is_struct(arg2))
    {
        throw "expected an object";
    }
    if (arg0 == "npc_preset" && arg1 == "general")
    {
        throw "the shared \"general\" entry cannot be changed by a mod";
    }
    var _entry = {};
    if (variable_struct_exists(arg2, "copy_from"))
    {
        var _source_id = arg2.copy_from;
        if (!is_string(_source_id) || !is_struct(variable_struct_get(_database, _source_id)) || (arg0 == "npc_preset" && _source_id == "general"))
        {
            throw "copy_from names \"" + string(_source_id) + "\", which does not exist";
        }
        _entry = SnapDeepCopy(variable_struct_get(_database, _source_id));
        if (arg0 == "npc")
        {
            _entry.speaker_id = "no_speaker";
        }
    }
    else if (is_struct(variable_struct_get(_database, arg1)))
    {
        _entry = SnapDeepCopy(variable_struct_get(_database, arg1));
    }
    npc_data_mod_merge(_entry, arg2);
    variable_struct_remove(_entry, "copy_from");
    if (variable_struct_exists(_entry, "id"))
    {
        _entry.id = arg1;
    }
    var _one_entry_data = {};
    variable_struct_set(_one_entry_data, arg1, _entry);
    var _was_thrown = variable_global_exists("__npc_data_errors_are_thrown") && global.__npc_data_errors_are_thrown;
    global.__npc_data_errors_are_thrown = true;
    try
    {
        npc_data_prepare(
        {
            version: 1,
            usage: arg0,
            data: _one_entry_data
        }, arg3);
        __npc_data_check_entry(arg3, arg0, arg1, _entry);
    }
    finally
    {
        global.__npc_data_errors_are_thrown = _was_thrown;
    }
    return _entry;
}

function npc_data_mod_load_file(arg0, arg1, arg2)
{
    if (!file_exists(arg1))
    {
        return 0;
    }
    var _json = undefined;
    try
    {
        _json = json_parse(SnapStringFromFile(arg1));
    }
    catch (_error)
    {
        trace("NPC mod ", arg0, ": \"", arg1, "\" is not valid JSON; file skipped");
        return 0;
    }
    if (!is_struct(_json) || struct_get_from_hash(_json, variable_get_hash("version")) != 1 || struct_get_from_hash(_json, variable_get_hash("usage")) != arg2 || !is_struct(struct_get_from_hash(_json, variable_get_hash("data"))))
    {
        trace("NPC mod ", arg0, ": \"", arg1, "\" needs version 1, usage \"", arg2, "\" and a data object; file skipped");
        return 0;
    }
    var _database = (arg2 == "npc") ? global.npc_data : global.npc_preset;
    var _id_list = (arg2 == "npc") ? global.npc_data_array : global.npc_preset_array;
    var _stored_count = 0;
    var _entry_ids = variable_struct_get_names(_json.data);
    for (var _entry_index = 0; _entry_index < array_length(_entry_ids); _entry_index++)
    {
        var _entry_id = _entry_ids[_entry_index];
        if (string_char_at(_entry_id, 1) == "_")
        {
            continue;
        }
        try
        {
            var _entry = npc_data_mod_build_entry(arg2, _entry_id, variable_struct_get(_json.data, _entry_id), arg1);
            if (!variable_struct_exists(_database, _entry_id))
            {
                array_push(_id_list, _entry_id);
            }
            variable_struct_set(_database, _entry_id, _entry);
            _stored_count++;
        }
        catch (_error)
        {
            trace("NPC mod ", arg0, ": \"", arg2, "\" entry \"", _entry_id, "\" skipped: ", string(_error));
        }
    }
    return _stored_count;
}

function npc_data_mod_autoload()
{
    if (!variable_global_exists("Mods_Order") || !variable_global_exists("Mods_Data"))
    {
        exit;
    }
    for (var _mod_index = 0; _mod_index < array_length(global.Mods_Order); _mod_index++)
    {
        var _mod_name = global.Mods_Order[_mod_index];
        var _mod = variable_struct_get(global.Mods_Data, _mod_name);
        if (!is_struct(_mod))
        {
            continue;
        }
        npc_data_mod_load_file(_mod_name, _mod.file_path + "/gamedata/npc_preset.json", "npc_preset");
        npc_data_mod_load_file(_mod_name, _mod.file_path + "/gamedata/npc.json", "npc");
    }
}
