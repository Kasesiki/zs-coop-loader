function train_skin_sync()
{
    var _new_skin_unlocked = false;
    if (train_skin_try_unlock("end_game", global.end_game_choice != -1))
    {
        _new_skin_unlocked = true;
    }
    if (train_skin_try_unlock("end_game_good", global.end_game_choice == UnknownEnum.Value_37))
    {
        _new_skin_unlocked = true;
    }
    if (train_skin_try_unlock("joined_ga", global.faction_joined == "Green Army"))
    {
        _new_skin_unlocked = true;
    }
    if (train_skin_try_unlock("joined_cc", global.faction_joined == "Crimson Corporation"))
    {
        _new_skin_unlocked = true;
    }
    if (train_skin_try_unlock("watcher", quest_is_complete("the_crystal")))
    {
        _new_skin_unlocked = true;
    }
    if (train_skin_try_unlock("scientist", faction_get_rep("Player", "Scientists") >= 450))
    {
        _new_skin_unlocked = true;
    }
    if (_new_skin_unlocked)
    {
        scr_draw_text_with_box("You have unlocked a new train type.");
    }
    skininthegame_achievement();
    railwaycollector_achievement();
}

function train_skin_try_unlock(arg0, arg1)
{
    if (!arg1)
    {
        return false;
    }
    var _was_unlocked = false;
    if (variable_struct_exists(global.train_skin_struct, arg0))
    {
        _was_unlocked = variable_struct_get(global.train_skin_struct, arg0);
    }
    if (!_was_unlocked)
    {
        variable_struct_set(global.train_skin_struct, arg0, true);
        return true;
    }
    return false;
}

enum UnknownEnum
{
    Value_37 = 37
}
