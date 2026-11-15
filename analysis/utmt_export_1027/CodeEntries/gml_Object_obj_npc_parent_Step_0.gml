var _player = player_get_local();
depth = -y - (sprite_get_height(sprite_index) / 2);
audio_emitter_position(emitter_shoot, x, y, 0);
audio_emitter_position(emitter_walk, x, y, 0);
audio_emitter_position(emitter_talk, x, y, 0);
var camx = camera_get_view_x(view_camera[0]);
var camy = camera_get_view_y(view_camera[0]);
var _lista_near_me = undefined;
alert_player -= 0.5;
alert_player = clamp(alert_player, 0, alert_player_max);
if (bark_cooldown > 0)
{
    bark_cooldown -= 1;
}
if (last_seen_delay == true)
{
    last_seen_delay_timer++;
    if (last_seen_delay_timer >= last_seen_delay_timer_max)
    {
        last_seen_delay = false;
        last_seen_x = last_seen_delay_x;
        last_seen_y = last_seen_delay_y;
    }
}
recoil_shooting -= 0.4;
recoil_shooting = clamp(recoil_shooting, 0, 10);
if (path_create_now == true)
{
    if (follow_path == true)
    {
        path_create_now = false;
        var _path_amount_max = array_length(path_goto_x);
        var _valid_x = x;
        var _valid_y = y;
        for (var i = 0; i < _path_amount_max; i++)
        {
            var _path = path_add();
            if (mp_grid_path(npc_motion_grid(), _path, _valid_x, _valid_y, path_goto_x[i], path_goto_y[i], true))
            {
                var _path_size = path_get_number(_path);
                if (_path_size > 0)
                {
                    for (var j = 0; j < _path_size; j++)
                    {
                        var _p_x = path_get_point_x(_path, j);
                        var _p_y = path_get_point_y(_path, j);
                        ds_list_add(lista_path_x, _p_x);
                        ds_list_add(lista_path_y, _p_y);
                    }
                }
                _valid_x = path_goto_x[i];
                _valid_y = path_goto_y[i];
            }
            path_delete(_path);
        }
    }
}
if (can_talk_reset)
{
    can_talk_reset_timer++;
    if (can_talk_reset_timer >= can_talk_reset_timer_max)
    {
        can_talk = true;
        can_talk_reset = false;
    }
}
current_move_speed_multiplier = 1;
move_speed_multiplier_from_skills = 1;
if (frames_left_of_impaler_shot_1 >= 0)
{
    frames_left_of_impaler_shot_1--;
    move_speed_multiplier_from_skills *= global.skills_data.impaler_shot_1.value_1;
}
if (frames_left_of_impaler_shot_2 >= 0)
{
    frames_left_of_impaler_shot_2--;
    move_speed_multiplier_from_skills *= global.skills_data.impaler_shot_2.value_1;
}
current_move_speed_multiplier *= move_speed_multiplier_from_skills;
ai_human_before_step(id);
switch (state)
{
    case "dummy":
        break;
    case "dummy_bunker":
        hp = npc_get_hp(npc_id);
        target_for_image_scale = x - 16;
        break;
    case "human_no_move":
        if (player_exists_local())
        {
            target_for_image_scale = _player.x;
        }
        break;
    case "sacriel_hub":
        target_for_image_scale = x + 1;
        break;
    case "deactivate":
        if (human_tick >= human_tick_max)
        {
            human_tick_max = human_tick_max_ref + 10 + irandom_range(-2, 2);
            human_tick = 0;
            if (player_exists_local())
            {
                var _x_start = _player.x - 480;
                var _y_start = _player.y - 270;
                if (point_in_rectangle(x, y, _x_start, _y_start, _x_start + 960, _y_start + 540))
                {
                    state = state_before;
                }
            }
        }
        break;
    case "unknown_sewer":
        if (player_exists_local())
        {
            target_for_image_scale = _player.x;
        }
        if (can_talk == true)
        {
            if (global.az_done[UnknownEnum.Value_7] == false)
            {
                global.az_done[UnknownEnum.Value_7] = true;
                can_talk = false;
                scr_draw_npc_text(id, UnknownEnum.Value_159);
            }
        }
        target = scr_find_target_for_human();
        if (target != -4)
        {
            switch (target_relation)
            {
                case UnknownEnum.Value_2:
                    hspd = 0;
                    vspd = 0;
                    state = "human_shoot";
                    break;
                case UnknownEnum.Value_0:
                    break;
                case UnknownEnum.Value_1:
                    break;
            }
        }
        break;
    case "forest_trader":
        if (player_exists_local())
        {
            target_for_image_scale = _player.x;
            if (point_distance(x, y, _player.x, _player.y) < 80)
            {
                if (can_talk == true)
                {
                    can_talk = false;
                    var prima_volta_fatta = global.az_done[UnknownEnum.Value_0];
                    if (prima_volta_fatta == false)
                    {
                        scr_draw_npc_text(id, UnknownEnum.Value_127);
                        global.az_done[UnknownEnum.Value_0] = true;
                    }
                    else
                    {
                        scr_draw_npc_text(id, UnknownEnum.Value_129);
                    }
                }
            }
        }
        break;
    case "junk_trader":
        target_for_image_scale = 1;
        if (player_exists_local())
        {
            if (point_distance(x, y, _player.x, _player.y) < 80)
            {
                if (can_talk == true)
                {
                    can_talk = false;
                    var prima_volta_fatta = global.az_done[UnknownEnum.Value_10];
                    onemanstrash_achievement();
                    if (prima_volta_fatta == false)
                    {
                        scr_draw_npc_text(id, UnknownEnum.Value_134);
                        global.az_done[UnknownEnum.Value_10] = true;
                    }
                    else
                    {
                        scr_draw_npc_text(id, UnknownEnum.Value_139);
                    }
                }
            }
        }
        break;
    case "guardia_ingresso":
        if (scr_chance(2))
        {
            weapon_pointing_amount = choose(-weapon_pointing_angle, weapon_pointing_angle, 0);
        }
        weapon_pointing_direction += weapon_pointing_amount;
        weapon_pointing_direction = clamp(weapon_pointing_direction, 240, 300);
        target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
        if (object_index == obj_guardia_ingresso_2)
        {
            if (can_talk == true)
            {
                if (player_exists_local())
                {
                    if (_player.y > (y + 4) && _player.y < (y + 18) && instance_line_of_sight(x, y, _player))
                    {
                        var first_time_ = global.az_done[UnknownEnum.Value_2];
                        if (first_time_ == false)
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_144);
                            global.az_done[UnknownEnum.Value_2] = true;
                            can_talk = false;
                        }
                        first_time_ = global.az_done[UnknownEnum.Value_3];
                        if (first_time_ == true)
                        {
                            var pp_ = UnknownEnum.Value_4;
                            var _first_time_ = global.az_done[pp_];
                            if (_first_time_ == false)
                            {
                                scr_draw_npc_text(id, UnknownEnum.Value_151);
                                global.az_done[pp_] = true;
                                can_talk = false;
                            }
                        }
                    }
                }
            }
        }
        if (object_index == obj_guardia_ingresso_1)
        {
            if (can_talk == true)
            {
                if (player_exists_local())
                {
                    if (_player.y > (y + 4) && _player.y < (y + 18) && instance_line_of_sight(x, y, _player))
                    {
                        var _active = scr_check_quest_in_corso(UnknownEnum.Value_37);
                        if (_active == UnknownEnum.Value_1)
                        {
                            can_talk = false;
                            scr_draw_npc_text(id, UnknownEnum.Value_156);
                        }
                        _active = scr_check_quest_in_corso(UnknownEnum.Value_37);
                        if ((_active == UnknownEnum.Value_2 || global.quest_unique_done[UnknownEnum.Value_37] == true) && global.az_done[UnknownEnum.Value_6] == false)
                        {
                            can_talk = false;
                            scr_draw_npc_text(id, UnknownEnum.Value_157);
                            global.az_done[UnknownEnum.Value_6] = true;
                        }
                    }
                }
            }
        }
        var point_player = false;
        if (player_exists_local())
        {
            if (object_index == obj_guardia_ingresso_1 || object_index == obj_guardia_ingresso_2)
            {
                if (instance_exists(obj_npc_draw_text))
                {
                    with (obj_npc_draw_text)
                    {
                        if (global.t_npc_text_next_id[text_id] == obj_guardia_ingresso_1 || global.t_npc_text_next_id[text_id] == obj_guardia_ingresso_2)
                        {
                            point_player = true;
                        }
                    }
                }
            }
            if (point_player == true)
            {
                weapon_pointing_direction = point_direction(x, y, _player.x, _player.y);
                target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            }
        }
        break;
    case "guardia_iniziale":
        if (scr_chance(2))
        {
            weapon_pointing_amount = choose(-weapon_pointing_angle, weapon_pointing_angle, 0);
        }
        weapon_pointing_direction += weapon_pointing_amount;
        weapon_pointing_direction = clamp(weapon_pointing_direction, -100, 15);
        if (quest_is_complete("unlock_makeshift_camp") == false)
        {
            if (player_distance_local(x, y) < 48)
            {
                if (instance_line_of_sight(x, y, _player))
                {
                    weapon_pointing_direction = point_direction(x, y, _player.x, _player.y);
                    if (can_talk == true)
                    {
                        can_talk = false;
                        scr_draw_npc_text(id, UnknownEnum.Value_119);
                    }
                }
            }
        }
        if (!instance_exists(obj_solid_bunker_green_army))
        {
            npc_speaker_id = "guardia_iniziale_posso_passare";
        }
        if (quest_is_complete("unlock_makeshift_camp") == true)
        {
            if (player_distance_local(x, y) < 16 && instance_line_of_sight(x, y, _player))
            {
                if (can_talk == true)
                {
                    can_talk = false;
                    scr_draw_npc_text(id, UnknownEnum.Value_120);
                }
            }
        }
        target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
        break;
    case "guardia_iniziale_posso_passare":
        if (scr_chance(2))
        {
            weapon_pointing_amount = choose(-weapon_pointing_angle, weapon_pointing_angle, 0);
        }
        weapon_pointing_direction += weapon_pointing_amount;
        weapon_pointing_direction = clamp(weapon_pointing_direction, -100, 15);
        target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
        break;
    case "crimson_ingresso_base":
        if (scr_chance(2))
        {
            weapon_pointing_amount = choose(-weapon_pointing_angle, weapon_pointing_angle, 0);
        }
        weapon_pointing_direction += weapon_pointing_amount;
        weapon_pointing_direction = clamp(weapon_pointing_direction, -100, 15);
        if (player_exists_local())
        {
            var _active = scr_check_quest_in_corso(UnknownEnum.Value_69);
            if (_active == UnknownEnum.Value_2)
            {
                if (player_distance_local(x, y) < 64)
                {
                    weapon_pointing_direction = point_direction(x, y, _player.x, _player.y);
                    if (can_talk == true)
                    {
                        if (global.az_done[UnknownEnum.Value_9] == false)
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_165);
                            can_talk = false;
                            global.az_done[UnknownEnum.Value_9] = true;
                        }
                    }
                }
            }
            if (global.quest_unique_done[UnknownEnum.Value_69] == false || _active != UnknownEnum.Value_2)
            {
                if (player_distance_local(x, y) < 96)
                {
                    weapon_pointing_direction = point_direction(x, y, _player.x, _player.y);
                    if (player_distance_local(x, y) < 64)
                    {
                        if (can_talk == true)
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_162);
                            can_talk = false;
                        }
                    }
                }
            }
            if (global.quest_unique_done[UnknownEnum.Value_70] == true)
            {
                if (player_distance_local(x, y) < 48)
                {
                    if (can_talk == true)
                    {
                        scr_draw_npc_text(id, UnknownEnum.Value_164);
                        can_talk = false;
                    }
                }
            }
        }
        target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
        target = scr_find_target_for_human();
        if (target != -4)
        {
            switch (target_relation)
            {
                case UnknownEnum.Value_2:
                    hspd = 0;
                    vspd = 0;
                    state = "human_shoot";
                    break;
                case UnknownEnum.Value_0:
                    break;
                case UnknownEnum.Value_1:
                    break;
            }
        }
        break;
    case "crimson_leader":
        if (!global.az_done[UnknownEnum.Value_8] && player_exists_local())
        {
            if (player_distance_local(x, y) < 128)
            {
                if (can_talk == true)
                {
                    can_talk = false;
                    global.az_done[UnknownEnum.Value_8] = true;
                    scr_draw_npc_text(id, UnknownEnum.Value_168);
                }
            }
        }
        break;
    case "human_fuma_sigaretta":
        scr_npc_state_arms(obj_arms_smoke);
        break;
    case "human_eat":
        scr_npc_state_arms(obj_arms_eat);
        break;
    case "human_drink":
        scr_npc_state_arms(obj_arms_drink);
        break;
    case "human_play_guitar":
        scr_npc_state_arms(obj_arms_guitar);
        break;
    case "human_go_near_fire":
        scr_enemy_path();
        if (point_distance(x, y, move_point_x, move_point_y) < 12)
        {
            path_end();
            if (!instance_exists(obj_arms_guitar))
            {
                scr_npc_arms("human_play_guitar", obj_arms_guitar);
            }
            else
            {
                state = "human_patrol";
            }
        }
        break;
    case "human_hub_general":
        if (is_in_hub())
        {
            if (x > (camx - 240) && x < (camx + 720) && y > (camy - 135) && y < (camy + 405))
            {
                scr_enemy_choose_idle_or_move();
                scr_collision();
            }
        }
        target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
        if (x > xprevious)
        {
            target_for_image_scale = x + 2;
            weapon_pointing_direction = 300;
        }
        else if (x == xprevious)
        {
        }
        else if (x < xprevious)
        {
            target_for_image_scale = x - 2;
            weapon_pointing_direction = 240;
        }
        break;
    case "human_go_to_bancone_hub":
        scr_enemy_path();
        if (point_distance(x, y, move_point_x, move_point_y) < 4)
        {
            path_end();
            move_point_x = original_x;
            move_point_y = original_y;
            if (scr_chance(50))
            {
                state = "human_eat";
                var aa = instance_create_depth(x, y, 0, obj_arms_eat);
                aa.linked_id = id;
                aa.image_xscale = image_xscale;
            }
            else
            {
                state = "human_drink";
                var aa = instance_create_depth(x, y, 0, obj_arms_drink);
                aa.linked_id = id;
                aa.image_xscale = image_xscale;
            }
        }
        break;
    case "human_go_to_original_position":
        scr_enemy_path();
        if (point_distance(x, y, move_point_x, move_point_y) < 4)
        {
            path_end();
            state = "human_hub_general";
        }
        break;
    case "human_patrol":
        scr_enemy_choose_idle_or_move();
        scr_collision();
        draw_weapon = true;
        if (is_in_hub())
        {
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            if (x > xprevious)
            {
                target_for_image_scale = x + 2;
                weapon_pointing_direction = 300;
            }
            else if (x == xprevious)
            {
            }
            else if (x < xprevious)
            {
                target_for_image_scale = x - 2;
                weapon_pointing_direction = 240;
            }
        }
        else
        {
            if (scr_chance(2))
            {
                weapon_pointing_amount = choose(-weapon_pointing_angle, weapon_pointing_angle, 0);
            }
            weapon_pointing_direction += weapon_pointing_amount;
            if (object_index == obj_green_quest_swamp)
            {
                if (instance_exists(obj_faro))
                {
                    weapon_pointing_direction = point_direction(x, y, obj_faro.x, obj_faro.y - 150);
                }
            }
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
        }
        target = scr_find_target_for_human();
        if (target != -4)
        {
            switch (target_relation)
            {
                case UnknownEnum.Value_2:
                    hspd = 0;
                    vspd = 0;
                    state = "human_shoot";
                    break;
                case UnknownEnum.Value_0:
                    hspd = 0;
                    vspd = 0;
                    state = "human_aim_neutral_target";
                    break;
                case UnknownEnum.Value_1:
                    break;
            }
        }
        if (scr_chance(1))
        {
            if (faction == "Loners")
            {
                if (!instance_exists(obj_arms_guitar))
                {
                    if (instance_exists(obj_barrel_acciaio_fire))
                    {
                        var nearest = instance_nearest(x, y, obj_barrel_acciaio_fire);
                        if (point_distance(x, y, nearest.x, nearest.y) < 160)
                        {
                            move_point_x = nearest.x + irandom_range(-10, 10);
                            move_point_y = nearest.y;
                            state = "human_go_near_fire";
                        }
                    }
                }
            }
        }
        break;
    case "human_aim_neutral_target":
        scr_collision();
        target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
        target = scr_find_target_for_human();
        if (target != -4)
        {
            switch (target_relation)
            {
                case UnknownEnum.Value_2:
                    hspd = 0;
                    vspd = 0;
                    state = "human_shoot";
                    break;
                case UnknownEnum.Value_0:
                    weapon_pointing_direction = point_direction(x, y, target.x, target.y);
                    var dis = point_distance(x, y, target.x, target.y);
                    if (point_distance(x, y, mouse_x, mouse_y) < 8 && dis < 96)
                    {
                        if (can_talk == true)
                        {
                            can_talk = false;
                            scr_draw_npc_text(id, UnknownEnum.Value_29);
                        }
                    }
                    if (!instance_line_of_sight(x, y, target))
                    {
                        state = "human_patrol";
                    }
                    break;
                case UnknownEnum.Value_1:
                    state = "human_patrol";
                    break;
            }
        }
        else
        {
            state = "human_patrol";
        }
        break;
    case "human_general":
        if (!ai_human_dispatch(id) && faction == "Mutants")
        {
            ai_legacy_mutant_general();
        }
        break;
    case "human_alert":
        target = scr_find_target_for_human();
        draw_weapon = true;
        if (target != -4)
        {
            if (target_relation == UnknownEnum.Value_2)
            {
                weapon_pointing_direction = point_direction(x, y, target.x, target.y);
                scr_enemy_alert_near_enemy();
                if (instance_line_of_sight(x, y, target))
                {
                    state = "human_shoot";
                }
                else
                {
                    move_point_x = 0;
                    move_point_y = 0;
                    if (point_distance(x, y, target.x, target.y) < 200)
                    {
                        scr_enemy_search_shoot_position();
                        if (move_point_x != 0)
                        {
                            state = "human_move_to_shoot_position";
                        }
                        else
                        {
                            scr_enemy_choose_move_pos(last_seen_x, last_seen_y, 64);
                            state = "human_chase_target";
                        }
                    }
                    else if (scr_chance(0.5))
                    {
                        scr_enemy_choose_move_pos(last_seen_x, last_seen_y, 64);
                        state = "human_chase_target";
                    }
                }
            }
            if (target_relation == UnknownEnum.Value_0)
            {
                hspd = 0;
                vspd = 0;
                state = "human_aim_neutral_target";
            }
            if (target_relation == UnknownEnum.Value_1)
            {
                hspd = 0;
                vspd = 0;
                state = "human_patrol";
            }
        }
        break;
    case "human_take_cover":
        if (object_index == obj_green_quest_swamp)
        {
            state = "human_alert";
        }
        if (point_distance(x, y, move_point_x, move_point_y) < 4)
        {
            target = scr_find_target_for_human();
            if (target_relation == UnknownEnum.Value_2)
            {
                if (ammo_now < (item_weapon_get_magazine(arma_now) * 0.5))
                {
                    var chance = (100 - ((ammo_now * 100) / item_weapon_get_magazine(arma_now))) * 2;
                    if (scr_chance(chance))
                    {
                        state = "human_reloading";
                        reloading = true;
                        alarm[0] = irandom(100) + 60;
                        scr_draw_npc_text(id, UnknownEnum.Value_6);
                    }
                }
                else if (target != -4)
                {
                    state = "human_alert";
                }
            }
            if (target_relation == UnknownEnum.Value_0)
            {
                hspd = 0;
                vspd = 0;
                state = "human_aim_neutral_target";
            }
            if (target_relation == UnknownEnum.Value_1)
            {
                hspd = 0;
                vspd = 0;
                state = "human_patrol";
            }
        }
        scr_enemy_path();
        break;
    case "human_move_to_shoot_position":
        target = scr_find_target_for_human();
        if (target != -4)
        {
            if (target_relation == UnknownEnum.Value_2)
            {
                weapon_pointing_direction = point_direction(x, y, target.x, target.y);
                if (point_distance(x, y, move_point_x, move_point_y) < 8)
                {
                    if (instance_line_of_sight(x, y, target))
                    {
                        state = "human_shoot";
                    }
                    else
                    {
                        state = "human_alert";
                    }
                }
            }
            if (target_relation == UnknownEnum.Value_0)
            {
                hspd = 0;
                vspd = 0;
                state = "human_aim_neutral_target";
            }
            if (target_relation == UnknownEnum.Value_1)
            {
                hspd = 0;
                vspd = 0;
                state = "human_patrol";
            }
        }
        scr_enemy_path();
        break;
    case "human_shoot":
        draw_weapon = true;
        if (shoot_time == 0)
        {
            path_end();
            if (scr_chance(75))
            {
                scr_enemy_choose_move_pos(x, y, 16);
            }
            else
            {
                move_point_x = x;
                move_point_y = y;
            }
        }
        if (hp <= (0.3 * npc_get_hp(npc_id)))
        {
            if (scr_chance(1))
            {
                scr_draw_npc_text(id, UnknownEnum.Value_2);
            }
        }
        target = scr_find_target_for_human();
        if (target != -4)
        {
            if (target_relation == UnknownEnum.Value_2)
            {
                last_seen_x = target.x;
                last_seen_y = target.y;
                if (instance_line_of_sight(x, y, target))
                {
                    if (point_distance(x, y, target.x, target.y) < (npc_get_alert_visual_distance(npc_id) * 1.5))
                    {
                        scr_enemy_alert_near_enemy();
                        scr_enemy_shoot();
                        shoot_time++;
                        if (shoot_time >= shoot_time_max)
                        {
                            shoot_time = 0;
                            if (scr_chance(50))
                            {
                                if (scr_chance(80))
                                {
                                    scr_enemy_search_cover_position();
                                    state = "human_take_cover";
                                    scr_draw_npc_text(id, UnknownEnum.Value_1);
                                }
                                else
                                {
                                    scr_enemy_change_cover();
                                    state = "human_take_cover";
                                }
                            }
                            else
                            {
                                state = "human_shoot";
                                if (scr_chance(10))
                                {
                                    scr_draw_npc_text(id, UnknownEnum.Value_0);
                                }
                            }
                            if (point_direction(x, y, obj_cursor.aa_x, obj_cursor.aa_y) < 16)
                            {
                                scr_enemy_search_cover_position();
                                state = "human_take_cover";
                                scr_draw_npc_text(id, UnknownEnum.Value_1);
                            }
                        }
                    }
                    else
                    {
                        scr_enemy_choose_move_pos(last_seen_x, last_seen_y, 8);
                        state = "human_chase_target";
                        scr_draw_npc_text(id, UnknownEnum.Value_8);
                    }
                }
                else
                {
                    shoot_time = 0;
                    riflessi = 0;
                    if (scr_chance(0.13))
                    {
                        scr_enemy_choose_move_pos(last_seen_x, last_seen_y, 8);
                        state = "human_chase_target";
                        scr_draw_npc_text(id, UnknownEnum.Value_8);
                    }
                }
                if (ammo_now < (item_weapon_get_magazine(arma_now) * 0.5))
                {
                    var chance = 100 - ((ammo_now * 100) / item_weapon_get_magazine(arma_now));
                    if (scr_chance(chance))
                    {
                        scr_enemy_search_cover_position();
                        state = "human_take_cover";
                        scr_draw_npc_text(id, UnknownEnum.Value_7);
                    }
                    if (npc_get_spd_alerted(npc_id) == 0)
                    {
                        if (scr_chance(chance))
                        {
                            state = "human_reloading";
                            reloading = true;
                            alarm[0] = irandom(100) + 60;
                            scr_draw_npc_text(id, UnknownEnum.Value_6);
                        }
                    }
                }
            }
            if (target_relation == UnknownEnum.Value_0)
            {
                hspd = 0;
                vspd = 0;
                state = "human_aim_neutral_target";
            }
            if (target_relation == UnknownEnum.Value_1)
            {
                hspd = 0;
                vspd = 0;
                state = "human_patrol";
            }
        }
        scr_enemy_path();
        break;
    case "human_chase_target":
        target = scr_find_target_for_human();
        draw_weapon = true;
        if (target != -4)
        {
            if (target_relation == UnknownEnum.Value_2)
            {
                if (instance_line_of_sight(x, y, target) && point_distance(x, y, target.x, target.y) < (npc_get_alert_visual_distance(npc_id) * 1.4))
                {
                    state = "human_shoot";
                }
                if (point_distance(x, y, move_point_x, move_point_y) < 8)
                {
                    if (!instance_line_of_sight(x, y, target))
                    {
                        path_end();
                        alarm[5] = reset_state_to_patrol_time;
                        state = "human_look_around";
                        scr_draw_npc_text(id, UnknownEnum.Value_9);
                    }
                }
            }
            if (target_relation == UnknownEnum.Value_0)
            {
                hspd = 0;
                vspd = 0;
                state = "human_aim_neutral_target";
            }
            if (target_relation == UnknownEnum.Value_1)
            {
                hspd = 0;
                vspd = 0;
                state = "human_patrol";
            }
        }
        scr_enemy_path();
        break;
    case "human_encounter_chase":
        if (faction != "Mutants")
        {
            target = scr_find_target_for_human();
            if (target != -4)
            {
                if (target_relation == UnknownEnum.Value_2)
                {
                    if (instance_line_of_sight(x, y, target) && point_distance(x, y, target.x, target.y) < (npc_get_alert_visual_distance(npc_id) * 1.2))
                    {
                        state = "human_shoot";
                    }
                }
                if (target_relation == UnknownEnum.Value_0)
                {
                    hspd = 0;
                    vspd = 0;
                    state = "human_aim_neutral_target";
                }
                if (target_relation == UnknownEnum.Value_1)
                {
                    hspd = 0;
                    vspd = 0;
                    state = "human_patrol";
                }
            }
        }
        if (faction == "Mutants")
        {
            if (instance_line_of_sight(x, y, target) && point_distance(x, y, target.x, target.y) < 400)
            {
                state = "mutant_alert";
            }
        }
        if (instance_exists(target))
        {
            move_point_x = target.x;
            move_point_y = target.y;
        }
        else
        {
            move_point_x = x;
            move_point_y = y;
        }
        scr_enemy_path();
        break;
    case "human_look_around":
        target = scr_find_target_for_human();
        draw_weapon = true;
        if (scr_chance(npc_get_prob_idle(npc_id)))
        {
            hspd = 0;
            vspd = 0;
        }
        if (scr_chance(npc_get_prob_move(npc_id) * 6))
        {
            var dir = irandom(360);
            hspd = lengthdir_x(npc_get_spd_not_alerted(npc_id), dir);
            vspd = lengthdir_y(npc_get_spd_not_alerted(npc_id), dir);
        }
        scr_collision();
        if (target != -4)
        {
            if (scr_chance(2))
            {
                weapon_pointing_amount = choose(-weapon_pointing_angle, weapon_pointing_angle, 0);
            }
            weapon_pointing_direction += weapon_pointing_amount;
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            if (target_relation == UnknownEnum.Value_2)
            {
                if (instance_line_of_sight(x, y, target))
                {
                    scr_draw_npc_text(id, UnknownEnum.Value_12);
                    state = "human_alert";
                }
            }
            if (target_relation == UnknownEnum.Value_0)
            {
                hspd = 0;
                vspd = 0;
                state = "human_aim_neutral_target";
            }
            if (target_relation == UnknownEnum.Value_1)
            {
                hspd = 0;
                vspd = 0;
                state = "human_patrol";
            }
        }
        break;
    case "human_reloading":
        if (reloading == false)
        {
            state = "human_alert";
        }
        if (image_xscale == 1)
        {
            weapon_pointing_direction = 0;
        }
        else
        {
            weapon_pointing_direction = 180;
        }
        break;
    case "quest_swamp_leader_talk":
        break;
    case "scientist_idle":
        scr_enemy_choose_idle_or_move();
        scr_collision();
        if (scr_chance(2))
        {
            weapon_pointing_amount = choose(-weapon_pointing_angle, weapon_pointing_angle, 0);
        }
        weapon_pointing_direction += weapon_pointing_amount;
        target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
        target = scr_find_target_for_human();
        if (target != -4)
        {
            switch (target_relation)
            {
                case UnknownEnum.Value_2:
                    hspd = 0;
                    vspd = 0;
                    state = "human_shoot";
                    break;
                case UnknownEnum.Value_0:
                    break;
                case UnknownEnum.Value_1:
                    break;
            }
        }
        break;
    case "scientist_working":
        scr_npc_state_arms(obj_arms_scientist_working);
        if (scr_chance(0.2))
        {
            scr_draw_npc_text(id, UnknownEnum.Value_117);
        }
        break;
    case "mutant_patrol":
        scr_bullet_near();
        state_enemy_mutant_patrol();
        break;
    case "mutant_alert":
        scr_bullet_near();
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            target_seen = true;
            if (instance_exists(target))
            {
                target_for_image_scale = target.x;
                if (move_point_x == 0)
                {
                    range_ = 64;
                    move_point_x = target.x + irandom_range(-range_, range_);
                    move_point_y = target.y + irandom_range(-range_, range_);
                }
                last_seen_x = target.x;
                last_seen_y = target.y;
                var range_ = 64;
                if (scr_chance(npc_get_prob_move(npc_id)))
                {
                    move_point_x = target.x + irandom_range(-range_, range_);
                    move_point_y = target.y + irandom_range(-range_, range_);
                    path_timer = path_timer_reset + 1;
                }
                if (point_distance(x, y, move_point_x, move_point_y) < 8)
                {
                    move_point_x = target.x + irandom_range(-range_ * 2, range_ * 2);
                    move_point_y = target.y + irandom_range(-range_ * 2, range_ * 2);
                    path_timer = path_timer_reset + 1;
                }
                if (scr_chance(npc_get_prob_attack(npc_id)))
                {
                    move_point_x = target.x;
                    move_point_y = target.y;
                    path_timer = path_timer_reset + 1;
                }
                if (npc_id == "ghoul")
                {
                    if (ghoul_buffed_timer > 0)
                    {
                        ghoul_buffed_timer++;
                        if (ghoul_buffed_timer >= ghoul_buffed_timer_max)
                        {
                            ghoul_buffed_timer = 0;
                        }
                    }
                    if (point_distance(x, y, target.x, target.y) < 80 && point_distance(x, y, target.x, target.y) > 40)
                    {
                        if (can_attack == true)
                        {
                            if (scr_chance(2))
                            {
                                state = "ghoul_attack1";
                            }
                        }
                    }
                }
                if (npc_id == "ghoul_2")
                {
                    ghoul_2_buff_timer++;
                    if (ghoul_2_buff_timer >= ghoul_2_buff_timer_max)
                    {
                        ghoul_2_buff_timer = 0;
                        var a = UnknownEnum.Value_63;
                        var _o = obj_particles_controller;
                        part_particles_create(_o.particles_system[a], x + (image_xscale * 15), y - 6, _o.particles_type[a], 1);
                        with (obj_enemy_ghoul)
                        {
                            if (point_distance(x, y, other.x, other.y) < 80 && npc_id == "ghoul")
                            {
                                ghoul_buffed_timer = 1;
                            }
                        }
                    }
                }
                if (object_index == obj_enemy_big)
                {
                    if (scr_chance(0.2))
                    {
                        timer_ruggito = 0;
                        state = "big_aggro";
                    }
                    if (point_distance(x, y, target.x, target.y) > 32 && point_distance(x, y, target.x, target.y) < 80)
                    {
                        if (can_attack == true)
                        {
                            if (scr_chance(20))
                            {
                                can_attack = false;
                                alarm[8] = attack_recovery;
                                dir_attack = point_direction(x, y, target.x, target.y);
                                state = "big_attack1";
                                var sspd = 3;
                                hspd = lengthdir_x(sspd, dir_attack);
                                vspd = lengthdir_y(sspd, dir_attack);
                            }
                        }
                    }
                }
                if (object_index == obj_enemy_blink)
                {
                    if (point_distance(x, y, target.x, target.y) < 16)
                    {
                        if (can_attack == true)
                        {
                            can_attack = false;
                            state = "blink_attack1";
                            alarm[8] = attack_recovery;
                            audio_play_sound_on(emitter_talk, snd_blink_attack1, false, 20);
                        }
                    }
                }
            }
        }
        else
        {
            scr_mutant_target_not_in_sight();
        }
        scr_enemy_path();
        break;
    case "wolf_idle1":
        scr_enemy_choose_idle_or_move();
        scr_collision();
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            hspd = 0;
            vspd = 0;
            state = "wolf_ringhio";
        }
        if (target == -4)
        {
            tick++;
            if (tick >= tick_max)
            {
                tick = 0;
                var _x = x;
                var _y = y;
                var _next_state = "wolf_idle1";
                if (scr_chance(8))
                {
                    _next_state = "wolf_idle2";
                }
                if (scr_chance(5))
                {
                    _next_state = "wolf_sleep";
                }
                if (scr_chance(0.5))
                {
                    _next_state = "wolf_ululato";
                }
                var _move_x = 0;
                var _move_y = 0;
                with (obj_chest_general)
                {
                    if (chest_is_drop(tipo))
                    {
                        if (point_distance(x, y, _x, _y) < 96)
                        {
                            var _r = 10;
                            _move_x = x + irandom_range(-_r, _r);
                            _move_y = y + irandom_range(-_r / 2, _r / 2);
                        }
                    }
                }
                if (_move_x != 0 && _move_y != 0)
                {
                    var _eat_counter = 0;
                    with (obj_enemy_wolf_brown)
                    {
                        if (state == "wolf_eat" || state == "wolf_move_to_eat")
                        {
                            _eat_counter++;
                        }
                    }
                    if (_eat_counter < 2)
                    {
                        _next_state = "wolf_move_to_eat";
                        move_point_x = _move_x;
                        move_point_y = _move_y;
                        path_timer = path_timer_reset;
                    }
                }
                if (_next_state != "wolf_move_to_eat")
                {
                    var _ret = scr_wolf_decidi_attaccare();
                }
                if (_next_state == "wolf_ululato")
                {
                    var _sound = choose(snd_wolf_ul1, snd_wolf_ul2);
                    var sound_durata = audio_sound_length(_sound);
                    wolf_ululato_max = sound_durata * 60;
                    wolf_ululato = 0;
                    audio_play_sound_on(emitter_shoot, _sound, false, 20);
                }
                state = _next_state;
            }
        }
        break;
    case "wolf_idle2":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            hspd = 0;
            vspd = 0;
            state = "wolf_ringhio";
        }
        if (target == -4)
        {
            var _end = scr_animation_end(s_lupo_idle2);
            if (_end == true)
            {
                state = "wolf_idle1";
            }
        }
        break;
    case "wolf_move_to_eat":
        target = scr_find_target_for_mutant(wolf_alert_raggio2);
        if (target != -4)
        {
            hspd = 0;
            vspd = 0;
            state = "wolf_ringhio";
        }
        if (target == -4)
        {
            if (point_distance(x, y, move_point_x, move_point_y) < 4)
            {
                state = "wolf_eat";
            }
        }
        scr_enemy_path();
        break;
    case "wolf_eat":
        target = scr_find_target_for_mutant(wolf_alert_raggio2);
        if (target != -4)
        {
            hspd = 0;
            vspd = 0;
            state = "wolf_ringhio";
        }
        if (target == -4)
        {
            var _end = scr_animation_end(s_lupo_eat);
            if (_end == true)
            {
                if (scr_chance(12))
                {
                    state = "wolf_idle1";
                }
            }
        }
        scr_enemy_path();
        break;
    case "wolf_sleep":
        target = scr_find_target_for_mutant(wolf_alert_raggio2);
        if (target != -4)
        {
            hspd = 0;
            vspd = 0;
            state = "wolf_ringhio";
            image_index = 0;
        }
        if (target == -4)
        {
            var _end = scr_animation_end(s_lupo_sleep);
            if (_end == true)
            {
                if (scr_chance(20))
                {
                    state = "wolf_idle1";
                }
            }
        }
        break;
    case "wolf_ringhio":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        path_end();
        if (target != -4)
        {
            hspd = 0;
            vspd = 0;
            var _end = scr_animation_end(s_lupo_ringhio);
            if (_end == true)
            {
                var _attack = scr_wolf_decidi_attaccare();
                if (_attack == true)
                {
                    state = "wolf_alert";
                }
            }
        }
        if (target == -4)
        {
            var _end = scr_animation_end(s_lupo_ringhio);
            if (_end == true)
            {
                state = "wolf_idle1";
            }
        }
        break;
    case "wolf_alert":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (instance_exists(target))
        {
            if (target != -4)
            {
                hspd = 0;
                vspd = 0;
                tick++;
                if (tick >= tick_max)
                {
                    tick = 0;
                    var _next_state = "wolf_alert";
                    var _movex = 0;
                    var _movey = 0;
                    var _id = id;
                    var _counter_attack = 0;
                    var _max_attack = 3;
                    var _counter_ululato = 0;
                    var _ululato_max = 2;
                    var _target = target;
                    with (obj_enemy_wolf_brown)
                    {
                        if (id != _id)
                        {
                            if (state == "wolf_attack_1")
                            {
                                if (target == _target)
                                {
                                    _counter_attack++;
                                }
                            }
                            if (state == "wolf_ululato")
                            {
                                _counter_ululato++;
                            }
                        }
                    }
                    _id = id;
                    _target = target;
                    var _x = x;
                    var _y = y;
                    with (obj_enemy_wolf_brown)
                    {
                        if (_id != id)
                        {
                            if (target == -4)
                            {
                                if (point_distance(x, y, _x, _y) < 96)
                                {
                                    target = _target;
                                    search_target_id = _target;
                                }
                            }
                        }
                    }
                    if (scr_chance(30))
                    {
                        var _dir = irandom(360);
                        _dis = 32;
                        _movex = target.x + lengthdir_x(_dis, _dir);
                        _movey = target.y + lengthdir_y(_dis, _dir);
                        path_timer = path_timer_reset;
                    }
                    if (scr_chance(5))
                    {
                        _next_state = "wolf_ringhio";
                    }
                    var _dis = point_distance(x, y, target.x, target.y);
                    if (_dis < 32)
                    {
                        if (can_attack == true)
                        {
                            if (_counter_attack < _max_attack)
                            {
                                can_attack = false;
                                alarm[8] = 60;
                                _next_state = "wolf_attack_1";
                                dir_attack = point_direction(x, y, target.x, target.y);
                                var sspd = 2.5;
                                hspd = lengthdir_x(sspd, dir_attack);
                                vspd = lengthdir_y(sspd, dir_attack);
                            }
                        }
                    }
                    if (_counter_ululato < _ululato_max)
                    {
                        if (_counter_attack >= _max_attack)
                        {
                            if (scr_chance(12))
                            {
                                _next_state = "wolf_ululato";
                            }
                        }
                        if (scr_chance(2))
                        {
                            _next_state = "wolf_ululato";
                        }
                    }
                    _dis = point_distance(x, y, target.x, target.y);
                    if (_dis > 96)
                    {
                        var _dir = irandom(360);
                        _dis = 32;
                        _movex = target.x + lengthdir_x(_dis, _dir);
                        _movey = target.y + lengthdir_y(_dis, _dir);
                    }
                    if (_next_state == "wolf_ululato")
                    {
                        var _sound = choose(snd_wolf_ul1, snd_wolf_ul2);
                        var sound_durata = audio_sound_length(_sound);
                        wolf_ululato_max = sound_durata * 60;
                        wolf_ululato = 0;
                        audio_play_sound_on(emitter_shoot, _sound, false, 20);
                    }
                    state = _next_state;
                    move_point_x = _movex;
                    move_point_y = _movey;
                    var _ret = scr_wolf_decidi_attaccare();
                }
                if (point_distance(x, y, move_point_x, move_point_y) < 3)
                {
                    var _dis = 28;
                    var _dir = irandom(360);
                    var _movex = target.x + lengthdir_x(_dis, _dir);
                    var _movey = target.y + lengthdir_y(_dis, _dir);
                    move_point_x = _movex;
                    move_point_y = _movey;
                    path_timer = path_timer_reset;
                    var _ret = scr_wolf_decidi_attaccare();
                }
                if (move_point_x != 0 && move_point_y != 0)
                {
                    scr_enemy_path();
                }
                if (point_distance(x, y, target.x, target.y) > 220 && !(variable_instance_exists(id, "prologue_relentless") && prologue_relentless))
                {
                    state = "wolf_idle1";
                }
            }
            if (target == -4)
            {
                state = "wolf_idle1";
                if (instance_exists(search_target_id))
                {
                    if (point_distance(x, y, search_target_id.x, search_target_id.y) > 220)
                    {
                        state = "wolf_idle1";
                    }
                    else
                    {
                        scr_mutant_target_not_in_sight();
                    }
                }
            }
        }
        break;
    case "wolf_attack_1":
        path_end();
        var _end = scr_animation_end(s_lupo_a1);
        if (_end == true)
        {
            state = "wolf_alert";
            hspd = 0;
            vspd = 0;
        }
        if (instance_exists(target))
        {
            if (image_index < 5)
            {
                dir_attack = point_direction(x, y, target.x, target.y);
                var sspd = 3;
                hspd = lengthdir_x(sspd, dir_attack);
                vspd = lengthdir_y(sspd, dir_attack);
            }
            if (image_index >= 5)
            {
                scr_collision();
            }
        }
        else
        {
            state = "wolf_idle1";
        }
        break;
    case "wolf_attack_2":
        path_end();
        hspd = 0;
        vspd = 0;
        var _end = scr_animation_end(s_lupo_a2);
        if (_end == true)
        {
            state = "wolf_alert";
            hspd = 0;
            vspd = 0;
        }
        break;
    case "wolf_run_to_amico":
        if (point_distance(x, y, move_point_x, move_point_y) < 10)
        {
            state = "wolf_idle1";
        }
        scr_enemy_path();
        break;
    case "wolf_ululato":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        path_end();
        if (image_index >= (image_number - 2))
        {
            image_index = image_number - 2;
        }
        wolf_ululato++;
        if (wolf_ululato >= wolf_ululato_max)
        {
            if (target != -4)
            {
                hspd = 0;
                vspd = 0;
                state = "wolf_alert";
            }
            if (target == -4)
            {
                state = "wolf_idle1";
            }
        }
        break;
    case "big_aggro":
        path_end();
        hspd = 0;
        vspd = 0;
        if (image_index >= 3)
        {
            var sound_durata = audio_sound_length(snd_big_ruggito_1) - 2.5;
            timer_ruggito_max = sound_durata * 60;
            timer_ruggito = 0;
            audio_play_sound_on(emitter_shoot, snd_big_ruggito_1, false, 20);
            state = "big_ruggito";
        }
        break;
    case "big_ruggito":
        timer_ruggito++;
        if (timer_ruggito >= timer_ruggito_max)
        {
            timer_ruggito = 0;
            state = "mutant_alert";
        }
        break;
    case "big_attack1":
        path_end();
        if (instance_exists(target))
        {
            if (image_index >= (sprite_get_number(sprite_index) - 1))
            {
                state = "mutant_alert";
                path_timer = 999;
            }
            if (image_index >= 4)
            {
                hspd = 0;
                vsdp = 0;
            }
            scr_collision();
        }
        else
        {
            state = "mutant_alert";
        }
        break;
    case "boar_alert":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            target_for_image_scale = target.x;
            if (move_point_x == 0)
            {
                range_ = 64;
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            path_end();
            last_seen_x = target.x;
            last_seen_y = target.y;
            var range_ = 64;
            if (scr_chance(npc_get_prob_attack(npc_id)))
            {
                move_point_x = target.x;
                move_point_y = target.y;
            }
            if (scr_chance(npc_get_prob_move(npc_id)))
            {
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            if (point_distance(x, y, target.x, target.y) < 8)
            {
                var dir = point_direction(x, y, target.x, target.y);
                var spazio_frenata = 64;
                start_frenata_x = target.x + lengthdir_x(spazio_frenata, dir);
                start_frenata_y = target.y + lengthdir_y(spazio_frenata, dir);
                state = "boar_frenata";
                frenata_dir = dir;
            }
            if (point_distance(x, y, target.x, target.y) > 80)
            {
                if (scr_chance(5))
                {
                    state = "boar_raspare";
                    if (target == player_get_local())
                    {
                        audio_play_sound_on(emitter_shoot, snd_boar_charge, false, 10);
                    }
                }
            }
            mp_potential_step_object(move_point_x, move_point_y, npc_get_spd_alerted(npc_id), obj_solid);
        }
        else
        {
            scr_mutant_target_not_in_sight();
        }
        break;
    case "boar_frenata":
        frenata_step++;
        if (frenata_step >= frenata_step_max)
        {
            frenata_step = 0;
            state = "mutant_patrol";
        }
        hspd = lengthdir_x(npc_get_spd_alerted(npc_id), frenata_dir) - ((lengthdir_x(npc_get_spd_alerted(npc_id), frenata_dir) / frenata_step_max) * frenata_step);
        vspd = lengthdir_y(npc_get_spd_alerted(npc_id), frenata_dir) - ((lengthdir_y(npc_get_spd_alerted(npc_id), frenata_dir) / frenata_step_max) * frenata_step);
        scr_collision();
        break;
    case "boar_raspare":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        var _end = scr_animation_end(s_enemy_cinghiale_raspare);
        if (target != -4)
        {
            if (_end == true)
            {
                state = "boar_carica";
            }
        }
        else
        {
            scr_mutant_target_not_in_sight();
        }
        if (image_index == 2 || image_index == 8 || image_index == 14)
        {
            var a = UnknownEnum.Value_46;
            var ob = obj_particles_controller;
            if (image_xscale == 1)
            {
                part_type_direction(ob.particles_type[a], -10, 10, 0, 0);
            }
            else
            {
                part_type_direction(ob.particles_type[a], 170, 190, 0, 0);
            }
            part_emitter_region(ob.particles_system[a], ob.partciles_emitter[a], x + (2 * image_xscale), x + (2 * image_xscale), y + 13, y + 11, 0, 1);
            part_emitter_burst(ob.particles_system[a], ob.partciles_emitter[a], ob.particles_type[a], 4);
        }
        hspd = 0;
        vspd = 0;
        scr_collision();
        break;
    case "boar_carica":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            move_point_x = target.x;
            move_point_y = target.y;
            if (move_point_x != 0 && move_point_y != 0)
            {
                scr_enemy_path();
            }
            if (point_distance(x, y, target.x, target.y) < 8)
            {
                var dir = point_direction(x, y, target.x, target.y);
                var spazio_frenata = 64;
                start_frenata_x = target.x + lengthdir_x(spazio_frenata, dir);
                start_frenata_y = target.y + lengthdir_y(spazio_frenata, dir);
                state = "boar_frenata";
                frenata_dir = dir;
            }
        }
        else
        {
            scr_mutant_target_not_in_sight();
        }
        break;
    case "blink_attack1":
        hspd = 0;
        vspd = 0;
        path_end();
        if (image_index >= (sprite_get_number(sprite_index) - 1))
        {
            state = "mutant_alert";
        }
        break;
    case "wolf_attack":
        hspd = 0;
        vspd = 0;
        path_end();
        if (image_index >= (sprite_get_number(sprite_index) - 1))
        {
            state = "mutant_alert";
        }
        break;
    case "wolf_attack2":
        path_end();
        if (instance_exists(target))
        {
            if (image_index >= 6)
            {
                state = "mutant_alert";
                var range_ = 64;
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
                path_timer = 999;
            }
            scr_collision();
        }
        else
        {
            state = "mutant_patrol";
        }
        break;
    case "ghoul_attack1":
        path_end();
        hspd = 0;
        vspd = 0;
        if (instance_exists(target))
        {
            if (image_index >= 8 && can_attack == true)
            {
                dir_attack = point_direction(x, y, target.x, target.y);
                can_attack = false;
                alarm[8] = attack_recovery;
                var bul = instance_create_depth(x, y - 10, 0, obj_bullet_ghoul);
                var sspd = 3;
                bul.hspd = lengthdir_x(sspd, dir_attack);
                bul.vspd = lengthdir_y(sspd, dir_attack);
                bul.damage = 10;
                bul.shooter_faction = faction;
                bul.shooter_id = id;
                audio_play_sound_on(emitter_talk, snd_ghoul_attack, false, 5);
            }
            if (image_index >= 11)
            {
                state = "mutant_alert";
            }
        }
        break;
    case "wraith_fire_patrol":
        state_enemy_mutant_patrol();
        break;
    case "wraith_fire_alert":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            target_for_image_scale = target.x;
            if (move_point_x == 0)
            {
                range_ = 64;
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            path_end();
            var range_ = 128;
            if (scr_chance(npc_get_prob_attack(npc_id)))
            {
                move_point_x = target.x;
                move_point_y = target.y;
            }
            if (scr_chance(npc_get_prob_move(npc_id)))
            {
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            if (scr_chance(prob_attac))
            {
                var vel = bullet_spd;
                var dir = point_direction(x, y, target.x, target.y);
                var bull = instance_create_depth(x, y, -y, obj_bullet_wraith_fire);
                bull.hspd = lengthdir_x(vel, dir);
                bull.vspd = lengthdir_y(vel, dir);
                bull.damage = damage_bullet;
                bull.shooter_faction = faction;
                bull.shooter_id = id;
            }
            if (abs(x - move_point_x) < 8 && abs(y - move_point_y) < 8)
            {
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            mp_potential_step_object(move_point_x, move_point_y, npc_get_spd_alerted(npc_id), obj_solid);
        }
        else
        {
            scr_mutant_target_not_in_sight();
        }
        break;
    case "wraith_electric_patrol":
        state_enemy_mutant_patrol();
        break;
    case "wraith_electric_alert":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            target_for_image_scale = target.x;
            if (move_point_x == 0)
            {
                range_ = 64;
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            path_end();
            last_seen_x = target.x;
            last_seen_y = target.y;
            var range_ = 64;
            if (scr_chance(npc_get_prob_attack(npc_id)))
            {
                move_point_x = target.x;
                move_point_y = target.y;
            }
            if (scr_chance(npc_get_prob_move(npc_id)))
            {
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            if (point_distance(x, y, target.x, target.y) < 96)
            {
                if (scr_chance(prob_attack1))
                {
                    instance_create_depth(x, y, 0, obj_hud_get_hit);
                    var dis_ = point_distance(x, y, target.x, target.y);
                    var dir_ = point_direction(x, y, target.x, target.y);
                    var a = UnknownEnum.Value_10;
                    var ob = obj_particles_controller;
                    var dis1 = 0;
                    var dir1 = 0;
                    var amount_ = choose(-1, 1);
                    var dividendo = irandom(7) + 3;
                    var x1, y1;
                    for (var i = 0; i < dis_; i++)
                    {
                        var xo = x + lengthdir_x(i, dir_);
                        var yo = y + lengthdir_y(i, dir_);
                        dividendo = irandom(7) + 3;
                        if (frac(i / dividendo) == 0)
                        {
                            amount_ = -amount_;
                        }
                        dis1 += amount_;
                        dir1 = dir_ + 90;
                        x1 = xo + lengthdir_x(dis1, dir1);
                        y1 = yo + lengthdir_y(dis1, dir1);
                        part_emitter_region(ob.particles_system[a], ob.partciles_emitter[a], x1, x1, y1, y1, 0, 1);
                        part_emitter_burst(ob.particles_system[a], ob.partciles_emitter[a], ob.particles_type[a], ob.particle_amount[a]);
                    }
                    instance_create_depth(x1, y1, 0, obj_light_electric_spark);
                    if (target.object_index == obj_npc_parent || object_is_ancestor(target.object_index, obj_npc_parent))
                    {
                        npc_damage(target, dmg_attack1, id);
                    }
                    else
                    {
                        target.hp -= dmg_attack1;
                    }
                }
            }
            if (abs(x - move_point_x) < 8 && abs(y - move_point_y) < 8)
            {
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            mp_potential_step_object(move_point_x, move_point_y, npc_get_spd_alerted(npc_id), obj_solid);
        }
        else
        {
            scr_mutant_target_not_in_sight();
        }
        break;
    case "crystal_violet_alert":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            target_for_image_scale = target.x;
            if (move_point_x == 0)
            {
                range_ = 64;
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            path_end();
            last_seen_x = target.x;
            last_seen_y = target.y;
            var range_ = 64;
            if (scr_chance(npc_get_prob_attack(npc_id)))
            {
                move_point_x = target.x;
                move_point_y = target.y;
            }
            if (scr_chance(npc_get_prob_move(npc_id)))
            {
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            timer_bullet_now++;
            if (timer_bullet_now >= timer_bullet_max)
            {
                timer_bullet_now = 0;
                var _dir = point_direction(x, y, target.x, target.y);
                var bul = instance_create_depth(x, y, 0, obj_bullet_crystal_violet);
                var sspd = 2;
                bul.hspd = lengthdir_x(sspd, _dir);
                bul.vspd = lengthdir_y(sspd, _dir);
                bul.damage = 5;
                bul.shooter_faction = faction;
                bul.shooter_id = id;
                bul.image_angle = _dir;
                bul.target = target;
            }
            if (abs(x - move_point_x) < 8 && abs(y - move_point_y) < 8)
            {
                move_point_x = target.x + irandom_range(-range_, range_);
                move_point_y = target.y + irandom_range(-range_, range_);
            }
            mp_potential_step_object(move_point_x, move_point_y, npc_get_spd_alerted(npc_id), obj_solid);
        }
        else
        {
            scr_mutant_target_not_in_sight();
        }
        break;
    case "rabbit_idle":
        scr_enemy_choose_idle_or_move();
        scr_collision();
        if (scr_chance(0.5))
        {
            state = "rabbit_idle2";
            hspd = 0;
            vspd = 0;
        }
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            hspd = 0;
            vspd = 0;
            var range = 128;
            move_point_x = x + irandom_range(-range - (range / 2), range + (range / 2));
            move_point_y = y + irandom_range(-range - (range / 2), range + (range / 2));
            state = "rabbit_escape";
        }
        break;
    case "rabbit_idle2":
        scr_collision();
        if (image_index >= (sprite_get_number(s_rabbit_idle2) - 2))
        {
            state = "rabbit_idle";
        }
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            hspd = 0;
            vspd = 0;
            var range = 128;
            move_point_x = x + irandom_range(-range - (range / 2), range + (range / 2));
            move_point_y = y + irandom_range(-range - (range / 2), range + (range / 2));
            state = "rabbit_escape";
        }
        break;
    case "rabbit_escape":
        path_timer++;
        if (path_timer >= path_timer_reset)
        {
            path_timer = 0;
            path_end();
            path_clear_points(path_to_target);
            mp_grid_path(npc_motion_grid(), path_to_target, x, y, move_point_x, move_point_y, true);
            path_start(path_to_target, npc_get_spd_alerted(npc_id), path_action_stop, false);
        }
        target_for_image_scale = move_point_x;
        if (abs(x - move_point_x) < 16 && abs(y - move_point_y) < 16)
        {
            state = "rabbit_idle";
        }
        break;
    case "crow_idle1":
        scr_enemy_choose_idle_or_move();
        scr_collision();
        if (scr_chance(0.5))
        {
            state = "crow_idle2";
            hspd = 0;
            vspd = 0;
        }
        scr_enemy_crow_check_if_escape();
        break;
    case "crow_idle2":
        scr_collision();
        if (image_index >= (sprite_get_number(s_crow_idle2) - 2))
        {
            state = "crow_idle1";
        }
        scr_enemy_crow_check_if_escape();
        break;
    case "crow_escape":
        move_towards_point(move_point_x, move_point_y, 2.5);
        unstuck_counter_timer = 0;
        if (point_distance(x, y, move_point_x, move_point_y) < 16)
        {
            instance_destroy();
        }
        break;
    case "crow_eat":
        if (scr_chance(0.5))
        {
            state = "crow_pause_eat";
            hspd = 0;
            vspd = 0;
        }
        scr_enemy_crow_check_if_escape();
        break;
    case "crow_pause_eat":
        speed = 0;
        if (scr_chance(1))
        {
            image_index = 0;
            state = "crow_eat";
        }
        scr_enemy_crow_check_if_escape();
        break;
    case "crow_move_to_target":
        move_towards_point(move_point_x, move_point_y, 2);
        unstuck_counter_timer = 0;
        var _point_distance = point_distance(x, y, move_point_x, move_point_y);
        if (_point_distance < 128 && _point_distance > 64)
        {
            if (scr_chance(10))
            {
                var ss = choose(snd_bird_fly1, snd_bird_fly2, snd_bird_fly3, snd_bird_fly4, snd_bird_fly5);
                if (!audio_is_playing(ss))
                {
                    audio_play_sound(ss, 10, false);
                }
            }
        }
        if (_point_distance < (irandom(3) + 1))
        {
            speed = 0;
            var range = 500;
            var dir = irandom_range(45, 135);
            move_point_x = x + lengthdir_x(range, dir);
            move_point_y = y + lengthdir_y(range, dir);
            if (scr_chance(30))
            {
                state = "crow_pause_eat";
            }
            else
            {
                state = "crow_eat";
            }
        }
        break;
    case "infestation_idle":
        target = scr_find_target_for_mutant(npc_get_alert_visual_distance(npc_id));
        if (target != -4)
        {
            timer++;
            if (timer >= timer_max)
            {
                timer = 0;
                if (spawned < spawn_max)
                {
                    var _amount = spawn_amount;
                    if (spawned == 0)
                    {
                        _amount = 3;
                    }
                    repeat (_amount)
                    {
                        var oo = instance_create_depth(x, y + 8, 0, obj_enemy_ghoul);
                        oo.target = target;
                        oo.search_target_id = target;
                    }
                    spawned += _amount;
                }
            }
        }
        break;
    default:
        trace_error("State \"", state, "\" unhandled");
        break;
}
if (is_in_raid())
{
    if (global.emission_make_npc_die == true)
    {
        if (global.is_emission_now == false)
        {
            if (instance_exists(obj_map_generator))
            {
                if (y < obj_map_generator.map_height)
                {
                    hp = -100;
                }
            }
        }
    }
}
if (hp <= 0)
{
    hp = -100;
    if (play_sound_death == true)
    {
        var sound_ = -1;
        switch (object_index)
        {
            case obj_enemy_wolf_brown:
                sound_ = snd_wolf_death;
                break;
            case obj_enemy_boar:
                sound_ = snd_boar_death;
                break;
            case obj_enemy_boar_zombie:
                sound_ = snd_boar_death;
                break;
            case obj_enemy_ghoul:
                sound_ = snd_ghoul_death;
                break;
            case obj_enemy_spider:
                sound_ = snd_spider_death;
                break;
            case obj_enemy_big:
                sound_ = snd_big_death;
                break;
        }
        if (sound_ != -1)
        {
            var emitter_death = instance_create_depth(x, y, 0, obj_emitter_death_sound);
            emitter_death.sound_ = sound_;
        }
    }
    if (object_index == obj_enemy_infestation || object_index == obj_enemy_infestation_motel)
    {
        var o = obj_particles_controller;
        var a = UnknownEnum.Value_2;
        part_particles_create(o.particles_system[a], x, y, o.particles_type[a], o.particle_amount[a]);
    }
    if (object_index == obj_forest_trader)
    {
        global.az_done[UnknownEnum.Value_1] = true;
    }
    if (object_index == obj_junk_trader)
    {
        global.az_done[UnknownEnum.Value_11] = true;
    }
    var _size = array_length(global.list_n_id);
    for (var i = 0; i < _size; i++)
    {
        if (id == global.list_n_id[i])
        {
            global.list_n_id[i] = -4;
            global.list_n_hp[i] = -10;
            part_create_blood(0, 360, 7);
        }
    }
    if (dead_outside_game_window == true)
    {
        create_item_in_chest = false;
    }
    if (!npc_died_event_sent)
    {
        npc_died_event_sent = true;
        mods_perform_event("npc_died", [id, npc_id, id_of_the_killer, false, x, y], id);
    }
    if (instance_exists(id))
    {
        instance_destroy();
    }
}
if (state == "wolf_ringhio" && state_before != "wolf_ringhio")
{
    audio_play_sound_on(emitter_talk, snd_wolf_growl, false, 8);
}
if (state == "ghoul_attack1" && state_before != "ghoul_attack1" && bark_cooldown <= 0)
{
    audio_play_sound_on(emitter_talk, snd_ghoul_1, false, 5);
    bark_cooldown = 180;
}
if (state != "deactivate")
{
    state_before = state;
}
if (!is_in_hub())
{
    var _sight = player_npc_sight(x, y, x - sight_last_x, y - sight_last_y);
    sight_last_x = x;
    sight_last_y = y;
    var _visibility = _sight == 2;
    if (_sight == undefined)
    {
    }
    else
    {
        var _alpha_target = 0;
        if (_visibility || remain_visible_frames > 0 || shot_reveal_frames > 0)
        {
            _alpha_target = 1;
        }
        else if (_sight == 1)
        {
            _alpha_target = 0.45;
        }
        if (_alpha_target == 1)
        {
            sight_glimpse = false;
        }
        else if (_alpha_target > 0)
        {
            sight_glimpse = true;
        }
        if (_alpha_target > 0)
        {
            timer_visible = 0;
            if (image_alpha < _alpha_target)
            {
                image_alpha = min(_alpha_target, max(0.5, image_alpha + 0.25));
            }
            else
            {
                image_alpha = max(_alpha_target, image_alpha - (a_gain / 2));
            }
        }
        else
        {
            var _out_of_sight_steps = variable_global_exists("fow_out_of_sight_steps") ? global.fow_out_of_sight_steps : 10;
            timer_visible++;
            if (timer_visible >= (_out_of_sight_steps * global.sk_k[UnknownEnum.Value_14]))
            {
                image_alpha = max(0, image_alpha - 0.1);
            }
        }
    }
    if (!_visibility && frames_left_of_prolonged_vision > 0 && remain_visible_frames < 0)
    {
        remain_visible_frames = global.skills_data.prolonged_vision.value_1;
        frames_left_of_prolonged_vision = 0;
    }
    if (remain_visible_frames >= 0)
    {
        remain_visible_frames--;
    }
    if (frames_left_of_prolonged_vision >= 0)
    {
        frames_left_of_prolonged_vision--;
    }
    if (shot_reveal_frames > 0)
    {
        shot_reveal_frames--;
    }
    if (_visibility && collision_point(obj_cursor.aa_x, obj_cursor.aa_y, id, true, false))
    {
        hover_frames++;
        skill_vital_shooting_frames++;
        _player.hovering_enemy = true;
    }
    else
    {
        hover_frames = 0;
        skill_vital_shooting_frames = 0;
    }
}
if (_lista_near_me != undefined)
{
    ds_list_destroy(_lista_near_me);
}
mods_object_perform_event("step_normal_event");

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_4,
    Value_6 = 6,
    Value_7,
    Value_8,
    Value_9,
    Value_10,
    Value_11,
    Value_12,
    Value_14 = 14,
    Value_29 = 29,
    Value_37 = 37,
    Value_46 = 46,
    Value_63 = 63,
    Value_69 = 69,
    Value_70,
    Value_117 = 117,
    Value_119 = 119,
    Value_120,
    Value_127 = 127,
    Value_129 = 129,
    Value_134 = 134,
    Value_139 = 139,
    Value_144 = 144,
    Value_151 = 151,
    Value_156 = 156,
    Value_157,
    Value_159 = 159,
    Value_162 = 162,
    Value_164 = 164,
    Value_165,
    Value_168 = 168
}
