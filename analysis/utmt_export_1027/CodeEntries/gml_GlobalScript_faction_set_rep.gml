function faction_set_rep(arg0, arg1, arg2)
{
    var _player_faction = undefined;
    var _player_rep_previous = 0;
    if (arg0 == "Player")
    {
        _player_faction = arg1;
        _player_rep_previous = faction_get_rep(arg0, arg1);
    }
    else if (arg1 == "Player")
    {
        _player_faction = arg0;
        _player_rep_previous = faction_get_rep(arg1, arg0);
    }
    variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1, arg2);
    variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0, arg2);
    variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1, clamp(variable_struct_get(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1), 0, 1000));
    variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0, clamp(variable_struct_get(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0), 0, 1000));
    if (_player_faction != undefined)
    {
        var _player_rep_new = faction_get_rep("Player", _player_faction);
        if (_player_rep_new != _player_rep_previous)
        {
            mods_perform_event("reputation_changed", [_player_faction, _player_rep_previous, _player_rep_new]);
        }
    }
}
