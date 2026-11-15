alpha += (alpha_amount * alpha_factor);
alpha = clamp(alpha, 0, 1);
if (alpha_factor == 1 && alpha >= 0.99 && !full_fade_done)
{
    alarm[0] = timer_full_white;
    full_fade_done = true;
    var _end_game_boss_transition_full = false;
    if (variable_instance_exists(id, "end_game_boss_transition"))
    {
        _end_game_boss_transition_full = end_game_boss_transition;
    }
    var _end_game_credits_on_full_fade = false;
    if (variable_instance_exists(id, "end_game_credits_on_full_fade"))
    {
        _end_game_credits_on_full_fade = end_game_credits_on_full_fade;
    }
    if (_end_game_boss_transition_full)
    {
        end_game_boss_transition_spawn();
    }
    else if (_end_game_credits_on_full_fade)
    {
        end_game_create_credits();
    }
    else if (is_method(on_full_fade))
    {
        on_full_fade();
    }
}
if (alpha_factor == -1 && alpha <= 0.01)
{
    if (!fade_out_done)
    {
        fade_out_done = true;
        var _end_game_boss_transition_complete = false;
        if (variable_instance_exists(id, "end_game_boss_transition"))
        {
            _end_game_boss_transition_complete = end_game_boss_transition;
        }
        var _end_game_credits_after_fade = false;
        if (variable_instance_exists(id, "end_game_credits_after_fade"))
        {
            _end_game_credits_after_fade = end_game_credits_after_fade;
        }
        if (_end_game_boss_transition_complete)
        {
            end_game_boss_transition_start_dialogue();
        }
        else if (_end_game_credits_after_fade)
        {
            end_game_create_credits();
        }
        else if (is_method(on_fade_complete))
        {
            on_fade_complete();
        }
    }
    if (destroy_on_complete)
    {
        instance_destroy();
    }
}
