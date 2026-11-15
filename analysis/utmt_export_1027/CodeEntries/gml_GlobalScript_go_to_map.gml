function go_to_map(arg0, arg1 = false)
{
    db_open("raid");
    db_write("Map", "Map id", arg0);
    db_close();
    with (player_get_local())
    {
        ftue_part3_complete = true;
        skills.save();
        skills_hunter.save("skills_hunter");
    }
    scr_save_skill_and_base();
    scr_save_exp();
    radio_save();
    train_skin_save();
    scr_save_ftue();
    scr_save_time();
    scr_save_unique_action();
    scr_save_player_status();
    faction_save();
    stash_save();
    quest_save();
    welcometozakovcity_achievement();
    if (!arg1)
    {
        var _value = inventory_get_total_value();
        db_open("pre_raid");
        db_write("inventory_value", "pre_raid", _value);
        db_close();
        inventory_handle_pre_raid_backup(true);
        steam_stat_increment("raidsstarted");
    }
    inventory_set_target_db_to_raid();
    __uiGlobal().__defaultOnion.Clear();
    room_goto(room1);
}
