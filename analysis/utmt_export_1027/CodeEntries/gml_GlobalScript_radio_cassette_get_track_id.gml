function radio_cassette_get_track_id(arg0)
{
    var _struct = variable_struct_get(global.item_data, arg0);
    if (!is_struct(_struct))
    {
        trace_error("Item \"", arg0, "\" not recognised");
    }
    _struct = struct_get_from_hash(_struct, variable_get_hash("cassette"));
    if (!is_struct(_struct))
    {
        trace_error("Item \"", arg0, "\" has no .cassette data");
    }
    return _struct.radio_track_id;
}
