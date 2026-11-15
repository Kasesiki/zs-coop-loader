function __npc_data_write(arg0, arg1, arg2)
{
    variable_struct_set(variable_struct_get(global.npc_data, arg0), arg1, SnapDeepCopy(arg2));
}

function __npc_data_copy(arg0, arg1)
{
    if (!npc_get_exists(arg1))
    {
        mods_trace_error("Cannot copy NPC \"" + string(arg1) + "\": source does not exist");
        return false;
    }
    var _copy = SnapDeepCopy(variable_struct_get(global.npc_data, arg1));
    _copy.speaker_id = "no_speaker";
    variable_struct_set(global.npc_data, arg0, _copy);
    if (array_find_index_our(global.npc_data_array, arg0) == undefined)
    {
        array_push(global.npc_data_array, arg0);
    }
    return true;
}
