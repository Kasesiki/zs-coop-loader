function scr_player_movement(arg0, arg1, arg2)
{
    var _speed_multiplier = arg0;
    var _can_move = arg1;
    var _can_run = arg2;
    var camx = camera_get_view_x(view_camera[0]);
    var camy = camera_get_view_y(view_camera[0]);
    var action = false;
    var _stamina_drain_mulitplier = 1;
    if (skill_hunter_obtained("nudist"))
    {
        var _loot = player_loadout_get_armor();
        var _armor_class = 0;
        if (_loot != undefined)
        {
            _armor_class = item_armor_get_class(_loot.item);
        }
        if (_armor_class >= 3)
        {
            _stamina_drain_mulitplier = 1 - struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("nudist")), variable_get_hash("stamina_drain"));
        }
    }
    stamina_run_drain = lerp(0.18, 0.75, player_weight / max_weight);
    stamina_run_drain *= (global.sk_k[UnknownEnum.Value_4] * _stamina_drain_mulitplier);
    var can_run = true;
    var can_walk = true;
    var _left = max(global.kb_hold[UnknownEnum.Value_3], obj_gamepad.action[UnknownEnum.Value_3].decimal);
    var _right = max(global.kb_hold[UnknownEnum.Value_2], obj_gamepad.action[UnknownEnum.Value_2].decimal);
    var _up = max(global.kb_hold[UnknownEnum.Value_0], obj_gamepad.action[UnknownEnum.Value_0].decimal);
    var _down = max(global.kb_hold[UnknownEnum.Value_1], obj_gamepad.action[UnknownEnum.Value_1].decimal);
    var _run = max(global.kb_hold[UnknownEnum.Value_4], obj_gamepad.action[UnknownEnum.Value_4].value);
    if (_can_run == false)
    {
        can_run = false;
    }
    if (_can_move == false)
    {
        can_walk = false;
    }
    var walk_k = 1;
    if (player_weight > max_weight)
    {
        can_run = false;
        if (is_in_hub())
        {
            can_run = true;
        }
    }
    if (player_weight > max_weight)
    {
        walk_k = 0.5;
        if (is_in_hub())
        {
            walk_k = 1;
        }
    }
    if (player_weight > (max_weight + 5))
    {
        can_walk = false;
        walk_k = 0;
        if (skill_hunter_obtained("mule"))
        {
            can_walk = true;
            walk_k = 0.4;
        }
        if (is_in_hub())
        {
            walk_k = 1;
            can_walk = true;
        }
    }
    if (mouse_check_button(mb_right) && !skill_active("run_and_gun"))
    {
        can_run = false;
    }
    if (can_run_after_exit_building == false)
    {
        can_run = false;
    }
    if (stamina >= 5)
    {
        sprint_exhausted = false;
    }
    var _exhausted_candidate = can_run && (sprint_exhausted || (!sprint_is_active && stamina < 5));
    var _exhausted_sprinting = false;
    if (sprint_is_active)
    {
        if (stamina <= 0)
        {
            can_run = false;
        }
    }
    else if (stamina < 5)
    {
        can_run = false;
    }
    if (_exhausted_candidate)
    {
        can_run = false;
    }
    var _hunterskills_movementspeed = 0;
    var _weapons = player_loadout_get_weapons();
    _hunterskills_movementspeed += (0.05 * (array_length(_weapons) < 1));
    _hunterskills_movementspeed += (0.05 * (array_length(_weapons) < 2));
    if (skill_hunter_obtained("nudist"))
    {
        var _loot = player_loadout_get_armor();
        var _armor_class = 0;
        if (_loot != undefined)
        {
            _armor_class = item_armor_get_class(_loot.item);
        }
        if (_armor_class <= 3)
        {
            _hunterskills_movementspeed += struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("nudist")), variable_get_hash("movement_speed"));
        }
    }
    spd_walk = 0.75 * ((100 + item_backpack_get_movement_speed(backpack_now)) / 100) * (_speed_multiplier + _hunterskills_movementspeed);
    spd_run = 1.2 * ((100 + item_backpack_get_movement_speed(backpack_now)) / 100) * (_speed_multiplier + _hunterskills_movementspeed);
    if (skill_active("emergency_sprint") && frames_since_last_swap_weapon <= global.skills_data.emergency_sprint.value_2)
    {
        spd_run *= global.skills_data.emergency_sprint.value_1;
        spd_walk *= global.skills_data.emergency_sprint.value_1;
    }
    if (skill_active("rolling_start") && frames_since_standing_still >= global.skills_data.rolling_start.value_1)
    {
        rolling_start_frames_cooldown = global.skills_data.rolling_start.value_3;
    }
    if (rolling_start_frames_cooldown > 0)
    {
        spd_run *= (1 + global.skills_data.rolling_start.value_2);
        spd_walk *= (1 + global.skills_data.rolling_start.value_2);
    }
    if (adrenalinerush_movement_speed_timer > 0)
    {
        spd_run *= (1 + struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("adrenalinerush")), variable_get_hash("movement_speed_bonus")));
        spd_walk *= (1 + struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("adrenalinerush")), variable_get_hash("movement_speed_bonus")));
    }
    if (skill_hunter_obtained("marathonrunner"))
    {
        if (arma_now == "no_item")
        {
            spd_run *= (1 + struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("marathonrunner")), variable_get_hash("movement_speed_bonus")));
            spd_walk *= (1 + struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("marathonrunner")), variable_get_hash("movement_speed_bonus")));
        }
    }
    if (is_in_hub())
    {
        spd_run *= 1.5;
    }
    var _sprint_toggle_mode = settings_get("toggle_sprint") || !obj_gamepad.last_input_keyboard;
    if (global.kb_pressed[UnknownEnum.Value_4] || obj_gamepad.action[UnknownEnum.Value_4].pressed)
    {
        sprint_suppressed = false;
        if (_sprint_toggle_mode)
        {
            sprint_is_toggled_now = !sprint_is_toggled_now;
        }
    }
    if (!_sprint_toggle_mode)
    {
        sprint_is_toggled_now = false;
    }
    if (sprint_is_toggled_now == true)
    {
        _run = true;
    }
    if (sprint_suppressed)
    {
        _run = false;
    }
    if (_run)
    {
        if (can_run == true)
        {
            if (_left || _down || _right || _up)
            {
                current_spd = (spd_run * global.sk_k[UnknownEnum.Value_5]) + (global.debug_speed * 4);
                image_speed_move_current = 0.75;
                walk_time++;
                if (player_weight < global.sk_k[UnknownEnum.Value_2])
                {
                    stamina += stamina_run_drain;
                }
                var _max_weight = inventory_calculate_max_weight(backpack_now);
                if (skill_hunter_obtained("jogger"))
                {
                    if (player_weight < (_max_weight * struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("jogger")), variable_get_hash("required_total_weight"))))
                    {
                        stamina += stamina_run_drain;
                    }
                }
                if (is_in_hub())
                {
                    stamina += stamina_run_drain;
                }
            }
        }
        else if (_exhausted_candidate && (_left || _down || _right || _up))
        {
            _exhausted_sprinting = true;
            _run = false;
        }
        else
        {
            _run = false;
            sprint_is_toggled_now = false;
        }
    }
    if (_exhausted_sprinting)
    {
        sprint_exhausted_timer = 1;
    }
    else
    {
        sprint_exhausted = false;
    }
    sprint_is_active = _run;
    if (!_run)
    {
        if (can_walk == true)
        {
            current_spd = spd_walk * walk_k;
            image_speed_move_current = 0.4;
            if (_exhausted_sprinting)
            {
                var _walk_spd = current_spd;
                var _run_spd = spd_run * global.sk_k[UnknownEnum.Value_5];
                current_spd = min(_walk_spd * 1.3, _run_spd);
                var _blend = (_run_spd > _walk_spd) ? clamp((current_spd - _walk_spd) / (_run_spd - _walk_spd), 0, 1) : 0;
                image_speed_move_current = lerp(0.4, 0.75, _blend);
            }
        }
        else
        {
            current_spd = 0;
        }
    }
    if (_left <= 0 && _down <= 0 && _right <= 0 && _up <= 0)
    {
        current_spd = 0;
        sprint_is_toggled_now = false;
        sprint_resume_pending = false;
    }
    hspd = current_spd * (_right - _left) * mutant_slow_multiplier;
    vspd = current_spd * (_down - _up) * mutant_slow_multiplier;
    if (hspd != 0 && vspd != 0)
    {
        hspd /= 1.4;
        vspd /= 1.4;
    }
    if (mouse_check_button(mb_right))
    {
        hspd *= 0.5;
        vspd *= 0.5;
    }
    scr_collision();
    if (_run)
    {
        if (can_run == true)
        {
            if (_left || _down || _right || _up)
            {
                if (hspd != 0 || vspd != 0)
                {
                    stamina -= stamina_run_drain;
                    if (stamina <= 0)
                    {
                        sprint_exhausted = true;
                        sprint_exhausted_timer = 1;
                    }
                }
            }
        }
    }
    if (hspd != 0 || vspd != 0)
    {
        fatigue -= (player_weight * 0.00003 * global.sk_k[UnknownEnum.Value_60]);
        frames_since_standing_still = 0;
    }
    else
    {
        frames_since_standing_still++;
    }
    scr_direzione_sprite();
    if (_left || _down || _right || _up)
    {
        recoil_from_movement += (item_get_weight(arma_now) / 5);
        walk_time++;
        if (walk_time >= 28)
        {
            walk_time = 0;
            if (hspd != 0 || vspd != 0)
            {
                ai_hearing_emit(id, _run);
                scr_choose_footstep_sound(UnknownEnum.Value_1);
            }
        }
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
    Value_60 = 60
}
