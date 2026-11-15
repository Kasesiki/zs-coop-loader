function scr_complete_base_building_quest()
{
    if (quest_is_active("base_building"))
    {
        for (var i = 0; i < 30; i++)
        {
            var _quest_id = global.quest_state[i].id;
            if (_quest_id != "")
            {
                if (_quest_id == "base_building")
                {
                    global.quest_state[i].amount_now[0] = variable_struct_get(global.quest_database, _quest_id).objective[0].amount_max;
                    obj_controller.alarm[1] = 1;
                }
            }
        }
    }
}
