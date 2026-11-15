function gamedata_load(arg0)
{
    if (is_array(arg0))
    {
        _i = 0;
        repeat (array_length(arg0))
        {
            gamedata_load(arg0[_i]);
            _i++;
        }
        exit;
    }
    if (!file_exists(arg0))
    {
        trace_error("\"", arg0, "\" doesn't exist");
    }
    trace("Gamedata: Loading \"", arg0, "\"");
    var _json = json_parse(SnapStringFromFile(arg0));
    var _npc_format = _json.usage == "npc" || _json.usage == "npc_preset";
    if (_json.version != 0 && !(_npc_format && _json.version == 1))
    {
        trace_error("Gamedata:\nVersion mismatch for \"", arg0, "\"");
    }
    var _struct_target, _array_target;
    switch (_json.usage)
    {
        case "ai_profiles":
            _struct_target = global.ai_profile_data;
            _array_target = global.ai_profile_data_array;
            break;
        case "npc":
            _struct_target = global.npc_data;
            _array_target = global.npc_data_array;
            break;
        case "npc_preset":
            _struct_target = global.npc_preset;
            _array_target = global.npc_preset_array;
            break;
        case "item":
            _struct_target = global.item_data;
            _array_target = global.item_data_array;
            break;
        case "caliber":
            _struct_target = global.caliber_data;
            _array_target = global.caliber_data_array;
            break;
        case "mod_positions":
            _struct_target = global.mod_pos_data;
            _array_target = global.mod_pos_data_array;
            break;
        case "mod_types":
            _struct_target = global.mod_type_data;
            _array_target = global.mod_type_data_array;
            break;
        case "weapon_types":
            _struct_target = global.weapon_type_data;
            _array_target = global.weapon_type_data_array;
            break;
        case "weapon_glance_stats":
            _struct_target = global.weapon_glance_stat;
            _array_target = global.weapon_glance_stat_array;
            break;
        case "loadouts":
            _struct_target = global.loadout_data;
            _array_target = global.loadout_data_array;
            break;
        case "item_categories":
            _struct_target = global.category_data;
            _array_target = global.category_data_array;
            break;
        case "traders":
            _struct_target = global.trader_data;
            _array_target = global.trader_data_array;
            break;
        case "trader_pages":
            _struct_target = global.trader_pages_data;
            _array_target = global.trader_pages_data_array;
            break;
        case "chest_sounds":
            _struct_target = global.chest_sound_data;
            _array_target = global.chest_sound_data_array;
            break;
        case "chests":
            _struct_target = global.chest_data;
            _array_target = global.chest_data_array;
            break;
        case "speakers":
            _struct_target = global.speaker_data;
            _array_target = global.speaker_data_array;
            break;
        case "stats":
            _struct_target = global.stat_data;
            _array_target = global.stat_data_array;
            break;
        case "gamepad":
            _struct_target = global.gamepad_data;
            _array_target = global.gamepad_data_array;
            break;
        case "languages":
            _struct_target = global.language_data;
            _array_target = global.language_data_array;
            break;
        case "skills":
            _struct_target = global.skills_data;
            _array_target = global.skills_data_array;
            break;
        case "skills_masteries":
            _struct_target = global.skills_masteries_data;
            _array_target = global.skills_masteries_data_array;
            break;
        case "skills_gun_passives":
            _struct_target = global.skills_gun_passives_data;
            _array_target = global.skills_gun_passives_data_array;
            break;
        case "skills_hunter":
            _struct_target = global.skills_hunter_data;
            _array_target = global.skills_hunter_data_array;
            break;
        case "xp":
            _struct_target = global.xp_data;
            _array_target = global.xp_data_array;
            break;
        case "weather":
            _struct_target = global.weather_data;
            _array_target = global.weather_array;
            break;
        case "radio_music":
            _struct_target = global.radio_music;
            _array_target = global.radio_music_array;
            break;
        case "index":
            var _directory = filename_dir(arg0);
            var _array = _json.data;
            _i = 0;
            repeat (array_length(_array))
            {
                var _path = _array[_i];
                var _drive = filename_drive(_path);
                if (_drive == "")
                {
                    gamedata_load(_directory + "/" + _path);
                }
                else
                {
                    gamedata_load(_path);
                }
                _i++;
            }
            exit;
            break;
        default:
            trace_error("Gamedata:\nUnrecognised usage \"", _json.usage, "\"");
            break;
    }
    var _data = _npc_format ? npc_data_prepare(_json, arg0) : _json.data;
    var _names_array = variable_struct_get_names(_data);
    var _size = array_length(_names_array);
    var _i = 0;
    repeat (_size)
    {
        var _name = _names_array[_i];
        if (!variable_struct_exists(_struct_target, _name))
        {
            array_push(_array_target, _name);
        }
        variable_struct_set(_struct_target, _name, variable_struct_get(_data, _name));
        _i++;
    }
    if (_npc_format)
    {
        __npc_data_queue_validation(_json, arg0);
    }
    var _order_array = struct_get_from_hash(_json, variable_get_hash("order"));
    if (is_array(_order_array))
    {
        _i = 0;
        repeat (array_length(_order_array))
        {
            var _name = _order_array[_i];
            var _index = array_find_index_our(_array_target, _name);
            if (_index != undefined)
            {
                array_delete(_array_target, _index, 1);
            }
            array_push(_array_target, _name);
            _i++;
        }
    }
}
