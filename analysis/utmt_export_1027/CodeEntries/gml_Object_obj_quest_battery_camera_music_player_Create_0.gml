emitter_music = audio_emitter_create();
audio_emitter_falloff(emitter_music, 32, 128, 1);
audio_emitter_position(emitter_music, x, y, 0);
audio_emitter_gain(emitter_music, 0.2);
audio_play_sound_on(emitter_music, snd_radio_kyle_campfire_guitar, true, 20);
