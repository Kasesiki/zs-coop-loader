function player_step_skill_cooldown()
{
    if (frames_left_of_killer_reload >= 0)
    {
        frames_left_of_killer_reload--;
    }
    if (nojamthanks_timer > 0)
    {
        nojamthanks_timer--;
    }
    if (frames_left_steady_sniper > 0)
    {
        frames_left_steady_sniper--;
    }
    if (adrenalinerush_cooldown > 0)
    {
        adrenalinerush_cooldown--;
    }
    if (adrenalinerush_movement_speed_timer > 0)
    {
        adrenalinerush_movement_speed_timer--;
    }
    if (rolling_start_frames_cooldown > 0)
    {
        rolling_start_frames_cooldown--;
    }
    if (mouse_check_button(mb_left) || obj_gamepad.action[UnknownEnum.Value_27].value || shoot_input)
    {
        sprint_resume_delay = 24;
    }
    else if (sprint_resume_delay > 0)
    {
        sprint_resume_delay--;
    }
}

enum UnknownEnum
{
    Value_27 = 27
}
