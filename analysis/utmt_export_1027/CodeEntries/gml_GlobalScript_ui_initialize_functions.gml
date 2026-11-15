global.Ui_Equipment_Selected = "";
global.Ui_TraderPage_Selected = 0;

function ui_initialize_functions()
{
    uiAddFunction("Min", function(arg0, arg1)
    {
        return min(arg0, arg1);
    });
    uiAddFunction("Max", function(arg0, arg1)
    {
        return max(arg0, arg1);
    });
    uiAddFunction("Clamp", function(arg0, arg1, arg2)
    {
        return clamp(arg0, arg1, arg2);
    });
    uiAddFunction("Lerp", function(arg0, arg1, arg2)
    {
        return lerp(arg0, arg1, arg2);
    });
    uiAddFunction("Clamp", function(arg0, arg1, arg2)
    {
        return clamp(arg0, arg1, arg2);
    });
    uiAddFunction("Lerp", function(arg0, arg1, arg2)
    {
        return lerp(arg0, arg1, arg2);
    });
    uiAddFunction("DrawSprite", function(arg0, arg1, arg2, arg3)
    {
        draw_sprite(arg0, arg1, arg2, arg3);
    });
    uiAddFunction("DrawSpriteExt", function(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    {
        draw_sprite_ext(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
    });
    uiAddFunction("DrawSpriteStretched", function(arg0, arg1, arg2, arg3, arg4, arg5)
    {
        draw_sprite_stretched(arg0, arg1, arg2, arg3, arg4, arg5);
    });
    uiAddFunction("DrawSpriteStretchedExt", function(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    {
        draw_sprite_stretched_ext(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
    });
    uiAddFunction("EndGameCreditsActive", function()
    {
        return uiGetData().end_game_credits_active;
    });
    uiAddFunction("EndGameCreditsComplete", function()
    {
        uiGetData().end_game_credits_finish_requested = true;
    });
    uiAddNativeFunction(floor, "Floor");
    uiAddNativeFunction(ceil, "Ceil");
    uiAddNativeFunction(round, "Round");
    uiAddNativeFunction(abs, "Abs");
    uiAddNativeFunction(sign, "Sign");
    uiAddNativeFunction(string, "String");
    uiAddNativeFunction(string_format, "StringFormat");
    uiAddNativeFunction(string_replace_all, "StringReplaceAll");
    uiAddNativeFunction(is_struct, "IsStruct");
    uiAddNativeFunction(is_array, "IsArray");
    uiAddNativeFunction(is_string, "IsString");
    uiAddNativeFunction(is_numeric, "IsNumeric");
    uiAddNativeFunction(array_length, "ArrayLength");
    uiAddNativeFunction(array_sort, "ArraySort");
    uiAddNativeFunction(array_push, "ArrayPush");
    uiAddNativeFunction(array_pop, "ArrayPop");
    uiAddNativeFunction(array_insert, "ArrayInsert");
    uiAddNativeFunction(array_delete, "ArrayDelete");
    uiAddNativeFunction(draw_rectangle, "DrawRectangle");
    uiAddNativeFunction(draw_circle, "DrawCircle");
    uiAddNativeFunction(draw_text, "DrawText");
    uiAddNativeFunction(draw_text_ext, "DrawTextExt");
    uiAddNativeFunction(file_exists, "FileExists");
    uiAddNativeFunction(string_width, "StringWidth");
    uiCatspeakGetEnvironment().addGlobalFunction("HasEyeForValueSkill", function()
    {
        return skill_hunter_obtained("eyeforvalue");
    }, "DrawSetFontLanguage", draw_set_font_language, "LanguageResolveFont", language_resolve_font, "EquipmentGetName", function(arg0)
    {
        return struct_get_from_hash(variable_struct_get(global.loadout_data, arg0), variable_get_hash("name"));
    });
    uiCatspeakGetEnvironment().addGlobalFunction("EquipmentNameSelected", function()
    {
        return global.Ui_Equipment_Selected;
    }, "EquipmentNameSet", function(arg0)
    {
        global.Ui_Equipment_Selected = arg0;
    }, "NewsGetRecent", function()
    {
        with (obj_news)
        {
            return news_get_recent();
        }
        return [];
    }, "ShowMessage", function(arg0)
    {
        show_message(arg0);
    });
    uiCatspeakGetEnvironment().addGlobalFunction("ModsFailedToCompile", function()
    {
        return global.Mods_Failed_To_Compile;
    }, "DateTimeString", function(arg0)
    {
        var _date = date_create_datetime(1970, 1, 1, 0, 0, arg0);
        var _str = string(date_get_day(_date)) + "/" + string(date_get_month(_date)) + "/" + string(date_get_year(_date));
        return _str;
    }, "StringNewsCleanup", string_news_cleanup, "HunterSkillGetNameFromId", function(arg0)
    {
        return variable_struct_get(global.skills_hunter_data, arg0).name;
    });
    uiCatspeakGetEnvironment().addGlobalFunction("HunterSkillGetNameFromId", function(arg0)
    {
        return variable_struct_get(global.skills_hunter_data, arg0).name;
    }, "HunterSkillGetDescFromId", function(arg0)
    {
        return variable_struct_get(global.skills_hunter_data, arg0).desc;
    }, "HunterSkillGetTypeColor", function(arg0)
    {
        switch (variable_struct_get(global.skills_hunter_data, arg0).type)
        {
            case "hunter":
                return 16777215;
                break;
            case "faction":
                return 3587261;
                break;
            case "level":
                return 3570109;
                break;
            case "special":
                return 12411702;
                break;
        }
    }, "HunterSkillGetIconsFromArray", function(arg0)
    {
        var _icon_array = [];
        for (var i = 0; i < array_length(arg0); i++)
        {
            array_push(_icon_array, variable_struct_get(global.skills_hunter_data, @@array_get@@(arg0, i)).icon);
        }
        return _icon_array;
    });
    uiCatspeakGetEnvironment().addGlobalFunction("HunterSkillSortSkillsByType", function(arg0)
    {
        var _array_hunter = [];
        var _array_faction = [];
        var _array_level = [];
        var _array_special = [];
        for (var i = 0; i < array_length(arg0); i++)
        {
            switch (variable_struct_get(global.skills_hunter_data, @@array_get@@(arg0, i)).type)
            {
                case "hunter":
                    array_push(_array_hunter, arg0[i]);
                    break;
                case "faction":
                    array_push(_array_faction, arg0[i]);
                    break;
                case "level":
                    array_push(_array_level, arg0[i]);
                    break;
                case "special":
                    array_push(_array_special, arg0[i]);
                    break;
            }
        }
        var _output_array = [];
        for (var i = 0; i < array_length(_array_hunter); i++)
        {
            array_push(_output_array, _array_hunter[i]);
        }
        for (var i = 0; i < array_length(_array_faction); i++)
        {
            array_push(_output_array, _array_faction[i]);
        }
        for (var i = 0; i < array_length(_array_level); i++)
        {
            array_push(_output_array, _array_level[i]);
        }
        for (var i = 0; i < array_length(_array_special); i++)
        {
            array_push(_output_array, _array_special[i]);
        }
        return _output_array;
    }, "HunterSkillsGetAll", function()
    {
        return global.skills_hunter_data_array;
    }, "HunterSkillsGetAllAssigned", function()
    {
        var _skills_assigned = [];
        with (player_get_local())
        {
            for (var i = 0; i < array_length(global.skills_hunter_data_array); i++)
            {
                if (skills_hunter.get_value(global.skills_hunter_data_array[i]) > 0)
                {
                    array_push(_skills_assigned, global.skills_hunter_data_array[i]);
                }
            }
        }
        return _skills_assigned;
    }, "HunterSkillsGetAllAssignedIcons", function()
    {
        var _icons = [];
        with (player_get_local())
        {
            for (var i = 0; i < array_length(global.skills_hunter_data_array); i++)
            {
                if (skills_hunter.get_value(global.skills_hunter_data_array[i]) > 0)
                {
                    array_push(_icons, variable_struct_get(global.skills_hunter_data, global.skills_hunter_data_array[i]).icon);
                }
            }
        }
        return _icons;
    });
    uiCatspeakGetEnvironment().addGlobalFunction("HunterSkillsReset", function()
    {
        with (player_get_local())
        {
            var _skills_to_keep = [];
            for (var i = 0; i < array_length(global.skills_hunter_data_array); i++)
            {
                if (skills_hunter.get_value(global.skills_hunter_data_array[i]) > 0)
                {
                    if (variable_struct_get(global.skills_hunter_data, global.skills_hunter_data_array[i]).group < 0)
                    {
                        array_push(_skills_to_keep, global.skills_hunter_data_array[i]);
                    }
                }
            }
            skills_hunter.reset_skills();
            for (var i = 0; i < array_length(_skills_to_keep); i++)
            {
                skills_hunter.set(_skills_to_keep[i], true);
            }
        }
    }, "HunterSkillsGetAllInGroup", function(arg0 = 0)
    {
        return global.skills_hunter_groups[arg0];
    }, "HunterSkillsGetAllIconsInGroup", function(arg0 = 0)
    {
        var _icons = [];
        for (var i = 0; i < array_length(global.skills_hunter_groups[arg0]); i++)
        {
            array_push(_icons, variable_struct_get(global.skills_hunter_data, global.skills_hunter_groups[arg0][i]).icon);
        }
        return _icons;
    }, "HunterSkillsGetAssigned", function(arg0)
    {
        with (player_get_local())
        {
            return skills_hunter.get_value(arg0) > 0;
        }
        return false;
    });
    uiCatspeakGetEnvironment().addGlobalFunction("HunterSkillsGetAllIcons", function()
    {
        var _icons = [];
        for (var i = 0; i < array_length(global.skills_hunter_data_array); i++)
        {
            array_push(_icons, variable_struct_get(global.skills_hunter_data, global.skills_hunter_data_array[i]).icon);
        }
        return _icons;
    }, "HunterSkillsGetPerkPointsAvailable", skill_hunter_get_points, "HunterSkillsGetPerkPointsUsed", function()
    {
        var _total_points = 0;
        with (player_get_local())
        {
            for (var i = 0; i < array_length(global.skills_hunter_data_array); i++)
            {
                if (skills_hunter.get_value(global.skills_hunter_data_array[i]) > 0 && variable_struct_get(global.skills_hunter_data, global.skills_hunter_data_array[i]).group > -1)
                {
                    _total_points++;
                }
            }
        }
        return _total_points;
    }, "HunterSkillsGetPerkPointsGroupCurrent", skill_hunter_get_group_current);
    uiCatspeakGetEnvironment().addGlobalFunction("HunterSkillsAssignSkill", skill_hunter_buy, "HunterSkillsEnabled", function()
    {
        return true;
    }, "IsDebug", function()
    {
        return global.general_debug;
    }, "Log", function(arg0)
    {
        show_debug_message(string(current_time) + ": " + string(arg0));
    });
    uiCatspeakGetEnvironment().addGlobalFunction("Translate", language_get_string, "LanguageSet", language_set_new_language, "SpriteGetNumber", sprite_get_number, "StringDecimal", function(arg0)
    {
        return string_format(arg0, 1, 2);
    });
    uiCatspeakGetEnvironment().addGlobalFunction("StringReplace", function(arg0, arg1, arg2)
    {
        return string_replace(arg0, arg1, arg2);
    }, "StringPos", function(arg0, arg1)
    {
        return string_pos(arg0, arg1);
    }, "String3DP", function(arg0)
    {
        return string_format(arg0, 1, 3);
    }, "StringMinutesTo24hrClock", function(arg0)
    {
        arg0 = round(arg0 % 3600);
        var _hours = arg0 div 60;
        var _minutes = arg0 % 60;
        _hours = _hours % 24;
        var _hour_string = ((_hours < 10) ? "0" : "") + string(_hours);
        var _minute_string = ((_minutes < 10) ? "0" : "") + string(_minutes);
        return _hour_string + ":" + _minute_string;
    });
    uiCatspeakGetEnvironment().addGlobalFunction("HexToDec", function(arg0)
    {
        return real("0x" + arg0);
    }, "GetPlaytimeDayMinutes", function()
    {
        return (60 * time_get_hours()) + time_get_minutes();
    }, "skill_gun_get_points", skill_gun_get_points, "skill_hunter_get_points", skill_hunter_get_points);
    uiCatspeakGetEnvironment().addGlobalFunction("StartupHangTryAgain", startup_hang_try_again, "GameResume", saveslot_resume, "GameLoad", saveslot_load, "GameEnd", game_end);
    uiCatspeakGetEnvironment().addGlobalFunction("GameNew", saveslot_new, "ZS2ExitRequest", zs2_exit_request, "ZS2ExitAction", zs2_exit_action, "ZS2ExitAssets", zs2_exit_assets);
    uiCatspeakGetEnvironment().addGlobalFunction("ExitSurveyAction", exit_survey_action, "GameInRaid", is_in_raid, "IsMainMenu", function()
    {
        return room == r_menu;
    }, "IsInRaid", is_in_raid);
    uiCatspeakGetEnvironment().addGlobalFunction("IsInHub", is_in_hub, "IsInHubOrInRaid", is_in_hub_or_in_raid, "SaveSlotAssign", saveslot_assign, "GameInFocus", game_in_focus);
    uiCatspeakGetEnvironment().addGlobalFunction("AudioPlay", function(arg0)
    {
        if (is_string(arg0) && __uiGlobal().__debug.__relaxedSprites)
        {
            arg0 = asset_get_index(arg0);
        }
        audio_play_sound(arg0, 10, false);
    }, "PopUpMessage", scr_draw_text_with_box, "KeyboardCheckPressed", keyboard_check_pressed_ui, "OnGamepad", function()
    {
        return !obj_gamepad.last_input_keyboard;
    });
    uiCatspeakGetEnvironment().addGlobalFunction("SaveslotGetTime", saveslot_get_time, "UrlOpen", url_open, "Unpause", game_unpause, "ExitToMainMenu", exit_to_main_menu);
    uiCatspeakGetEnvironment().addGlobalFunction("CloudEnabled", db_cloud_enabled, "CloudSavesAvailable", function()
    {
        return db_cloud_enabled() && room == r_menu;
    }, "CloudWipe", saveslot_delete_cloud, "CloudResolve", function(arg0)
    {
        if (arg0 != "delete" && arg0 != "keep")
        {
            trace_error("Cloud resolution \"", arg0, "\" not supported");
            exit;
        }
        if (!__uiGlobal().__defaultOnion.LayerExists("cloud conflict"))
        {
            trace("Cannot resolve cloud conflict right now");
            exit;
        }
        if (global.database_cloud_conflict == 0)
        {
            trace("No conflict to resolve");
            exit;
        }
        trace("Cloud conflict resolution is \"", arg0, "\"");
        global.database_cloud_conflict = 0;
        db_open("local settings");
        db_write("cloud", "using_cloud", db_cloud_enabled());
        db_close();
        db_cloud_sync_all((arg0 == "delete") ? 1 : 2);
        db_cloud_sync_step();
    });
    uiCatspeakGetEnvironment().addGlobalFunction("LoadoutGenerate", loadout_generate_loot, "GetVersionString", function()
    {
        return concat(1, ".", 4, ".", 13);
    }, "GetFullVersionString", ui_full_version_string, "PlatformStoreUrlZs2Available", function()
    {
        return platform_store_url_zs2() != "";
    }, "PlatformUgcAvailable", function()
    {
        return platform_ugc_available();
    }, "PlatformNewsAvailable", function()
    {
        return platform_news_available();
    }, "CanGoToMap", can_go_to_map);
    uiCatspeakGetEnvironment().addGlobalFunction("InventoryStashChangePage", ui_stash_populate, "InventoryStashUnlocked", ui_stash_unlocked, "InventoryClose", ui_inventory_close_all, "InventoryTraderOpen", player_action_open_trader);
    uiCatspeakGetEnvironment().addGlobalFunction("InventoryTraderChangePage", function(arg0)
    {
        ui_trader_populate(uiGetData().trader_target, arg0);
    }, "InventoryTraderCalculateDealValue", ui_trader_calculate_deal_value, "InventoryTraderDoDeal", ui_trader_do_deal, "InventoryTraderSetPageIndex", function(arg0)
    {
        global.Ui_TraderPage_Selected = arg0;
    });
    uiCatspeakGetEnvironment().addGlobalFunction("InventoryTraderGetPageIndex", function()
    {
        return global.Ui_TraderPage_Selected;
    }, "InventorySort", ui_inventory_sort, "StashGetTotalOfAnItem", stash_get_total_of_item, "ItemExists", item_exists);
    uiCatspeakGetEnvironment().addGlobalFunction("ItemDraw", item_draw, "ItemSetTrackingMaterials", item_set_tracking_materials, "ItemGetTrackingMaterials", item_get_tracking_materials, "ItemIsTrackedMaterial", item_is_tracked_material);
    uiCatspeakGetEnvironment().addGlobalFunction("ItemIsTracked", item_is_tracked, "ItemTrackedGetArrayLength", item_tracked_get_array_length, "ItemTrackedGetArray", item_tracked_get_array, "ItemTrackedGetTrackType", item_tracked_get_track_type);
    uiCatspeakGetEnvironment().addGlobalFunction("ItemTrackedGetTrackReqAmount", item_tracked_get_track_req_amount, "ItemTrackedGetTrackQuestID", item_tracked_get_track_quest_id, "ItemTrackedGetTrackCraftItem", item_tracked_get_track_craft_item, "StashGetName", stash_get_name);
    uiCatspeakGetEnvironment().addGlobalFunction("StashGetSprite", stash_get_sprite, "StashGetSpriteDatabase", stash_get_sprite_database, "StashGetSpriteMax", stash_get_sprite_max, "StashLoad", stash_load);
    uiCatspeakGetEnvironment().addGlobalFunction("StashSave", stash_save, "StashSpriteSync", stash_sprite_sync, "StashGetSpriteIndex", stash_get_sprite_index, "StashSpriteSet", stash_sprite_set);
    uiCatspeakGetEnvironment().addGlobalFunction("PlayerGetWeight", function()
    {
        if (!player_exists_local())
        {
            return 0;
        }
        return player_get_local().player_weight;
    }, "PlayerGetMaxWeight", function()
    {
        if (!player_exists_local())
        {
            return 0;
        }
        return player_get_local().max_weight;
    }, "PlayerGetExtremeWeight", function()
    {
        if (!player_exists_local())
        {
            return 0;
        }
        return player_get_local().max_weight + 5;
    }, "PlayerGetMoney", function()
    {
        return global.player_money;
    });
    uiCatspeakGetEnvironment().addGlobalFunction("PlayerGetFatigueString", function()
    {
        var _player = player_get_local();
        if (!instance_exists(_player))
        {
            return "";
        }
        return string(round(_player.fatigue)) + "/" + string(_player.fatigue_start) + "  (" + language_get_string(global.status_des[UnknownEnum.Value_0][global.status_state_now[UnknownEnum.Value_0]]) + ")";
    }, "PlayerGetHungerString", function()
    {
        var _player = player_get_local();
        if (!instance_exists(_player))
        {
            return "";
        }
        return string(round(_player.energy)) + "/" + "100" + "  (" + language_get_string(global.status_des[UnknownEnum.Value_1][global.status_state_now[UnknownEnum.Value_1]]) + ")";
    }, "PlayerGetThirstString", function()
    {
        var _player = player_get_local();
        if (!instance_exists(_player))
        {
            return "";
        }
        return string(round(_player.thirst)) + "/" + "100" + "  (" + language_get_string(global.status_des[UnknownEnum.Value_2][global.status_state_now[UnknownEnum.Value_2]]) + ")";
    }, "PlayerGetRadiationString", function()
    {
        var _player = player_get_local();
        if (!instance_exists(_player))
        {
            return "";
        }
        return string(_player.radiation_accumulata) + "  (" + language_get_string(global.status_des[UnknownEnum.Value_3][global.status_state_now[UnknownEnum.Value_3]]) + ")";
    });
    uiCatspeakGetEnvironment().addGlobalFunction("PlayerGetFatigueColor", function()
    {
        return global.status_color[global.status_state_now[UnknownEnum.Value_0]];
    }, "PlayerGetHungerColor", function()
    {
        return global.status_color[global.status_state_now[UnknownEnum.Value_1]];
    }, "PlayerGetThirstColor", function()
    {
        return global.status_color[global.status_state_now[UnknownEnum.Value_2]];
    }, "PlayerGetRadiationColor", function()
    {
        return global.status_color[global.status_state_now[UnknownEnum.Value_3]];
    });
    uiCatspeakGetEnvironment().addGlobalFunction("PlayerGetBonusStatusesString", function()
    {
        var _string = "";
        for (var i = 0; i < ds_list_size(global.list_status_id); i++)
        {
            var _status = ds_list_find_value(global.list_status_id, i);
            if (_status == UnknownEnum.Value_3)
            {
                continue;
            }
            var _amount = global.status_f1[_status][global.status_state_now[_status]];
            if (_amount < 0)
            {
                _amount *= global.sk_k[UnknownEnum.Value_73];
            }
            else
            {
                _amount *= global.sk_k[UnknownEnum.Value_72];
            }
            if (_amount == 0)
            {
                continue;
            }
            var _line_string = "";
            switch (_status)
            {
                case UnknownEnum.Value_0:
                    _line_string = ((_amount > 0) ? "+" : "") + string(round(_amount * 100)) + "% " + language_get_string("player.status.stamina_regeneration");
                    break;
                case UnknownEnum.Value_1:
                    _line_string = ((_amount > 0) ? "+" : "") + string(_amount) + "kg " + language_get_string("player.status.max_weight");
                    break;
                case UnknownEnum.Value_2:
                    _line_string = ((_amount > 0) ? "+" : "") + string(round(_amount * 100)) + "% " + language_get_string("modules_description.looting_speed");
                    break;
            }
            _string += (_line_string + "\n\n");
        }
        return _string;
    }, "PlayerRecalculateWeight", ui_inventory_check_weight, "GetMinutesToRestoreFatigue", function()
    {
        var _player = player_get_local();
        if (!instance_exists(_player))
        {
            return infinity;
        }
        return (_player.fatigue_start - _player.fatigue) / 0.27;
    }, "DebugSpawnerGetCategoryNames", debug_spawner_get_category_names);
    uiCatspeakGetEnvironment().addGlobalFunction("DebugMenuEntries", debug_menu_ui_entries, "DebugMenuLabel", debug_menu_ui_label, "DebugMenuKeys", debug_menu_ui_keys, "DebugMenuIsOn", debug_menu_ui_is_on, "DebugMenuClick", debug_menu_ui_click, "DebugMenuClose", debug_menu_close);
    uiCatspeakGetEnvironment().addGlobalFunction("DebugSpawnerPopulate", ui_debug_spawner_populate, "TraderGetMoney", function()
    {
        if (is_in_hub())
        {
            return global.trader_money_all;
        }
        else
        {
            return uiGetData().trader_target.money_trader;
        }
    }, "TraderPagesGetCount", trader_pages_get_count, "TraderPagesGetAlias", trader_pages_get_alias);
    uiCatspeakGetEnvironment().addGlobalFunction("TraderPagesGetSprite", trader_pages_get_sprite, "TraderPagesGetImage", trader_pages_get_image, "TraderPagesGetTitle", trader_pages_get_title, "UiTraderPagesHasItem", ui_trader_page_has_item);
    uiCatspeakGetEnvironment().addGlobalFunction("CraftingGetModes", crafting_get_modes, "CraftingModeGetName", crafting_mode_get_name, "CraftingPopulate", ui_crafting_populate, "Craft", function()
    {
        return crafting_mode_execute(uiGetData().crafting_mode, uiGetData().crafting_loot);
    });
    uiCatspeakGetEnvironment().addGlobalFunction("CraftRequiredSkillName", craft_required_skill_name, "CraftRequiredSkillLevel", craft_required_skill_level, "CraftRequiredBaseModuleName", craft_required_module_name, "CraftRequiredBaseModuleLevel", craft_required_module_level);
    uiCatspeakGetEnvironment().addGlobalFunction("ModdingGetPositions", modding_get_positions, "ModPositionGetName", mod_pos_get_name, "ModdingPopulate", ui_modding_populate, "ModdingUpdateTooltip", modding_update_tooltip);
    uiCatspeakGetEnvironment().addGlobalFunction("TeleportTo", teleport_to, "TeleportAllowed", teleport_allowed, "Sleep", function(arg0)
    {
        var _instance = instance_create_depth(0, 0, 0, obj_sleep_fade);
        _instance.minutes = arg0;
    }, "PlayerStateSetMove", function()
    {
        player_set_local_state(scr_player_state_move);
    });
    uiCatspeakGetEnvironment().addGlobalFunction("PlayerActionOpenInventory", player_action_open_inventory, "PlayerActionOpenMinimap", player_action_open_minimap, "SettingsSet", settings_set, "SettingsGet", settings_get);
    uiCatspeakGetEnvironment().addGlobalFunction("SettingsGetMin", settings_get_min, "SettingsGetMax", settings_get_max, "SettingsSetWriteToDisk", settings_set_write_to_disk, "SettingsGetType", settings_get_type);
    uiCatspeakGetEnvironment().addGlobalFunction("SettingsGetDescription", settings_get_description, "GetBindingName", function(arg0)
    {
        return scr_key_map(global.kb_now[arg0]);
    }, "KeybindStart", keybind_start, "KeybindResetToDefaults", keybind_reset_to_defaults);
    uiCatspeakGetEnvironment().addGlobalFunction("SeenGameAnalyticsModal", function()
    {
        db_open("shared settings");
        db_write("Game analytics", "pop_up", false);
        db_close();
    }, "SetupLootLocker", function()
    {
        scr_setup_lootlocker();
    }, "DifficultySet", difficulty_set, "DifficultyGet", difficulty_get);
    uiCatspeakGetEnvironment().addGlobalFunction("DifficultyResetAll", difficulty_reset_all, "DifficultyCustomSelected", function(arg0)
    {
        uiGetData().difficulty_custom_selected = arg0;
    }, "DifficultyGetType", difficulty_get_type, "DifficultyGetMin", difficulty_get_min);
    uiCatspeakGetEnvironment().addGlobalFunction("DifficultyGetMax", difficulty_get_max, "DifficultyGetDescription", difficulty_get_description, "DifficultySave", difficulty_sandbox_save);
    uiCatspeakGetEnvironment().addGlobalFunction("DifficultyGetIncrement", difficulty_get_increment, "DifficultyValueString", difficulty_get_value_string, "NpcBarkGet", npc_bark_get, "NpcBarkSet", npc_bark_set, "StatGetCount", stat_count);
    uiCatspeakGetEnvironment().addGlobalFunction("StatGetID", stat_get_id, "StatGetName", stat_get_name, "StatGetValue", stat_get_value, "FactionGetName", faction_get_name);
    uiCatspeakGetEnvironment().addGlobalFunction("FactionGetReputation", function(arg0)
    {
        return faction_get_rep("Player", arg0);
    }, "FactionJoin", faction_join, "ExperienceGet", experience_get, "ExperienceGetLevel", experience_get_level);
    uiCatspeakGetEnvironment().addGlobalFunction("ExperienceGetName", experience_get_name, "ExperienceGetForLevel", experience_get_for_level, "SkillGetName", skill_get_name, "SkillGetDescriptionA", skill_get_description_a);
    uiCatspeakGetEnvironment().addGlobalFunction("SkillGetDescriptionB", skill_get_description_b, "SkillGetSpecialization", skill_get_specialization, "SkillCanSpecialize", skill_can_specialize, "SkillGetSpecializationCount", skill_get_specialization_count);
    uiCatspeakGetEnvironment().addGlobalFunction("SkillGetSpecializationSkill", skill_get_specialization_skill, "SkillSpecialize", skill_specialize, "MinimapGetCustomMarkerCount", minimap_get_custom_marker_count, "MinimapGetCustomMarkerX", minimap_get_custom_marker_x);
    uiCatspeakGetEnvironment().addGlobalFunction("MinimapGetCustomMarkerY", minimap_get_custom_marker_y, "MinimapGetCustomMarkerID", minimap_get_custom_marker_id, "MinimapAddCustomMarker", minimap_add_custom_marker, "MinimapRemoveCustomMarker", minimap_remove_custom_marker);
    uiCatspeakGetEnvironment().addGlobalFunction("MinimapGetExtractionMarkerCount", minimap_get_extraction_marker_count, "MinimapGetExtractionMarkerX", minimap_get_extraction_marker_x, "MinimapGetExtractionMarkerY", minimap_get_extraction_marker_y, "MinimapGetPlayerOnMap", minimap_get_player_on_map);
    uiCatspeakGetEnvironment().addGlobalFunction("MinimapGetPlayerX", minimap_get_player_x, "MinimapGetPlayerY", minimap_get_player_y, "MinimapGetInterestingMarkerCount", minimap_get_interesting_marker_count, "MinimapGetInterestingMarkerX", minimap_get_interesting_marker_x);
    uiCatspeakGetEnvironment().addGlobalFunction("MinimapGetInterestingMarkerY", minimap_get_interesting_marker_y, "MinimapGetInterestingMarkerText", minimap_get_interesting_marker_text, "MinimapGetQuestMarkerCount", minimap_get_quest_marker_count, "MinimapGetQuestMarkerX", minimap_get_quest_marker_x);
    uiCatspeakGetEnvironment().addGlobalFunction("MinimapGetQuestMarkerY", minimap_get_quest_marker_y, "MinimapGetQuestMarkerText", minimap_get_quest_marker_text, "UiFocusElement", function(arg0)
    {
        __uiHoverSet(uiCurrentRoot(), uiFindRelaxed(uiCurrentRoot(), arg0), false);
    }, "QuestLogGetCount", quest_log_get_count);
    uiCatspeakGetEnvironment().addGlobalFunction("QuestLogGetName", quest_log_get_name, "QuestLogGetID", quest_log_get_id, "QuestLogGetState", quest_log_get_state, "QuestLogGetDescription", quest_log_get_description);
    uiCatspeakGetEnvironment().addGlobalFunction("QuestLogGetObjective", quest_log_get_objective, "QuestLogGetFull", quest_log_get_full, "QuestLogGetGiverName", quest_log_get_giver_name, "QuestLogGetRemovable", quest_log_get_removable);
    uiCatspeakGetEnvironment().addGlobalFunction("QuestLogRemove", quest_log_remove, "QuestGetName", quest_get_name, "UiQuestBuildRewardsText", quest_build_rewards_text, "RadiationGetAmount", radiation_get_amount);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueGetName", npc_dialogue_get_name, "NPCDialogueGetGreeting", npc_dialogue_get_greeting, "NPCDialogueGetPromptCount", npc_dialogue_get_prompt_count, "NPCDialogueGetPrompt", npc_dialogue_get_prompt);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueGetPromptType", npc_dialogue_get_prompt_type, "NPCDialogueGetRepair", npc_dialogue_get_repair, "NPCDialogueGetQuestionCount", npc_dialogue_get_question_count, "NPCDialogueGetQuestion", npc_dialogue_get_question);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueGetAnswer", npc_dialogue_get_answer, "NPCDialogueGetAnswerUnique", npc_dialogue_get_answer_unique, "BaseInstall", base_install, "BaseUninstall", base_uninstall);
    uiCatspeakGetEnvironment().addGlobalFunction("BaseFindSlot", base_find_slot, "BaseGetModule", base_get_module, "BaseGetFree", base_get_free, "BaseGetOccupied", base_get_occupied);
    uiCatspeakGetEnvironment().addGlobalFunction("BaseModuleGetLevel", base_module_get_level, "BaseModuleGetName", base_module_get_name, "BaseModuleGetDescription", base_module_get_description, "BaseModuleGetDescriptionLevel", base_module_get_description_level);
    uiCatspeakGetEnvironment().addGlobalFunction("BaseModuleGetInstalled", base_module_get_installed, "BaseModuleGetSprite", base_module_get_sprite, "BaseModuleCount", base_module_count, "ugc_upload", ugc_upload);
    uiCatspeakGetEnvironment().addGlobalFunction("ugc_check_owner", ugc_check_owner, "ugc_pre_check", ugc_pre_check, "steam_ok", steam_ok, "NPCDialogueGetQuestCount", npc_dialogue_get_quest_count);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueGetQuestID", npc_dialogue_get_quest_id, "NPCDialogueGetQuestName", npc_dialogue_get_quest_name, "NPCDialogueGetQuestDescription", npc_dialogue_get_quest_description, "NPCDialogueGetQuestObjective", npc_dialogue_get_quest_objective);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueGetQuestFull", npc_dialogue_get_quest_full, "NPCDialogueGetQuestRewardsAsLoot", npc_dialogue_get_quest_rewards_as_loot, "NPCDialogueGetQuestState", npc_dialogue_get_quest_state, "NPCDialogueGetQuestStateCurrent", npc_dialogue_get_quest_state_current);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueGetQuestStateCurrentCompleted", npc_dialogue_get_quest_state_current_is_completed, "NPCDialogueGetQuestStateCurrentActive", npc_dialogue_get_quest_state_current_is_active, "NPCDialogueQuestAccept", npc_dialogue_quest_accept, "NPCDialogueQuestTurnIn", npc_dialogue_quest_turn_in);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueQuestPopulateTaskRewards", npc_dialogue_quest_populate_task_rewards, "NPCDialogueGetFoodPrice", npc_dialogue_get_food_price, "NPCDialogueFeed", npc_dialogue_feed, "NPCDialogueGetDrinkPrice", npc_dialogue_get_drink_price);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueDrink", npc_dialogue_drink, "NPCDialogueGetRepairPrice", npc_dialogue_get_repair_price, "NPCDialogueRepair", npc_dialogue_repair, "NPCDialogueGetHealHPPrice", npc_dialogue_get_heal_hp_price);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueHealHP", npc_dialogue_heal_hp, "NPCDialogueGetHealWoundPrice", npc_dialogue_get_heal_wound_price, "NPCDialogueHealWound", npc_dialogue_heal_wound, "NPCDialogueGetHealRadPrice", npc_dialogue_get_heal_rad_price);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueHealRad", npc_dialogue_heal_rad, "NPCDialogueFreeEquipment", npc_dialogue_free_equipment, "NPCDialogueMapGetName", npc_dialogue_map_get_name, "NPCDialogueMapGo", npc_dialogue_map_go);
    uiCatspeakGetEnvironment().addGlobalFunction("NPCDialogueMapIsUnlocked", npc_dialogue_map_is_unlocked, "NPCDialogueTrainSkinAplliable", get_train_skin_appliable, "NPCDialogueTrainSkinApply", train_skin_apply, "NPCDialogueTrainSkinSync", train_skin_sync);
    uiCatspeakGetEnvironment().addGlobalFunction("LootActionGetArray", loot_action_get_array, "LootActionExecute", loot_action_execute, "LootActionScrapNow", loot_action_scrap_now, "LootActionGetYOffset", loot_action_get_y_offset);
    uiCatspeakGetEnvironment().addGlobalFunction("LootDraw", loot_draw, "LootGetItem", loot_get_item, "LootGetName", loot_get_name, "LootGetDescription", loot_get_description);
    uiCatspeakGetEnvironment().addGlobalFunction("LootGetWeight", loot_get_weight, "LootGetValue", loot_get_value, "LootGetValuePerUnit", loot_get_value_per_unit, "LootGetValueSell", loot_get_value_sell);
    uiCatspeakGetEnvironment().addGlobalFunction("LootGetValueSellPerUnit", loot_get_value_sell_per_unit, "LootGetValueDiffMultiplier", loot_get_value_diff_multiplier, "LootGetValuePerUnitDiffMultiplier", loot_get_value_per_unit_diff_multiplier, "LootGetSeen", loot_get_seen);
    uiCatspeakGetEnvironment().addGlobalFunction("LootGetDurability", loot_get_durability, "LootGetCategory", loot_get_category, "LootIsTraders", loot_is_traders, "LootWeaponGetFireMode", loot_weapon_get_fire_mode);
    uiCatspeakGetEnvironment().addGlobalFunction("LootWeaponGetRateOfFire", loot_weapon_get_rate_of_fire, "LootWeaponGetFireModeName", loot_weapon_get_fire_mode_name, "LootWeaponGetMagazine", loot_weapon_get_magazine, "LootWeaponGetCaliber", loot_weapon_get_caliber);
    uiCatspeakGetEnvironment().addGlobalFunction("LootWeaponGetCaliberName", loot_weapon_get_caliber_name, "LootWeaponGetDamage", loot_weapon_get_damage, "LootWeaponGetAccuracy", loot_weapon_get_accuracy, "LootWeaponGetRecoil", loot_weapon_get_recoil);
    uiCatspeakGetEnvironment().addGlobalFunction("LootWeaponGetErgonomics", loot_weapon_get_ergonomics, "LootWeaponGetReloadTime", loot_weapon_get_reload_time, "LootWeaponGetModdable", loot_weapon_get_moddable, "LootWeaponGetModPosModdable", loot_weapon_get_position_moddable);
    uiCatspeakGetEnvironment().addGlobalFunction("LootWeaponGetMod", loot_weapon_get_mod, "LootWeaponGetType", loot_weapon_get_type, "LootWeaponModRemove", loot_weapon_mod_remove, "LootWeaponModAdd", loot_weapon_mod_add);
    uiCatspeakGetEnvironment().addGlobalFunction("LootArmorGetMelee", loot_armor_get_pierce, "LootArmorGetRadiation", loot_armor_get_radiation, "LootArmorGetAnomaly", loot_armor_get_anomaly, "LootArmorGetFirearm", loot_armor_get_firearm);
    uiCatspeakGetEnvironment().addGlobalFunction("LootArmorGetFragility", loot_armor_get_dur_damage, "LootArmorGetClass", loot_armor_get_class, "LootBackpackGetWeight", loot_backpack_get_weight, "LootBackpackGetMovementSpeed", loot_backpack_get_movement_speed);
    uiCatspeakGetEnvironment().addGlobalFunction("LootBackpackGetErgonomics", loot_backpack_get_ergonomic, "LootAmmoGetPenetration", loot_ammo_get_pen, "LootAmmoGetDamageBoost", loot_ammo_get_damage, "LootAmmoGetAccuracyBoost", loot_ammo_get_acc);
    uiCatspeakGetEnvironment().addGlobalFunction("LootAmmoGetRecoilBoost", loot_ammo_get_recoil, "LootAmmoGetBurnDuration", loot_ammo_get_dur, "LootMedGetDuration", loot_med_get_duration, "LootMedGetDurationSeconds", loot_med_get_duration_seconds);
    uiCatspeakGetEnvironment().addGlobalFunction("LootMedGetCanMove", loot_med_get_can_move, "LootMedGetSpeedMultiplier", loot_med_get_speed_multiplier, "LootMedGetHealth", loot_med_get_hp, "LootMedGetBleed", loot_med_get_bleed);
    uiCatspeakGetEnvironment().addGlobalFunction("LootMedGetWound", loot_med_get_wound, "LootMedGetRadiation", loot_med_get_radiation, "LootConsumableGetHunger", loot_consumable_get_energy, "LootConsumableGetThirst", loot_consumable_get_thirst);
    uiCatspeakGetEnvironment().addGlobalFunction("LootConsumableGetFatigue", loot_consumable_get_fatigue, "LootConsumableGetRadiation", loot_consumable_get_radiation, "LootInjectorGetDuration", loot_injector_get_duration, "LootInjectorGetDurationSeconds", loot_injector_get_duration_seconds);
    uiCatspeakGetEnvironment().addGlobalFunction("LootInjectorGetMaxHP", loot_injector_get_max_hp, "LootInjectorGetHPRegen", loot_injector_get_hp_regen, "LootInjectorGetBleedRec", loot_injector_get_bleed_rec, "LootInjectorGetBleedImmune", loot_injector_get_bleed_immune);
    uiCatspeakGetEnvironment().addGlobalFunction("LootInjectorGetStaminaMax", loot_injector_get_stamina_max, "LootInjectorGetStaminaRegen", loot_injector_get_stamina_regen, "LootInjectorGetMaxWeight", loot_injector_get_max_weight, "LootInjectorGetRadRegen", loot_injector_get_rad_regen);
    uiCatspeakGetEnvironment().addGlobalFunction("LootInjectorGetRadDefence", loot_injector_get_rad_defence, "LootInjectorGetHunger", loot_injector_get_hunger, "LootInjectorGetHungerRegen", loot_injector_get_hunger_regen, "LootInjectorGetThirst", loot_injector_get_thirst);
    uiCatspeakGetEnvironment().addGlobalFunction("LootInjectorGetThirstRegen", loot_injector_get_thirst_regen, "LootRepairGetMinDur", loot_repair_get_min_dur, "LootRepairGetMaxDur", loot_repair_get_max_dur, "LootRepairGetGain", loot_repair_get_gain);
    uiCatspeakGetEnvironment().addGlobalFunction("LootRepairGetArmorClass", loot_repair_get_armor_class, "LootRepairGetCaliberCount", loot_repair_get_caliber_count, "LootRepairGetCaliber", loot_repair_get_caliber, "CaliberGetName", caliber_get_name);
    uiCatspeakGetEnvironment().addGlobalFunction("LootModGetType", loot_mod_get_type, "LootModGetRecoil", loot_mod_get_recoil, "LootModGetErgonomics", loot_mod_get_ergo, "LootModGetAccuracy", loot_mod_get_acc);
    uiCatspeakGetEnvironment().addGlobalFunction("LootModGetDamage", loot_mod_get_damage, "LootModGetReloadSpeed", loot_mod_get_reload_speed, "LootModGetMagazineSize", loot_mod_get_magazine_size, "LootModGetHandguardPosExists", loot_mod_handguard_pos_exists);
    uiCatspeakGetEnvironment().addGlobalFunction("LootModGetWeaponAll", loot_mod_get_weapon_all, "LootModGetWeaponString", loot_mod_get_weapon_string, "LootModGetWeaponCount", loot_mod_get_weapon_count, "LootModGetWeapon", loot_mod_get_weapon);
    uiCatspeakGetEnvironment().addGlobalFunction("LootModGetScopeViewDistance", loot_mod_get_scope_view_distance, "LootModGetScopeEffRange", loot_mod_get_scope_eff_range, "LootGrenadeGetThrowType", loot_grenade_get_throw_type, "LootGrenadeGetDetonationType", loot_grenade_get_detonation_type);
    uiCatspeakGetEnvironment().addGlobalFunction("LootGrenadeGetRadiusMinDamage", loot_grenade_get_radius_min_damage, "LootGrenadeGetDamageMax", loot_grenade_get_damage_max, "ItemGetName", item_get_name, "DialogueLogicCCSpokeAfterPortQuest", dialogue_logic_cc_spoke_after_port_quest);
    uiCatspeakGetEnvironment().addGlobalFunction("DialogueLogicSpokeWithArtemovichAfterTookEyes", dialogue_logic_spoke_with_artemovich_after_took_eyes, "DialogueLogicGivePrologueLetterToBarman", dialogue_logic_give_prologue_letter_to_barman, "WeatherGetTemperatureNowUi", weather_get_temperature_now_ui, "WeatherGetIconUi", weather_get_icon_ui);
    uiCatspeakGetEnvironment().addGlobalFunction("WeatherGetIconUiCurrentMap", weather_get_icon_ui_current_map, "WeatherGetKitBuilt", weather_get_kit_built, "PrologueIsDone", prologue_is_done, "PrologueMapOpened", prologue_map_opened);
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_72 = 72,
    Value_73
}
