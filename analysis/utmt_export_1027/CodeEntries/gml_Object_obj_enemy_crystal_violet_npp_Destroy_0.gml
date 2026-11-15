if (audio_is_playing(crystal_sound_loop))
{
    audio_stop_sound(crystal_sound_loop);
}
audio_emitter_free(emitter_crystal_sound);
instance_activate_object(obj_bullet_crystal_violet);
with (obj_bullet_crystal_violet)
{
    instance_destroy();
}
instance_activate_object(obj_enemy_ghoul);
instance_activate_object(obj_enemy_ghoul_2);
array_push(obj_controller.function_queue_end_step, method(undefined, function()
{
    with (obj_enemy_ghoul)
    {
        instance_destroy();
    }
    with (obj_enemy_ghoul_2)
    {
        instance_destroy();
    }
}));
complete_quest("last_quest", 4);
end_game_start_boss_transition(x, y);
