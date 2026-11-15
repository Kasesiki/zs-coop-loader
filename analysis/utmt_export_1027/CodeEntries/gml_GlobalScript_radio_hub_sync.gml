function radio_hub_sync()
{
    if (!variable_global_exists("radio_struct"))
    {
        exit;
    }
    var _track_snd = radio_get_sound(global.radio_struct.track_now);
    var _master = global.radio_struct.master_instance;
    var _master_pos = 0;
    if (_master != -4 && audio_is_playing(_master))
    {
        _master_pos = audio_sound_get_track_position(_master);
    }
    with (obj_radio_speaker_play_music)
    {
        on = global.radio_struct.on;
        track = global.radio_struct.track_now;
        volume = global.radio_struct.volume;
        audio_emitter_gain(emitter_music, on ? volume : 0);
        if (is_undefined(_track_snd))
        {
            exit;
        }
        var _restart = false;
        if (track_instance == -4)
        {
            _restart = true;
        }
        else
        {
            if (!audio_is_playing(track_instance))
            {
                track_instance = -4;
                _restart = true;
            }
            if (prev_track != _track_snd)
            {
                _restart = true;
            }
        }
        if (_restart)
        {
            if (track_instance != -4 && audio_is_playing(track_instance))
            {
                audio_stop_sound(track_instance);
            }
            track_instance = audio_play_sound_on(emitter_music, _track_snd, global.radio_struct.loop_track, 20, 1);
            if (_master != -4 && audio_is_playing(_master))
            {
                audio_sound_set_track_position(track_instance, _master_pos);
            }
            prev_track = _track_snd;
        }
        else
        {
            audio_sound_loop(track_instance, global.radio_struct.loop_track);
        }
    }
}
