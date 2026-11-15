function player_get(arg0 = 0)
{
    static last_player = -4;
    static last_index = -1;
    
    if (arg0 == -1)
    {
        last_index = -1;
        last_player = -4;
        return -4;
    }
    if (last_index == arg0)
    {
        return last_player;
    }
    with (obj_player_parent)
    {
        if (mp_index == arg0)
        {
            last_index = arg0;
            last_player = id;
            return id;
        }
    }
    return -4;
}
