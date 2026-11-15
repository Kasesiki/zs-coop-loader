function review_prompt_should_show()
{
    if (platform_survey_url() == "")
    {
        return false;
    }
    if (platform_is_steam_deck())
    {
        return false;
    }
    if (!variable_global_exists("last_run_succeeded"))
    {
        return false;
    }
    if (global.last_run_succeeded != true)
    {
        return false;
    }
    var _total_seconds = 0;
    if (instance_exists(obj_main_menu))
    {
        with (obj_main_menu)
        {
            for (var _i = 0; _i < 3; _i++)
            {
                var _slot_time = play_time[_i];
                if (is_real(_slot_time))
                {
                    _total_seconds += _slot_time;
                }
            }
        }
    }
    if (_total_seconds < 7200)
    {
        return false;
    }
    if (db_read_ext("shared settings", "leave a review prompt", "shown", false))
    {
        return false;
    }
    return true;
}

function review_prompt_fire()
{
    __uiGlobal().__defaultOnion.LayerAddTop("ZS_vanilla/ui/modal_exit_survey.ui", "exit survey prompt");
}

function exit_survey_action(arg0)
{
    db_open("shared settings");
    db_write("leave a review prompt", "shown", true);
    db_close();
    if (arg0 == "open")
    {
        var _url = platform_survey_url();
        if (_url != "")
        {
            url_open(_url);
        }
    }
    db_quit_with_flush();
}
