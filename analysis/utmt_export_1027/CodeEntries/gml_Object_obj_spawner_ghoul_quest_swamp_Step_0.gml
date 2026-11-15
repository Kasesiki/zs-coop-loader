if (can_finish)
{
    var _count = 0;
    var _x = x;
    var _y = y;
    with (obj_enemy_ghoul)
    {
        if (point_distance(x, y, _x, _y) < 160)
        {
            _count++;
        }
    }
    if (_count == 0)
    {
        if (quest_done == false)
        {
            with (obj_green_quest_swamp_leader)
            {
                scr_draw_npc_text(id, UnknownEnum.Value_125);
            }
            complete_quest("clear_swamp");
            quest_done = true;
        }
    }
}

enum UnknownEnum
{
    Value_125 = 125
}
