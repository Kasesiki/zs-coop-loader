function complete_quest(arg0, arg1 = 0)
{
    for (var i = 0; i < 30; i++)
    {
        var _quest = global.quest_state[i].id;
        if (_quest != "")
        {
            if (_quest == arg0)
            {
                global.quest_state[i].amount_now[arg1] = variable_struct_get(global.quest_database, arg0).objective[arg1].amount_max;
                obj_controller.alarm[1] = 1;
            }
        }
    }
}
