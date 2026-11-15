depth = -y;
if (instance_exists(obj_map_generator))
{
    if (obj_map_generator.state == UnknownEnum.Value_21)
    {
        if (obj_map_generator.area == UnknownEnum.Value_9 && !quest_is_complete("watcher_headquarters"))
        {
            instance_destroy();
            exit;
        }
        if (state == UnknownEnum.Value_6)
        {
            if (go_back == false)
            {
                spd_now += acc;
                spd_now = clamp(spd_now, 0, spd);
                x -= spd_now;
                if (x < stop_x)
                {
                    spd_now = 0;
                }
            }
            else
            {
                spd_now += acc;
                spd_now = clamp(spd_now, 0, spd);
                x += spd_now;
                if (x > stop_x)
                {
                    spd_now = 0;
                }
            }
        }
        if (state == UnknownEnum.Value_9)
        {
            spd_now = 0;
            if (player_deployed == false)
            {
                player_deployed = true;
                with (obj_player_parent)
                {
                    y = other.y + 24;
                    visible = true;
                    player_set_state(scr_player_state_move, mp_index);
                }
                if (!exit_train_mod_event_performed)
                {
                    exit_train_mod_event_performed = true;
                    mods_perform_event("exit_train");
                }
                alarm[3] = 60;
                stop_x = -300;
                alarm[1] = 60;
                obj_controller.alarm[5] = 5400;
                if (instance_exists(obj_camera))
                {
                    obj_camera.follow = UnknownEnum.Value_1;
                }
            }
            if (skip_go == true)
            {
                if (skip_timer > 0)
                {
                    skip_timer--;
                    skip_alpha -= (1 / skip_timer_max);
                }
                else
                {
                    skip_go = false;
                    skip_alpha = 0;
                }
            }
            skip_alpha = clamp(skip_alpha, 0, 1);
        }
        if (state == UnknownEnum.Value_8)
        {
            spd_now = spd;
            if ((x - stop_x) < dis_frenata)
            {
                spd_now = lerp(0, spd, (x - stop_x) / dis_frenata);
                if (spd_now < 0.3)
                {
                    spd_now = 0;
                }
            }
            x -= spd_now;
            if (spd_now == 0)
            {
                state = UnknownEnum.Value_9;
                obj_minimap.alarm[1] = 2;
                alarm[1] = wait_time;
            }
            if (obj_map_generator.area != UnknownEnum.Value_9 && (keyboard_check_pressed(vk_space) || obj_gamepad.action[UnknownEnum.Value_6].pressed || obj_gamepad.input_pressed[UnknownEnum.Value_13]))
            {
                if (obj_map_generator.state == UnknownEnum.Value_21)
                {
                    skip_go = true;
                }
            }
            if (skip_go == true)
            {
                if (skip_timer < skip_timer_max)
                {
                    skip_timer++;
                    skip_alpha += (1 / skip_timer_max);
                }
                else
                {
                    skip_timer = skip_timer_max;
                    skip_alpha = 1;
                    x = stop_x;
                    with (obj_player_parent)
                    {
                        x = other.stop_x;
                    }
                    state = UnknownEnum.Value_9;
                    obj_minimap.alarm[1] = 2;
                    obj_controller.alarm[4] = 5;
                    spd_now = 0;
                    if (!exit_train_mod_event_performed)
                    {
                        exit_train_mod_event_performed = true;
                        mods_perform_event("exit_train");
                    }
                }
            }
            skip_alpha = clamp(skip_alpha, 0, 1);
        }
        if (spd_now > 0)
        {
            var a = UnknownEnum.Value_28;
            var ob = obj_particles_controller;
            var rr = 2;
            var _particle_array = variable_struct_get(global.train_skin_struct_data, skin_type).particle;
            for (var i = 0; i < array_length(_particle_array); i++)
            {
                var sx = x - (_particle_array[i].x * image_xscale);
                var sy = y - _particle_array[i].y;
                part_emitter_region(ob.particles_system[a], ob.partciles_emitter[a], sx - rr, sx + rr, sy - rr, sy + rr, 0, 1);
                part_emitter_burst(ob.particles_system[a], ob.partciles_emitter[a], ob.particles_type[a], 2);
            }
        }
        image_speed = spd_now / 4;
        audio_emitter_position(train_snd_emitter, x, y, 0);
        if (train_snd_id == -1 || !audio_is_playing(train_snd_id))
        {
            train_snd_id = audio_play_sound_on(train_snd_emitter, snd_train, 0, true);
            audio_sound_gain(train_snd_id, 0, 0);
        }
        var _target_gain = clamp(abs(spd_now) / spd, 0, 1) * train_snd_max_gain;
        if (state == UnknownEnum.Value_9 || state == UnknownEnum.Value_7)
        {
            _target_gain = 0;
        }
        train_snd_gain = lerp(train_snd_gain, _target_gain, train_snd_lerp);
        if (train_snd_gain < 0.01)
        {
            train_snd_gain = 0;
        }
        audio_sound_gain(train_snd_id, train_snd_gain, 0);
    }
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_6 = 6,
    Value_7,
    Value_8,
    Value_9,
    Value_13 = 13,
    Value_21 = 21,
    Value_28 = 28
}
