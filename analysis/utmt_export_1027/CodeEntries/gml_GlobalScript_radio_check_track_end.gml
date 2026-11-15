function radio_check_track_end()
{
    if (!variable_global_exists("radio_struct"))
    {
        exit;
    }
    if (!global.radio_struct.on)
    {
        exit;
    }
    var _master = global.radio_struct.master_instance;
    if (_master == -4)
    {
        radio_master_sync(false);
        exit;
    }
    audio_sound_loop(_master, global.radio_struct.loop_track);
    if (global.radio_struct.loop_track)
    {
        exit;
    }
    if (!audio_is_playing(_master))
    {
        global.radio_struct.master_instance = -4;
        radio_next_track(true);
    }
}
