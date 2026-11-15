function npc_get_ai_preset(arg0)
{
    var _definition = variable_struct_get(global.npc_data, arg0);
    if (!is_struct(_definition))
    {
        return undefined;
    }
    var _preset_id = struct_get_from_hash(_definition, variable_get_hash("npc_preset"));
    if (!is_string(_preset_id))
    {
        return undefined;
    }
    var _preset = variable_struct_get(global.npc_preset, _preset_id);
    return is_struct(_preset) ? SnapDeepCopy(struct_get_from_hash(_preset, variable_get_hash("ai"))) : undefined;
}
