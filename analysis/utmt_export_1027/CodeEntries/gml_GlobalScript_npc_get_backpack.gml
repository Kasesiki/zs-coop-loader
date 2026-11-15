function npc_get_backpack(arg0)
{
    var _struct = variable_struct_get(global.npc_data, arg0);
    if (!is_struct(_struct))
    {
        trace_error("NPC \"", arg0, "\" not recognised");
    }
    var _backpack = struct_get_from_hash(_struct, variable_get_hash("backpack"));
    if (_backpack == undefined)
    {
        trace_error("NPC \"", arg0, "\" has no .backpack data");
    }
    _backpack = npc_get_general(arg0, _backpack, "backpack");
    if (is_array(_backpack))
    {
        return _backpack[irandom(array_length(_backpack) - 1)];
    }
    return _backpack;
}
