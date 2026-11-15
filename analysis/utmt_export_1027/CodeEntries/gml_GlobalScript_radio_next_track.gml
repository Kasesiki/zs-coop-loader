function radio_next_track(arg0 = true)
{
    var _track_now = global.radio_struct.track_now;
    var _available_array = radio_get_unlocked_array();
    if (array_length(_available_array) <= 0)
    {
        exit;
    }
    if (arg0)
    {
        repeat (50)
        {
            var _i = irandom(array_length(_available_array) - 1);
            var _new_track = _available_array[_i];
            if (_new_track != _track_now || array_length(_available_array) == 1)
            {
                global.radio_struct.track_now = _new_track;
                break;
            }
        }
    }
    radio_master_sync(true);
    radio_hub_sync();
}
