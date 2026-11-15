function npc_dialogue_map_is_unlocked(arg0 = uiGetData().map_selected)
{
    if (!global.general_debug)
    {
        switch (arg0)
        {
            case UnknownEnum.Value_2:
                return quest_is_complete("unlock_makeshift_camp");
                break;
            case UnknownEnum.Value_3:
                return quest_is_complete("kill_orel");
                break;
            case UnknownEnum.Value_4:
                return quest_is_complete("kill_orel");
                break;
            case UnknownEnum.Value_6:
                return quest_is_complete("gate_sewer");
                break;
            case UnknownEnum.Value_8:
                return quest_is_complete("bridge_to_zakov");
                break;
            case UnknownEnum.Value_9:
                return true;
                break;
        }
    }
    return true;
}

function npc_dialogue_map_go()
{
    var _map = uiGetData().map_selected;
    if (!global.general_debug)
    {
        switch (_map)
        {
            case UnknownEnum.Value_2:
                if (!quest_is_complete("unlock_makeshift_camp"))
                {
                    scr_draw_text_with_box("Not yet unlocked");
                    exit;
                }
                break;
            case UnknownEnum.Value_3:
                if (!quest_is_complete("kill_orel"))
                {
                    scr_draw_text_with_box("Not yet unlocked");
                    exit;
                }
                break;
            case UnknownEnum.Value_4:
                if (!quest_is_complete("kill_orel"))
                {
                    scr_draw_text_with_box("Not yet unlocked");
                    exit;
                }
                break;
            case UnknownEnum.Value_6:
                if (!quest_is_complete("gate_sewer"))
                {
                    scr_draw_text_with_box("Not yet unlocked");
                    exit;
                }
                break;
            case UnknownEnum.Value_8:
                if (!quest_is_complete("bridge_to_zakov"))
                {
                    scr_draw_text_with_box("Not yet unlocked");
                    exit;
                }
                break;
            case UnknownEnum.Value_9:
                break;
        }
    }
    go_to_map(_map);
}

enum UnknownEnum
{
    Value_2 = 2,
    Value_3,
    Value_4,
    Value_6 = 6,
    Value_8 = 8,
    Value_9
}
