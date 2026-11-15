function radio_master_sync(arg0 = false)
{
    var _track_snd = radio_get_sound(global.radio_struct.track_now);
    if (is_undefined(_track_snd))
    {
        exit;
    }
    var _master = global.radio_struct.master_instance;
    if (_master != -4)
    {
        if (!audio_is_playing(_master))
        {
            global.radio_struct.master_instance = -4;
            _master = -4;
        }
    }
    if (arg0)
    {
        if (_master != -4 && audio_is_playing(_master))
        {
            audio_stop_sound(_master);
        }
        global.radio_struct.master_instance = audio_play_sound(_track_snd, 20, global.radio_struct.loop_track);
        audio_sound_gain(global.radio_struct.master_instance, 0, 0);
    }
    else if (_master == -4)
    {
        global.radio_struct.master_instance = audio_play_sound(_track_snd, 20, global.radio_struct.loop_track);
        audio_sound_gain(global.radio_struct.master_instance, 0, 0);
    }
    else
    {
        audio_sound_loop(global.radio_struct.master_instance, global.radio_struct.loop_track);
    }
}
