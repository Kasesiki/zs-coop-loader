function db_cloud_clean_up(arg0)
{
    var _filename = arg0.files[arg0.index];
    var _root = global.database_savedata_root;
    switch (arg0.state)
    {
        case "cleanup_begin":
            if (file_exists(_root + _filename))
            {
                __db_trace("\"", _filename, "\" exists locally");
                __db_trace("Checking if \"", _filename, "\" exists in Steam Cloud");
                switch (arg0.mode)
                {
                    case 0:
                        __db_trace("\"", _filename, "\" doesn't exist in Steam Cloud. Mode=0: Alerting user");
                        global.database_cloud_conflict = 1;
                        arg0.state = "file_done";
                        break;
                    case 1:
                        __db_trace("\"", _filename, "\" doesn't exist in Steam Cloud. Mode=1: Backing up local file then deleting \"", _root + _filename, "\"");
                        db_create_backup(_filename, "backup/backup_");
                        file_delete(_root + _filename);
                        arg0.state = "file_done";
                        break;
                    case 2:
                        __db_trace("\"", _filename, "\" doesn't exist in Steam Cloud. Mode=2: Sending local file to Steam Cloud");
                        __db_trace("Attempting to push to Steam Cloud");
                        var _buffer = buffer_load(_root + _filename);
                        var _local_text = buffer_read(_buffer, buffer_string);
                        buffer_delete(_buffer);
                        arg0.req = platform_cloud_write(_filename, _local_text);
                        arg0.state = "cleanup_post_write";
                        break;
                }
            }
            else
            {
                __db_trace("\"", _filename, "\" doesn't exist locally");
                arg0.state = "file_done";
            }
            break;
        case "cleanup_post_write":
            var _r = arg0.req;
            __db_trace("result = ", _r.ok ? 1 : 0, " ", _r.error);
            if (global.strict_steam_mode && !_r.ok)
            {
                show_message("Steam Cloud write failed");
            }
            arg0.state = "file_done";
            break;
    }
}
