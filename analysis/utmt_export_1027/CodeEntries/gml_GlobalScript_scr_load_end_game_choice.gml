function scr_load_end_game_choice()
{
    db_open("general");
    global.end_game_choice = db_read("end_game_choice", "choice", -1);
    db_close();
    if (global.end_game_choice == UnknownEnum.Value_37)
    {
        shadowofzakov_achievement();
    }
}

enum UnknownEnum
{
    Value_37 = 37
}
