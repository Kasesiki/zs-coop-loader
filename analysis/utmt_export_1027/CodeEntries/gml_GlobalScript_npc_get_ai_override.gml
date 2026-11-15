function npc_get_ai_override(arg0)
{
    var _definition = variable_struct_get(global.npc_data, arg0);
    return is_struct(_definition) ? SnapDeepCopy(struct_get_from_hash(_definition, variable_get_hash("ai"))) : undefined;
}
