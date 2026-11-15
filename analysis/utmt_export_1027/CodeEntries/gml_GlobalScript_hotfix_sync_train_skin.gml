function sync_train_skin_data()
{
    db_open("shared settings");
    var _sync = db_read("Train skin", "save sync", false);
    var _saved_train_skin_struct = db_read("Train skin", "skin", train_skin_struct());
    global.train_skin_struct = variable_clone(_saved_train_skin_struct);
    db_close();
    if (_sync)
    {
        exit;
    }
    for (var i = 1; i < 4; i++)
    {
        scr_aggiorna_save_slot(i);
        if (db_file_exists("shared"))
        {
            db_load("shared");
            db_open("general");
            var _end_game_choice = db_read("end_game_choice", "choice", -1);
            if (_end_game_choice != -1)
            {
                global.train_skin_struct.end_game = true;
            }
            enum_p_int();
            if (_end_game_choice == UnknownEnum.Value_37)
            {
                global.train_skin_struct.end_game_good = true;
            }
            var _faction_joined = db_read("factions", "joined", "");
            if (_faction_joined == "Green Army")
            {
                global.train_skin_struct.joined_ga = true;
            }
            if (_faction_joined == "Crimson Corporation")
            {
                global.train_skin_struct.joined_cc = true;
            }
            var _quest_completed = db_read("quest line", "completed", {});
            if (struct_get_from_hash(_quest_completed, variable_get_hash("the_crystal")) == true)
            {
                global.train_skin_struct.watcher = true;
            }
            var _rel = db_read("factions", "struct", 0);
            if (is_struct(_rel))
            {
                var _rel_scientist = struct_get_from_hash(_rel, variable_get_hash("Player")).relationship.Scientists;
                if (_rel_scientist >= 450)
                {
                    global.train_skin_struct.scientist = true;
                }
            }
            db_close();
            db_unload("shared");
        }
    }
    db_open("shared settings");
    db_write("Train skin", "save sync", true);
    db_write("Train skin", "skin", global.train_skin_struct);
    db_close();
}

enum UnknownEnum
{
    Value_37 = 37
}
