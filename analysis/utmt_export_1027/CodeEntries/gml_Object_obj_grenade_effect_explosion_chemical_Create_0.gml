alarm[0] = 180;
emitter_explosion = audio_emitter_create();
audio_emitter_falloff(emitter_explosion, 200, 500, 1);
audio_play_sound_on(emitter_explosion, snd_grenade_explosion_1, false, 20, 1.5);
scr_create_particle(UnknownEnum.Value_55, 1);
scr_create_particle(UnknownEnum.Value_53, 10);
scr_create_particle(UnknownEnum.Value_54, 4);
ricochet_counter_max = 60;
ricochet_counter = 0;

enum UnknownEnum
{
    Value_53 = 53,
    Value_54,
    Value_55
}
