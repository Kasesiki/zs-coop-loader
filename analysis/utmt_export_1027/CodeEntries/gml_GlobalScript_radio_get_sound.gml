function radio_get_sound(arg0)
{
    var _struct = variable_struct_get(global.radio_music, arg0);
    if (!is_struct(_struct))
    {
        trace_error("Radio Music \"", arg0, "\" not recognised");
    }
    return variable_struct_get(global.Mods_Audio_Data, _struct.sound_id);
}
