function radio_load()
{
    var _default_unlocked = {};
    for (var i = 0; i < array_length(global.radio_music_array); i++)
    {
        var _id = global.radio_music_array[i];
        if (radio_get_unlocked_by_default(_id))
        {
            variable_struct_set(_default_unlocked, _id, true);
        }
    }
    db_open("general");
    var _unlocked = db_read("radio", "unlocked", _default_unlocked);
    for (var i = 0; i < array_length(global.radio_music_array); i++)
    {
        var _id = global.radio_music_array[i];
        if (radio_get_unlocked_by_default(_id))
        {
            variable_struct_set(_unlocked, _id, true);
        }
    }
    global.radio_struct = 
    {
        on: db_read("radio", "on", false),
        track_now: db_read("radio", "track_now", "main_menu_2"),
        volume: db_read("radio", "volume", 0.5),
        unlocked: _unlocked,
        loop_track: db_read("radio", "loop_track", false),
        master_instance: noone
    };
    db_close();
}
