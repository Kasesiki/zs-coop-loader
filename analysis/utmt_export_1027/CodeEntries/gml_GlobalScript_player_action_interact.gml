function player_action_interact()
{
    var cam_x = camera_get_view_x(view_camera[0]);
    var cam_y = camera_get_view_y(view_camera[0]);
    var _task_pos;
    switch (ds_list_find_value(global.list_interact, global.p_int_instance_id))
    {
        case UnknownEnum.Value_1:
            if (!ai_roaming_claim_on_interact(ds_list_find_value(global.list_interact_id, global.p_int_instance_id), id))
            {
                player_action_open_chest(ds_list_find_value(global.list_interact_id, global.p_int_instance_id));
            }
            break;
        case UnknownEnum.Value_2:
            player_action_open_stash();
            break;
        case UnknownEnum.Value_3:
            var _special = false;
            var _get_instance_id = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            var _get_object_index = _get_instance_id.object_index;
            if (_get_object_index == obj_sacriel)
            {
                _special = true;
                scr_draw_npc_text(obj_sacriel, UnknownEnum.Value_170);
            }
            if (_special == false)
            {
                global.speaker_nearest = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
                player_action_talk_to_npc();
            }
            break;
        case UnknownEnum.Value_4:
            __uiGlobal().__defaultOnion.LayerAddTop("ZS_vanilla/ui/sleep.ui");
            player_set_local_state(scr_player_state_sleep);
            break;
        case UnknownEnum.Value_5:
            var indoor_id = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            var _offy = 0;
            if (y > obj_map_generator.area_height[obj_map_generator.area])
            {
                _offy = -4;
            }
            x = indoor_id.tele_x;
            y = indoor_id.tele_y + _offy;
            can_run_after_exit_building = false;
            obj_controller.can_pause = true;
            obj_controller.alarm[4] = 2;
            if (instance_exists(obj_fog_setup))
            {
                obj_fog_setup.alarm[0] = 3;
            }
            if (instance_exists(obj_camera))
            {
                obj_camera.alarm[1] = 1;
            }
            update_position = y < obj_map_generator.map_height;
            if (indoor_id.object_index == obj_indoor_specific_city_start_block || indoor_id.object_index == obj_indoor_specific_city_start_central || indoor_id.object_index == obj_indoor_specific_city_start_construction)
            {
                global.city_map_started = true;
            }
            break;
        case UnknownEnum.Value_58:
            x = global.last_quest_npp_teleport_back_position_x;
            y = global.last_quest_npp_teleport_back_position_y;
            can_run_after_exit_building = false;
            obj_controller.can_pause = true;
            obj_controller.alarm[4] = 2;
            if (instance_exists(obj_fog_setup))
            {
                obj_fog_setup.alarm[0] = 3;
            }
            if (instance_exists(obj_camera))
            {
                obj_camera.alarm[1] = 1;
            }
            update_position = y < obj_map_generator.map_height;
            break;
        case UnknownEnum.Value_6:
            break;
        case UnknownEnum.Value_10:
            var _quest_pos = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            var _quest_id = global.quest_state[_quest_pos].id;
            _task_pos = ds_list_find_value(global.list_interact_task_pos, global.p_int_instance_id);
            if (_quest_id != "")
            {
                if (variable_struct_get(global.quest_database, _quest_id).objective[_task_pos].type == "interact_obj" || variable_struct_get(global.quest_database, _quest_id).objective[_task_pos].type == "place_analyzer")
                {
                    var _item_id = variable_struct_get(global.quest_database, _quest_id).objective[_task_pos].item_id;
                    var _i_have_item = true;
                    if (_item_id != -1)
                    {
                        _i_have_item = false;
                        _i_have_item = inventory_item_exists(_item_id);
                    }
                    if (_i_have_item == true)
                    {
                        var _text_item = variable_struct_get(global.quest_database, _quest_id).objective[_task_pos].text_if_item;
                        if (_text_item != -1)
                        {
                            scr_draw_npc_text(id, _text_item);
                        }
                        if (_item_id != -1)
                        {
                            inventory_remove_item(_item_id, 1);
                        }
                        global.quest_state[_quest_pos].amount_now[_task_pos] = 1;
                        obj_controller.alarm[1] = 1;
                        if (_quest_id == UnknownEnum.Value_37)
                        {
                            obj_quest_destroy_ghoul_lair_esplosione.alarm[1] = 3600;
                            global.show_explosion_ghoul_lair = true;
                        }
                        if (_quest_id == "last_quest")
                        {
                            last_quest_npp_switch_update();
                            last_quest_npp_switch_checkpoint(_quest_pos, _task_pos);
                            last_quest_npp_doors_update_state();
                            instance_create_depth(x, y, 0, obj_quest_npp_teleport_back_interactable);
                        }
                    }
                    if (_i_have_item == false)
                    {
                        var _text_no_item = variable_struct_get(global.quest_database, _quest_id).objective[_task_pos].text_if_no_item;
                        if (_text_no_item != -1)
                        {
                            scr_draw_npc_text(id, _text_no_item);
                        }
                    }
                }
            }
            break;
        case UnknownEnum.Value_9:
            var _quest_pos = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            _task_pos = ds_list_find_value(global.list_interact_task_pos, global.p_int_instance_id);
            var _quest_id = global.quest_state[_quest_pos].id;
            global.quest_state[_quest_pos].amount_now[_task_pos] = 1;
            obj_controller.alarm[1] = 1;
            if (_quest_id == UnknownEnum.Value_89)
            {
                scr_draw_npc_text(id, UnknownEnum.Value_55);
            }
            if (_quest_id == UnknownEnum.Value_25)
            {
                scr_draw_npc_text(id, UnknownEnum.Value_57);
            }
            if (_quest_id == UnknownEnum.Value_30)
            {
                scr_draw_npc_text(id, UnknownEnum.Value_60);
            }
            if (_quest_id == UnknownEnum.Value_36)
            {
                scr_draw_npc_text(id, UnknownEnum.Value_62);
            }
            break;
        case UnknownEnum.Value_7:
            __uiGlobal().__defaultOnion.LayerAddTop("ZS_vanilla/ui/crafting.ui", "crafting layer");
            player_set_local_state(scr_player_state_craft);
            break;
        case UnknownEnum.Value_59:
            var _open_door = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            if (instance_exists(_open_door))
            {
                if (last_quest_npp_doors_update_state(true))
                {
                    audio_play_sound(snd_npp_door_open, 10, false);
                    instance_destroy(_open_door);
                }
                else
                {
                    scr_draw_npc_text(id, UnknownEnum.Value_326);
                }
            }
            break;
        case UnknownEnum.Value_60:
            var _letter = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            if (!instance_exists(_letter))
            {
                break;
            }
            if (!inventory_item_exists("letter_zs2") && !stash_item_exists("letter_zs2"))
            {
                if (!inventory_check_for_space("letter_zs2", 1))
                {
                    scr_draw_text_with_box("ui.not_enough_inventory_space");
                    break;
                }
                if (!inventory_add_item("letter_zs2", 1))
                {
                    break;
                }
                var _pickup_text = string_replace(language_get_string("ui.popup.item_added_to_inventory"), "[ITEM]", item_get_name("letter_zs2"));
                scr_draw_text_with_box(_pickup_text, false);
            }
            instance_destroy(_letter);
            ds_list_delete(global.list_interact, global.p_int_instance_id);
            ds_list_delete(global.list_interact_id, global.p_int_instance_id);
            ds_list_delete(global.list_interact_task_pos, global.p_int_instance_id);
            global.p_int_instance_id = max(0, min(global.p_int_instance_id, ds_list_size(global.list_interact) - 1));
            break;
        case UnknownEnum.Value_8:
            var door_near = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            var d_id = door_near.id_door;
            var have_key = inventory_item_exists(global.door_key_id[d_id]);
            if (have_key == false)
            {
                scr_draw_npc_text(id, UnknownEnum.Value_31);
            }
            var togli_chiave = false;
            if (item_get_key_single_use(global.door_key_id[d_id]))
            {
                togli_chiave = true;
            }
            if (d_id == UnknownEnum.Value_9)
            {
                if (instance_exists(obj_junk_trader))
                {
                    audio_play_sound(snd_electric_spark, 15, false);
                    global.last_damage_source = "instakill_interact";
                    player_damage_local(infinity);
                }
            }
            if (have_key == true)
            {
                with (door_near)
                {
                    if (place_meeting(x, y, obj_solid))
                    {
                        var solid_my_poosition = instance_place(x, y, obj_solid);
                        var xx, yy;
                        with (solid_my_poosition)
                        {
                            xx = x;
                            yy = y;
                            instance_destroy();
                        }
                        if (togli_chiave == true)
                        {
                            inventory_remove_item(global.door_key_id[d_id], 1);
                            inventory_clean_up_empty_items();
                        }
                        sprite_index = global.door_sprite_open[d_id];
                        visible = true;
                        x = xx;
                        y = yy;
                        depth = -yy;
                        open = true;
                    }
                }
            }
            break;
        case UnknownEnum.Value_11:
            var closer = instance_place(x, y, obj_base_parent);
            var base_slot_ = closer.slot;
            var closer_id = closer.id_base;
            var c_id = 0;
            if (closer_id == UnknownEnum.Value_8)
            {
                c_id = obj_chest_material;
                if (base_module_get_level(UnknownEnum.Value_8) > 1)
                {
                    c_id = obj_chest_material_2;
                }
            }
            if (closer_id == UnknownEnum.Value_10)
            {
                c_id = obj_chest_garden;
            }
            if (closer_id == UnknownEnum.Value_11)
            {
                c_id = obj_chest_ammo;
            }
            if (closer_id == UnknownEnum.Value_9)
            {
                c_id = obj_chest_scav;
            }
            if (c_id != 0)
            {
                instance_create_depth(x, y, 0, c_id);
                closer.preso = true;
                db_open("general");
                db_write("Module preso", "slot_" + string(base_slot_), true);
                db_close();
            }
            break;
        case UnknownEnum.Value_13:
            var i_have_the_kit = inventory_item_exists("repair_radio_tower");
            if (i_have_the_kit == true)
            {
                scr_complete_specific_q_type(UnknownEnum.Value_62, UnknownEnum.Value_11);
                inventory_remove_item("repair_radio_tower", 1);
                scr_draw_text_with_box("Quest completed!");
            }
            else
            {
                scr_draw_npc_text(id, UnknownEnum.Value_24);
            }
            break;
        case UnknownEnum.Value_14:
            var i_have_the_marker = inventory_item_exists("gps_marker");
            if (i_have_the_marker == true)
            {
                var _quest_pos = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
                var _quest_id = global.quest_state[_quest_pos].id;
                _task_pos = ds_list_find_value(global.list_interact_task_pos, global.p_int_instance_id);
                global.quest_state[_quest_pos].amount_now[_task_pos] = 1;
                obj_controller.alarm[1] = 1;
                inventory_remove_item("gps_marker", 1);
            }
            else
            {
                scr_draw_npc_text(id, UnknownEnum.Value_23);
            }
            break;
        case UnknownEnum.Value_15:
            var i_have_the_analyzer = inventory_item_exists("scientific_analyzer");
            if (i_have_the_analyzer == true)
            {
                global.save_quest_amount_now[i][0] = 1;
                global.quest_state[i].amount_now[_task_pos] = 1;
                obj_controller.alarm[1] = 1;
                inventory_remove_item("scientific_analyzer", 1);
                scr_draw_text_with_box("Quest completed!");
            }
            else
            {
                scr_draw_npc_text(id, UnknownEnum.Value_27);
            }
            break;
        case UnknownEnum.Value_16:
            var quest_pos_ = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            var i_have_repair_kit = inventory_item_exists("repair_radio_tower");
            if (i_have_repair_kit == true)
            {
                scr_complete_specific_q_type(UnknownEnum.Value_170, UnknownEnum.Value_13);
                inventory_remove_item("repair_radio_tower", 1);
                scr_draw_text_with_box("Quest completed!");
            }
            else
            {
                scr_draw_npc_text(id, UnknownEnum.Value_24);
            }
            break;
        case UnknownEnum.Value_17:
            var quest_pos_ = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            scr_complete_specific_q_type(UnknownEnum.Value_171, UnknownEnum.Value_14);
            obj_controller.alarm[1] = 1;
            scr_draw_text_with_box("Quest completed!");
            break;
        case UnknownEnum.Value_57:
            go_to_map(UnknownEnum.Value_9, true);
            break;
        case UnknownEnum.Value_18:
            break;
        case UnknownEnum.Value_19:
            var i_have_the_marker = inventory_item_exists("camera_crimson_quest");
            if (i_have_the_marker == true)
            {
                scr_complete_specific_q_type(UnknownEnum.Value_19, UnknownEnum.Value_19);
                inventory_remove_item("camera_crimson_quest", 1);
                scr_draw_text_with_box("Quest completed!");
            }
            else
            {
                scr_draw_npc_text(id, UnknownEnum.Value_34);
            }
            break;
        case UnknownEnum.Value_20:
            if (obj_faro.light_on == false)
            {
                obj_faro.light_start = true;
                obj_spawner_ghoul_quest_swamp.alarm[0] = 480;
                obj_faro.alarm[3] = 90;
                with (obj_green_quest_swamp_leader)
                {
                    scr_draw_npc_text(id, UnknownEnum.Value_121);
                }
            }
            break;
        case UnknownEnum.Value_21:
            scr_draw_npc_text(id, UnknownEnum.Value_52);
            break;
        case UnknownEnum.Value_22:
            scr_draw_npc_text(id, UnknownEnum.Value_92);
            global.az_done[UnknownEnum.Value_15] = true;
            break;
        case UnknownEnum.Value_23:
            with (obj_prologue)
            {
                timer_go = true;
                timer_max = 10;
            }
            break;
        case UnknownEnum.Value_24:
            if (global.luci_natale_on == true)
            {
                global.luci_natale_on = false;
                scr_draw_text_with_box("Lights OFF");
            }
            else
            {
                global.luci_natale_on = true;
                scr_draw_text_with_box("Lights ON");
            }
            db_open("general");
            db_write("Christman", "lights on", global.luci_natale_on);
            db_close();
            with (obj_light_natale_parent)
            {
                scale = scale_start;
            }
            break;
        case UnknownEnum.Value_25:
            var _colore_now;
            with (obj_light_natale_1)
            {
                colore_now += 1;
                var _max = array_length(colore_luce);
                if (colore_now >= (_max - 1))
                {
                    colore_now = 0;
                }
                _colore_now = colore_now;
                db_open("general");
                db_write("Christman", "lights color 1", colore_now);
                db_close();
            }
            scr_draw_text_with_box(language_get_string("ui.lights_1_color") + " " + string(_colore_now), false);
            break;
        case UnknownEnum.Value_26:
            var _colore_now;
            with (obj_light_natale_2)
            {
                colore_now += 1;
                var _max = array_length(colore_luce);
                if (colore_now >= (_max - 1))
                {
                    colore_now = 0;
                }
                _colore_now = colore_now;
                db_open("general");
                db_write("Christman", "lights color 2", colore_now);
                db_close();
            }
            scr_draw_text_with_box(language_get_string("ui.lights_2_color") + " " + string(_colore_now), false);
            break;
        case UnknownEnum.Value_27:
            global.luci_natale_mode += 1;
            if (global.luci_natale_mode > UnknownEnum.Value_2)
            {
                global.luci_natale_mode = UnknownEnum.Value_0;
            }
            if (global.luci_natale_mode == UnknownEnum.Value_2)
            {
                with (obj_light_natale_1)
                {
                    scale = 0;
                }
                with (obj_light_natale_1)
                {
                    scale = scale_start;
                }
            }
            db_open("general");
            db_write("Christman", "lights mode", global.luci_natale_mode);
            db_close();
            with (obj_light_natale_parent)
            {
                luci_natale_timer_alternato = 0;
            }
            scr_draw_text_with_box(language_get_string("ui.lights_mode") + " - " + string(global.luci_natale_mode), false);
            break;
        case UnknownEnum.Value_28:
            global.luci_natale_timer += 1;
            if (global.luci_natale_timer > 4)
            {
                global.luci_natale_timer = 0;
            }
            with (obj_light_natale_parent)
            {
                luci_natale_timer_alternato = 0;
            }
            db_open("general");
            db_write("Christman", "lights timer", global.luci_natale_timer);
            db_close();
            scr_draw_text_with_box(language_get_string("ui.lights_timer") + " - " + string(global.luci_natale_timer), false);
            break;
        case UnknownEnum.Value_29:
            if (!global.santa2023_given_milk)
            {
                if (inventory_item_exists("milk"))
                {
                    inventory_remove_item("milk", 1);
                    with (obj_santa_claus)
                    {
                        scr_draw_npc_text(id, UnknownEnum.Value_182);
                    }
                    global.santa2023_given_milk = true;
                    obj_controller.alarm[3] = 1;
                    audio_play_sound(snd_natale2023_woosh, 20, false);
                }
                else
                {
                    scr_draw_npc_text(id, UnknownEnum.Value_107);
                }
            }
            else
            {
                with (obj_santa_claus)
                {
                    scr_draw_npc_text(id, UnknownEnum.Value_181);
                }
            }
            break;
        case UnknownEnum.Value_30:
            var indoor_id = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            x = indoor_id.tele_x;
            y = indoor_id.tele_y;
            can_run_after_exit_building = false;
            obj_controller.can_pause = true;
            obj_controller.alarm[4] = 2;
            instance_create_depth(x, y, 0, obj_hud_outer_deity);
            global.quest_outer_deity_sound = true;
            if (instance_exists(obj_fog_setup))
            {
                obj_fog_setup.alarm[0] = 3;
            }
            if (instance_exists(obj_camera))
            {
                obj_camera.alarm[1] = 1;
            }
            with (obj_quest_outer_deity_interact)
            {
                instance_destroy();
            }
            break;
        case UnknownEnum.Value_31:
            var _id = ds_list_find_value(global.list_interact_id, global.p_int_instance_id);
            var _object = _id.object_index;
            switch (_object)
            {
                case obj_interact_lab_elevator_room_experiment_1:
                    scr_draw_npc_text(obj_interact_lab_elevator_room_experiment_1, UnknownEnum.Value_221);
                    break;
                case obj_interact_lab_elevator_room_experiment_2:
                    scr_draw_npc_text(obj_interact_lab_elevator_room_experiment_2, UnknownEnum.Value_224);
                    break;
                case obj_interact_lab_elevator_room_experiment_3:
                    scr_draw_npc_text(obj_interact_lab_elevator_room_experiment_3, UnknownEnum.Value_229);
                    break;
                case obj_interact_lab_elevator_room_experiment_4:
                    scr_draw_npc_text(obj_interact_lab_elevator_room_experiment_4, UnknownEnum.Value_232);
                    break;
            }
            break;
        case UnknownEnum.Value_35:
            global.end_game_choice = UnknownEnum.Value_35;
            end_game_save_choice();
            scr_draw_npc_text(obj_quest_end_game, UnknownEnum.Value_261);
            end_game_delete_choices();
            faction_set_rep("Player", "Green Army", 1000);
            faction_set_rep("Player", "Crimson Corporation", 1000);
            faction_set_rep("Player", "Loners", 1000);
            faction_set_rep("Player", "Scientists", 1000);
            break;
        case UnknownEnum.Value_32:
            global.end_game_choice = UnknownEnum.Value_32;
            end_game_save_choice();
            scr_draw_npc_text(obj_quest_end_game, UnknownEnum.Value_261);
            end_game_delete_choices();
            global.player_money = 100000000;
            break;
        case UnknownEnum.Value_34:
            global.end_game_choice = UnknownEnum.Value_34;
            end_game_save_choice();
            scr_draw_npc_text(obj_quest_end_game, UnknownEnum.Value_261);
            end_game_delete_choices();
            with (player_get_local())
            {
                skills_hunter.set("immortal", true);
            }
            break;
        case UnknownEnum.Value_39:
            global.end_game_choice = UnknownEnum.Value_39;
            end_game_save_choice();
            scr_draw_npc_text(obj_quest_end_game, UnknownEnum.Value_261);
            end_game_delete_choices();
            global.az_done[UnknownEnum.Value_11] = false;
            global.az_done[UnknownEnum.Value_1] = false;
            scr_save_unique_action();
            break;
        case UnknownEnum.Value_40:
            with (obj_dummy_bunker)
            {
                delete_npc = true;
                instance_destroy();
            }
            scr_draw_text_with_box("All dummies resetted");
            break;
        case UnknownEnum.Value_41:
            global.sr_class_now = 0;
            scr_draw_text_with_box("No armor selected");
            break;
        case UnknownEnum.Value_42:
            global.sr_class_now = 1;
            scr_draw_text_with_box("Class 1 armor selected");
            break;
        case UnknownEnum.Value_43:
            global.sr_class_now = 2;
            scr_draw_text_with_box("Class 2 armor selected");
            break;
        case UnknownEnum.Value_44:
            global.sr_class_now = 3;
            scr_draw_text_with_box("Class 3 armor selected");
            break;
        case UnknownEnum.Value_45:
            global.sr_class_now = 4;
            scr_draw_text_with_box("Class 4 armor selected");
            break;
        case UnknownEnum.Value_46:
            global.sr_class_now = 5;
            scr_draw_text_with_box("Class 5 armor selected");
            break;
        case UnknownEnum.Value_47:
            global.sr_class_now = 6;
            scr_draw_text_with_box("Class 6 armor selected");
            break;
        case UnknownEnum.Value_48:
            global.radio_struct.on = true;
            audio_play_sound(snd_laser_on, 10, false, undefined, undefined, random_range(0.95, 1.05));
            radio_master_sync(false);
            radio_hub_sync();
            pirateradio_achievement();
            break;
        case UnknownEnum.Value_49:
            global.radio_struct.on = false;
            audio_play_sound(snd_laser_on, 10, false, undefined, undefined, random_range(0.95, 1.05));
            radio_hub_sync();
            break;
        case UnknownEnum.Value_51:
            global.radio_struct.volume -= 0.1;
            global.radio_struct.volume = clamp(global.radio_struct.volume, 0, 1);
            audio_play_sound(snd_laser_on, 10, false, undefined, undefined, random_range(0.95, 1.05));
            radio_hub_sync();
            break;
        case UnknownEnum.Value_50:
            global.radio_struct.volume += 0.1;
            global.radio_struct.volume = clamp(global.radio_struct.volume, 0, 1);
            audio_play_sound(snd_laser_on, 10, false, undefined, undefined, random_range(0.95, 1.05));
            radio_hub_sync();
            break;
        case UnknownEnum.Value_52:
            audio_play_sound(snd_laser_on, 10, false, undefined, undefined, random_range(0.95, 1.05));
            global.radio_struct.loop_track = false;
            radio_next_track(true);
            radio_track_name_pop_up(global.radio_struct.track_now);
            break;
        case UnknownEnum.Value_54:
            global.radio_struct.loop_track = true;
            audio_play_sound(snd_laser_on, 10, false, undefined, undefined, random_range(0.95, 1.05));
            radio_master_sync(false);
            radio_hub_sync();
            break;
        case UnknownEnum.Value_55:
            global.radio_struct.loop_track = false;
            audio_play_sound(snd_laser_on, 10, false, undefined, undefined, random_range(0.95, 1.05));
            radio_master_sync(false);
            radio_hub_sync();
            break;
        case UnknownEnum.Value_56:
            var _track_id = global.radio_struct.track_now;
            radio_track_name_pop_up(_track_id);
            break;
        case UnknownEnum.Value_53:
            var _new_track = radio_add_cassette();
            if (is_string(_new_track))
            {
                global.radio_struct.track_now = _new_track;
                radio_next_track(false);
            }
            break;
    }
}

function last_quest_npp_switch_checkpoint(arg0, arg1)
{
    if (!variable_global_exists("quest_state") || !variable_global_exists("quest_database"))
    {
        return false;
    }
    if (!variable_global_exists("last_quest_npp_switch_amount"))
    {
        global.last_quest_npp_switch_amount = 4;
    }
    if (arg0 < 0 || arg0 >= 30)
    {
        return false;
    }
    if (arg1 < 0 || arg1 >= global.last_quest_npp_switch_amount)
    {
        return false;
    }
    if (!is_struct(global.quest_database) || !variable_struct_exists(global.quest_database, "last_quest"))
    {
        return false;
    }
    var _live_state = global.quest_state[arg0];
    if (!is_struct(_live_state) || _live_state.id != "last_quest")
    {
        return false;
    }
    var _objective = struct_get_from_hash(global.quest_database, variable_get_hash("last_quest")).objective[arg1];
    if (_live_state.amount_now[arg1] < _objective.amount_max)
    {
        return false;
    }
    var _checkpoint_saved = false;
    db_open("general");
    for (var i = 0; i < 30; i++)
    {
        var _saved_state = SnapDeepCopy(db_read("quest", i, new class_quest_state()));
        if (is_struct(_saved_state) && _saved_state.id == "last_quest")
        {
            _saved_state.amount_now[arg1] = max(_saved_state.amount_now[arg1], _live_state.amount_now[arg1]);
            _saved_state.notifica_sub[arg1] = true;
            db_write("quest", i, _saved_state);
            _checkpoint_saved = true;
            break;
        }
    }
    db_close();
    return _checkpoint_saved;
}

function last_quest_npp_switch_update()
{
    if (!variable_global_exists("last_quest_npp_switch_used"))
    {
        global.last_quest_npp_switch_used = 0;
    }
    if (!variable_global_exists("last_quest_npp_switch_amount"))
    {
        global.last_quest_npp_switch_amount = 4;
    }
    if (!variable_global_exists("last_quest_npp_switch_completed"))
    {
        global.last_quest_npp_switch_completed = array_create(global.last_quest_npp_switch_amount, false);
    }
    if (!variable_global_exists("last_quest_npp_door_slide"))
    {
        global.last_quest_npp_door_slide = 32;
    }
    if (!variable_global_exists("last_quest_npp_door_slide_duration"))
    {
        global.last_quest_npp_door_slide_duration = 0.9;
    }
    if (variable_global_exists("quest_line_progress"))
    {
        if (quest_is_complete("last_quest"))
        {
            global.last_quest_npp_switch_used = global.last_quest_npp_switch_amount;
            global.last_quest_npp_switch_completed = array_create(global.last_quest_npp_switch_amount, true);
            return global.last_quest_npp_switch_used;
        }
    }
    if (!variable_global_exists("quest_state") || !variable_global_exists("quest_database"))
    {
        return global.last_quest_npp_switch_used;
    }
    if (!is_struct(global.quest_database) || !variable_struct_exists(global.quest_database, "last_quest"))
    {
        return global.last_quest_npp_switch_used;
    }
    var _used = 0;
    var _completed = array_create(global.last_quest_npp_switch_amount, false);
    var _quest_data = struct_get_from_hash(global.quest_database, variable_get_hash("last_quest"));
    var _switch_amount = min(global.last_quest_npp_switch_amount, array_length(_quest_data.objective));
    for (var i = 0; i < 30; i++)
    {
        if (global.quest_state[i].id == "last_quest")
        {
            for (var j = 0; j < _switch_amount; j++)
            {
                if (global.quest_state[i].amount_now[j] >= _quest_data.objective[j].amount_max)
                {
                    _used += 1;
                    _completed[j] = true;
                }
            }
            break;
        }
    }
    global.last_quest_npp_switch_used = _used;
    global.last_quest_npp_switch_completed = _completed;
    return _used;
}

function last_quest_npp_doors_update_state(arg0 = false)
{
    var _switches_ready = last_quest_npp_switch_update() >= global.last_quest_npp_switch_amount;
    var _is_open = _switches_ready && arg0;
    with (obj_npp_door_sx)
    {
        last_quest_npp_door_update_state(id, -1, _is_open);
    }
    with (obj_npp_door_dx)
    {
        last_quest_npp_door_update_state(id, 1, _is_open);
    }
    return _is_open;
}

function last_quest_npp_door_update_state(arg0, arg1, arg2 = undefined)
{
    static _sprites_sx = [s_npp_door_sx_0, s_npp_door_sx_1, s_npp_door_sx_2, s_npp_door_sx_3];
    static _sprites_dx = [s_npp_door_dx_0, s_npp_door_dx_1, s_npp_door_dx_2, s_npp_door_dx_3];
    
    if (!instance_exists(arg0))
    {
        return false;
    }
    if (!variable_global_exists("last_quest_npp_door_slide"))
    {
        global.last_quest_npp_door_slide = 32;
    }
    var _position_ready = false;
    if (variable_instance_exists(arg0, "last_quest_npp_door_position_ready"))
    {
        _position_ready = arg0.last_quest_npp_door_position_ready;
    }
    if (!_position_ready)
    {
        arg0.last_quest_npp_door_closed_x = arg0.x;
        arg0.last_quest_npp_door_closed_y = arg0.y;
        arg0.last_quest_npp_door_target_x = arg0.x;
        arg0.last_quest_npp_door_target_y = arg0.y;
        arg0.last_quest_npp_door_position_ready = true;
    }
    if (!variable_instance_exists(arg0, "last_quest_npp_door_target_x"))
    {
        arg0.last_quest_npp_door_target_x = arg0.x;
    }
    if (!variable_instance_exists(arg0, "last_quest_npp_door_target_y"))
    {
        arg0.last_quest_npp_door_target_y = arg0.y;
    }
    if (is_undefined(arg2))
    {
        last_quest_npp_switch_update();
        arg2 = false;
    }
    arg2 = arg2 || arg0.last_quest_npp_door_is_open;
    var _completed = global.last_quest_npp_switch_completed;
    var _sprite;
    if (arg1 < 0)
    {
        _sprite = _sprites_sx[_completed[1] + (2 * _completed[0])];
        arg0.mask_index = s_npp_door_sx;
    }
    else
    {
        _sprite = _sprites_dx[_completed[3] + (2 * _completed[2])];
        arg0.mask_index = s_npp_door_dx;
    }
    if (arg0.sprite_index != _sprite)
    {
        sprite_set_offset(_sprite, 0, sprite_get_height(_sprite));
        arg0.sprite_index = _sprite;
    }
    arg0.image_speed = 0;
    arg0.image_index = 0;
    arg0.last_quest_npp_door_is_open = arg2;
    arg0.last_quest_npp_door_target_x = arg0.last_quest_npp_door_closed_x;
    arg0.last_quest_npp_door_target_y = arg0.last_quest_npp_door_closed_y;
    if (arg2)
    {
        arg0.last_quest_npp_door_target_x += global.last_quest_npp_door_slide * arg1;
    }
    return arg2;
}

function last_quest_npp_door_step()
{
    if (!variable_instance_exists(id, "last_quest_npp_door_target_x"))
    {
        last_quest_npp_door_target_x = x;
    }
    if (!variable_global_exists("last_quest_npp_door_slide_duration"))
    {
        global.last_quest_npp_door_slide_duration = 0.9;
    }
    var _duration = global.last_quest_npp_door_slide_duration;
    if (_duration <= 0)
    {
        _duration = 0.9;
    }
    var _steps = max(_duration * game_get_speed(gamespeed_fps), 1);
    var _speed = abs(global.last_quest_npp_door_slide) / _steps;
    var _move_x = last_quest_npp_door_target_x - x;
    if (abs(_move_x) <= _speed)
    {
        x = last_quest_npp_door_target_x;
    }
    else
    {
        x += (sign(_move_x) * _speed);
    }
}

enum UnknownEnum
{
    Value_0,
    Value_1,
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
    Value_13 = 13,
    Value_14,
    Value_15,
    Value_16,
    Value_17,
    Value_18,
    Value_19,
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
    Value_31,
    Value_32,
    Value_34 = 34,
    Value_35,
    Value_36,
    Value_37,
    Value_39 = 39,
    Value_40,
    Value_41,
    Value_42,
    Value_43,
    Value_44,
    Value_45,
    Value_46,
    Value_47,
    Value_48,
    Value_49,
    Value_50,
    Value_51,
    Value_52,
    Value_53,
    Value_54,
    Value_55,
    Value_56,
    Value_57,
    Value_58,
    Value_59,
    Value_60,
    Value_62 = 62,
    Value_89 = 89,
    Value_92 = 92,
    Value_107 = 107,
    Value_121 = 121,
    Value_170 = 170,
    Value_171,
    Value_181 = 181,
    Value_182,
    Value_221 = 221,
    Value_224 = 224,
    Value_229 = 229,
    Value_232 = 232,
    Value_261 = 261,
    Value_326 = 326
}
