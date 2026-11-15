emitter_music = audio_emitter_create();
audio_emitter_falloff(emitter_music, 64, 256, 1);
audio_emitter_position(emitter_music, x, y, 0);
track_instance = -4;
prev_track = -4;
on = false;
track = "";
volume = 1;
