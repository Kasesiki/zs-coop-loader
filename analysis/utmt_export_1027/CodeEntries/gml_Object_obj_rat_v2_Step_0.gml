event_inherited();
var _chance = 0.8333333333333334;
if (scr_chance(_chance))
{
    var sound = choose(snd_rat_v2_1, snd_rat_v2_2, snd_rat_v2_3);
    audio_play_sound_on(emitter_talk, sound, false, 5);
}
