function skill_hunter_get_points()
{
    var _total_points = experience_get_level();
    with (player_get_local())
    {
        for (var i = 0; i < array_length(global.skills_hunter_data_array); i++)
        {
            if (skills_hunter.get_value(global.skills_hunter_data_array[i]) > 0)
            {
                if (variable_struct_get(global.skills_hunter_data, global.skills_hunter_data_array[i]).group > -1)
                {
                    _total_points--;
                }
            }
        }
    }
    return _total_points;
}

function skill_hunter_get_group_current()
{
    var _total_points = 0;
    with (player_get_local())
    {
        for (var i = 0; i < array_length(global.skills_hunter_data_array); i++)
        {
            if (skills_hunter.get_value(global.skills_hunter_data_array[i]) > 0 && variable_struct_get(global.skills_hunter_data, global.skills_hunter_data_array[i]).group > -1)
            {
                _total_points++;
            }
        }
    }
    var _group = 0;
    if (_total_points >= 3 && _total_points <= 6)
    {
        _group = 1;
    }
    else if (_total_points >= 7)
    {
        _group = 2;
    }
    return _group;
}

function skill_hunter_buy(arg0)
{
    if (is_in_raid())
    {
        return false;
    }
    if (skill_hunter_get_points() <= 0)
    {
        return false;
    }
    var _skill_info = variable_struct_get(global.skills_hunter_data, arg0);
    if (!is_struct(_skill_info))
    {
        return false;
    }
    if (_skill_info.group != skill_hunter_get_group_current())
    {
        return false;
    }
    with (player_get_local())
    {
        if (skills_hunter.get_value(arg0) > 0)
        {
            return false;
        }
        return skills_hunter.set(arg0, true);
    }
    return false;
}
