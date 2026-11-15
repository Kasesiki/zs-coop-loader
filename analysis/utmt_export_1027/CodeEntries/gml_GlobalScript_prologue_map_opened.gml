function prologue_map_opened()
{
    with (obj_prologue)
    {
        if (state == UnknownEnum.Value_25)
        {
            timer_go = true;
            timer_max = 5;
        }
    }
}

enum UnknownEnum
{
    Value_25 = 25
}
