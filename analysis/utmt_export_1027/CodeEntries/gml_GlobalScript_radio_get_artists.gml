function radio_get_artists(arg0)
{
    var _struct = variable_struct_get(global.radio_music, arg0);
    if (!is_struct(_struct))
    {
        trace_error("Radio Music \"", arg0, "\" not recognised");
    }
    return _struct.artists;
}
