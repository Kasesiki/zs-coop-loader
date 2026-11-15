function ai_roaming_config_defaults()
{
    return 
    {
        rest_seconds_min: 0,
        rest_seconds_max: 0,
        trip_distance_min_px: 800,
        trip_distance_max_px: 6000,
        map_border_margin_px: 320,
        offscreen_speed_multiplier: 1,
        straggler_wait_seconds: 60,
        destination_tries: 30,
        failed_destination_limit: 3,
        failed_destination_wait_seconds: 15,
        offscreen_fight_range_px: 120,
        offscreen_fight_chance_percent: 50,
        offscreen_fight_interval_seconds: 8,
        offscreen_fight_power_exponent: 1,
        templates_that_do_not_keep_roaming: ["boss_arman", "boss_phantom"],
        templates_that_react_to_noise: ["loner_1", "loner_2"],
        noise_motive_weights: 
        {
            aggressive: 40,
            patient: 35,
            scavenger: 25
        },
        noise_merge_distance_px: 250,
        noise_spot_limit: 8,
        noise_spot_lifetime_seconds: 90,
        noise_active_seconds: 20,
        noise_hearing_range_px: 750,
        noise_response_chance_percent: 50,
        noise_response_cooldown_seconds: 120,
        noise_responders_per_spot: 2,
        noise_max_active_responders: 2,
        noise_patient_distance_px: 300,
        noise_patient_distance_spread_percent: 20,
        noise_patient_wait_seconds: 40,
        noise_arrival_radius_px: 96,
        noise_scavenger_quiet_seconds: 30,
        noise_travel_speed_multiplier: 1,
        regroup_after_combat_seconds: 8,
        departure_health_percent: 30,
        departure_timeout_seconds: 240,
        claim_player_distance_px: 64,
        claim_loot_seconds: 4,
        claim_warning_repeat_seconds: 4,
        claim_warning_seconds: 3,
        claim_lifetime_seconds: 180,
        claim_approach_distance_px: 64,
        claim_stand_distance_min_px: 24,
        claim_stand_distance_max_px: 48,
        claim_aim_distance_px: 140,
        claim_loot_reach_px: 28,
        scavenger_body_radius_px: 300,
        scavenger_body_lifetime_seconds: 240,
        recent_body_limit: 24,
        static_heir_radius_px: 250,
        own_dead_recovery_radius_px: 400,
        loot: ai_roaming_loot_defaults(),
        spawning: undefined
    };
}

function ai_roaming_loot_defaults()
{
    var _loot = 
    {
        seconds_first_item: 1.5,
        seconds_per_item: 0.4,
        seconds_max: 8,
        budget_by_tier: 
        {
            rookie: 6,
            intermediate: 8,
            skilled: 10,
            expert: 12,
            veteran: 14,
            master: 16
        },
        budget_default: 10,
        budget_bonus: 0,
        spare_equipment_max: 1,
        max_item_weight: 6,
        overlook_chance_by_tier: 
        {
            rookie: 15,
            intermediate: 10,
            skilled: 6,
            expert: 3,
            veteran: 1,
            master: 0
        },
        heal_below_hp_percent: 60,
        never_categories: ["key", "documents", "upgrade_base_kit", "base_storage_use"],
        never_item_prefixes: ["quest"],
        priority: ["weapon", "armor", "backpack", "medication", "injector", "ammo", "grenade", "w_mod", "repair_weapon", "repair_armor", "barter", "headset", "cassette", "container", "consumable"],
        take_other_calibers: false,
        loots_kills: false,
        recovers_own_dead: false,
        factions: {}
    };
    _loot.factions.Bandits = 
    {
        loots_kills: true,
        take_other_calibers: true
    };
    variable_struct_set(_loot.factions, "Green Army", 
    {
        recovers_own_dead: true,
        priority: ["weapon", "armor", "backpack", "ammo", "grenade", "w_mod", "medication", "injector", "repair_weapon", "repair_armor", "headset"]
    });
    variable_struct_set(_loot.factions, "Crimson Corporation", 
    {
        recovers_own_dead: true,
        priority: ["weapon", "armor", "backpack", "injector", "medication", "w_mod", "ammo", "grenade", "repair_weapon", "repair_armor", "headset"]
    });
    _loot.factions.Watcher = 
    {
        priority: ["weapon", "armor", "backpack", "injector", "medication", "ammo", "w_mod", "grenade", "barter", "cassette", "container"]
    };
    _loot.factions.Loners = 
    {
        loots_kills: true,
        budget_bonus: 5,
        spare_equipment_max: 2,
        priority: ["weapon", "armor", "backpack", "medication", "injector", "ammo", "repair_weapon", "repair_armor", "w_mod", "grenade", "barter", "container", "headset"]
    };
    _loot.factions.scavenger = 
    {
        loots_kills: true,
        budget_bonus: 5,
        spare_equipment_max: 2,
        take_other_calibers: true,
        priority: ["weapon", "armor", "backpack", "medication", "injector", "ammo", "grenade", "w_mod", "repair_weapon", "repair_armor", "barter", "headset", "cassette", "container", "consumable"]
    };
    return _loot;
}

function ai_roaming_read_file(arg0)
{
    try
    {
        var _buffer = buffer_load(arg0);
        var _json_text = buffer_read(_buffer, buffer_text);
        buffer_delete(_buffer);
        var _json = json_parse(_json_text);
        if (!is_struct(_json) || struct_get_from_hash(_json, variable_get_hash("usage")) != "roaming" || !is_struct(struct_get_from_hash(_json, variable_get_hash("data"))))
        {
            show_debug_message("Roaming: \"" + arg0 + "\" is not a roaming file, ignored");
            return undefined;
        }
        return _json.data;
    }
    catch (_error)
    {
        show_debug_message("Roaming: could not read \"" + arg0 + "\". " + string(_error));
        return undefined;
    }
}

function ai_roaming_config_from_data(arg0)
{
    var _config = ai_roaming_config_defaults();
    if (is_struct(struct_get_from_hash(arg0, variable_get_hash("spawning"))))
    {
        _config.spawning = arg0.spawning;
    }
    var _file_values = struct_get_from_hash(arg0, variable_get_hash("continuous_roaming"));
    if (!is_struct(_file_values))
    {
        return _config;
    }
    var _field_names = variable_struct_get_names(_config);
    for (var _field_index = 0; _field_index < array_length(_field_names); _field_index++)
    {
        var _field_name = _field_names[_field_index];
        if (_field_name == "spawning" || !variable_struct_exists(_file_values, _field_name))
        {
            continue;
        }
        var _default_value = variable_struct_get(_config, _field_name);
        var _file_value = variable_struct_get(_file_values, _field_name);
        var _same_type = (is_array(_default_value) && is_array(_file_value)) || (is_struct(_default_value) && is_struct(_file_value)) || (is_numeric(_default_value) && is_numeric(_file_value));
        if (!_same_type)
        {
            show_debug_message("Roaming: wrong value type for \"" + _field_name + "\", using the default");
        }
        else if (is_struct(_default_value))
        {
            var _merged = variable_clone(_default_value);
            ai_roaming_merge_patch(_merged, _file_value);
            variable_struct_set(_config, _field_name, _merged);
        }
        else
        {
            variable_struct_set(_config, _field_name, _file_value);
        }
    }
    return _config;
}

function ai_roaming_config_load(arg0 = "ZS_vanilla/gamedata/roaming.json")
{
    if (!file_exists(arg0))
    {
        show_debug_message("Roaming: \"" + arg0 + "\" not found, using default values");
        return ai_roaming_config_defaults();
    }
    var _file_data = ai_roaming_read_file(arg0);
    if (is_undefined(_file_data))
    {
        return ai_roaming_config_defaults();
    }
    ai_roaming_apply_difficulty(_file_data);
    var _mod_patches = ai_roaming_mod_patches();
    for (var _patch_index = 0; _patch_index < array_length(_mod_patches); _patch_index++)
    {
        ai_roaming_merge_patch(_file_data, _mod_patches[_patch_index]);
    }
    return ai_roaming_config_from_data(_file_data);
}

function ai_roaming_apply_difficulty(arg0)
{
    var _settings = struct_get_from_hash(arg0, variable_get_hash("continuous_roaming"));
    if (!is_struct(_settings))
    {
        _settings = {};
        arg0.continuous_roaming = _settings;
    }
    _settings.noise_hearing_range_px = difficulty_get("npc_join_fights_range");
    _settings.noise_max_active_responders = difficulty_get("npc_join_fights_groups");
}

function ai_roaming_mod_patches()
{
    if (!variable_global_exists("ai_roaming_mod_patch_list"))
    {
        global.ai_roaming_mod_patch_list = [];
    }
    return global.ai_roaming_mod_patch_list;
}

function ai_roaming_merge_patch(arg0, arg1)
{
    var _field_names = variable_struct_get_names(arg1);
    for (var _field_index = 0; _field_index < array_length(_field_names); _field_index++)
    {
        var _field_name = _field_names[_field_index];
        var _patch_value = variable_struct_get(arg1, _field_name);
        var _target_value = variable_struct_get(arg0, _field_name);
        if (is_struct(_patch_value) && is_struct(_target_value))
        {
            ai_roaming_merge_patch(_target_value, _patch_value);
        }
        else
        {
            variable_struct_set(arg0, _field_name, variable_clone(_patch_value));
        }
    }
}

function ai_roaming_mod_autoload(arg0 = "ZS_vanilla/gamedata/roaming.json")
{
    global.ai_roaming_mod_patch_list = [];
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
        var _mod_path = _mod.file_path + "/gamedata/roaming.json";
        if (!file_exists(_mod_path))
        {
            continue;
        }
        var _patch = ai_roaming_read_file(_mod_path);
        if (is_undefined(_patch))
        {
            trace("Roaming mod ", _mod_name, " skipped: the file could not be read as a roaming file");
        }
        else
        {
            var _result_data = ai_roaming_read_file(arg0);
            if (is_undefined(_result_data))
            {
                _result_data = {};
            }
            var _accepted_patches = global.ai_roaming_mod_patch_list;
            for (var _patch_index = 0; _patch_index < array_length(_accepted_patches); _patch_index++)
            {
                ai_roaming_merge_patch(_result_data, _accepted_patches[_patch_index]);
            }
            ai_roaming_merge_patch(_result_data, _patch);
            var _problems = ai_roaming_data_problems(_result_data);
            if (array_length(_problems) > 0)
            {
                trace("Roaming mod ", _mod_name, " skipped: ", string(_problems));
            }
            else
            {
                array_push(global.ai_roaming_mod_patch_list, _patch);
            }
        }
    }
}

function ai_roaming_data_problems(arg0)
{
    var _problems = [];
    var _settings = struct_get_from_hash(arg0, variable_get_hash("continuous_roaming"));
    if (!is_undefined(_settings) && !is_struct(_settings))
    {
        array_push(_problems, "continuous_roaming must be an object");
    }
    if (is_struct(_settings))
    {
        var _defaults = ai_roaming_config_defaults();
        var _setting_names = variable_struct_get_names(_settings);
        for (var _setting_index = 0; _setting_index < array_length(_setting_names); _setting_index++)
        {
            var _setting_name = _setting_names[_setting_index];
            if (string_char_at(_setting_name, 1) == "_")
            {
                continue;
            }
            var _where = "continuous_roaming." + _setting_name;
            if (_setting_name == "spawning" || !variable_struct_exists(_defaults, _setting_name))
            {
                array_push(_problems, _where + " is not a known setting");
            }
            else
            {
                var _default_value = variable_struct_get(_defaults, _setting_name);
                if (_setting_name == "loot")
                {
                    ai_roaming_check_loot(_problems, _settings, _where);
                }
                else if (is_array(_default_value))
                {
                    ai_roaming_check_text_list(_problems, _settings, _setting_name, _where);
                }
                else if (is_struct(_default_value))
                {
                    ai_roaming_check_number_table(_problems, _settings, _setting_name, _where);
                }
                else
                {
                    ai_roaming_check_number(_problems, _settings, _setting_name, _where, 0);
                }
            }
        }
    }
    var _spawning = struct_get_from_hash(arg0, variable_get_hash("spawning"));
    if (!is_undefined(_spawning) && !is_struct(_spawning))
    {
        array_push(_problems, "spawning must be an object");
    }
    if (!is_struct(_spawning))
    {
        return _problems;
    }
    ai_roaming_check_number(_problems, _spawning, "initial_groups", "spawning.initial_groups", 0);
    ai_roaming_check_number(_problems, _spawning, "initial_groups_during_war", "spawning.initial_groups_during_war", 0);
    ai_roaming_check_number_table(_problems, _spawning, "preset_weights", "spawning.preset_weights");
    ai_roaming_check_number_table(_problems, _spawning, "character_weights", "spawning.character_weights");
    ai_roaming_check_number_table(_problems, _spawning, "arrival_rhythm_weights", "spawning.arrival_rhythm_weights");
    var _templates = ai_roaming_check_entries(_problems, _spawning, "templates", "spawning.templates");
    for (var _index = 0; _index < array_length(_templates); _index++)
    {
        var _template = _templates[_index].entry;
        var _where = _templates[_index].where;
        var _object_name = struct_get_from_hash(_template, variable_get_hash("object"));
        var _npc_id = struct_get_from_hash(_template, variable_get_hash("npc_id"));
        var _has_object = is_string(_object_name) && _object_name != "";
        var _has_npc_id = is_string(_npc_id) && _npc_id != "";
        if (_has_object == _has_npc_id)
        {
            array_push(_problems, _where + " needs either \"object\" or \"npc_id\" (one of them, as text)");
        }
        ai_roaming_check_number(_problems, _template, "members", _where + ".members", 1, 20);
        ai_roaming_check_text_list(_problems, _template, "requires_quests_complete", _where + ".requires_quests_complete");
    }
    var _maps = ai_roaming_check_entries(_problems, _spawning, "maps", "spawning.maps");
    for (var _index = 0; _index < array_length(_maps); _index++)
    {
        var _map = _maps[_index].entry;
        var _where = _maps[_index].where;
        ai_roaming_check_number_table(_problems, _map, "weights", _where + ".weights");
        ai_roaming_check_number_table(_problems, _map, "preset_weights", _where + ".preset_weights");
        ai_roaming_check_number_table(_problems, _map, "character_weights", _where + ".character_weights");
        ai_roaming_check_number(_problems, _map, "initial_groups", _where + ".initial_groups", 0);
        ai_roaming_check_number(_problems, _map, "initial_groups_during_war", _where + ".initial_groups_during_war", 0);
        var _forced_name = struct_get_from_hash(_map, variable_get_hash("forced_first_group"));
        if (!is_undefined(_forced_name) && !is_string(_forced_name))
        {
            array_push(_problems, _where + ".forced_first_group must be a template name");
        }
    }
    var _war_quests = ai_roaming_check_entries(_problems, _spawning, "war_quests", "spawning.war_quests");
    for (var _index = 0; _index < array_length(_war_quests); _index++)
    {
        ai_roaming_check_number_table(_problems, _war_quests[_index].entry, "weights", _war_quests[_index].where + ".weights");
    }
    var _presets = ai_roaming_check_entries(_problems, _spawning, "population_presets", "spawning.population_presets");
    for (var _index = 0; _index < array_length(_presets); _index++)
    {
        var _preset = _presets[_index].entry;
        var _where = _presets[_index].where;
        ai_roaming_check_number(_problems, _preset, "initial_groups_percent", _where + ".initial_groups_percent", 0);
        ai_roaming_check_number_table(_problems, _preset, "arrivals", _where + ".arrivals");
    }
    var _rhythms = ai_roaming_check_entries(_problems, _spawning, "arrival_rhythms", "spawning.arrival_rhythms");
    for (var _index = 0; _index < array_length(_rhythms); _index++)
    {
        var _rhythm = _rhythms[_index].entry;
        var _where = _rhythms[_index].where;
        ai_roaming_check_number(_problems, _rhythm, "cluster_size_min", _where + ".cluster_size_min", 1);
        ai_roaming_check_number(_problems, _rhythm, "cluster_size_max", _where + ".cluster_size_max", 1);
        ai_roaming_check_number(_problems, _rhythm, "cluster_gap_seconds", _where + ".cluster_gap_seconds", 0);
        ai_roaming_check_number(_problems, _rhythm, "interval_multiplier", _where + ".interval_multiplier", 0);
    }
    ai_roaming_check_number_table(_problems, _spawning, "arrival_placement", "spawning.arrival_placement");
    var _characters = ai_roaming_check_entries(_problems, _spawning, "raid_characters", "spawning.raid_characters");
    for (var _index = 0; _index < array_length(_characters); _index++)
    {
        var _character = _characters[_index].entry;
        var _where = _characters[_index].where;
        ai_roaming_check_number_table(_problems, _character, "weight_multipliers", _where + ".weight_multipliers");
        ai_roaming_check_text_list(_problems, _character, "candidates", _where + ".candidates");
        ai_roaming_check_number(_problems, _character, "pair_weight_multiplier", _where + ".pair_weight_multiplier", 0);
        ai_roaming_check_number(_problems, _character, "dominant_weight_multiplier", _where + ".dominant_weight_multiplier", 0);
        ai_roaming_check_number(_problems, _character, "initial_groups_multiplier", _where + ".initial_groups_multiplier", 0);
        var _pairs = struct_get_from_hash(_character, variable_get_hash("pairs"));
        if (!is_undefined(_pairs))
        {
            var _pairs_are_right = is_array(_pairs);
            for (var _pair_index = 0; _pairs_are_right && _pair_index < array_length(_pairs); _pair_index++)
            {
                var _pair = _pairs[_pair_index];
                _pairs_are_right = is_array(_pair) && array_length(_pair) == 2 && is_string(_pair[0]) && is_string(_pair[1]);
            }
            if (!_pairs_are_right)
            {
                array_push(_problems, _where + ".pairs must be a list of pairs of template names");
            }
        }
        var _character_arrivals = struct_get_from_hash(_character, variable_get_hash("arrivals"));
        if (!is_undefined(_character_arrivals) && !is_struct(_character_arrivals))
        {
            array_push(_problems, _where + ".arrivals must be an object");
        }
        if (is_struct(_character_arrivals))
        {
            ai_roaming_check_number(_problems, _character_arrivals, "first_delay_seconds", _where + ".arrivals.first_delay_seconds", -1);
            ai_roaming_check_number(_problems, _character_arrivals, "interval_multiplier", _where + ".arrivals.interval_multiplier", 0);
            ai_roaming_check_number(_problems, _character_arrivals, "total_multiplier", _where + ".arrivals.total_multiplier", 0);
        }
    }
    return _problems;
}

function ai_roaming_check_loot(arg0, arg1, arg2)
{
    var _loot = struct_get_from_hash(arg1, variable_get_hash("loot"));
    if (!is_struct(_loot))
    {
        array_push(arg0, arg2 + " must be an object");
        exit;
    }
    ai_roaming_check_number(arg0, _loot, "seconds_first_item", arg2 + ".seconds_first_item", 0);
    ai_roaming_check_number(arg0, _loot, "seconds_per_item", arg2 + ".seconds_per_item", 0);
    ai_roaming_check_number(arg0, _loot, "seconds_max", arg2 + ".seconds_max", 0);
    ai_roaming_check_number(arg0, _loot, "budget_default", arg2 + ".budget_default", 0);
    ai_roaming_check_number(arg0, _loot, "heal_below_hp_percent", arg2 + ".heal_below_hp_percent", 0, 100);
    ai_roaming_check_number_table(arg0, _loot, "budget_by_tier", arg2 + ".budget_by_tier");
    ai_roaming_check_number_table(arg0, _loot, "overlook_chance_by_tier", arg2 + ".overlook_chance_by_tier");
    ai_roaming_check_loot_rules(arg0, _loot, arg2);
    var _factions = struct_get_from_hash(_loot, variable_get_hash("factions"));
    if (is_undefined(_factions))
    {
        exit;
    }
    if (!is_struct(_factions))
    {
        array_push(arg0, arg2 + ".factions must be an object");
        exit;
    }
    var _names = variable_struct_get_names(_factions);
    for (var _index = 0; _index < array_length(_names); _index++)
    {
        if (string_char_at(_names[_index], 1) == "_")
        {
            continue;
        }
        var _override = variable_struct_get(_factions, _names[_index]);
        var _override_where = arg2 + ".factions." + _names[_index];
        if (!is_struct(_override))
        {
            array_push(arg0, _override_where + " must be an object");
        }
        else
        {
            ai_roaming_check_loot_rules(arg0, _override, _override_where);
        }
    }
}

function ai_roaming_check_loot_rules(arg0, arg1, arg2)
{
    ai_roaming_check_number(arg0, arg1, "budget_bonus", arg2 + ".budget_bonus", -100);
    ai_roaming_check_number(arg0, arg1, "spare_equipment_max", arg2 + ".spare_equipment_max", 0);
    ai_roaming_check_number(arg0, arg1, "max_item_weight", arg2 + ".max_item_weight", 0);
    ai_roaming_check_text_list(arg0, arg1, "never_categories", arg2 + ".never_categories");
    ai_roaming_check_text_list(arg0, arg1, "never_item_prefixes", arg2 + ".never_item_prefixes");
    ai_roaming_check_text_list(arg0, arg1, "priority", arg2 + ".priority");
    var _flag_names = ["take_other_calibers", "loots_kills", "recovers_own_dead"];
    for (var _index = 0; _index < array_length(_flag_names); _index++)
    {
        if (variable_struct_exists(arg1, _flag_names[_index]) && !is_bool(variable_struct_get(arg1, _flag_names[_index])))
        {
            array_push(arg0, arg2 + "." + _flag_names[_index] + " must be true or false");
        }
    }
}

function ai_roaming_check_number(arg0, arg1, arg2, arg3, arg4, arg5 = infinity)
{
    if (!variable_struct_exists(arg1, arg2))
    {
        exit;
    }
    var _value = variable_struct_get(arg1, arg2);
    if (!is_numeric(_value) || is_bool(_value) || is_nan(_value) || _value < arg4 || _value > arg5)
    {
        array_push(arg0, arg3 + " must be a number, not below " + string(arg4) + ((arg5 == infinity) ? "" : (" and not above " + string(arg5))));
    }
}

function ai_roaming_check_number_table(arg0, arg1, arg2, arg3)
{
    if (!variable_struct_exists(arg1, arg2))
    {
        exit;
    }
    var _table = variable_struct_get(arg1, arg2);
    if (!is_struct(_table))
    {
        array_push(arg0, arg3 + " must be an object");
        exit;
    }
    var _names = variable_struct_get_names(_table);
    for (var _index = 0; _index < array_length(_names); _index++)
    {
        if (string_char_at(_names[_index], 1) == "_")
        {
            continue;
        }
        ai_roaming_check_number(arg0, _table, _names[_index], arg3 + "." + _names[_index], 0);
    }
}

function ai_roaming_check_text_list(arg0, arg1, arg2, arg3)
{
    if (!variable_struct_exists(arg1, arg2))
    {
        exit;
    }
    var _list = variable_struct_get(arg1, arg2);
    var _list_is_right = is_array(_list);
    for (var _index = 0; _list_is_right && _index < array_length(_list); _index++)
    {
        _list_is_right = is_string(_list[_index]);
    }
    if (!_list_is_right)
    {
        array_push(arg0, arg3 + " must be a list of names");
    }
}

function ai_roaming_check_entries(arg0, arg1, arg2, arg3)
{
    var _entries = [];
    if (!variable_struct_exists(arg1, arg2))
    {
        return _entries;
    }
    var _table = variable_struct_get(arg1, arg2);
    if (!is_struct(_table))
    {
        array_push(arg0, arg3 + " must be an object");
        return _entries;
    }
    var _names = variable_struct_get_names(_table);
    for (var _index = 0; _index < array_length(_names); _index++)
    {
        if (string_char_at(_names[_index], 1) == "_")
        {
            continue;
        }
        var _entry = variable_struct_get(_table, _names[_index]);
        var _entry_where = arg3 + "." + _names[_index];
        if (is_struct(_entry))
        {
            array_push(_entries, 
            {
                entry: _entry,
                where: _entry_where
            });
        }
        else
        {
            array_push(arg0, _entry_where + " must be an object");
        }
    }
    return _entries;
}

function ai_roaming_reset()
{
    global.ai_roaming = 
    {
        room_id: room,
        config: ai_roaming_config_load(),
        groups: [],
        next_group_to_check: 0,
        path_queue: [],
        step_count: 0,
        last_roster_visit_step: [],
        next_offscreen_fight_step: [],
        roamers_at_start: 0,
        spawned_from_json: false,
        preset_name: "normal",
        character_name: "standard",
        character_detail: "",
        player_x: undefined,
        player_y: undefined,
        template_weights: undefined,
        arrival_weights: undefined,
        arrivals: undefined,
        arriving: undefined,
        rhythm_name: "",
        arrived_group_count: 0,
        noise_spots: [],
        next_noise_spot_id: 0,
        noise_response_count: 0,
        exits: [],
        departing: [],
        departed_count: 0,
        regroup_count: 0,
        claims: [],
        recent_bodies: [],
        static_owners: [],
        claim_looted_count: 0,
        claim_hostile_count: 0,
        claim_yielded_count: 0,
        claim_items_taken: 0,
        offscreen_loot_count: 0,
        offscreen_fight_deaths: 0,
        routes_given: 0,
        failed_searches: 0,
        slowest_path_ms: 0
    };
}

function ai_roaming_state()
{
    if (!variable_global_exists("ai_roaming") || global.ai_roaming.room_id != room)
    {
        ai_roaming_reset();
    }
    return global.ai_roaming;
}

function ai_roaming_template_name(arg0)
{
    static _template_names = ["green_army_1", "crimson_1", "loner_1", "loner_2", "bandit_1", "wolf_1", "boar_1", "ghoul_1", "watcher_1", "boss_arman", "boss_phantom"];
    
    if (arg0 < 0 || arg0 >= array_length(_template_names))
    {
        return "unknown";
    }
    return _template_names[arg0];
}

function ai_roaming_group_create(arg0)
{
    var _roaming = ai_roaming_state();
    var _group = 
    {
        group_id: array_length(_roaming.groups),
        template_name: arg0,
        keeps_roaming: !array_contains(_roaming.config.templates_that_do_not_keep_roaming, arg0),
        members: [],
        state: "travelling",
        rest_until_step: 0,
        first_member_finished_step: -1,
        destination_x: 0,
        destination_y: 0,
        members_waiting_for_path: 0,
        members_given_path: 0,
        failed_destination_count: 0,
        next_rest_seconds: -1,
        reacts_to_noise: array_contains(_roaming.config.templates_that_react_to_noise, arg0),
        noise_motive: "",
        noise_cooldown_until_step: 0,
        noise_spot_ids_considered: [],
        in_combat: false,
        last_contact_step: 0,
        on_noise_trip: false,
        aiming_player: noone,
        aiming_player_until_step: 0
    };
    if (_group.reacts_to_noise)
    {
        var _motive = ai_roaming_weighted_pick(_roaming.config.noise_motive_weights);
        _group.noise_motive = is_undefined(_motive) ? "aggressive" : _motive;
    }
    array_push(_roaming.groups, _group);
    return _group;
}

function ai_roaming_group_add_member(arg0, arg1)
{
    array_push(arg0.members, 
    {
        npc: arg1,
        roster_index: -1,
        path_failed: false,
        max_hp: 0,
        alerted_speed: 0,
        claim_duty_count: 0,
        is_static: false,
        left_group: false
    });
    arg1.roaming_group_id = arg0.group_id;
    ai_roaming_state().roamers_at_start++;
}

function ai_roaming_group_of(arg0)
{
    if (!instance_exists(arg0) || !variable_instance_exists(arg0, "roaming_group_id") || arg0.roaming_group_id < 0)
    {
        return undefined;
    }
    var _groups = ai_roaming_state().groups;
    return (arg0.roaming_group_id < array_length(_groups)) ? _groups[arg0.roaming_group_id] : undefined;
}

function ai_roaming_group_report_aiming_player(arg0, arg1)
{
    var _group = ai_roaming_group_of(arg0);
    if (is_undefined(_group))
    {
        exit;
    }
    _group.aiming_player = arg1;
    _group.aiming_player_until_step = ai_roaming_state().step_count + ai_roaming_seconds_to_steps(1);
}

function ai_roaming_group_aiming_player(arg0)
{
    var _group = ai_roaming_group_of(arg0);
    if (is_undefined(_group) || !instance_exists(_group.aiming_player))
    {
        return -4;
    }
    return (ai_roaming_state().step_count < _group.aiming_player_until_step) ? _group.aiming_player : -4;
}

function ai_roaming_bind_roster()
{
    var _roaming = ai_roaming_state();
    for (var _group_index = 0; _group_index < array_length(_roaming.groups); _group_index++)
    {
        var _members = _roaming.groups[_group_index].members;
        for (var _member_index = 0; _member_index < array_length(_members); _member_index++)
        {
            var _member = _members[_member_index];
            if (!instance_exists(_member.npc))
            {
                continue;
            }
            if (variable_instance_exists(_member.npc, "ai_roster_index"))
            {
                _member.roster_index = _member.npc.ai_roster_index;
            }
            ai_roaming_member_store_npc_values(_member);
        }
    }
}

function ai_roaming_member_store_npc_values(arg0)
{
    var _max_hp = 0;
    var _alerted_speed = 0;
    with (arg0.npc)
    {
        roaming_patrol_speed = npc_get_spd_not_alerted(npc_id);
        roaming_travel_speed = 0;
        _alerted_speed = npc_get_spd_alerted(npc_id);
        _max_hp = npc_get_hp(npc_id);
    }
    arg0.max_hp = _max_hp;
    arg0.alerted_speed = _alerted_speed;
}

function ai_roaming_route_speed(arg0, arg1)
{
    if (!variable_instance_exists(arg0, "roaming_travel_speed") || arg0.roaming_travel_speed <= 0)
    {
        return arg1;
    }
    return arg0.roaming_travel_speed;
}

function ai_roaming_roster_add(arg0)
{
    var _npc = arg0.npc;
    var _roster_index = array_length(global.list_n_id);
    array_push(global.list_n_id, _npc);
    array_push(global.list_n_npc_id, _npc.npc_id);
    array_push(global.list_n_hp, _npc.hp);
    array_push(global.list_n_x, _npc.x);
    array_push(global.list_n_y, _npc.y);
    array_push(global.list_n_follow_path, false);
    array_push(global.list_n_power, npc_get_power(_npc.npc_id));
    _npc.ai_roster_index = _roster_index;
    arg0.roster_index = _roster_index;
    ai_roaming_member_store_npc_values(arg0);
}

function ai_roaming_map_name(arg0)
{
    static _map_names = ["zerosievert", "forest", "makeshift_camp", "industrial_area", "swamp", "farm", "mall", "zaton", "city", "npp", "prologue"];
    
    if (arg0 < 0 || arg0 >= array_length(_map_names))
    {
        return "unknown";
    }
    return _map_names[arg0];
}

function ai_roaming_field(arg0, arg1, arg2)
{
    if (!is_struct(arg0) || !variable_struct_exists(arg0, arg1))
    {
        return arg2;
    }
    return variable_struct_get(arg0, arg1);
}

function ai_roaming_has_spawn_data()
{
    var _spawning = ai_roaming_state().config.spawning;
    return is_struct(ai_roaming_field(_spawning, "templates", undefined)) && is_struct(ai_roaming_field(_spawning, "maps", undefined));
}

function ai_roaming_weighted_pick(arg0)
{
    if (!is_struct(arg0))
    {
        return undefined;
    }
    var _names = variable_struct_get_names(arg0);
    var _possible_names = [];
    var _total_weight = 0;
    for (var _index = 0; _index < array_length(_names); _index++)
    {
        var _weight = variable_struct_get(arg0, _names[_index]);
        if (string_char_at(_names[_index], 1) == "_" || !is_numeric(_weight) || _weight <= 0)
        {
            continue;
        }
        array_push(_possible_names, _names[_index]);
        _total_weight += _weight;
    }
    if (_total_weight <= 0)
    {
        return undefined;
    }
    var _roll = random(_total_weight);
    for (var _index = 0; _index < array_length(_possible_names); _index++)
    {
        var _weight = variable_struct_get(arg0, _possible_names[_index]);
        if (_roll < _weight)
        {
            return _possible_names[_index];
        }
        _roll -= _weight;
    }
    return _possible_names[array_length(_possible_names) - 1];
}

function ai_roaming_template_is_unlocked(arg0)
{
    var _required_quests = ai_roaming_field(arg0, "requires_quests_complete", []);
    for (var _index = 0; _index < array_length(_required_quests); _index++)
    {
        if (!quest_is_complete(_required_quests[_index]))
        {
            return false;
        }
    }
    return true;
}

function ai_roaming_template_can_be_created(arg0)
{
    var _npc_id = ai_roaming_field(arg0, "npc_id", "");
    if (_npc_id != "")
    {
        return npc_get_exists(_npc_id) && ai_roaming_object_name_is_npc("obj_mod_npc");
    }
    return ai_roaming_object_name_is_npc(ai_roaming_field(arg0, "object", ""));
}

function ai_roaming_object_name_is_npc(arg0)
{
    if (!is_string(arg0) || asset_get_type(arg0) != 0)
    {
        return false;
    }
    var _object_index = asset_get_index(arg0);
    return _object_index == obj_npc_parent || object_is_ancestor(_object_index, obj_npc_parent);
}

function ai_roaming_template_create_npc(arg0, arg1, arg2)
{
    var _npc_id = ai_roaming_field(arg0, "npc_id", "");
    if (_npc_id == "")
    {
        return instance_create_depth(arg1, arg2, 0, asset_get_index(arg0.object));
    }
    var _npc = instance_create_depth(arg1, arg2, 0, asset_get_index("obj_mod_npc"));
    with (_npc)
    {
        npc_setup(_npc_id);
        npc_setup_weapon();
    }
    return _npc;
}

function ai_roaming_active_war_quest(arg0)
{
    var _war_quests = ai_roaming_field(arg0, "war_quests", undefined);
    if (!is_struct(_war_quests))
    {
        return "";
    }
    var _quest_names = variable_struct_get_names(_war_quests);
    for (var _index = 0; _index < array_length(_quest_names); _index++)
    {
        if (string_char_at(_quest_names[_index], 1) == "_")
        {
            continue;
        }
        if (quest_is_active(_quest_names[_index]))
        {
            return _quest_names[_index];
        }
    }
    return "";
}

function ai_roaming_template_weights(arg0, arg1, arg2)
{
    var _weights = {};
    var _map_weights = ai_roaming_field(arg1, "weights", {});
    var _war_weights = {};
    if (arg2 != "")
    {
        _war_weights = ai_roaming_field(variable_struct_get(arg0.war_quests, arg2), "weights", {});
    }
    var _template_names = variable_struct_get_names(arg0.templates);
    for (var _index = 0; _index < array_length(_template_names); _index++)
    {
        var _template_name = _template_names[_index];
        if (string_char_at(_template_name, 1) == "_")
        {
            continue;
        }
        var _template = variable_struct_get(arg0.templates, _template_name);
        var _weight = ai_roaming_field(_map_weights, _template_name, 0);
        _weight = ai_roaming_field(_war_weights, _template_name, _weight);
        if (!ai_roaming_template_is_unlocked(_template))
        {
            _weight = 0;
        }
        if (_weight > 0 && !ai_roaming_template_can_be_created(_template))
        {
            show_debug_message("Roaming: template \"" + _template_name + "\" names an object or NPC that does not exist");
            _weight = 0;
        }
        variable_struct_set(_weights, _template_name, _weight);
    }
    return _weights;
}

function ai_roaming_apply_character(arg0, arg1, arg2)
{
    var _multipliers = ai_roaming_field(arg1, "weight_multipliers", undefined);
    if (is_struct(_multipliers))
    {
        var _any_template_can_spawn = false;
        var _multiplied_names = variable_struct_get_names(_multipliers);
        for (var _index = 0; _index < array_length(_multiplied_names); _index++)
        {
            var _template_name = _multiplied_names[_index];
            var _weight = ai_roaming_field(arg2, _template_name, 0);
            if (_weight <= 0)
            {
                continue;
            }
            _any_template_can_spawn = true;
            variable_struct_set(arg2, _template_name, _weight * variable_struct_get(_multipliers, _template_name));
        }
        return _any_template_can_spawn;
    }
    var _pairs = ai_roaming_field(arg1, "pairs", undefined);
    if (is_array(_pairs))
    {
        var _possible_pairs = [];
        for (var _index = 0; _index < array_length(_pairs); _index++)
        {
            var _pair = _pairs[_index];
            if (ai_roaming_field(arg2, _pair[0], 0) > 0 && ai_roaming_field(arg2, _pair[1], 0) > 0)
            {
                array_push(_possible_pairs, _pair);
            }
        }
        if (array_length(_possible_pairs) == 0)
        {
            return false;
        }
        var _chosen_pair = _possible_pairs[irandom(array_length(_possible_pairs) - 1)];
        var _pair_multiplier = ai_roaming_field(arg1, "pair_weight_multiplier", 1);
        variable_struct_set(arg2, _chosen_pair[0], variable_struct_get(arg2, _chosen_pair[0]) * _pair_multiplier);
        variable_struct_set(arg2, _chosen_pair[1], variable_struct_get(arg2, _chosen_pair[1]) * _pair_multiplier);
        arg0.character_detail = _chosen_pair[0] + " vs " + _chosen_pair[1];
        return true;
    }
    var _candidates = ai_roaming_field(arg1, "candidates", undefined);
    if (is_array(_candidates))
    {
        var _candidate_weights = {};
        for (var _index = 0; _index < array_length(_candidates); _index++)
        {
            variable_struct_set(_candidate_weights, _candidates[_index], ai_roaming_field(arg2, _candidates[_index], 0));
        }
        var _dominant_name = ai_roaming_weighted_pick(_candidate_weights);
        if (is_undefined(_dominant_name))
        {
            return false;
        }
        var _dominant_multiplier = ai_roaming_field(arg1, "dominant_weight_multiplier", 1);
        variable_struct_set(arg2, _dominant_name, variable_struct_get(arg2, _dominant_name) * _dominant_multiplier);
        arg0.character_detail = _dominant_name;
        return true;
    }
    return true;
}

function ai_roaming_choose_initial_groups(arg0)
{
    var _roaming = ai_roaming_state();
    var _spawning = _roaming.config.spawning;
    _roaming.spawned_from_json = true;
    _roaming.preset_name = "normal";
    _roaming.character_name = "standard";
    _roaming.character_detail = "";
    var _map = ai_roaming_field(ai_roaming_field(_spawning, "maps", undefined), arg0, undefined);
    if (!is_struct(_map))
    {
        return [];
    }
    var _war_quest_name = ai_roaming_active_war_quest(_spawning);
    var _weights = ai_roaming_template_weights(_spawning, _map, _war_quest_name);
    var _group_count = 0;
    if (_war_quest_name != "")
    {
        _group_count = ai_roaming_field(_map, "initial_groups_during_war", ai_roaming_field(_spawning, "initial_groups_during_war", 20));
        _roaming.character_name = _war_quest_name;
    }
    else
    {
        var _normal_group_count = ai_roaming_field(_map, "initial_groups", ai_roaming_field(_spawning, "initial_groups", 12));
        _group_count = _normal_group_count;
        var _preset_weights = ai_roaming_field(_map, "preset_weights", ai_roaming_field(_spawning, "preset_weights", undefined));
        var _preset_name = ai_roaming_weighted_pick(_preset_weights);
        var _preset = ai_roaming_field(ai_roaming_field(_spawning, "population_presets", undefined), _preset_name, undefined);
        if (is_struct(_preset))
        {
            _roaming.preset_name = _preset_name;
            _group_count = round((_normal_group_count * ai_roaming_field(_preset, "initial_groups_percent", 100)) / 100);
            if (_normal_group_count > 0)
            {
                _group_count = max(1, _group_count);
            }
        }
        var _character_weights = ai_roaming_field(_map, "character_weights", ai_roaming_field(_spawning, "character_weights", undefined));
        var _character_name = ai_roaming_weighted_pick(_character_weights);
        var _character = ai_roaming_field(ai_roaming_field(_spawning, "raid_characters", undefined), _character_name, undefined);
        if (is_struct(_character) && ai_roaming_apply_character(_roaming, _character, _weights))
        {
            _roaming.character_name = _character_name;
            _group_count = round(_group_count * ai_roaming_field(_character, "initial_groups_multiplier", 1));
            if (_normal_group_count > 0)
            {
                _group_count = max(1, _group_count);
            }
        }
        else
        {
            _roaming.character_detail = "";
        }
    }
    var _chosen_template_names = [];
    var _forced_name = ai_roaming_field(_map, "forced_first_group", "");
    if (_group_count > 0 && _forced_name != "" && variable_struct_exists(_weights, _forced_name))
    {
        var _forced_template = variable_struct_get(_spawning.templates, _forced_name);
        if (ai_roaming_template_is_unlocked(_forced_template) && ai_roaming_template_can_be_created(_forced_template))
        {
            array_push(_chosen_template_names, _forced_name);
            if (ai_roaming_field(_forced_template, "unique", false))
            {
                variable_struct_set(_weights, _forced_name, 0);
            }
        }
    }
    while (array_length(_chosen_template_names) < _group_count)
    {
        var _template_name = ai_roaming_weighted_pick(_weights);
        if (is_undefined(_template_name))
        {
            break;
        }
        array_push(_chosen_template_names, _template_name);
        if (ai_roaming_field(variable_struct_get(_spawning.templates, _template_name), "unique", false))
        {
            variable_struct_set(_weights, _template_name, 0);
        }
    }
    _roaming.template_weights = _weights;
    ai_roaming_arrivals_setup(_roaming, _spawning, _map);
    return _chosen_template_names;
}

function ai_roaming_spawn_group(arg0, arg1, arg2)
{
    var _group = ai_roaming_group_create(arg0);
    var _spawn_points = ai_roaming_spawn_points(arg1, arg2);
    repeat (ai_roaming_template_member_count(arg0))
    {
        ai_roaming_spawn_member(_group, _spawn_points);
    }
    return _group;
}

function ai_roaming_template_member_count(arg0)
{
    var _template = variable_struct_get(ai_roaming_state().config.spawning.templates, arg0);
    return ai_roaming_field(_template, "members", 1);
}

function ai_roaming_spawn_member(arg0, arg1)
{
    var _template = variable_struct_get(ai_roaming_state().config.spawning.templates, arg0.template_name);
    var _spawn_point = arg1[irandom(array_length(arg1) - 1)];
    var _npc = ai_roaming_template_create_npc(_template, _spawn_point.x, _spawn_point.y);
    ai_roaming_group_add_member(arg0, _npc);
    return arg0.members[array_length(arg0.members) - 1];
}

function ai_roaming_spawn_points(arg0, arg1)
{
    var _center_cell_x = arg0 div 16;
    var _center_cell_y = arg1 div 16;
    var _half_cell_px = 8;
    var _center_x = (_center_cell_x * 16) + _half_cell_px;
    var _center_y = (_center_cell_y * 16) + _half_cell_px;
    var _spawn_points = [];
    for (var _offset_x = -2; _offset_x <= 2; _offset_x++)
    {
        for (var _offset_y = -2; _offset_y <= 2; _offset_y++)
        {
            if (!ai_roaming_cell_is_free(_center_cell_x + _offset_x, _center_cell_y + _offset_y))
            {
                continue;
            }
            var _point_x = _center_x + (_offset_x * 16);
            var _point_y = _center_y + (_offset_y * 16);
            if (collision_line(_center_x, _center_y, _point_x, _point_y, obj_solid, false, true))
            {
                continue;
            }
            array_push(_spawn_points, 
            {
                x: _point_x,
                y: _point_y
            });
        }
    }
    if (array_length(_spawn_points) == 0)
    {
        array_push(_spawn_points, 
        {
            x: _center_x,
            y: _center_y
        });
    }
    return _spawn_points;
}

function ai_roaming_member_is_alive(arg0)
{
    if (arg0.roster_index < 0 || arg0.roster_index >= array_length(global.list_n_id))
    {
        return false;
    }
    return global.list_n_id[arg0.roster_index] == arg0.npc;
}

function ai_roaming_npc_has_finished_route(arg0)
{
    if (!arg0.follow_path)
    {
        return true;
    }
    if (!ds_exists(arg0.lista_path_x, ds_type_list))
    {
        return true;
    }
    return arg0.path_position_now >= (ds_list_size(arg0.lista_path_x) - 1);
}

function ai_roaming_group_remove_dead_members(arg0)
{
    var _member_index = array_length(arg0.members) - 1;
    while (_member_index >= 0)
    {
        if (!ai_roaming_member_is_alive(arg0.members[_member_index]))
        {
            array_delete(arg0.members, _member_index, 1);
        }
        _member_index--;
    }
}

function ai_roaming_cell_is_free(arg0, arg1)
{
    if (arg0 < 0 || arg1 < 0)
    {
        return false;
    }
    if (mp_grid_get_cell(global.grid_move, arg0, arg1) != 0)
    {
        return false;
    }
    var _cell_is_free = true;
    with (obj_map_generator)
    {
        if (arg0 >= ds_grid_width(grid_tile) || arg1 >= ds_grid_height(grid_tile))
        {
            _cell_is_free = false;
        }
        else
        {
            _cell_is_free = ds_grid_get(grid_tile, arg0, arg1) == -1 && ds_grid_get(grid_water, arg0, arg1) == -7 && ds_grid_get(grid_building, arg0, arg1) != UnknownEnum.Value_2;
        }
    }
    return _cell_is_free;
}

function ai_roaming_pick_destination(arg0, arg1)
{
    var _config = ai_roaming_state().config;
    var _margin_px = _config.map_border_margin_px;
    var _map_width = room_width;
    var _map_height = room_height;
    with (obj_map_generator)
    {
        _map_height = map_height;
    }
    if (_map_width <= (_margin_px * 2) || _map_height <= (_margin_px * 2))
    {
        return undefined;
    }
    repeat (_config.destination_tries)
    {
        var _try_x = random_range(_margin_px, _map_width - _margin_px);
        var _try_y = random_range(_margin_px, _map_height - _margin_px);
        var _trip_distance_px = point_distance(arg0, arg1, _try_x, _try_y);
        if (_trip_distance_px < _config.trip_distance_min_px || _trip_distance_px > _config.trip_distance_max_px)
        {
            continue;
        }
        var _cell_x = _try_x div 16;
        var _cell_y = _try_y div 16;
        if (!ai_roaming_cell_is_free(_cell_x, _cell_y))
        {
            continue;
        }
        return 
        {
            x: (_cell_x * 16) + 8,
            y: (_cell_y * 16) + 8
        };
    }
    return undefined;
}

function ai_roaming_path_start(arg0)
{
    var _cell_x = arg0.x div 16;
    var _cell_y = arg0.y div 16;
    if (mp_grid_get_cell(global.grid_move, _cell_x, _cell_y) == 0)
    {
        return 
        {
            x: arg0.x,
            y: arg0.y
        };
    }
    for (var _offset_x = -1; _offset_x <= 1; _offset_x++)
    {
        for (var _offset_y = -1; _offset_y <= 1; _offset_y++)
        {
            if (mp_grid_get_cell(global.grid_move, _cell_x + _offset_x, _cell_y + _offset_y) == 0)
            {
                return 
                {
                    x: ((_cell_x + _offset_x) * 16) + 8,
                    y: ((_cell_y + _offset_y) * 16) + 8
                };
            }
        }
    }
    return 
    {
        x: arg0.x,
        y: arg0.y
    };
}

function ai_roaming_give_route(arg0, arg1, arg2)
{
    var _roaming = ai_roaming_state();
    var _npc = arg0.npc;
    if (point_distance(_npc.x, _npc.y, arg1, arg2) < 24)
    {
        if (ds_exists(_npc.lista_path_x, ds_type_list))
        {
            _npc.path_position_now = max(0, ds_list_size(_npc.lista_path_x) - 1);
        }
        return true;
    }
    var _start = ai_roaming_path_start(_npc);
    var _path = path_add();
    var _search_started_at = get_timer();
    var _path_found = mp_grid_path(global.grid_move, _path, _start.x, _start.y, arg1, arg2, true);
    var _search_ms = (get_timer() - _search_started_at) / 1000;
    _roaming.slowest_path_ms = max(_roaming.slowest_path_ms, _search_ms);
    var _point_count = path_get_number(_path);
    var _route_given = _path_found && _point_count > 1;
    if (_route_given)
    {
        ds_list_clear(_npc.lista_path_x);
        ds_list_clear(_npc.lista_path_y);
        for (var _point_index = 0; _point_index < _point_count; _point_index++)
        {
            ds_list_add(_npc.lista_path_x, path_get_point_x(_path, _point_index));
            ds_list_add(_npc.lista_path_y, path_get_point_y(_path, _point_index));
        }
        _npc.path_position_now = 0;
        _npc.follow_path = true;
        global.list_n_follow_path[arg0.roster_index] = true;
        global.list_n_x[arg0.roster_index] = _npc.x;
        global.list_n_y[arg0.roster_index] = _npc.y;
        _roaming.last_roster_visit_step[arg0.roster_index] = _roaming.step_count;
        _roaming.routes_given++;
    }
    else
    {
        _roaming.failed_searches++;
    }
    path_delete(_path);
    return _route_given;
}

function ai_roaming_step(arg0 = undefined, arg1 = undefined)
{
    var _roaming = ai_roaming_state();
    _roaming.step_count++;
    _roaming.player_x = arg0;
    _roaming.player_y = arg1;
    ai_roaming_check_next_group(_roaming);
    ai_roaming_serve_path_queue(_roaming);
    ai_roaming_arrivals_step(_roaming);
    ai_roaming_departures_step(_roaming);
    ai_roaming_claims_step(_roaming);
    ai_roaming_noise_forget_old_spots(_roaming);
}

function ai_roaming_seconds_to_steps(arg0)
{
    return round(arg0 * 60);
}

function ai_roaming_check_next_group(arg0)
{
    var _group_count = array_length(arg0.groups);
    if (_group_count == 0)
    {
        exit;
    }
    if (arg0.next_group_to_check >= _group_count)
    {
        arg0.next_group_to_check = 0;
    }
    var _group = arg0.groups[arg0.next_group_to_check];
    arg0.next_group_to_check++;
    if (!_group.keeps_roaming)
    {
        exit;
    }
    ai_roaming_group_remove_dead_members(_group);
    if (array_length(_group.members) == 0)
    {
        exit;
    }
    if (_group.state == "arriving")
    {
        exit;
    }
    if (ai_roaming_group_update_combat(arg0, _group))
    {
        exit;
    }
    if (ai_roaming_group_consider_noise(arg0, _group))
    {
        exit;
    }
    if (_group.state == "travelling")
    {
        ai_roaming_group_check_arrival(arg0, _group);
    }
    else if (_group.state == "resting")
    {
        ai_roaming_group_check_rest(arg0, _group);
    }
}

function ai_roaming_group_check_arrival(arg0, arg1)
{
    var _walking_member_count = 0;
    var _finished_member_count = 0;
    for (var _member_index = 0; _member_index < array_length(arg1.members); _member_index++)
    {
        var _member = arg1.members[_member_index];
        if (_member.path_failed || _member.claim_duty_count > 0)
        {
            continue;
        }
        _walking_member_count++;
        if (ai_roaming_npc_has_finished_route(_member.npc))
        {
            _finished_member_count++;
        }
    }
    var _everyone_finished = _finished_member_count == _walking_member_count;
    if (!_everyone_finished && _finished_member_count == 0)
    {
        exit;
    }
    if (arg1.first_member_finished_step < 0)
    {
        arg1.first_member_finished_step = arg0.step_count;
    }
    var _waited_steps = arg0.step_count - arg1.first_member_finished_step;
    var _waited_long_enough = _waited_steps >= ai_roaming_seconds_to_steps(arg0.config.straggler_wait_seconds);
    if (!_everyone_finished && !_waited_long_enough)
    {
        exit;
    }
    var _rest_seconds = random_range(arg0.config.rest_seconds_min, arg0.config.rest_seconds_max);
    if (arg1.next_rest_seconds >= 0)
    {
        _rest_seconds = arg1.next_rest_seconds;
        arg1.next_rest_seconds = -1;
    }
    arg1.state = "resting";
    arg1.rest_until_step = arg0.step_count + ai_roaming_seconds_to_steps(_rest_seconds);
    arg1.first_member_finished_step = -1;
    if (arg1.on_noise_trip)
    {
        arg1.on_noise_trip = false;
        if (arg1.noise_motive == "scavenger")
        {
            ai_roaming_group_scavenge_bodies(arg0, arg1);
        }
    }
}

function ai_roaming_group_check_rest(arg0, arg1)
{
    if (arg0.step_count < arg1.rest_until_step)
    {
        exit;
    }
    var _first_npc = arg1.members[0].npc;
    var _destination = ai_roaming_pick_destination(_first_npc.x, _first_npc.y);
    if (is_undefined(_destination))
    {
        arg1.rest_until_step = arg0.step_count + ai_roaming_seconds_to_steps(5);
        exit;
    }
    ai_roaming_group_send_to(arg0, arg1, _destination.x, _destination.y);
}

function ai_roaming_group_send_to(arg0, arg1, arg2, arg3, arg4 = 0)
{
    arg1.destination_x = arg2;
    arg1.destination_y = arg3;
    arg1.members_waiting_for_path = 0;
    arg1.members_given_path = 0;
    arg1.first_member_finished_step = -1;
    arg1.on_noise_trip = false;
    arg1.state = "waiting_for_path";
    for (var _member_index = 0; _member_index < array_length(arg1.members); _member_index++)
    {
        var _member = arg1.members[_member_index];
        if (_member.claim_duty_count > 0)
        {
            continue;
        }
        _member.path_failed = false;
        _member.npc.roaming_travel_speed = _member.alerted_speed * arg4;
        arg1.members_waiting_for_path++;
        array_push(arg0.path_queue, 
        {
            group: arg1,
            member: _member,
            destination_x: arg2,
            destination_y: arg3
        });
    }
    if (arg1.members_waiting_for_path == 0)
    {
        arg1.state = "resting";
        arg1.rest_until_step = arg0.step_count + ai_roaming_seconds_to_steps(5);
    }
}

function ai_roaming_serve_path_queue(arg0)
{
    if (array_length(arg0.path_queue) == 0)
    {
        exit;
    }
    var _world = ai_world_get();
    if (_world.paths >= 8)
    {
        exit;
    }
    var _request = arg0.path_queue[0];
    array_delete(arg0.path_queue, 0, 1);
    var _group = _request.group;
    var _member = _request.member;
    if (is_struct(_group))
    {
        _group.members_waiting_for_path--;
    }
    if (ai_roaming_member_is_alive(_member))
    {
        _world.paths++;
        if (ai_roaming_give_route(_member, _request.destination_x, _request.destination_y))
        {
            if (is_struct(_group))
            {
                _group.members_given_path++;
            }
        }
        else
        {
            _member.path_failed = true;
        }
    }
    if (is_struct(_group) && _group.members_waiting_for_path <= 0)
    {
        ai_roaming_group_paths_done(arg0, _group);
    }
}

function ai_roaming_group_paths_done(arg0, arg1)
{
    if (arg1.members_given_path > 0)
    {
        arg1.state = "travelling";
        arg1.failed_destination_count = 0;
        arg1.first_member_finished_step = -1;
        exit;
    }
    arg1.state = "resting";
    arg1.failed_destination_count++;
    if (arg1.failed_destination_count < arg0.config.failed_destination_limit)
    {
        arg1.rest_until_step = arg0.step_count;
    }
    else
    {
        arg1.failed_destination_count = 0;
        arg1.rest_until_step = arg0.step_count + ai_roaming_seconds_to_steps(arg0.config.failed_destination_wait_seconds);
    }
}

function ai_roaming_arrivals_setup(arg0, arg1, arg2)
{
    arg0.arrivals = undefined;
    arg0.rhythm_name = "";
    var _preset = ai_roaming_field(ai_roaming_field(arg1, "population_presets", undefined), arg0.preset_name, undefined);
    var _preset_arrivals = ai_roaming_field(_preset, "arrivals", undefined);
    var _map_normal_group_count = ai_roaming_field(arg2, "initial_groups", ai_roaming_field(arg1, "initial_groups", 12));
    if (!is_struct(_preset_arrivals) || _map_normal_group_count <= 0)
    {
        exit;
    }
    arg0.arrival_weights = {};
    var _template_names = variable_struct_get_names(arg0.template_weights);
    for (var _index = 0; _index < array_length(_template_names); _index++)
    {
        var _template = variable_struct_get(arg1.templates, _template_names[_index]);
        var _can_arrive = ai_roaming_field(_template, "can_arrive", true) && !ai_roaming_field(_template, "unique", false);
        variable_struct_set(arg0.arrival_weights, _template_names[_index], _can_arrive ? variable_struct_get(arg0.template_weights, _template_names[_index]) : 0);
    }
    var _rhythm_name = ai_roaming_weighted_pick(ai_roaming_field(arg1, "arrival_rhythm_weights", undefined));
    var _rhythm = ai_roaming_field(ai_roaming_field(arg1, "arrival_rhythms", undefined), _rhythm_name, undefined);
    arg0.rhythm_name = is_struct(_rhythm) ? _rhythm_name : "steady";
    var _character = ai_roaming_field(ai_roaming_field(arg1, "raid_characters", undefined), arg0.character_name, undefined);
    var _character_arrivals = ai_roaming_field(_character, "arrivals", undefined);
    var _total_groups = round(ai_roaming_field(_preset_arrivals, "total_groups", 0) * ai_roaming_field(_character_arrivals, "total_multiplier", 1));
    arg0.arrivals = 
    {
        groups_left: _total_groups,
        interval_seconds_min: ai_roaming_field(_preset_arrivals, "interval_seconds_min", 180),
        interval_seconds_max: ai_roaming_field(_preset_arrivals, "interval_seconds_max", 300),
        max_living_groups: ai_roaming_field(_preset_arrivals, "max_living_groups", 14),
        cluster_size_min: ai_roaming_field(_rhythm, "cluster_size_min", 1),
        cluster_size_max: ai_roaming_field(_rhythm, "cluster_size_max", 1),
        cluster_gap_seconds: ai_roaming_field(_rhythm, "cluster_gap_seconds", 20),
        interval_multiplier: ai_roaming_field(_rhythm, "interval_multiplier", 1) * ai_roaming_field(_character_arrivals, "interval_multiplier", 1),
        groups_left_in_cluster: 0,
        next_arrival_step: 0
    };
    arg0.arrivals.groups_left_in_cluster = irandom_range(arg0.arrivals.cluster_size_min, arg0.arrivals.cluster_size_max) - 1;
    arg0.arrivals.next_arrival_step = arg0.step_count + ai_roaming_arrival_interval_steps(arg0.arrivals);
    var _first_delay_seconds = ai_roaming_field(_character_arrivals, "first_delay_seconds", -1);
    if (_first_delay_seconds >= 0)
    {
        arg0.arrivals.next_arrival_step = arg0.step_count + ai_roaming_seconds_to_steps(_first_delay_seconds);
    }
}

function ai_roaming_arrival_interval_steps(arg0)
{
    var _seconds = random_range(arg0.interval_seconds_min, arg0.interval_seconds_max) * arg0.interval_multiplier;
    return ai_roaming_seconds_to_steps(_seconds);
}

function ai_roaming_living_group_count(arg0)
{
    var _living_group_count = 0;
    for (var _group_index = 0; _group_index < array_length(arg0.groups); _group_index++)
    {
        var _members = arg0.groups[_group_index].members;
        for (var _member_index = 0; _member_index < array_length(_members); _member_index++)
        {
            if (ai_roaming_member_is_alive(_members[_member_index]))
            {
                _living_group_count++;
                break;
            }
        }
    }
    return _living_group_count;
}

function ai_roaming_pick_arrival_position(arg0)
{
    var _placement = ai_roaming_field(arg0.config.spawning, "arrival_placement", undefined);
    var _edge_band_px = ai_roaming_field(_placement, "edge_band_px", 480);
    var _min_player_distance_px = ai_roaming_field(_placement, "min_player_distance_px", 1000);
    var _edge_inset_px = 80;
    var _map_width = room_width;
    var _map_height = room_height;
    with (obj_map_generator)
    {
        _map_height = map_height;
    }
    if (_map_width <= (_edge_band_px * 2) || _map_height <= (_edge_band_px * 2))
    {
        return undefined;
    }
    repeat (ai_roaming_field(_placement, "position_tries", 40))
    {
        var _try_x = random_range(_edge_inset_px, _map_width - _edge_inset_px);
        var _try_y = random_range(_edge_inset_px, _map_height - _edge_inset_px);
        switch (irandom(3))
        {
            case 0:
                _try_x = random_range(_edge_inset_px, _edge_band_px);
                break;
            case 1:
                _try_x = random_range(_map_width - _edge_band_px, _map_width - _edge_inset_px);
                break;
            case 2:
                _try_y = random_range(_edge_inset_px, _edge_band_px);
                break;
            case 3:
                _try_y = random_range(_map_height - _edge_band_px, _map_height - _edge_inset_px);
                break;
        }
        if (!is_undefined(arg0.player_x) && point_distance(_try_x, _try_y, arg0.player_x, arg0.player_y) < _min_player_distance_px)
        {
            continue;
        }
        var _cell_x = _try_x div 16;
        var _cell_y = _try_y div 16;
        if (!ai_roaming_cell_is_free(_cell_x, _cell_y))
        {
            continue;
        }
        return 
        {
            x: _cell_x * 16,
            y: _cell_y * 16
        };
    }
    return undefined;
}

function ai_roaming_arrivals_step(arg0)
{
    if (is_struct(arg0.arriving))
    {
        var _arriving = arg0.arriving;
        ai_roaming_roster_add(ai_roaming_spawn_member(_arriving.group, _arriving.spawn_points));
        _arriving.members_left--;
        if (_arriving.members_left <= 0)
        {
            _arriving.group.state = "resting";
            _arriving.group.rest_until_step = arg0.step_count;
            arg0.arriving = undefined;
            ai_roaming_mod_event_group_arrived(_arriving.group);
        }
        exit;
    }
    var _arrivals = arg0.arrivals;
    if (!is_struct(_arrivals) || _arrivals.groups_left <= 0)
    {
        exit;
    }
    if (arg0.step_count < _arrivals.next_arrival_step)
    {
        exit;
    }
    var _placement = ai_roaming_field(arg0.config.spawning, "arrival_placement", undefined);
    var _retry_steps = ai_roaming_seconds_to_steps(ai_roaming_field(_placement, "retry_seconds", 30));
    if (ai_roaming_living_group_count(arg0) >= _arrivals.max_living_groups)
    {
        _arrivals.next_arrival_step = arg0.step_count + _retry_steps;
        exit;
    }
    var _template_name = ai_roaming_weighted_pick(arg0.arrival_weights);
    if (is_undefined(_template_name))
    {
        _arrivals.groups_left = 0;
        exit;
    }
    var _position = ai_roaming_pick_arrival_position(arg0);
    if (is_undefined(_position))
    {
        _arrivals.next_arrival_step = arg0.step_count + _retry_steps;
        exit;
    }
    var _group = ai_roaming_group_create(_template_name);
    _group.state = "arriving";
    arg0.arriving = 
    {
        group: _group,
        spawn_points: ai_roaming_spawn_points(_position.x, _position.y),
        members_left: ai_roaming_template_member_count(_template_name)
    };
    _arrivals.groups_left--;
    arg0.arrived_group_count++;
    if (_arrivals.groups_left_in_cluster > 0)
    {
        _arrivals.groups_left_in_cluster--;
        _arrivals.next_arrival_step = arg0.step_count + ai_roaming_seconds_to_steps(_arrivals.cluster_gap_seconds);
    }
    else
    {
        _arrivals.groups_left_in_cluster = irandom_range(_arrivals.cluster_size_min, _arrivals.cluster_size_max) - 1;
        _arrivals.next_arrival_step = arg0.step_count + ai_roaming_arrival_interval_steps(_arrivals);
    }
}

function ai_roaming_noise_responses_enabled()
{
    return difficulty_get("npc_join_fights");
}

function ai_roaming_is_outdoors(arg0)
{
    var _map_height = room_height;
    with (obj_map_generator)
    {
        _map_height = map_height;
    }
    return arg0 < _map_height;
}

function ai_roaming_noise_add(arg0, arg1)
{
    if (!global.roaming_enabled)
    {
        exit;
    }
    if (!variable_global_exists("ai_roaming") || global.ai_roaming.room_id != room)
    {
        exit;
    }
    if (!ai_roaming_is_outdoors(arg1))
    {
        exit;
    }
    var _roaming = global.ai_roaming;
    var _config = _roaming.config;
    var _spots = _roaming.noise_spots;
    var _oldest_spot_index = -1;
    for (var _spot_index = 0; _spot_index < array_length(_spots); _spot_index++)
    {
        var _spot = _spots[_spot_index];
        if (point_distance(arg0, arg1, _spot.x, _spot.y) <= _config.noise_merge_distance_px)
        {
            _spot.last_shot_step = _roaming.step_count;
            _spot.shot_count++;
            exit;
        }
        if (_oldest_spot_index < 0 || _spot.last_shot_step < _spots[_oldest_spot_index].last_shot_step)
        {
            _oldest_spot_index = _spot_index;
        }
    }
    if (array_length(_spots) >= _config.noise_spot_limit && _oldest_spot_index >= 0)
    {
        array_delete(_spots, _oldest_spot_index, 1);
    }
    array_push(_spots, 
    {
        spot_id: _roaming.next_noise_spot_id,
        x: arg0,
        y: arg1,
        last_shot_step: _roaming.step_count,
        shot_count: 1,
        responder_count: 0
    });
    _roaming.next_noise_spot_id++;
}

function ai_roaming_noise_forget_old_spots(arg0)
{
    if ((arg0.step_count % 60) != 0)
    {
        exit;
    }
    var _lifetime_steps = ai_roaming_seconds_to_steps(arg0.config.noise_spot_lifetime_seconds);
    var _spot_index = array_length(arg0.noise_spots) - 1;
    while (_spot_index >= 0)
    {
        if ((arg0.step_count - arg0.noise_spots[_spot_index].last_shot_step) > _lifetime_steps)
        {
            array_delete(arg0.noise_spots, _spot_index, 1);
        }
        _spot_index--;
    }
}

function ai_roaming_pick_cell_near(arg0, arg1, arg2, arg3)
{
    var _map_height = room_height;
    with (obj_map_generator)
    {
        _map_height = map_height;
    }
    var _edge_inset_px = 80;
    repeat (20)
    {
        var _direction = random(360);
        var _distance_px = random_range(arg2, arg3);
        var _try_x = arg0 + lengthdir_x(_distance_px, _direction);
        var _try_y = arg1 + lengthdir_y(_distance_px, _direction);
        if (_try_x < _edge_inset_px || _try_y < _edge_inset_px || _try_x > (room_width - _edge_inset_px) || _try_y > (_map_height - _edge_inset_px))
        {
            continue;
        }
        var _cell_x = _try_x div 16;
        var _cell_y = _try_y div 16;
        if (!ai_roaming_cell_is_free(_cell_x, _cell_y))
        {
            continue;
        }
        return 
        {
            x: (_cell_x * 16) + 8,
            y: (_cell_y * 16) + 8
        };
    }
    return undefined;
}

function ai_roaming_noise_active_responder_count(arg0)
{
    var _active_count = 0;
    for (var _group_index = 0; _group_index < array_length(arg0.groups); _group_index++)
    {
        var _group = arg0.groups[_group_index];
        if (!_group.on_noise_trip)
        {
            continue;
        }
        for (var _member_index = 0; _member_index < array_length(_group.members); _member_index++)
        {
            if (ai_roaming_member_is_alive(_group.members[_member_index]))
            {
                _active_count++;
                break;
            }
        }
    }
    return _active_count;
}

function ai_roaming_group_consider_noise(arg0, arg1)
{
    if (!arg1.reacts_to_noise || array_length(arg0.noise_spots) == 0)
    {
        return false;
    }
    if (!ai_roaming_noise_responses_enabled())
    {
        return false;
    }
    if (arg1.state == "waiting_for_path")
    {
        return false;
    }
    if (arg0.step_count < arg1.noise_cooldown_until_step)
    {
        return false;
    }
    var _config = arg0.config;
    if (_config.noise_max_active_responders > 0 && ai_roaming_noise_active_responder_count(arg0) >= _config.noise_max_active_responders)
    {
        return false;
    }
    var _first_npc = arg1.members[0].npc;
    if (!ai_roaming_is_outdoors(_first_npc.y))
    {
        return false;
    }
    for (var _spot_index = 0; _spot_index < array_length(arg0.noise_spots); _spot_index++)
    {
        var _spot = arg0.noise_spots[_spot_index];
        if (array_contains(arg1.noise_spot_ids_considered, _spot.spot_id))
        {
            continue;
        }
        if (_spot.responder_count >= _config.noise_responders_per_spot)
        {
            continue;
        }
        if (point_distance(_first_npc.x, _first_npc.y, _spot.x, _spot.y) > _config.noise_hearing_range_px)
        {
            continue;
        }
        var _quiet_steps = arg0.step_count - _spot.last_shot_step;
        if (arg1.noise_motive == "scavenger")
        {
            if (_quiet_steps < ai_roaming_seconds_to_steps(_config.noise_scavenger_quiet_seconds))
            {
                continue;
            }
        }
        else if (_quiet_steps > ai_roaming_seconds_to_steps(_config.noise_active_seconds))
        {
            continue;
        }
        array_push(arg1.noise_spot_ids_considered, _spot.spot_id);
        if (!scr_chance(_config.noise_response_chance_percent))
        {
            continue;
        }
        var _destination = undefined;
        if (arg1.noise_motive == "patient")
        {
            var _spread = _config.noise_patient_distance_spread_percent / 100;
            _destination = ai_roaming_pick_cell_near(_spot.x, _spot.y, _config.noise_patient_distance_px * max(0, 1 - _spread), _config.noise_patient_distance_px * (1 + _spread));
        }
        else
        {
            _destination = ai_roaming_pick_cell_near(_spot.x, _spot.y, 0, _config.noise_arrival_radius_px);
        }
        if (is_undefined(_destination))
        {
            continue;
        }
        _spot.responder_count++;
        arg0.noise_response_count++;
        arg1.noise_cooldown_until_step = arg0.step_count + ai_roaming_seconds_to_steps(_config.noise_response_cooldown_seconds);
        arg1.next_rest_seconds = (arg1.noise_motive == "patient") ? _config.noise_patient_wait_seconds : -1;
        ai_roaming_group_send_to(arg0, arg1, _destination.x, _destination.y, _config.noise_travel_speed_multiplier);
        arg1.on_noise_trip = true;
        return true;
    }
    return false;
}

function ai_roaming_add_exit(arg0, arg1)
{
    array_push(ai_roaming_state().exits, 
    {
        x: arg0,
        y: arg1
    });
}

function ai_roaming_npc_has_contact(arg0)
{
    if (!instance_exists(arg0) || !variable_instance_exists(arg0, "ai_execution"))
    {
        return false;
    }
    var _execution = arg0.ai_execution;
    return is_struct(_execution) && variable_struct_exists(_execution, "knowledge") && _execution.knowledge.valid;
}

function ai_roaming_group_update_combat(arg0, arg1)
{
    for (var _member_index = 0; _member_index < array_length(arg1.members); _member_index++)
    {
        if (ai_roaming_npc_has_contact(arg1.members[_member_index].npc))
        {
            arg1.in_combat = true;
            arg1.last_contact_step = arg0.step_count;
            return true;
        }
    }
    if (!arg1.in_combat)
    {
        return false;
    }
    if ((arg0.step_count - arg1.last_contact_step) < ai_roaming_seconds_to_steps(arg0.config.regroup_after_combat_seconds))
    {
        return true;
    }
    arg1.in_combat = false;
    ai_roaming_group_after_combat(arg0, arg1);
    return true;
}

function ai_roaming_group_after_combat(arg0, arg1)
{
    var _member_index = array_length(arg1.members) - 1;
    while (_member_index >= 0)
    {
        var _member = arg1.members[_member_index];
        var _npc = _member.npc;
        if (_member.max_hp > 0 && _npc.hp > 0 && _npc.hp <= ((_member.max_hp * arg0.config.departure_health_percent) / 100))
        {
            array_delete(arg1.members, _member_index, 1);
            ai_roaming_member_depart(arg0, _member);
        }
        _member_index--;
    }
    var _member_count = array_length(arg1.members);
    if (_member_count < 2 || arg1.state == "waiting_for_path")
    {
        exit;
    }
    var _middle_x = 0;
    var _middle_y = 0;
    for (_member_index = 0; _member_index < _member_count; _member_index++)
    {
        _middle_x += (arg1.members[_member_index].npc.x / _member_count);
        _middle_y += (arg1.members[_member_index].npc.y / _member_count);
    }
    var _gather_npc = arg1.members[0].npc;
    for (_member_index = 1; _member_index < _member_count; _member_index++)
    {
        var _candidate_npc = arg1.members[_member_index].npc;
        if (point_distance(_candidate_npc.x, _candidate_npc.y, _middle_x, _middle_y) < point_distance(_gather_npc.x, _gather_npc.y, _middle_x, _middle_y))
        {
            _gather_npc = _candidate_npc;
        }
    }
    arg0.regroup_count++;
    ai_roaming_group_send_to(arg0, arg1, _gather_npc.x, _gather_npc.y);
}

function ai_roaming_member_depart(arg0, arg1)
{
    var _npc = arg1.npc;
    _npc.roaming_group_id = -1;
    _npc.roaming_travel_speed = 0;
    arg1.left_group = true;
    var _nearest_exit = undefined;
    for (var _exit_index = 0; _exit_index < array_length(arg0.exits); _exit_index++)
    {
        var _exit = arg0.exits[_exit_index];
        if (is_undefined(_nearest_exit) || point_distance(_npc.x, _npc.y, _exit.x, _exit.y) < point_distance(_npc.x, _npc.y, _nearest_exit.x, _nearest_exit.y))
        {
            _nearest_exit = _exit;
        }
    }
    arg1.path_failed = false;
    array_push(arg0.departing, 
    {
        member: arg1,
        walks_to_exit: !is_undefined(_nearest_exit),
        deadline_step: arg0.step_count + ai_roaming_seconds_to_steps(arg0.config.departure_timeout_seconds)
    });
    if (!is_undefined(_nearest_exit))
    {
        array_push(arg0.path_queue, 
        {
            group: undefined,
            member: arg1,
            destination_x: _nearest_exit.x,
            destination_y: _nearest_exit.y
        });
    }
}

function ai_roaming_departures_step(arg0)
{
    var _index = array_length(arg0.departing) - 1;
    while (_index >= 0)
    {
        var _departure = arg0.departing[_index];
        var _member = _departure.member;
        if (!ai_roaming_member_is_alive(_member))
        {
            array_delete(arg0.departing, _index, 1);
        }
        else
        {
            var _npc = _member.npc;
            var _ready_to_leave = !_departure.walks_to_exit || arg0.step_count >= _departure.deadline_step;
            if (!_ready_to_leave && !ai_roaming_departure_path_pending(arg0, _member))
            {
                _ready_to_leave = _member.path_failed || ai_roaming_npc_has_finished_route(_npc);
            }
            if (!_ready_to_leave || instance_exists(_npc))
            {
            }
            else
            {
                array_delete(arg0.departing, _index, 1);
                ai_roaming_remove_npc(_member);
                arg0.departed_count++;
            }
        }
        _index--;
    }
}

function ai_roaming_departure_path_pending(arg0, arg1)
{
    for (var _index = 0; _index < array_length(arg0.path_queue); _index++)
    {
        if (arg0.path_queue[_index].member == arg1 && !is_struct(arg0.path_queue[_index].group))
        {
            return true;
        }
    }
    return false;
}

function ai_roaming_remove_npc(arg0)
{
    var _npc = arg0.npc;
    global.list_n_id[arg0.roster_index] = -4;
    global.list_n_follow_path[arg0.roster_index] = false;
    global.list_n_x[arg0.roster_index] = -10000;
    global.list_n_y[arg0.roster_index] = -10000;
    instance_activate_object(_npc);
    _npc.delete_npc = true;
    ai_roaming_mod_event_npc_despawned(_npc);
    if (instance_exists(_npc))
    {
        instance_destroy(_npc);
    }
}

function ai_roaming_npc_has_behaviour_tree(arg0)
{
    if (!instance_exists(arg0) || !variable_instance_exists(arg0, "ai_execution"))
    {
        return false;
    }
    return is_struct(arg0.ai_execution) && variable_struct_exists(arg0.ai_execution, "knowledge");
}

function ai_roaming_looting_enabled()
{
    return global.roaming_enabled && difficulty_get("npc_loot_bodies");
}

function ai_roaming_claims_defended()
{
    return ai_roaming_looting_enabled() && difficulty_get("npc_claim_bodies");
}

function ai_roaming_loot_profile_key(arg0, arg1)
{
    var _group_id = -1;
    if (instance_exists(arg0))
    {
        if (variable_instance_exists(arg0, "roaming_group_id"))
        {
            _group_id = arg0.roaming_group_id;
        }
    }
    else
    {
        _group_id = arg0.roaming_group_id;
    }
    var _groups = ai_roaming_state().groups;
    if (_group_id >= 0 && _group_id < array_length(_groups))
    {
        var _group = _groups[_group_id];
        if (variable_struct_exists(_group, "noise_motive") && _group.noise_motive == "scavenger")
        {
            return "scavenger";
        }
    }
    if (!is_string(arg1) || arg1 == "")
    {
        return "";
    }
    return npc_get_faction(arg1);
}

function ai_roaming_npc_data_id(arg0)
{
    return (instance_exists(arg0) && variable_instance_exists(arg0, "npc_id") && is_string(arg0.npc_id)) ? arg0.npc_id : "";
}

function ai_roaming_roster_npc_can_loot(arg0)
{
    if (arg0 < 0 || arg0 >= array_length(global.list_n_id) || global.list_n_id[arg0] == -4)
    {
        return false;
    }
    if (arg0 >= array_length(global.list_n_npc_id))
    {
        return false;
    }
    return npc_get_faction(global.list_n_npc_id[arg0]) != "Mutants";
}

function ai_roaming_loot_flag(arg0, arg1, arg2)
{
    var _override = (is_struct(arg0.factions) && is_string(arg1) && arg1 != "") ? variable_struct_get(arg0.factions, arg1) : undefined;
    if (is_struct(_override) && variable_struct_exists(_override, arg2))
    {
        return variable_struct_get(_override, arg2) == true;
    }
    return variable_struct_exists(arg0, arg2) && variable_struct_get(arg0, arg2) == true;
}

function ai_roaming_npc_may_loot_body(arg0, arg1)
{
    if (!instance_exists(arg0))
    {
        return false;
    }
    var _faction = variable_instance_exists(arg0, "faction") ? arg0.faction : "";
    var _profile_key = (ai_roaming_loot_profile_key(arg0, ai_roaming_npc_data_id(arg0)) == "scavenger") ? "scavenger" : _faction;
    var _config_loot = ai_roaming_state().config.loot;
    if (ai_roaming_loot_flag(_config_loot, _profile_key, "loots_kills"))
    {
        return true;
    }
    return is_string(arg1) && arg1 == _faction && ai_roaming_loot_flag(_config_loot, _profile_key, "recovers_own_dead");
}

function ai_roaming_body_faction(arg0)
{
    var _faction = instance_exists(arg0) ? (variable_instance_exists(arg0, "chest_faction") ? arg0.chest_faction : "") : arg0.chest_faction;
    return is_string(_faction) ? _faction : "";
}

function ai_roaming_claim_owner_for(arg0)
{
    if (!instance_exists(arg0) || !variable_instance_exists(arg0, "roaming_group_id"))
    {
        return undefined;
    }
    if (variable_instance_exists(arg0, "faction") && arg0.faction == "Mutants")
    {
        return undefined;
    }
    var _roaming = ai_roaming_state();
    if (arg0.roaming_group_id >= 0)
    {
        if (arg0.roaming_group_id >= array_length(_roaming.groups))
        {
            return undefined;
        }
        var _members = _roaming.groups[arg0.roaming_group_id].members;
        for (var _member_index = 0; _member_index < array_length(_members); _member_index++)
        {
            if (_members[_member_index].npc == arg0)
            {
                return _members[_member_index];
            }
        }
        return undefined;
    }
    if (!ai_roaming_npc_has_behaviour_tree(arg0) || !variable_instance_exists(arg0, "ai_roster_index"))
    {
        return undefined;
    }
    var _roster_index = arg0.ai_roster_index;
    if (_roster_index < 0 || _roster_index >= array_length(global.list_n_id) || global.list_n_id[_roster_index] != arg0)
    {
        return undefined;
    }
    for (var _owner_index = 0; _owner_index < array_length(_roaming.static_owners); _owner_index++)
    {
        if (_roaming.static_owners[_owner_index].npc == arg0)
        {
            return _roaming.static_owners[_owner_index];
        }
    }
    var _has_post = variable_instance_exists(arg0, "original_x") && variable_instance_exists(arg0, "original_y");
    var _static_member = 
    {
        npc: arg0,
        roster_index: _roster_index,
        path_failed: false,
        max_hp: 0,
        alerted_speed: 0,
        claim_duty_count: 0,
        is_static: true,
        left_group: false,
        home_x: _has_post ? arg0.original_x : arg0.x,
        home_y: _has_post ? arg0.original_y : arg0.y
    };
    ai_roaming_member_store_npc_values(_static_member);
    array_push(_roaming.static_owners, _static_member);
    return _static_member;
}

function ai_roaming_body_dropped(arg0, arg1)
{
    if (!global.roaming_enabled)
    {
        exit;
    }
    var _roaming = ai_roaming_state();
    array_push(_roaming.recent_bodies, 
    {
        body: arg0,
        x: arg0.x,
        y: arg0.y,
        dropped_step: _roaming.step_count,
        looted: false
    });
    if (array_length(_roaming.recent_bodies) > _roaming.config.recent_body_limit)
    {
        array_delete(_roaming.recent_bodies, 0, 1);
    }
    if (!ai_roaming_claim_create(arg0, arg1))
    {
        ai_roaming_claim_create_for_comrade(arg0);
    }
}

function ai_roaming_claim_create(arg0, arg1)
{
    if (!ai_roaming_looting_enabled() || ai_roaming_claim_find(arg0) >= 0)
    {
        return false;
    }
    var _owner_member = ai_roaming_claim_owner_for(arg1);
    if (is_undefined(_owner_member))
    {
        return false;
    }
    if (!ai_roaming_npc_may_loot_body(arg1, ai_roaming_body_faction(arg0)))
    {
        return false;
    }
    var _roaming = ai_roaming_state();
    _owner_member.claim_duty_count++;
    array_push(_roaming.claims, 
    {
        body: arg0,
        body_x: arg0.x,
        body_y: arg0.y,
        group: _owner_member.is_static ? undefined : _roaming.groups[arg1.roaming_group_id],
        owner_faction: variable_instance_exists(arg1, "faction") ? arg1.faction : undefined,
        owner_member: _owner_member,
        warned: false,
        owner_warning_end_step: -1,
        owner_warning_done: false,
        warning_said_step: -1,
        loot_started_step: -1,
        looting_line_said: false,
        loot_plan: [],
        loot_taken_count: 0,
        loot_seconds_per_item: 0,
        next_move_step: 0,
        next_say_step: 0,
        expires_step: _roaming.step_count + ai_roaming_seconds_to_steps(_roaming.config.claim_lifetime_seconds)
    });
    ai_roaming_mod_event_body_claimed(arg0, arg1);
    return true;
}

function ai_roaming_claim_create_for_comrade(arg0)
{
    var _config = ai_roaming_state().config;
    var _faction = ai_roaming_body_faction(arg0);
    if (_faction == "" || !ai_roaming_loot_flag(_config.loot, _faction, "recovers_own_dead"))
    {
        return false;
    }
    if (variable_instance_exists(arg0, "already_looted") && arg0.already_looted)
    {
        return false;
    }
    var _nearest_npc = -4;
    var _nearest_distance_px = _config.own_dead_recovery_radius_px;
    var _body_x = arg0.x;
    var _body_y = arg0.y;
    with (obj_npc_parent)
    {
        if (!variable_instance_exists(id, "faction") || faction != _faction)
        {
            continue;
        }
        if (!variable_instance_exists(id, "hp") || hp <= 0 || !ai_roaming_npc_has_behaviour_tree(id))
        {
            continue;
        }
        var _distance_px = point_distance(x, y, _body_x, _body_y);
        if (_distance_px >= _nearest_distance_px)
        {
            continue;
        }
        _nearest_npc = id;
        _nearest_distance_px = _distance_px;
    }
    return ai_roaming_claim_create(arg0, _nearest_npc);
}

function ai_roaming_group_scavenge_bodies(arg0, arg1)
{
    var _config = arg0.config;
    var _lifetime_steps = ai_roaming_seconds_to_steps(_config.scavenger_body_lifetime_seconds);
    var _next_member_index = 0;
    for (var _body_index = 0; _body_index < array_length(arg0.recent_bodies); _body_index++)
    {
        var _entry = arg0.recent_bodies[_body_index];
        if (_entry.looted || (arg0.step_count - _entry.dropped_step) > _lifetime_steps)
        {
            continue;
        }
        if (point_distance(_entry.x, _entry.y, arg1.destination_x, arg1.destination_y) > _config.scavenger_body_radius_px)
        {
            continue;
        }
        if (instance_exists(_entry.body) && variable_instance_exists(_entry.body, "already_looted") && _entry.body.already_looted)
        {
            continue;
        }
        if (array_length(arg1.members) == 0)
        {
            exit;
        }
        var _owner_npc = arg1.members[_next_member_index % array_length(arg1.members)].npc;
        if (ai_roaming_claim_create(_entry.body, _owner_npc))
        {
            _next_member_index++;
        }
    }
}

function ai_roaming_claim_find(arg0)
{
    if (!variable_global_exists("ai_roaming") || global.ai_roaming.room_id != room)
    {
        return -1;
    }
    var _claims = global.ai_roaming.claims;
    for (var _claim_index = 0; _claim_index < array_length(_claims); _claim_index++)
    {
        if (_claims[_claim_index].body == arg0)
        {
            return _claim_index;
        }
    }
    return -1;
}

function ai_roaming_body_is_marked(arg0)
{
    return ai_roaming_claims_defended() && ai_roaming_claim_find(arg0) >= 0;
}

function ai_roaming_body_needs_warning(arg0)
{
    if (!ai_roaming_claims_defended())
    {
        return false;
    }
    var _claim_index = ai_roaming_claim_find(arg0);
    return _claim_index >= 0 && !global.ai_roaming.claims[_claim_index].warned;
}

function ai_roaming_claim_on_interact(arg0, arg1)
{
    var _claim_index = ai_roaming_claim_find(arg0);
    if (_claim_index < 0)
    {
        return false;
    }
    var _roaming = global.ai_roaming;
    var _claim = _roaming.claims[_claim_index];
    if (!ai_roaming_claims_defended())
    {
        _roaming.claim_yielded_count++;
        ai_roaming_claim_release(_roaming, _claim_index);
        return false;
    }
    if (!_claim.warned)
    {
        _claim.warned = true;
        ai_roaming_claim_say_warning(_roaming, _claim);
        _claim.next_move_step = 0;
        return true;
    }
    _claim.owner_member.npc.roaming_hostile_target = arg1;
    _roaming.claim_hostile_count++;
    ai_roaming_claim_release(_roaming, _claim_index);
    return false;
}

function ai_roaming_npc_is_hostile_to(arg0, arg1)
{
    return variable_instance_exists(arg0, "roaming_hostile_target") && arg0.roaming_hostile_target == arg1;
}

function ai_roaming_claim_release(arg0, arg1)
{
    var _claim = arg0.claims[arg1];
    var _member = _claim.owner_member;
    _member.claim_duty_count = max(0, _member.claim_duty_count - 1);
    array_delete(arg0.claims, arg1, 1);
    if (_member.claim_duty_count > 0 || !ai_roaming_member_is_alive(_member))
    {
        exit;
    }
    var _destination = _member.is_static ? 
    {
        x: _member.home_x,
        y: _member.home_y
    } : ai_roaming_group_rejoin_point(_claim.group, _member);
    if (is_undefined(_destination))
    {
        exit;
    }
    _member.path_failed = false;
    _member.npc.roaming_travel_speed = 0;
    array_push(arg0.path_queue, 
    {
        group: undefined,
        member: _member,
        destination_x: _destination.x,
        destination_y: _destination.y
    });
}

function ai_roaming_group_rejoin_point(arg0, arg1)
{
    if (!is_struct(arg0))
    {
        return undefined;
    }
    if (arg0.state == "travelling")
    {
        return 
        {
            x: arg0.destination_x,
            y: arg0.destination_y
        };
    }
    var _nearest = undefined;
    var _nearest_distance_px = 0;
    for (var _member_index = 0; _member_index < array_length(arg0.members); _member_index++)
    {
        var _other = arg0.members[_member_index];
        if (_other == arg1 || _other.left_group || !ai_roaming_member_is_alive(_other))
        {
            continue;
        }
        var _other_x = global.list_n_x[_other.roster_index];
        var _other_y = global.list_n_y[_other.roster_index];
        var _distance_px = point_distance(arg1.npc.x, arg1.npc.y, _other_x, _other_y);
        if (is_undefined(_nearest) || _distance_px < _nearest_distance_px)
        {
            _nearest = 
            {
                x: _other_x,
                y: _other_y
            };
            _nearest_distance_px = _distance_px;
        }
    }
    return _nearest;
}

function ai_roaming_claim_find_heir(arg0, arg1)
{
    var _old_member = arg1.owner_member;
    if (is_struct(arg1.group))
    {
        for (var _member_index = 0; _member_index < array_length(arg1.group.members); _member_index++)
        {
            var _candidate = arg1.group.members[_member_index];
            if (_candidate != _old_member && !_candidate.left_group && ai_roaming_member_is_alive(_candidate) && instance_exists(_candidate.npc))
            {
                return _candidate;
            }
        }
        return undefined;
    }
    if (is_undefined(arg1.owner_faction))
    {
        return undefined;
    }
    var _nearest_npc = -4;
    var _nearest_distance_px = arg0.config.static_heir_radius_px;
    var _body_x = arg1.body_x;
    var _body_y = arg1.body_y;
    var _faction = arg1.owner_faction;
    var _old_npc = _old_member.npc;
    with (obj_npc_parent)
    {
        if (id == _old_npc || !variable_instance_exists(id, "faction") || faction != _faction)
        {
            continue;
        }
        if (!variable_instance_exists(id, "hp") || hp <= 0)
        {
            continue;
        }
        var _distance_px = point_distance(x, y, _body_x, _body_y);
        if (_distance_px >= _nearest_distance_px)
        {
            continue;
        }
        _nearest_npc = id;
        _nearest_distance_px = _distance_px;
    }
    return ai_roaming_claim_owner_for(_nearest_npc);
}

function ai_roaming_claim_say(arg0, arg1)
{
    if (!instance_exists(arg0))
    {
        exit;
    }
    var _faction_name = variable_instance_exists(arg0, "faction") ? arg0.faction : "";
    var _lines = ai_barks_lines_or_default(_faction_name, arg1);
    if (array_length(_lines) == 0)
    {
        exit;
    }
    ai_roaming_npc_say(arg0, language_get_string(ai_barks_pick_line(_lines)));
}

function ai_roaming_npc_say(arg0, arg1)
{
    if (!instance_exists(arg0))
    {
        exit;
    }
    scr_draw_npc_text(arg0, UnknownEnum.Value_6);
    with (obj_npc_draw_text)
    {
        if (id_npc == arg0)
        {
            alarm[1] = -1;
            t = arg1;
        }
    }
}

function ai_roaming_claim_move_owner(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
{
    if (arg0.step_count < arg1.next_move_step || ai_roaming_departure_path_pending(arg0, arg2))
    {
        exit;
    }
    arg1.next_move_step = arg0.step_count + ai_roaming_seconds_to_steps(arg6);
    arg2.path_failed = false;
    arg2.npc.roaming_travel_speed = arg5;
    array_push(arg0.path_queue, 
    {
        group: undefined,
        member: arg2,
        destination_x: arg3,
        destination_y: arg4
    });
}

function ai_roaming_claims_step(arg0)
{
    var _claims = arg0.claims;
    if (array_length(_claims) == 0)
    {
        exit;
    }
    var _members_already_looting = [];
    var _members_warning_the_player = [];
    var _claims_defended = ai_roaming_claims_defended();
    for (_claim_index = 0; _claim_index < array_length(_claims); _claim_index++)
    {
        var _claim = _claims[_claim_index];
        if (_claim.loot_started_step >= 0)
        {
            array_push(_members_already_looting, _claim.owner_member);
        }
        else if (_claims_defended && !_claim.owner_warning_done && ai_roaming_claim_player_is_near_body(arg0, _claim))
        {
            array_push(_members_warning_the_player, _claim.owner_member);
        }
    }
    var _busy_members = [];
    var _claim_index = 0;
    while (_claim_index < array_length(_claims))
    {
        var _claim = _claims[_claim_index];
        if (arg0.step_count >= _claim.expires_step)
        {
            ai_roaming_claim_release(arg0, _claim_index);
            continue;
        }
        var _member = _claim.owner_member;
        if (!ai_roaming_member_is_alive(_member) || _member.left_group)
        {
            var _heir = ai_roaming_claim_find_heir(arg0, _claim);
            if (is_undefined(_heir))
            {
                ai_roaming_claim_release(arg0, _claim_index);
                instance_activate_object(_claim.body);
                if (instance_exists(_claim.body))
                {
                    ai_roaming_claim_create_for_comrade(_claim.body);
                }
                continue;
            }
            _member.claim_duty_count = max(0, _member.claim_duty_count - 1);
            _heir.claim_duty_count++;
            _claim.owner_member = _heir;
            _claim.loot_started_step = -1;
            _claim.loot_plan = [];
            _claim.next_move_step = 0;
            _claim.owner_warning_end_step = -1;
            _claim.owner_warning_done = false;
            _claim.warning_said_step = -1;
            _claim.looting_line_said = false;
            _member = _heir;
        }
        var _is_looting = _claim.loot_started_step >= 0;
        var _is_warning = _claims_defended && !_is_looting && !_claim.owner_warning_done && ai_roaming_claim_player_is_near_body(arg0, _claim);
        var _owner_is_needed_elsewhere = array_contains(_busy_members, _member) || (!_is_looting && array_contains(_members_already_looting, _member)) || (!_is_looting && !_is_warning && array_contains(_members_warning_the_player, _member));
        if (_owner_is_needed_elsewhere)
        {
            _claim.loot_started_step = -1;
            _claim_index++;
            continue;
        }
        array_push(_busy_members, _member);
        if (ai_roaming_npc_has_contact(_member.npc))
        {
            _claim.loot_started_step = -1;
            _claim_index++;
            continue;
        }
        if (_is_warning && ai_roaming_claim_warn_player(arg0, _claim, _member))
        {
            _claim_index++;
        }
        else if (!ai_roaming_claim_loot_body(arg0, _claim, _member, _claim_index))
        {
            _claim_index++;
        }
    }
}

function ai_roaming_claim_player_is_near_body(arg0, arg1)
{
    if (is_undefined(arg0.player_x))
    {
        return false;
    }
    return point_distance(arg0.player_x, arg0.player_y, arg1.body_x, arg1.body_y) <= arg0.config.claim_player_distance_px;
}

function ai_roaming_claim_say_warning(arg0, arg1)
{
    ai_roaming_claim_say(arg1.owner_member.npc, "body_warning");
    arg1.warning_said_step = arg0.step_count;
    arg1.next_say_step = arg0.step_count + ai_roaming_seconds_to_steps(arg0.config.claim_warning_repeat_seconds);
}

function ai_roaming_claim_warn_player(arg0, arg1, arg2)
{
    var _config = arg0.config;
    if (arg1.owner_warning_end_step >= 0 && arg0.step_count >= arg1.owner_warning_end_step)
    {
        arg1.owner_warning_done = true;
        arg1.next_move_step = 0;
        return false;
    }
    var _npc = arg2.npc;
    var _distance_to_player_px = point_distance(_npc.x, _npc.y, arg0.player_x, arg0.player_y);
    if (_distance_to_player_px > _config.claim_approach_distance_px)
    {
        var _stand_point = ai_roaming_pick_cell_near(arg0.player_x, arg0.player_y, _config.claim_stand_distance_min_px, _config.claim_stand_distance_max_px);
        if (is_undefined(_stand_point))
        {
            _stand_point = 
            {
                x: arg0.player_x,
                y: arg0.player_y
            };
        }
        ai_roaming_claim_move_owner(arg0, arg1, arg2, _stand_point.x, _stand_point.y, arg2.alerted_speed, 1);
    }
    if (instance_exists(_npc) && _distance_to_player_px < _config.claim_aim_distance_px)
    {
        _npc.weapon_pointing_direction = point_direction(_npc.x, _npc.y, arg0.player_x, arg0.player_y);
        _npc.target_for_image_scale = arg0.player_x;
        if (arg1.owner_warning_end_step < 0)
        {
            arg1.owner_warning_end_step = arg0.step_count + ai_roaming_seconds_to_steps(_config.claim_warning_seconds);
        }
        if (arg0.step_count >= arg1.next_say_step)
        {
            ai_roaming_claim_say_warning(arg0, arg1);
        }
    }
    return true;
}

function ai_roaming_claim_loot_body(arg0, arg1, arg2, arg3)
{
    var _npc = arg2.npc;
    if (point_distance(_npc.x, _npc.y, arg1.body_x, arg1.body_y) > arg0.config.claim_loot_reach_px)
    {
        arg1.loot_started_step = -1;
        ai_roaming_claim_move_owner(arg0, arg1, arg2, arg1.body_x, arg1.body_y, 0, 5);
        return false;
    }
    var _loot_config = arg0.config.loot;
    if (arg1.loot_started_step < 0)
    {
        arg1.loot_started_step = arg0.step_count;
        arg1.loot_taken_count = 0;
        instance_activate_object(arg1.body);
        var _plan = ai_loot_body_plan(_npc, arg1.body, _loot_config, ai_roaming_loot_profile_key(_npc, ai_roaming_npc_data_id(_npc)));
        arg1.loot_plan = ai_roaming_mod_event_body_looted(arg1.body, _npc, _plan);
        var _item_count = array_length(arg1.loot_plan);
        var _seconds_per_item = _loot_config.seconds_per_item;
        if (_item_count > 1)
        {
            _seconds_per_item = min(_seconds_per_item, (_loot_config.seconds_max - _loot_config.seconds_first_item) / (_item_count - 1));
        }
        arg1.loot_seconds_per_item = max(0, _seconds_per_item);
    }
    var _warning_is_fresh = arg1.warning_said_step >= 0 && (arg0.step_count - arg1.warning_said_step) < ai_roaming_seconds_to_steps(2);
    if (!arg1.looting_line_said && !_warning_is_fresh)
    {
        arg1.looting_line_said = true;
        ai_roaming_claim_say(_npc, "body_looting");
    }
    var _elapsed_steps = arg0.step_count - arg1.loot_started_step;
    if (arg1.loot_taken_count < array_length(arg1.loot_plan))
    {
        var _due_seconds = _loot_config.seconds_first_item + (arg1.loot_taken_count * arg1.loot_seconds_per_item);
        if (_elapsed_steps < ai_roaming_seconds_to_steps(_due_seconds))
        {
            return false;
        }
        if (ai_loot_body_take(_npc, arg1.body, arg1.loot_plan[arg1.loot_taken_count]))
        {
            arg0.claim_items_taken++;
        }
        arg1.loot_taken_count++;
        if (arg1.loot_taken_count < array_length(arg1.loot_plan))
        {
            return false;
        }
    }
    if (_elapsed_steps < ai_roaming_seconds_to_steps(arg0.config.claim_loot_seconds))
    {
        return false;
    }
    for (var _body_index = 0; _body_index < array_length(arg0.recent_bodies); _body_index++)
    {
        if (arg0.recent_bodies[_body_index].body == arg1.body)
        {
            arg0.recent_bodies[_body_index].looted = true;
        }
    }
    arg0.claim_looted_count++;
    ai_roaming_claim_release(arg0, arg3);
    return true;
}

function ai_roaming_offscreen_distance(arg0, arg1)
{
    var _roaming = ai_roaming_state();
    var _last_visit_steps = _roaming.last_roster_visit_step;
    while (array_length(_last_visit_steps) <= arg0)
    {
        array_push(_last_visit_steps, _roaming.step_count);
    }
    var _elapsed_steps = min(_roaming.step_count - _last_visit_steps[arg0], 600);
    _last_visit_steps[arg0] = _roaming.step_count;
    var _speed = (arg1.roaming_travel_speed > 0) ? arg1.roaming_travel_speed : arg1.roaming_patrol_speed;
    return _elapsed_steps * _speed * _roaming.config.offscreen_speed_multiplier;
}

function ai_roaming_walk_offscreen(arg0, arg1, arg2)
{
    if (!arg0.follow_path || !ds_exists(arg0.lista_path_x, ds_type_list))
    {
        exit;
    }
    var _waypoint_count = ds_list_size(arg0.lista_path_x);
    var _remaining_px = min(arg2, 256);
    while (_remaining_px > 0 && arg0.path_position_now < (_waypoint_count - 1))
    {
        var _next_x = ds_list_find_value(arg0.lista_path_x, arg0.path_position_now + 1);
        var _next_y = ds_list_find_value(arg0.lista_path_y, arg0.path_position_now + 1);
        var _gap_px = point_distance(arg0.x, arg0.y, _next_x, _next_y);
        if (_gap_px < 0.01)
        {
            arg0.path_position_now++;
            continue;
        }
        var _move_px = min(8, _remaining_px, _gap_px);
        var _direction = point_direction(arg0.x, arg0.y, _next_x, _next_y);
        var _new_x = arg0.x + lengthdir_x(_move_px, _direction);
        var _new_y = arg0.y + lengthdir_y(_move_px, _direction);
        var _entering_new_cell = (_new_x div 16) != (arg0.x div 16) || (_new_y div 16) != (arg0.y div 16);
        if (_entering_new_cell && mp_grid_get_cell(global.grid_move, _new_x div 16, _new_y div 16) != 0)
        {
            arg0.path_position_now = _waypoint_count - 1;
            break;
        }
        arg0.x = _new_x;
        arg0.y = _new_y;
        _remaining_px -= _move_px;
        if ((_gap_px - _move_px) < 0.01)
        {
            arg0.path_position_now++;
        }
    }
    global.list_n_x[arg1] = arg0.x;
    global.list_n_y[arg1] = arg0.y;
}

function ai_roaming_npc_types_are_enemies(arg0, arg1)
{
    var _faction_a = npc_get_faction(arg0);
    var _faction_b = npc_get_faction(arg1);
    if (_faction_a == _faction_b)
    {
        return false;
    }
    return scr_get_relation(_faction_a, _faction_b) == UnknownEnum.Value_2;
}

function ai_roaming_can_fight_offscreen(arg0, arg1, arg2, arg3, arg4)
{
    var _npc = global.list_n_id[arg0];
    if (_npc == -4 || instance_exists(_npc))
    {
        return false;
    }
    return !point_in_rectangle(_npc.x, _npc.y, arg1, arg2, arg3, arg4);
}

function ai_roaming_offscreen_fight(arg0, arg1, arg2, arg3, arg4)
{
    var _roaming = ai_roaming_state();
    var _config = _roaming.config;
    var _next_fight_steps = _roaming.next_offscreen_fight_step;
    var _roster_size = array_length(global.list_n_id);
    while (array_length(_next_fight_steps) < _roster_size)
    {
        array_push(_next_fight_steps, 0);
    }
    if (_roaming.step_count < _next_fight_steps[arg0])
    {
        exit;
    }
    if (!ai_roaming_can_fight_offscreen(arg0, arg1, arg2, arg3, arg4))
    {
        exit;
    }
    var _npc = global.list_n_id[arg0];
    if (_npc.roaming_group_id < 0)
    {
        exit;
    }
    var _opponent_index = -1;
    var _opponent_distance_px = _config.offscreen_fight_range_px;
    for (var _other_index = 0; _other_index < _roster_size; _other_index++)
    {
        if (_other_index == arg0)
        {
            continue;
        }
        if (_roaming.step_count < _next_fight_steps[_other_index])
        {
            continue;
        }
        var _distance_px = point_distance(global.list_n_x[arg0], global.list_n_y[arg0], global.list_n_x[_other_index], global.list_n_y[_other_index]);
        if (_distance_px >= _opponent_distance_px)
        {
            continue;
        }
        if (!ai_roaming_can_fight_offscreen(_other_index, arg1, arg2, arg3, arg4))
        {
            continue;
        }
        if (!ai_roaming_npc_types_are_enemies(global.list_n_npc_id[arg0], global.list_n_npc_id[_other_index]))
        {
            continue;
        }
        _opponent_index = _other_index;
        _opponent_distance_px = _distance_px;
    }
    if (_opponent_index < 0)
    {
        exit;
    }
    var _next_allowed_step = _roaming.step_count + ai_roaming_seconds_to_steps(_config.offscreen_fight_interval_seconds);
    _next_fight_steps[arg0] = _next_allowed_step;
    _next_fight_steps[_opponent_index] = _next_allowed_step;
    if (!scr_chance(_config.offscreen_fight_chance_percent))
    {
        exit;
    }
    var _my_power = global.list_n_power[arg0];
    var _opponent_power = global.list_n_power[_opponent_index];
    var _weaker_index = (_my_power <= _opponent_power) ? arg0 : _opponent_index;
    var _stronger_index = (_weaker_index == arg0) ? _opponent_index : arg0;
    var _stronger_power = max(_my_power, _opponent_power);
    var _weaker_power = min(_my_power, _opponent_power);
    var _weaker_win_chance_percent = 50;
    if (_stronger_power > 0)
    {
        _weaker_win_chance_percent = 50 * power(_weaker_power / _stronger_power, _config.offscreen_fight_power_exponent);
    }
    if (_weaker_power <= 0 && _stronger_power > 0)
    {
        _weaker_win_chance_percent = 0;
    }
    var _weaker_wins = _weaker_win_chance_percent > 0 && scr_chance(_weaker_win_chance_percent);
    var _loser_index = _weaker_wins ? _stronger_index : _weaker_index;
    ai_roaming_kill_offscreen(_loser_index, (_loser_index == arg0) ? _opponent_index : arg0);
}

function ai_roaming_offscreen_takes_loose_items()
{
    return difficulty_get("npc_loot_attachments") || difficulty_get("npc_loot_ammo") || difficulty_get("npc_loot_medical") || difficulty_get("npc_loot_valuables");
}

function ai_roaming_kill_offscreen(arg0, arg1 = -1)
{
    var _npc = global.list_n_id[arg0];
    _npc.hp = -10;
    _npc.play_sound_death = false;
    var _gone = 
    {
        weapon: false,
        armor: false,
        backpack: false
    };
    if (ai_roaming_looting_enabled() && difficulty_get("npc_loot_unseen_fights"))
    {
        var _winner_loots = false;
        var _winner_profile_key = "";
        if (ai_roaming_roster_npc_can_loot(arg1))
        {
            _winner_profile_key = ai_roaming_loot_profile_key(global.list_n_id[arg1], global.list_n_npc_id[arg1]);
            _winner_loots = ai_roaming_loot_flag(ai_roaming_state().config.loot, _winner_profile_key, "loots_kills");
        }
        else
        {
            _gone = 
            {
                weapon: true,
                armor: true,
                backpack: true
            };
        }
        if (_winner_loots)
        {
            var _winner = global.list_n_id[arg1];
            _gone = ai_loot_take_from_npc(_winner, _npc, ai_roaming_state().config.loot, _winner_profile_key);
            var _loot_amount = ai_roaming_offscreen_takes_loose_items() ? difficulty_get("npc_loot_amount") : 0;
            var _tier_bumps = floor(_loot_amount);
            if (frac(_loot_amount) > 0 && scr_chance(frac(_loot_amount) * 100))
            {
                _tier_bumps += 1;
            }
            repeat (_tier_bumps)
            {
                ai_loot_tier_bump(_winner);
            }
            ai_roaming_state().offscreen_loot_count++;
        }
    }
    _npc.roaming_strip_equipment = true;
    _npc.roaming_strip_weapon = _gone.weapon;
    _npc.roaming_strip_armor = _gone.armor;
    _npc.roaming_strip_backpack = _gone.backpack;
    _npc.dead_outside_game_window = false;
    global.list_n_hp[arg0] = -10;
    global.list_n_id[arg0] = -4;
    ai_roaming_state().offscreen_fight_deaths++;
    ai_roaming_mod_event_npc_died_offscreen(_npc, global.list_n_x[arg0], global.list_n_y[arg0]);
}

function ai_roaming_raid_is_running()
{
    return variable_global_exists("ai_roaming") && global.ai_roaming.room_id == room && variable_global_exists("list_n_id");
}

function ai_roaming_mod_group_info(arg0)
{
    var _active_members = [];
    var _members_alive = 0;
    var _group_x = 0;
    var _group_y = 0;
    var _position_known = false;
    for (var _member_index = 0; _member_index < array_length(arg0.members); _member_index++)
    {
        var _member = arg0.members[_member_index];
        var _is_alive = (_member.roster_index < 0) ? instance_exists(_member.npc) : ai_roaming_member_is_alive(_member);
        if (!_is_alive)
        {
            continue;
        }
        _members_alive++;
        if (instance_exists(_member.npc))
        {
            array_push(_active_members, _member.npc);
        }
        if (_position_known)
        {
            continue;
        }
        if (instance_exists(_member.npc))
        {
            _group_x = _member.npc.x;
            _group_y = _member.npc.y;
        }
        else
        {
            _group_x = global.list_n_x[_member.roster_index];
            _group_y = global.list_n_y[_member.roster_index];
        }
        _position_known = true;
    }
    return 
    {
        group_id: arg0.group_id,
        template: arg0.template_name,
        members: _active_members,
        members_alive: _members_alive,
        x: _group_x,
        y: _group_y,
        state: arg0.state,
        in_combat: arg0.in_combat
    };
}

function ai_roaming_mod_raid_info()
{
    if (!ai_roaming_raid_is_running())
    {
        return undefined;
    }
    var _roaming = global.ai_roaming;
    return 
    {
        roaming_on: global.roaming_enabled,
        preset: _roaming.preset_name,
        character: _roaming.character_name,
        character_detail: _roaming.character_detail,
        arrival_rhythm: _roaming.rhythm_name,
        raid_seconds: _roaming.step_count div 60,
        groups_alive: ai_roaming_living_group_count(_roaming),
        arrivals_left: is_struct(_roaming.arrivals) ? _roaming.arrivals.groups_left : 0
    };
}

function ai_roaming_mod_groups()
{
    var _group_infos = [];
    if (!ai_roaming_raid_is_running())
    {
        return _group_infos;
    }
    var _groups = global.ai_roaming.groups;
    for (var _group_index = 0; _group_index < array_length(_groups); _group_index++)
    {
        var _group_info = ai_roaming_mod_group_info(_groups[_group_index]);
        if (_group_info.members_alive > 0)
        {
            array_push(_group_infos, _group_info);
        }
    }
    return _group_infos;
}

function ai_roaming_mod_spawn_group(arg0, arg1 = undefined, arg2 = undefined)
{
    if (!ai_roaming_raid_is_running() || !ai_roaming_has_spawn_data())
    {
        return undefined;
    }
    var _roaming = global.ai_roaming;
    var _template = ai_roaming_field(_roaming.config.spawning.templates, arg0, undefined);
    if (!is_struct(_template) || !ai_roaming_template_can_be_created(_template))
    {
        show_debug_message("Roaming: a mod asked for the group \"" + string(arg0) + "\", which cannot be created");
        return undefined;
    }
    if (is_undefined(arg1) || is_undefined(arg2))
    {
        var _position = ai_roaming_pick_arrival_position(_roaming);
        if (is_undefined(_position))
        {
            return undefined;
        }
        arg1 = _position.x;
        arg2 = _position.y;
    }
    var _group = ai_roaming_spawn_group(arg0, arg1, arg2);
    for (var _member_index = 0; _member_index < array_length(_group.members); _member_index++)
    {
        ai_roaming_roster_add(_group.members[_member_index]);
    }
    _group.state = "resting";
    _group.rest_until_step = _roaming.step_count;
    return ai_roaming_mod_group_info(_group);
}

function ai_roaming_mod_event_group_arrived(arg0)
{
    mods_perform_event("roaming_group_arrived", [ai_roaming_mod_group_info(arg0)]);
}

function ai_roaming_mod_event_body_claimed(arg0, arg1)
{
    mods_perform_event("roaming_body_claimed", [arg1, arg0, arg0.x, arg0.y]);
}

function ai_roaming_mod_event_body_looted(arg0, arg1, arg2)
{
    var _item_ids = ai_loot_plan_item_ids(arg2);
    mods_perform_event("roaming_body_looted", [arg1, arg0, _item_ids, arg0.x, arg0.y]);
    return ai_loot_plan_keep_ids(arg2, _item_ids);
}

function ai_roaming_mod_event_npc_died_offscreen(arg0, arg1, arg2)
{
    arg0.npc_died_event_sent = true;
    mods_perform_event("npc_died", [arg0, arg0.npc_id, -4, true, arg1, arg2]);
}

function ai_roaming_mod_event_npc_despawned(arg0)
{
    mods_perform_event("npc_despawned", [arg0, variable_instance_exists(arg0, "npc_id") ? arg0.npc_id : ""], arg0);
}

function ai_roaming_debug_text()
{
    if (!global.roaming_enabled)
    {
        return "roaming: OFF\n";
    }
    if (!variable_global_exists("ai_roaming"))
    {
        return "roaming: ON\n";
    }
    var _roaming = global.ai_roaming;
    var _travelling_count = 0;
    var _resting_count = 0;
    var _waiting_count = 0;
    var _roamers_alive = 0;
    for (var _group_index = 0; _group_index < array_length(_roaming.groups); _group_index++)
    {
        var _group = _roaming.groups[_group_index];
        for (var _member_index = 0; _member_index < array_length(_group.members); _member_index++)
        {
            if (ai_roaming_member_is_alive(_group.members[_member_index]))
            {
                _roamers_alive++;
            }
        }
        if (!_group.keeps_roaming || array_length(_group.members) == 0)
        {
            continue;
        }
        if (_group.state == "travelling")
        {
            _travelling_count++;
        }
        else if (_group.state == "resting")
        {
            _resting_count++;
        }
        else
        {
            _waiting_count++;
        }
    }
    var _raid_seconds = _roaming.step_count div 60;
    var _seconds_text = string(_raid_seconds % 60);
    if (string_length(_seconds_text) < 2)
    {
        _seconds_text = "0" + _seconds_text;
    }
    var _text = "roaming: ON\n";
    if (_roaming.spawned_from_json)
    {
        _text += ("raid: " + _roaming.preset_name + " / " + _roaming.character_name);
        if (_roaming.character_detail != "")
        {
            _text += (" (" + _roaming.character_detail + ")");
        }
        _text += "\n";
    }
    _text += ("raid time: " + string(_raid_seconds div 60) + ":" + _seconds_text + "\n");
    _text += ("roamers alive: " + string(_roamers_alive) + " of " + string(_roaming.roamers_at_start) + "  killed offscreen: " + string(_roaming.offscreen_fight_deaths) + "\n");
    _text += ("groups travelling/resting/waiting path: " + string(_travelling_count) + "/" + string(_resting_count) + "/" + string(_waiting_count) + "\n");
    _text += ("routes given: " + string(_roaming.routes_given) + "  failed searches: " + string(_roaming.failed_searches) + "\n");
    _text += ("slowest path search: " + string_format(_roaming.slowest_path_ms, 1, 2) + " ms\n");
    if (is_struct(_roaming.arrivals))
    {
        var _next_arrival_seconds = max(0, _roaming.arrivals.next_arrival_step - _roaming.step_count) div 60;
        _text += ("arrivals (" + _roaming.rhythm_name + "): " + string(_roaming.arrived_group_count) + " arrived, " + string(_roaming.arrivals.groups_left) + " left");
        if (_roaming.arrivals.groups_left > 0)
        {
            _text += (", next in " + string(_next_arrival_seconds) + " s");
        }
        _text += "\n";
    }
    _text += ("noise spots: " + string(array_length(_roaming.noise_spots)) + "  hunter responses: " + string(_roaming.noise_response_count) + "  heading there now: " + string(ai_roaming_noise_active_responder_count(_roaming)) + "/" + string(_roaming.config.noise_max_active_responders) + "  hearing: " + (ai_roaming_noise_responses_enabled() ? (string(_roaming.config.noise_hearing_range_px) + " px") : "OFF") + "\n");
    _text += ("body claims: " + string(array_length(_roaming.claims)) + "  looted by owner: " + string(_roaming.claim_looted_count) + "  owners turned hostile: " + string(_roaming.claim_hostile_count) + "  given up to the player: " + string(_roaming.claim_yielded_count) + "  looting: " + (ai_roaming_looting_enabled() ? (ai_roaming_claims_defended() ? "defended" : "undefended") : "OFF") + "\n");
    _text += ("regroups: " + string(_roaming.regroup_count) + "  wounded leaving: " + string(array_length(_roaming.departing)) + "  left the map: " + string(_roaming.departed_count) + "\n");
    return _text;
}

enum UnknownEnum
{
    Value_2 = 2,
    Value_6 = 6
}
