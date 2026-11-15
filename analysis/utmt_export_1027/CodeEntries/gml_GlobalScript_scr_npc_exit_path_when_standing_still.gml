function scr_npc_exit_path_when_standing_still()
{
    exit;
    if (x == xprevious && y == yprevious)
    {
        timer_exit_path++;
        if (timer_exit_path >= timer_exit_path_max)
        {
            path_end();
            state_finito = true;
            timer_exit_path = 0;
        }
    }
    else
    {
        timer_exit_path = 0;
    }
}
