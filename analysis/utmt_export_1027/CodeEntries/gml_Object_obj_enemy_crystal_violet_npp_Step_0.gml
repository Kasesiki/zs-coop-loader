audio_emitter_position(emitter_crystal_sound, x, y, 0);
if (!audio_is_playing(crystal_sound_loop))
{
    crystal_sound_loop = audio_play_sound_on(emitter_crystal_sound, snd_cristallo_viola, true, crystal_sound_priority);
}
if (!boss_combat_started)
{
    hspd = 0;
    vspd = 0;
    if (first_shot_from_player)
    {
        boss_combat_started = true;
        with (obj_npc_draw_text)
        {
            if (id_che_parla == other.id)
            {
                instance_destroy();
            }
        }
    }
    else if (!boss_intro_started)
    {
        if (player_exists_local())
        {
            var _player = player_get_local();
            if (point_distance(x, y, _player.x, _player.y) <= boss_intro_radius)
            {
                boss_intro_started = true;
                scr_draw_npc_text(id, UnknownEnum.Value_324);
            }
        }
    }
    else
    {
        boss_intro_text_active = false;
        with (obj_npc_draw_text)
        {
            if (id_che_parla == other.id)
            {
                if (text_id == UnknownEnum.Value_324 || text_id == UnknownEnum.Value_325)
                {
                    other.boss_intro_text_active = true;
                }
            }
        }
        if (!boss_intro_text_active)
        {
            boss_combat_started = true;
        }
    }
}
if (boss_combat_started)
{
    event_inherited();
    if (!instance_exists(id) || hp <= 0)
    {
        exit;
    }
    if (!ghoul_spawn_positions_cached)
    {
        instance_activate_object(obj_infestation_crystal);
        var _cache_positions = method(
        {
            boss_id: id
        }, function()
        {
            if (!instance_exists(boss_id))
            {
                exit;
            }
            with (boss_id)
            {
                with (obj_infestation_crystal)
                {
                    array_push(other.ghoul_spawn_positions, 
                    {
                        x: x,
                        y: y
                    });
                }
                ghoul_spawn_positions_cached = true;
            }
        });
        array_push(obj_controller.function_queue_end_step, _cache_positions);
    }
    if (player_exists_local())
    {
        timer_ghoul_spawn_now++;
        var _spawn_count = array_length(ghoul_spawn_positions);
        if (timer_ghoul_spawn_now >= timer_ghoul_spawn_max && _spawn_count > 0)
        {
            timer_ghoul_spawn_now = 0;
            var _spawn_pos = ghoul_spawn_positions[irandom(_spawn_count - 1)];
            var _ghoul = instance_create_depth(_spawn_pos.x, _spawn_pos.y + ghoul_spawn_y_offset, 0, obj_enemy_ghoul_2);
            with (_ghoul)
            {
                npc_force_moving_towards_player();
            }
        }
    }
}

enum UnknownEnum
{
    Value_324 = 324,
    Value_325
}
