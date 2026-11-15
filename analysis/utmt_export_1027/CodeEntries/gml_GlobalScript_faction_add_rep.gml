function faction_add_rep(arg0, arg1, arg2)
{
    if (!variable_struct_exists(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1))
    {
        variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1, 0);
    }
    if (!variable_struct_exists(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0))
    {
        variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0, 0);
    }
    var _player_faction = undefined;
    var _player_rep_previous = 0;
    if (arg0 == "Player")
    {
        _player_faction = arg1;
        _player_rep_previous = variable_struct_get(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1);
    }
    else if (arg1 == "Player")
    {
        _player_faction = arg0;
        _player_rep_previous = variable_struct_get(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0);
    }
    variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1, variable_struct_get(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1) + arg2);
    variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0, variable_struct_get(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0) + arg2);
    var _max = 1000;
    if (arg0 == "Player" || arg1 == "Player")
    {
        if (arg0 == "Player")
        {
            if (variable_struct_get(global.struct_faction, arg1).rep_amount_no_join == 1000)
            {
                _max = 1000;
            }
            else
            {
                _max = variable_struct_get(global.struct_faction, arg1).rep_amount_no_join - 1;
            }
        }
        if (arg1 == "Player")
        {
            if (variable_struct_get(global.struct_faction, arg0).rep_amount_no_join == 1000)
            {
                _max = 1000;
            }
            else
            {
                _max = variable_struct_get(global.struct_faction, arg0).rep_amount_no_join - 1;
            }
        }
        if (global.faction_joined == "Green Army")
        {
            _max = 1000;
            if (arg0 == "Crimson Corporation" || arg1 == "Crimson Corporation")
            {
                _max = 249;
            }
        }
        if (global.faction_joined == "Crimson Corporation")
        {
            _max = 1000;
            if (arg0 == "Green Army" || arg1 == "Green Army")
            {
                _max = 249;
            }
        }
        if (global.end_game_choice == UnknownEnum.Value_35)
        {
            _max = 1000;
        }
    }
    variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1, clamp(variable_struct_get(struct_get_from_hash(variable_struct_get(global.struct_faction, arg0), variable_get_hash("relationship")), arg1), 0, _max));
    variable_struct_set(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0, clamp(variable_struct_get(struct_get_from_hash(variable_struct_get(global.struct_faction, arg1), variable_get_hash("relationship")), arg0), 0, _max));
    if (_player_faction != undefined)
    {
        var _player_rep_new = faction_get_rep("Player", _player_faction);
        if (_player_rep_new != _player_rep_previous)
        {
            mods_perform_event("reputation_changed", [_player_faction, _player_rep_previous, _player_rep_new]);
        }
    }
}

enum UnknownEnum
{
    Value_35 = 35
}
