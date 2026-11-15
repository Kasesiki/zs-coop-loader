function __npc_data_fields()
{
    static _fields = ["name", "faction", "speaker_id", "trader_id", "hp", "damage_melee", "power", "spd_not_alerted", "spd_alerted", "rotating_angle", "alert_min_distance", "alert_radius", "alert_visual_distance", "reflexes_minimum", "reflexes_distance_min", "reflexes_distance_max", "reflexes_angle_min", "reflexes_angle_max", "aim_factor", "recoil_crosshair_delay", "recoil_radius_min", "recoil_radius_max", "sweet_angle", "sweet_angle_chance_min", "sweet_angle_chance_max", "prob_attack", "arma", "armor", "backpack", "ammo_value", "attachment_value", "grenade_amount", "prob_grenade_throw", "prob_grenade_f1", "prob_grenade_rgd", "prob_grenade_flash", "prob_grenade_immune_flash", "experience", "chest_dropped", "footstep_sound", "ims_idle", "ims_move", "sprite_idle", "sprite_move", "sprite_dead", "state_patrol", "state_alert", "prob_idle", "prob_move", "prob_grenade_cover"];
    
    return _fields;
}

function __npc_data_shared_fields()
{
    static _fields = ["alert_visual_distance_h", "recoil_crosshair_speed", "recoil_crosshair_speed_max", "recoil_radius_decrease"];
    
    return _fields;
}

function __npc_data_error(arg0, arg1, arg2, arg3)
{
    if (variable_global_exists("__npc_data_errors_are_thrown") && global.__npc_data_errors_are_thrown)
    {
        throw "field \"" + string(arg2) + "\": " + string(arg3);
    }
    trace_error("NPC data \"", arg0, "\", entry \"", arg1, "\", field \"", arg2, "\": ", arg3);
}

function __npc_data_value_check(arg0, arg1, arg2, arg3)
{
    if (is_array(arg3))
    {
        if (arg2 != "arma" && arg2 != "armor" && arg2 != "backpack" && arg2 != "grenade_amount" && arg2 != "chest_dropped")
        {
            __npc_data_error(arg0, arg1, arg2, "this getter does not sample pools");
        }
        if (array_length(arg3) == 0)
        {
            __npc_data_error(arg0, arg1, arg2, "pool must not be empty");
        }
        for (var _i = 0; _i < array_length(arg3); _i++)
        {
            if (!is_string(arg3[_i]) && !is_numeric(arg3[_i]) && !is_bool(arg3[_i]))
            {
                __npc_data_error(arg0, arg1, arg2, "pool entries must be scalar values");
            }
        }
    }
    else if (!is_string(arg3) && !is_numeric(arg3) && !is_bool(arg3))
    {
        __npc_data_error(arg0, arg1, arg2, "expected a scalar value or supported pool, not null/object");
    }
}

function npc_data_prepare(arg0, arg1)
{
    if (arg0.version == 0)
    {
        return arg0.data;
    }
    var _data = arg0.data;
    if (!is_struct(_data))
    {
        __npc_data_error(arg1, "data", "data", "expected an object");
    }
    var _fields = __npc_data_fields();
    var _shared_fields = __npc_data_shared_fields();
    var _ids = variable_struct_get_names(_data);
    for (var _i = 0; _i < array_length(_ids); _i++)
    {
        var _id = _ids[_i];
        var _entry = variable_struct_get(_data, _id);
        if (!is_struct(_entry))
        {
            __npc_data_error(arg1, _id, "entry", "expected an object");
        }
        if (arg0.usage == "npc_preset" && _id == "general")
        {
            var _aliases = struct_get_from_hash(_entry, variable_get_hash("aliases"));
            var _shared = struct_get_from_hash(_entry, variable_get_hash("shared"));
            if (!is_struct(_aliases))
            {
                __npc_data_error(arg1, _id, "aliases", "expected an object");
            }
            if (!is_struct(_shared))
            {
                __npc_data_error(arg1, _id, "shared", "expected an object");
            }
            var _flat = SnapDeepCopy(_entry);
            variable_struct_remove(_flat, "aliases");
            variable_struct_remove(_flat, "shared");
            var _names = variable_struct_get_names(_aliases);
            for (var _j = 0; _j < array_length(_names); _j++)
            {
                var _field = _names[_j];
                if (array_find_index_our(_fields, _field) == undefined || !is_struct(variable_struct_get(_aliases, _field)))
                {
                    __npc_data_error(arg1, _id, "aliases." + _field, "expected a known field's label table");
                }
                var _labels = variable_struct_get_names(variable_struct_get(_aliases, _field));
                for (var _k = 0; _k < array_length(_labels); _k++)
                {
                    __npc_data_value_check(arg1, _id, _field, variable_struct_get(variable_struct_get(_aliases, _field), @@array_get@@(_labels, _k)));
                }
            }
            for (var _j = 0; _j < array_length(_fields); _j++)
            {
                var _field = _fields[_j];
                if (variable_struct_exists(_entry, _field))
                {
                    __npc_data_error(arg1, _id, _field, "version 1 uses aliases, not general forcing");
                }
                variable_struct_set(_flat, _field, variable_struct_exists(_aliases, _field) ? variable_struct_get(_aliases, _field) : "{use_preset}");
            }
            _names = variable_struct_get_names(_shared);
            for (var _j = 0; _j < array_length(_names); _j++)
            {
                if (array_find_index_our(_shared_fields, _names[_j]) == undefined)
                {
                    __npc_data_error(arg1, _id, "shared." + _names[_j], "only the four global settings are supported");
                }
            }
            for (var _j = 0; _j < array_length(_shared_fields); _j++)
            {
                var _field = _shared_fields[_j];
                var _value = variable_struct_get(_shared, _field);
                if (!is_numeric(_value) || is_bool(_value) || is_nan(_value) || is_infinity(_value))
                {
                    __npc_data_error(arg1, _id, "shared." + _field, "expected a finite number");
                }
                if (variable_struct_exists(_entry, _field))
                {
                    __npc_data_error(arg1, _id, _field, "move this setting into shared");
                }
                variable_struct_set(_flat, _field, _value);
            }
            variable_struct_set(_data, _id, _flat);
        }
        else
        {
            var _uses_preset = false;
            if (arg0.usage == "npc")
            {
                var _preset = struct_get_from_hash(_entry, variable_get_hash("npc_preset"));
                if (!is_string(_preset) || _preset == "" || _preset == "general" || _preset == "{use_preset}")
                {
                    __npc_data_error(arg1, _id, "npc_preset", "expected a named preset or no_preset");
                }
                _uses_preset = _preset != "no_preset";
            }
            for (var _j = 0; _j < array_length(_fields); _j++)
            {
                var _field = _fields[_j];
                if (!variable_struct_exists(_entry, _field))
                {
                    if (_uses_preset)
                    {
                        variable_struct_set(_entry, _field, "{use_preset}");
                    }
                    else if (arg0.usage == "npc" && _field == "attachment_value" && struct_get_from_hash(_entry, variable_get_hash("arma")) == "no_item")
                    {
                        continue;
                    }
                    else
                    {
                        __npc_data_error(arg1, _id, _field, "required field has no preset to inherit from");
                    }
                }
                var _value = variable_struct_get(_entry, _field);
                __npc_data_value_check(arg1, _id, _field, _value);
                if (!_uses_preset && _value == "{use_preset}")
                {
                    __npc_data_error(arg1, _id, _field, "inheritance requires a concrete NPC preset");
                }
            }
            for (var _j = 0; _j < array_length(_shared_fields); _j++)
            {
                if (variable_struct_exists(_entry, _shared_fields[_j]))
                {
                    __npc_data_error(arg1, _id, _shared_fields[_j], "belongs in general.shared only");
                }
            }
            if (variable_struct_exists(_entry, "ai") && !is_struct(_entry.ai))
            {
                __npc_data_error(arg1, _id, "ai", "expected an object; omit it to inherit");
            }
            if (variable_struct_exists(_entry, "damage_reduction_from_npcs"))
            {
                var _reduction = _entry.damage_reduction_from_npcs;
                if (!is_numeric(_reduction) || is_bool(_reduction) || is_nan(_reduction) || _reduction < 0 || _reduction > 1)
                {
                    __npc_data_error(arg1, _id, "damage_reduction_from_npcs", "expected a number from 0 to 1; omit it to inherit");
                }
            }
        }
    }
    return _data;
}

function __npc_data_queue_validation(arg0, arg1)
{
    if (!variable_global_exists("__npc_data_pending"))
    {
        global.__npc_data_pending = {};
    }
    var _ids = variable_struct_get_names(arg0.data);
    for (var _i = 0; _i < array_length(_ids); _i++)
    {
        var _key = arg0.usage + "/" + _ids[_i];
        if (arg0.version == 1)
        {
            variable_struct_set(global.__npc_data_pending, _key, 
            {
                file: arg1,
                usage: arg0.usage,
                npc_id: _ids[_i]
            });
        }
        else
        {
            variable_struct_remove(global.__npc_data_pending, _key);
        }
    }
}

function npc_data_validate()
{
    if (!variable_global_exists("__npc_data_pending"))
    {
        exit;
    }
    var _keys = variable_struct_get_names(global.__npc_data_pending);
    var _fields = __npc_data_fields();
    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _ref = variable_struct_get(global.__npc_data_pending, @@array_get@@(_keys, _i));
        var _id = _ref.npc_id;
        var _entry = (_ref.usage == "npc") ? variable_struct_get(global.npc_data, _id) : variable_struct_get(global.npc_preset, _id);
        __npc_data_check_entry(_ref.file, _ref.usage, _id, _entry);
    }
    global.__npc_data_pending = {};
}

function __npc_data_check_entry(arg0, arg1, arg2, arg3)
{
    if (arg1 == "npc_preset" && arg2 == "general")
    {
        exit;
    }
    var _fields = __npc_data_fields();
    var _general = struct_get_from_hash(global.npc_preset, variable_get_hash("general"));
    if (!is_struct(_general))
    {
        __npc_data_error(arg0, arg2, "general", "missing shared preset data");
    }
    var _preset = undefined;
    if (arg1 == "npc" && arg3.npc_preset != "no_preset")
    {
        _preset = variable_struct_get(global.npc_preset, arg3.npc_preset);
        if (!is_struct(_preset))
        {
            __npc_data_error(arg0, arg2, "npc_preset", "unknown preset " + arg3.npc_preset);
        }
    }
    for (var _j = 0; _j < array_length(_fields); _j++)
    {
        var _field = _fields[_j];
        var _value = variable_struct_get(arg3, _field);
        if (_value == "{use_preset}" && (!is_struct(_preset) || is_undefined(variable_struct_get(_preset, _field)) || variable_struct_get(_preset, _field) == "{use_preset}"))
        {
            __npc_data_error(arg0, arg2, _field, "selected preset has no inherited value");
        }
        if (!is_undefined(_value) && !((_field == "arma" || _field == "chest_dropped") && is_array(_value)) && is_undefined(variable_struct_get(_general, _field)))
        {
            __npc_data_error(arg0, arg2, "general." + _field, "missing alias table or internal passthrough marker");
        }
    }
    var _preset_ai = is_struct(_preset) ? struct_get_from_hash(_preset, variable_get_hash("ai")) : undefined;
    var _ai = struct_get_from_hash(arg3, variable_get_hash("ai"));
    if (is_struct(_preset_ai) || is_struct(_ai))
    {
        var _result = ai_profile_resolve(global.ai_profile_data, _preset_ai, _ai, undefined, 123);
        if (!_result.valid)
        {
            __npc_data_error(arg0, arg2, "ai", string(_result.diagnostics));
        }
    }
}
