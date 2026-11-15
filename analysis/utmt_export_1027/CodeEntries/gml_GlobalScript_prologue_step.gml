function prologue_step()
{
    if (!instance_exists(obj_map_generator))
    {
        exit;
    }
    if (obj_map_generator.state != UnknownEnum.Value_21)
    {
        exit;
    }
    player_follow_local();
    var _pl = player_get_local();
    if (instance_exists(_pl))
    {
        if (!ghoul_spoken && instance_exists(obj_enemy_ghoul))
        {
            var _g = instance_nearest(_pl.x, _pl.y, obj_enemy_ghoul);
            if (point_distance(_pl.x, _pl.y, _g.x, _g.y) < 220)
            {
                scr_draw_npc_text(obj_player, UnknownEnum.Value_49);
                ghoul_spoken = true;
            }
        }
        if (!bandit_spoken && state >= UnknownEnum.Value_29 && instance_exists(obj_bandit_preset_rookie))
        {
            var _b = instance_nearest(_pl.x, _pl.y, obj_bandit_preset_rookie);
            if (point_distance(_pl.x, _pl.y, _b.x, _b.y) < 220)
            {
                scr_draw_npc_text(obj_player, UnknownEnum.Value_50);
                bandit_spoken = true;
            }
        }
    }
    if (global.general_debug && keyboard_check_pressed(vk_space) && false)
    {
        state++;
        state = clamp(state, 0, UnknownEnum.Value_35);
    }
    if (timer_go)
    {
        timer++;
        if (timer >= timer_max)
        {
            timer_go = false;
            state++;
            state = clamp(state, 0, UnknownEnum.Value_35);
            timer = 0;
            text_counter = 0;
            switch (state)
            {
                case UnknownEnum.Value_4:
                    scr_draw_npc_text(obj_prologue_npc, UnknownEnum.Value_290);
                    break;
                case UnknownEnum.Value_5:
                    audio_play_sound(snd_wolf_ul1, 30, false);
                    timer_go = true;
                    timer_max = 120;
                    break;
                case UnknownEnum.Value_6:
                    scr_draw_npc_text(obj_prologue_npc, UnknownEnum.Value_292);
                    break;
                case UnknownEnum.Value_7:
                    db_open(inventory_target_db());
                    var _loadout = db_read("loadout", "id", 0);
                    db_close();
                    loadout_has_backpack = false;
                    for (var _i = 0; _i < loadout_get_item_count(_loadout); _i++)
                    {
                        if (item_get_category(loadout_get_item_id(_loadout, _i)) == "backpack")
                        {
                            loadout_has_backpack = true;
                            break;
                        }
                    }
                    break;
                case UnknownEnum.Value_9:
                    scr_draw_npc_text(obj_prologue_npc, UnknownEnum.Value_294);
                    timer_go = true;
                    timer_max = 120;
                    break;
                case UnknownEnum.Value_10:
                    repeat (3)
                    {
                        var _obj = instance_create_depth(1055, 1700 + irandom_range(-32, 32), 0, obj_enemy_wolf_brown);
                        _obj.alarm[6] = 5;
                        _obj.no_leash = true;
                    }
                    with (obj_enemy_wolf_brown)
                    {
                        no_leash = true;
                        prologue_relentless = true;
                    }
                    timer_go = true;
                    timer_max = 30;
                    break;
                case UnknownEnum.Value_16:
                    break;
                case UnknownEnum.Value_12:
                    var _primary = player_loadout_get_item(player_get_local(), "weapon slot 1");
                    var _kit = "repair_weapon1_high";
                    if (item_repair_caliber_fits_weapon("repair_weapon2_high", _primary))
                    {
                        _kit = "repair_weapon2_high";
                    }
                    else if (item_repair_caliber_fits_weapon("repair_weapon3_high", _primary))
                    {
                        _kit = "repair_weapon3_high";
                    }
                    inventory_add_item(_kit, 1);
                    player_loadout_set_durability("weapon slot 1", 70);
                    scr_draw_npc_text(obj_prologue_npc, UnknownEnum.Value_51);
                    timer_go = true;
                    timer_max = 150;
                    break;
                case UnknownEnum.Value_13:
                    scr_draw_npc_text(obj_prologue_npc, UnknownEnum.Value_295);
                    break;
                case UnknownEnum.Value_19:
                    scr_draw_npc_text(obj_prologue_npc, UnknownEnum.Value_301);
                    break;
                case UnknownEnum.Value_20:
                    with (player_get_local())
                    {
                        if (hp >= (hp_max * 0.9))
                        {
                            hp = hp_max * 0.9;
                        }
                    }
                    player_hp_before = player_get_hp();
                    break;
                case UnknownEnum.Value_21:
                    scr_draw_npc_text(obj_prologue_npc, UnknownEnum.Value_305);
                    break;
                case UnknownEnum.Value_22:
                    with (obj_prologue_npc)
                    {
                        npc_speaker_id = "tutorial_npc";
                    }
                    break;
                case UnknownEnum.Value_23:
                    scr_draw_npc_text(obj_prologue_npc, UnknownEnum.Value_308);
                    break;
                case UnknownEnum.Value_25:
                    minimap_add_interesting_marker(120, 63, UnknownEnum.Value_7);
                    break;
                case UnknownEnum.Value_29:
                    minimap_remove_interesting_marker_by_id(UnknownEnum.Value_7);
                    break;
                case UnknownEnum.Value_30:
                    scr_draw_npc_text(obj_player, UnknownEnum.Value_315);
                    break;
                case UnknownEnum.Value_32:
                    scr_draw_npc_text(obj_player, UnknownEnum.Value_318);
                    break;
            }
        }
    }
    switch (state)
    {
        case UnknownEnum.Value_1:
            text_now = language_get_string("npc.text.hey_wake_up");
            if (text_counter >= (string_length(text_now) - 2) && text_counter < (string_length(text_now) - 1))
            {
                timer_go = true;
                timer_max = 150;
            }
            break;
        case UnknownEnum.Value_2:
            text_now = language_get_string("npc.text.can_you_hear_me");
            if (text_counter >= (string_length(text_now) - 2) && text_counter < (string_length(text_now) - 1))
            {
                timer_go = true;
                timer_max = 150;
            }
            break;
        case UnknownEnum.Value_3:
            screen_alpha -= screen_alpha_k;
            screen_alpha = clamp(screen_alpha, 0, 1);
            if (screen_alpha == 0)
            {
                timer_go = true;
                timer_max = 90;
            }
            break;
        case UnknownEnum.Value_4:
            var _go = false;
            with (obj_npc_draw_text)
            {
                if (text_id == UnknownEnum.Value_291)
                {
                    _go = true;
                }
            }
            if (_go)
            {
                timer_go = true;
                timer_max = 90;
            }
            break;
        case UnknownEnum.Value_6:
            if (item_exists(player_get_local().arma_now))
            {
                timer_go = true;
                timer_max = 20;
            }
            break;
        case UnknownEnum.Value_7:
            var _in_chest = false;
            with (obj_chest_prologue_equipment)
            {
                var _a = db_read_ext("all loot", "chest_" + string(id), "items", []);
                for (var _i = 0; _i < array_length(_a); _i++)
                {
                    if (_a[_i].quantity > 0 && item_get_category(_a[_i].item) == "backpack")
                    {
                        _in_chest = true;
                        break;
                    }
                }
            }
            backpack_in_chest = _in_chest;
            if (player_loadout_get_item(player_get_local(), "backpack slot") != "no_item" || !loadout_has_backpack)
            {
                timer_go = true;
                timer_max = 60;
            }
            break;
        case UnknownEnum.Value_8:
            if (player_loadout_get_ammo(player_get_local(), player_get_local().weapon_slot_now) > 0)
            {
                timer_go = true;
                timer_max = 60;
            }
            break;
        case UnknownEnum.Value_16:
            if (!player_loadout_get_jammed(player_get_local(), player_get_local().weapon_slot_now))
            {
                timer_go = true;
                timer_max = 30;
            }
            break;
        case UnknownEnum.Value_11:
            if (!instance_exists(obj_enemy_wolf_brown))
            {
                timer_go = true;
                timer_max = 60;
            }
            break;
        case UnknownEnum.Value_13:
            var _go = false;
            with (obj_npc_draw_text)
            {
                if (text_id == UnknownEnum.Value_299)
                {
                    _go = true;
                }
            }
            if (_go)
            {
                timer_go = true;
                timer_max = 180;
            }
            break;
        case UnknownEnum.Value_14:
            if (instance_exists(obj_chest_prologue_medication))
            {
                if (point_distance(player_get_local().x, player_get_local().y, obj_chest_prologue_medication.x, obj_chest_prologue_medication.y) < 64)
                {
                    timer_go = true;
                    timer_max = 5;
                }
            }
            break;
        case UnknownEnum.Value_15:
            if (inventory_item_exists("medikit_long"))
            {
                timer_go = true;
                timer_max = 5;
            }
            break;
        case UnknownEnum.Value_17:
            if (instance_exists(obj_prologue_npc))
            {
                if (point_distance(player_get_local().x, player_get_local().y, obj_prologue_npc.x, obj_prologue_npc.y) < 128)
                {
                    timer_go = true;
                    timer_max = 5;
                }
            }
            break;
        case UnknownEnum.Value_19:
            var _go = false;
            with (obj_npc_draw_text)
            {
                if (text_id == UnknownEnum.Value_304)
                {
                    _go = true;
                }
            }
            if (_go)
            {
                timer_go = true;
                timer_max = 180;
            }
            break;
        case UnknownEnum.Value_20:
            if (player_get_hp() > player_hp_before)
            {
                timer_go = true;
                timer_max = 60;
            }
            break;
        case UnknownEnum.Value_21:
            var _go = false;
            with (obj_npc_draw_text)
            {
                if (text_id == UnknownEnum.Value_307)
                {
                    _go = true;
                }
            }
            if (_go)
            {
                timer_go = true;
                timer_max = 180;
            }
            break;
        case UnknownEnum.Value_22:
            if (deal_done && player_state_is(player_get_local().mp_index, scr_player_state_move))
            {
                timer_go = true;
                timer_max = 60;
            }
            break;
        case UnknownEnum.Value_24:
            if (global.kb_pressed[UnknownEnum.Value_10])
            {
                timer_go = true;
                timer_max = 5;
            }
            break;
        case UnknownEnum.Value_25:
            break;
        case UnknownEnum.Value_26:
            if (global.kb_pressed[UnknownEnum.Value_11])
            {
                timer_go = true;
                timer_max = 5;
            }
            break;
        case UnknownEnum.Value_23:
            var _go = false;
            with (obj_npc_draw_text)
            {
                if (text_id == UnknownEnum.Value_314)
                {
                    _go = true;
                }
            }
            if (_go)
            {
                timer_go = true;
                timer_max = 120;
            }
            break;
        case UnknownEnum.Value_27:
            if (instance_exists(obj_chest_prologue_letter))
            {
                if (point_distance(player_get_local().x, player_get_local().y, obj_chest_prologue_letter.x, obj_chest_prologue_letter.y) < 96)
                {
                    timer_go = true;
                    timer_max = 5;
                }
            }
            break;
        case UnknownEnum.Value_28:
            if (inventory_item_exists("prologue_letter"))
            {
                timer_go = true;
                timer_max = 5;
            }
            break;
        case UnknownEnum.Value_30:
            var _go = false;
            with (obj_npc_draw_text)
            {
                if (text_id == UnknownEnum.Value_317)
                {
                    _go = true;
                }
            }
            if (_go)
            {
                timer_go = true;
                timer_max = 120;
            }
            break;
        case UnknownEnum.Value_32:
            var _go = false;
            with (obj_npc_draw_text)
            {
                if (text_id == UnknownEnum.Value_318)
                {
                    _go = true;
                }
            }
            if (_go)
            {
                timer_go = true;
                timer_max = 180;
            }
            break;
        case UnknownEnum.Value_34:
            if (instance_exists(obj_green_army_prologue))
            {
                if (point_distance(obj_green_army_prologue.x, obj_green_army_prologue.y, player_get_local().x, player_get_local().y) < 220)
                {
                    if (ga_spoken_1 == false)
                    {
                        scr_draw_npc_text(obj_green_army_prologue, UnknownEnum.Value_319);
                        ga_spoken_1 = true;
                    }
                }
                if (point_distance(obj_green_army_prologue.x, obj_green_army_prologue.y, player_get_local().x, player_get_local().y) < 48)
                {
                    if (ga_spoken_2 == false)
                    {
                        scr_draw_npc_text(obj_green_army_prologue, UnknownEnum.Value_321);
                        ga_spoken_2 = true;
                    }
                }
            }
            break;
    }
    if (state < UnknownEnum.Value_28 && inventory_item_exists("prologue_letter"))
    {
        state = UnknownEnum.Value_29;
    }
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_2,
    Value_3,
    Value_4,
    Value_5,
    Value_6,
    Value_7,
    Value_8,
    Value_9,
    Value_10,
    Value_11,
    Value_12,
    Value_13,
    Value_14,
    Value_15,
    Value_16,
    Value_17,
    Value_19 = 19,
    Value_20,
    Value_21,
    Value_22,
    Value_23,
    Value_24,
    Value_25,
    Value_26,
    Value_27,
    Value_28,
    Value_29,
    Value_30,
    Value_32 = 32,
    Value_34 = 34,
    Value_35,
    Value_49 = 49,
    Value_50,
    Value_51,
    Value_290 = 290,
    Value_291,
    Value_292,
    Value_294 = 294,
    Value_295,
    Value_299 = 299,
    Value_301 = 301,
    Value_304 = 304,
    Value_305,
    Value_307 = 307,
    Value_308,
    Value_314 = 314,
    Value_315,
    Value_317 = 317,
    Value_318,
    Value_319,
    Value_321 = 321
}
