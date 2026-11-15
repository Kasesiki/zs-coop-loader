function exit_to_main_menu_permadeath()
{
    permadeath_wipe_save();
    __uiGlobal().__defaultOnion.Clear();
    room_goto(r_menu);
}

function permadeath_wipe_save()
{
    db_file_delete("shared");
    struct_get_from_hash(global.database_struct, variable_get_hash("shared")).allow_save = false;
}

function permadeath_unlock_save()
{
    var _database = struct_get_from_hash(global.database_struct, variable_get_hash("shared"));
    if (_database.allow_save)
    {
        exit;
    }
    _database.allow_save = true;
    _database.changed = false;
}
