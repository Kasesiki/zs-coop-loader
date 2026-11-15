alpha += a;
if (alpha >= 1 && !pausa)
{
    alarm[0] = time_black;
    pausa = true;
}
if (alpha <= 0)
{
    player_set_local_state(scr_player_state_move);
    instance_destroy();
    if (sleep_effects_applied && minutes > 0)
    {
        sleep_effects_applied = false;
        var _player = player_get_local();
        mods_perform_event("sleep_completed", [_player, minutes], _player);
    }
}
alpha = clamp(alpha, 0, 1);
