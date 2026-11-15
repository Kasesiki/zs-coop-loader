function item_container_get_item_id(arg0)
{
    if (!item_exists(arg0))
    {
        return "no_item";
    }
    var _struct = variable_struct_get(global.item_data, arg0);
    if (!is_struct(_struct))
    {
        trace_error("Item \"", arg0, "\" not recognised");
    }
    _struct = struct_get_from_hash(_struct, variable_get_hash("container"));
    if (!is_struct(_struct))
    {
        trace("Item \"", arg0, "\" has no .container data");
        return 0;
    }
    return _struct.item_id;
}
