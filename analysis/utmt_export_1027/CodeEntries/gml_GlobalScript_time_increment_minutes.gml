function time_increment_minutes(arg0)
{
    with (obj_light_controller)
    {
        var _old_hours = time_get_hours();
        var _old_day = time_get_days();
        game_time_played = date_inc_minute(game_time_played, arg0);
        var _new_day = time_get_days();
        if (_new_day != _old_day)
        {
            mods_perform_event("day_changed", [_old_day, _new_day]);
        }
        if ((_old_hours < 7 || _old_day < time_get_days()) && time_get_hours() >= 7)
        {
            time_restock_traders();
        }
    }
}
