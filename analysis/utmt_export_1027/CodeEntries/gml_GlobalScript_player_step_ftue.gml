function player_step_ftue()
{
    if (ftue_part1_complete == 0)
    {
        if (ftue_part1_barman_player_walks_away == 0)
        {
            if (is_in_hub())
            {
                var _prologue = db_read_ext("general", "prologue", "play", false);
                if ((!_prologue && point_distance(x, y, obj_tradr_bar.x, obj_tradr_bar.y) > 70) || (_prologue && point_distance(x, y, obj_tradr_bar.x, obj_tradr_bar.y) > 2))
                {
                    ftue_produce_dialogue(obj_tradr_head, UnknownEnum.Value_187);
                    ftue_part1_barman_player_walks_away = true;
                }
            }
        }
        if (!is_in_hub() || instance_exists(obj_map_generator))
        {
            ftue_part1_barman_player_takes_too_long = true;
        }
        if (ftue_part1_barman_player_takes_too_long == 0)
        {
            ftue_part1_barman_player_takes_too_long_timer++;
            if (ftue_part1_barman_player_takes_too_long_timer > 480)
            {
                ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_188);
                ftue_part1_barman_player_takes_too_long = true;
            }
        }
        var _quest_string = "first_step_1";
        var _quest_is_active = quest_is_active(_quest_string);
        var _someone_else_talking = false;
        with (obj_npc_draw_text)
        {
            if (visible == true)
            {
                _someone_else_talking = true;
                break;
            }
        }
        if (ftue_part1_barman_player_spoken_to_barman && !_quest_is_active && !__uiGlobal().__defaultOnion.HasInputReceiver() && !_someone_else_talking)
        {
            if (((current_time / 50) % 150) < 1)
            {
                ftue_produce_dialogue(obj_tradr_head, UnknownEnum.Value_189);
            }
        }
        if (_quest_is_active)
        {
            ftue_part1_complete = true;
        }
    }
    if (ftue_part2_complete == 0)
    {
        if (y < 670 && !instance_exists(obj_npc_draw_text))
        {
            ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_190);
            ftue_part2_complete = true;
        }
    }
    if (!ftue_part3_complete)
    {
        if (instance_exists(obj_capotreno))
        {
            var _distance_to_conductor = point_distance(x, y, obj_capotreno.x, obj_capotreno.y);
            if (_distance_to_conductor > 125)
            {
                ftue_part3_conductor_far = true;
            }
            if (_distance_to_conductor < 90)
            {
                ftue_part2_complete = true;
                if (ftue_part3_conductor_far == true)
                {
                    var _quest_string = "first_step_1";
                    var _quest_is_active = quest_is_active(_quest_string);
                    if (!_quest_is_active)
                    {
                        ftue_produce_dialogue(obj_capotreno, UnknownEnum.Value_191);
                    }
                    else if (arma_now == "no_item")
                    {
                        ftue_produce_dialogue(obj_capotreno, UnknownEnum.Value_192);
                    }
                    else
                    {
                        ftue_produce_dialogue(obj_capotreno, UnknownEnum.Value_193);
                    }
                }
                ftue_part3_conductor_far = false;
            }
        }
    }
    if (!ftue_part4_complete)
    {
        if (is_in_raid() && !instance_exists(obj_loading_map))
        {
            if (instance_exists(obj_train) && obj_train.state == UnknownEnum.Value_6)
            {
                ftue_part4_train_timer++;
                if (ftue_part4_train_timer > 300 && !ftue_part4_player_no_bullets_1)
                {
                    ftue_part4_player_no_bullets_1 = true;
                    if (arma_now == "no_item")
                    {
                        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_194);
                    }
                    else if (player_loadout_get_ammo(self, weapon_slot_now) <= 0 && reloading == false)
                    {
                        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_195);
                    }
                }
                if (ftue_part4_train_timer > 1000 && !ftue_part4_player_no_bullets_2)
                {
                    ftue_part4_player_no_bullets_2 = true;
                    if (arma_now == "no_item")
                    {
                        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_196);
                    }
                    else if (player_loadout_get_ammo(self, weapon_slot_now) <= 0 && reloading == false)
                    {
                        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_197);
                    }
                }
                if (ftue_part4_train_timer > 1600 && !ftue_part4_player_no_bullets_3)
                {
                    ftue_part4_player_no_bullets_3 = true;
                    ftue_part4_complete = true;
                    if (arma_now == "no_item")
                    {
                        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_198);
                    }
                    else if (player_loadout_get_ammo(self, weapon_slot_now) <= 0 && reloading == false)
                    {
                        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_199);
                    }
                }
            }
        }
    }
    if (!ftue_durability_shown && ftue_part4_complete && is_in_raid() && !instance_exists(obj_loading_map))
    {
        if (item_get_category(arma_now) == "weapon")
        {
            var _dur_reached = player_loadout_get_durability(self, weapon_slot_now) <= 70;
            var _prologue_fallback = instance_exists(obj_prologue) && obj_prologue.state >= UnknownEnum.Value_29;
            if (_dur_reached || _prologue_fallback)
            {
                ftue_durability_shown = true;
                ftue_produce_dialogue(player_get_local(), settings_get("show_durability") ? UnknownEnum.Value_216 : UnknownEnum.Value_212);
            }
        }
    }
    if (!ftue_scroll_shown && !!obj_gamepad.last_input_keyboard && is_in_raid() && !instance_exists(obj_loading_map) && player_local_state_is(scr_player_state_move) && !instance_exists(obj_npc_draw_text) && ds_list_size(global.list_interact) > 1)
    {
        ftue_scroll_shown = true;
        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_220);
    }
    if (!ftue_part5_complete)
    {
        if (is_in_hub() && stat_get_value("tot_hunt") == 1)
        {
            ftue_part5_delay_timer++;
            if (ftue_part5_delay_timer > 200)
            {
                if (stat_get_value("tot_hunt_survived") == 0)
                {
                    ftue_produce_dialogue(obj_capotreno, UnknownEnum.Value_200);
                }
                else
                {
                    var _quest_string = "first_step_1";
                    if (quest_tasks_done(_quest_string))
                    {
                        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_201);
                    }
                    else if (hp < (hp_max / 2))
                    {
                        ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_202);
                    }
                    else
                    {
                    }
                }
                ftue_part5_complete = true;
            }
        }
    }
    if (ftue_part6_complete == 0)
    {
        if (is_in_raid() && (!instance_exists(obj_npc_draw_text) || obj_npc_draw_text.id_npc != player_get_local()) && !instance_exists(obj_loading_map) && (instance_exists(obj_train) && obj_train.state == UnknownEnum.Value_6))
        {
            if (!ftue_part6_carrying_too_much)
            {
                if (player_weight > max_weight && !__uiGlobal().__defaultOnion.HasInputReceiver())
                {
                    ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_204);
                    ftue_part6_carrying_too_much = true;
                }
            }
            if (!ftue_part6_out_of_energy)
            {
                if (stamina < (stamina_max_total * 0.1) && player_weight > (max_weight * 0.7))
                {
                    ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_206);
                    ftue_part6_out_of_energy = true;
                }
            }
            if (!ftue_part6_bleeding)
            {
                if (player_get_local_var("bleed") && !instance_exists(obj_bullet_parent))
                {
                    ftue_produce_dialogue(player_get_local(), UnknownEnum.Value_208);
                    ftue_part6_bleeding = true;
                }
            }
        }
        if (ftue_part6_carrying_too_much && ftue_part6_out_of_energy && ftue_part6_bleeding)
        {
            ftue_part6_complete = true;
        }
    }
}

enum UnknownEnum
{
    Value_6 = 6,
    Value_29 = 29,
    Value_187 = 187,
    Value_188,
    Value_189,
    Value_190,
    Value_191,
    Value_192,
    Value_193,
    Value_194,
    Value_195,
    Value_196,
    Value_197,
    Value_198,
    Value_199,
    Value_200,
    Value_201,
    Value_202,
    Value_204 = 204,
    Value_206 = 206,
    Value_208 = 208,
    Value_212 = 212,
    Value_216 = 216,
    Value_220 = 220
}
