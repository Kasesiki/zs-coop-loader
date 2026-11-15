function __debug_menu_entry(arg0, arg1)
{
    return 
    {
        kind: arg0,
        label: arg1,
        keys: "",
        key: undefined,
        ctrl: false,
        alt: false,
        hold_key: undefined,
        global_name: undefined,
        on_change: undefined,
        default_on: false,
        run: undefined,
        run_value: undefined
    };
}

function __debug_menu_toggle(arg0, arg1, arg2 = false, arg3 = undefined)
{
    var _entry = __debug_menu_entry("toggle", arg0);
    _entry.global_name = arg1;
    _entry.default_on = arg2;
    if (!is_undefined(arg3))
    {
        _entry.on_change = method(undefined, arg3);
    }
    return _entry;
}

function __debug_menu_action(arg0, arg1, arg2 = undefined)
{
    var _entry = __debug_menu_entry("action", arg0);
    _entry.run = method(undefined, arg1);
    _entry.run_value = arg2;
    return _entry;
}

function __debug_menu_key(arg0, arg1, arg2, arg3, arg4)
{
    var _entry = __debug_menu_entry("key", arg0);
    _entry.run = method(undefined, arg4);
    return __debug_menu_with_key(_entry, arg1, arg2, arg3);
}

function __debug_menu_info(arg0, arg1)
{
    var _entry = __debug_menu_entry("info", arg0);
    _entry.keys = arg1;
    return _entry;
}

function __debug_menu_with_key(arg0, arg1, arg2, arg3 = false, arg4 = false, arg5 = undefined)
{
    arg0.keys = arg1;
    arg0.key = arg2;
    arg0.ctrl = arg3;
    arg0.alt = arg4;
    arg0.hold_key = arg5;
    return arg0;
}

function debug_menu_entries()
{
    static _entries = undefined;
    
    if (!is_undefined(_entries))
    {
        return _entries;
    }
    _entries = [__debug_menu_with_key(__debug_menu_toggle("AI labels and paths", "show_npc_state"), "Ctrl+N", 78, true), __debug_menu_toggle("Roaming numbers", "show_roaming_debug"), __debug_menu_toggle("Continuous roaming", "roaming_enabled", true), __debug_menu_toggle("NPC reflexes", "show_reflexes_npc"), __debug_menu_toggle("NPC recoil", "show_npc_recoil"), __debug_menu_toggle("NPC paths on map (slow)", "show_dynamic_npc_path"), __debug_menu_toggle("HUD glance system", "hud_glance_sysytem"), __debug_menu_toggle("HUD damage system", "hud_damage_sysytem"), __debug_menu_toggle("Hide HUD", "debug_hide_hud"), __debug_menu_toggle("Show seed / player position", "show_debug_position"), __debug_menu_with_key(__debug_menu_toggle("Fast run", "debug_speed"), "Ctrl+S", 83, true), __debug_menu_toggle("Fast weapon wear", "debug_fast_wear"), __debug_menu_with_key(__debug_menu_toggle("Hide NPCs outside line of sight", "dev_hide_npcs"), "Ctrl+V", 86, true), __debug_menu_toggle("Unlock framerate", "fps_unlocked", false, function(arg0)
    {
        game_set_speed(arg0 ? 1000 : 60, gamespeed_fps);
    }), __debug_menu_toggle("Opaque grass (optimised)", "grass_opt", true), __debug_menu_action("+10000 roubles", function()
    {
        global.player_money += 10000;
    }), __debug_menu_action("+50 rep Green Army", function()
    {
        faction_add_rep("Player", "Green Army", 50);
        scr_draw_text_with_box("Reputation with Green Army increased by 50", false);
    }), __debug_menu_action("+50 rep Crimson Corp.", function()
    {
        faction_add_rep("Player", "Crimson Corporation", 50);
        scr_draw_text_with_box("Reputation with Crimson Corporation increased by 50", false);
    }), __debug_menu_action("+1000 XP", function()
    {
        global.xp += 1000;
    }), __debug_menu_action("-100 XP", function()
    {
        global.xp -= 100;
    }), __debug_menu_action("+1 skill point", function()
    {
        global.skill_points++;
    }), __debug_menu_action("+10 survive XP", function()
    {
        global.xp_survive += 10;
    }), __debug_menu_with_key(__debug_menu_action("+1 hour", function()
    {
        time_increment_hours(1);
        weather_particle_array_clear();
    }), "T+Right", 39, false, false, 84), __debug_menu_action("Change weather", function()
    {
        if (!__debug_menu_raid_only())
        {
            exit;
        }
        var _map = from_map_enum_to_map_macro(obj_map_generator.area);
        var _weather = weather_choose_new_weather(_map);
        for (var i = 0; i < array_length(global.weather.map); i++)
        {
            global.weather.map[i].weather_type[0] = _weather;
        }
        weather_particle_array_clear();
        weather_transition(1, false);
    }), __debug_menu_action("Call airdrop", function()
    {
        if (!__debug_menu_raid_only())
        {
            exit;
        }
        obj_controller.alarm[3] = 1;
    }), __debug_menu_action("Start emission", function()
    {
        if (!__debug_menu_raid_only())
        {
            exit;
        }
        if (global.state_emission_now == UnknownEnum.Value_0)
        {
            obj_meteo_controller.alarm[1] = 1;
            scr_draw_text_with_box("Emission started");
        }
    }), __debug_menu_action("+2 pistol exp", __debug_menu_add_weapon_exp, "pistol_exp"), __debug_menu_action("+2 SMG exp", __debug_menu_add_weapon_exp, "smg_exp"), __debug_menu_action("+2 shotgun exp", __debug_menu_add_weapon_exp, "shotgun_exp"), __debug_menu_action("+2 rifle exp", __debug_menu_add_weapon_exp, "rifle_exp"), __debug_menu_action("+2 DMR exp", __debug_menu_add_weapon_exp, "dmr_exp"), __debug_menu_action("+2 sniper exp", __debug_menu_add_weapon_exp, "sniper_exp"), __debug_menu_action("All weapon exp: zero", __debug_menu_set_all_weapon_exp, 0), __debug_menu_action("All weapon exp: half", __debug_menu_set_all_weapon_exp, 0.5), __debug_menu_action("All weapon exp: max", __debug_menu_set_all_weapon_exp, 1), __debug_menu_action("Save missing translations", __debug_menu_save_missing_translations), __debug_menu_key("Spawn dummy at cursor", "Ctrl+F3", 114, true, function()
    {
        instance_create_depth(obj_cursor.aa_x, obj_cursor.aa_y, 0, obj_dummy);
    }), __debug_menu_key("Teleport to cursor", "Ctrl+F4", 115, true, function()
    {
        x = obj_cursor.aa_x;
        y = obj_cursor.aa_y;
    }), __debug_menu_key("Item spawner", "Ctrl+F5", 116, true, function()
    {
        __uiGlobal().__defaultOnion.LayerAddTop("ZS_vanilla/ui/debug_spawner.ui", "debug layer");
        player_set_local_state(scr_player_state_item_spawn);
        ui_debug_spawner_populate(uiGetData().debug_spawner_category, 0);
    }), __debug_menu_key("Spawn enemy loner at cursor", "Ctrl+F8", 119, true, function()
    {
        if (is_in_raid() || is_in_test_room())
        {
            instance_create_depth(obj_cursor.aa_x, obj_cursor.aa_y, 0, obj_loner_enemy2);
        }
    }), __debug_menu_key("Spawn Hunter master", "F10", 121, false, function()
    {
        npc_spawn_near_player(obj_hunter_preset_master, 1, true);
    }), __debug_menu_key("Free camera", "Ctrl+F10", 121, true, function()
    {
        if (player_local_state_is(scr_player_state_move))
        {
            player_set_local_state(scr_player_state_free_camera);
            visible = false;
        }
        else if (player_local_state_is(scr_player_state_free_camera))
        {
            player_set_local_state(scr_player_state_move);
            visible = true;
        }
        else
        {
            scr_draw_text_with_box("Cannot use free camera when the player is busy");
        }
    }), __debug_menu_info("This menu", "F1"), __debug_menu_info("FPS overlay", "F11"), __debug_menu_info("Debug mode off", "Ctrl+Alt+P"), __debug_menu_info("Skill factors", "Hold F2"), __debug_menu_info("Skill levels", "Hold F3"), __debug_menu_info("Map generation timers", "Hold Numpad 1"), __debug_menu_info("Movement grid", "Hold I"), __debug_menu_info("AI inspector (AI labels on)", "Alt on NPC")];
    return _entries;
}

function __debug_menu_raid_only()
{
    if (is_in_raid())
    {
        return true;
    }
    scr_draw_text_with_box("DEBUG: only works in a raid", false);
    return false;
}

function __debug_menu_add_weapon_exp(arg0)
{
    stat_add_value(arg0.run_value, 2);
    skills_update_masteries();
    scr_save_stat();
}

function __debug_menu_set_all_weapon_exp(arg0)
{
    var _rank_totals = global.skills_masteries_data.exp_rank.total;
    var _exp = _rank_totals[array_length(_rank_totals) - 1] * arg0.run_value;
    var _weapon_stats = ["pistol_exp", "smg_exp", "shotgun_exp", "rifle_exp", "dmr_exp", "sniper_exp"];
    for (var i = 0; i < array_length(_weapon_stats); i++)
    {
        stat_set_value(_weapon_stats[i], _exp);
    }
    skills_update_masteries();
    scr_save_stat();
}

function __debug_menu_save_missing_translations()
{
    var _buffer = buffer_create(8, buffer_grow, 1);
    var _text = "";
    var _keys = variable_struct_get_names(global.language_tracking);
    for (var i = 0; i < array_length(_keys); i++)
    {
        if (string_pos("_", string(_keys[i])) != 1)
        {
            _text = _text + string(string_replace_all(_keys[i], "\n", "\\n")) + "\n";
        }
    }
    buffer_write(_buffer, buffer_text, _text);
    buffer_save(_buffer, "Missing_Translations.txt");
    buffer_delete(_buffer);
    scr_draw_text_with_box("DEBUG: saved Missing_Translations.txt", false);
}

function debug_menu_entry_is_on(arg0)
{
    if (arg0.kind != "toggle")
    {
        return false;
    }
    if (!variable_global_exists(arg0.global_name))
    {
        return arg0.default_on;
    }
    return variable_global_get(arg0.global_name);
}

function debug_menu_entry_set_on(arg0, arg1)
{
    if (arg0.kind != "toggle")
    {
        exit;
    }
    variable_global_set(arg0.global_name, arg1);
    if (!is_undefined(arg0.on_change))
    {
        var _on_change = arg0.on_change;
        _on_change(arg1);
    }
}

function debug_menu_entry_run(arg0)
{
    if (arg0.kind == "toggle")
    {
        debug_menu_entry_set_on(arg0, !debug_menu_entry_is_on(arg0));
        exit;
    }
    if (is_undefined(arg0.run) || !player_exists_local())
    {
        exit;
    }
    var _run = arg0.run;
    with (player_get_local())
    {
        _run(arg0);
    }
}

function debug_menu_entry_key_pressed(arg0)
{
    if (is_undefined(arg0.key))
    {
        return false;
    }
    if (!is_undefined(arg0.hold_key) && !keyboard_check(arg0.hold_key))
    {
        return false;
    }
    return keyboard_check_pressed(arg0.key) && keyboard_check(vk_control) == arg0.ctrl && keyboard_check(vk_alt) == arg0.alt;
}

function debug_menu_handle_keys()
{
    if (keyboard_check_pressed(vk_f1))
    {
        if (debug_menu_is_open())
        {
            debug_menu_close();
        }
        else
        {
            debug_menu_open();
        }
        exit;
    }
    if (debug_menu_is_open())
    {
        exit;
    }
    var _entries = debug_menu_entries();
    for (var i = 0; i < array_length(_entries); i++)
    {
        var _entry = _entries[i];
        if (!debug_menu_entry_key_pressed(_entry))
        {
            continue;
        }
        debug_menu_entry_run(_entry);
        if (_entry.kind == "toggle")
        {
            scr_draw_text_with_box("DEBUG " + _entry.label + ": " + (debug_menu_entry_is_on(_entry) ? "ON" : "OFF"), false);
        }
    }
}

function debug_menu_reset_flags()
{
    var _entries = debug_menu_entries();
    for (var i = 0; i < array_length(_entries); i++)
    {
        var _entry = _entries[i];
        if (_entry.kind == "toggle" && debug_menu_entry_is_on(_entry) != _entry.default_on)
        {
            debug_menu_entry_set_on(_entry, _entry.default_on);
        }
    }
}

function debug_menu_is_open()
{
    return __uiGlobal().__defaultOnion.LayerExists("debug menu layer");
}

function debug_menu_open()
{
    if (debug_menu_is_open())
    {
        exit;
    }
    if (!player_exists_local() || !player_local_state_is(scr_player_state_move))
    {
        scr_draw_text_with_box("Cannot open the debug menu when the player is busy", false);
        exit;
    }
    __uiGlobal().__defaultOnion.LayerAddTop("ZS_vanilla/ui/debug_menu.ui", "debug menu layer");
    player_set_local_state(scr_player_state_item_spawn);
}

function debug_menu_close()
{
    if (!debug_menu_is_open())
    {
        exit;
    }
    __uiGlobal().__defaultOnion.LayerDelete("debug menu layer");
    if (player_exists_local() && player_local_state_is(scr_player_state_item_spawn))
    {
        player_set_local_state(scr_player_state_move);
    }
}

function debug_menu_ui_entries(arg0)
{
    var _entries = debug_menu_entries();
    var _indexes = [];
    for (var i = 0; i < array_length(_entries); i++)
    {
        var _kind = _entries[i].kind;
        if (_kind == arg0 || (arg0 == "key" && _kind == "info"))
        {
            array_push(_indexes, i);
        }
    }
    return _indexes;
}

function debug_menu_ui_label(arg0)
{
    var _entries = debug_menu_entries();
    return _entries[arg0].label;
}

function debug_menu_ui_keys(arg0)
{
    var _entries = debug_menu_entries();
    return _entries[arg0].keys;
}

function debug_menu_ui_is_on(arg0)
{
    var _entries = debug_menu_entries();
    return debug_menu_entry_is_on(_entries[arg0]);
}

function debug_menu_ui_click(arg0)
{
    var _entries = debug_menu_entries();
    debug_menu_entry_run(_entries[arg0]);
}

enum UnknownEnum
{
    Value_0
}
