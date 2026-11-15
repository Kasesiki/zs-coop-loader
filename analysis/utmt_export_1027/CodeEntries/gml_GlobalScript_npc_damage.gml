function npc_damage(arg0, arg1, arg2 = -4)
{
    if (instance_exists(arg0))
    {
        if (arg1 > 0 && instance_exists(arg2) && !object_is_player(arg2) && object_is_ancestor(arg2.object_index, obj_npc_parent) && variable_instance_exists(arg0, "npc_id"))
        {
            arg1 *= (1 - npc_get_damage_reduction_from_npcs(arg0.npc_id));
        }
        arg0.hp -= arg1;
        if (arg0.hp <= 0 && instance_exists(arg2) && (object_is_player(arg2) || object_is_ancestor(arg2.object_index, obj_npc_parent)))
        {
            arg0.id_of_the_killer = arg2;
        }
        if (arg1 > 0)
        {
            mods_perform_event("npc_damaged", [arg0, arg1, arg0.hp, arg2], arg0);
        }
    }
}

function npc_get_damage_reduction_from_npcs(arg0)
{
    var _definition = variable_struct_get(global.npc_data, arg0);
    if (!is_struct(_definition))
    {
        return 0;
    }
    var _value = struct_get_from_hash(_definition, variable_get_hash("damage_reduction_from_npcs"));
    if (_value == undefined)
    {
        var _preset_id = struct_get_from_hash(_definition, variable_get_hash("npc_preset"));
        var _preset = is_string(_preset_id) ? variable_struct_get(global.npc_preset, _preset_id) : undefined;
        if (is_struct(_preset))
        {
            _value = struct_get_from_hash(_preset, variable_get_hash("damage_reduction_from_npcs"));
        }
    }
    if (!is_numeric(_value) || is_bool(_value))
    {
        return 0;
    }
    return clamp(_value, 0, 1);
}
