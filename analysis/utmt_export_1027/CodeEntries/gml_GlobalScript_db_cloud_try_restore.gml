function db_cloud_try_restore(arg0)
{
    var _filename = arg0.files[arg0.index];
    var _root = global.database_savedata_root;
    switch (arg0.state)
    {
        case "restore_begin":
            __db_trace("Checking if \"", _filename, "\" exists in Steam Cloud");
            if (file_exists(_root + _filename))
            {
                __db_trace("\"", _filename, "\" exists locally");
                switch (arg0.mode)
                {
                    case 0:
                        if (global.database_was_previously_using_cloud_saves == undefined)
                        {
                            __db_trace("Mode=0: Unknown cloud state");
                            arg0.req = platform_cloud_read(_filename);
                            arg0.state = "restore_compare";
                        }
                        else if (global.database_was_previously_using_cloud_saves == false)
                        {
                            __db_trace("Mode=0: Not using cloud save previously. Alerting user");
                            global.database_cloud_conflict = 2;
                            arg0.state = "file_done";
                        }
                        else
                        {
                            __db_trace("Mode=0. Using cloud save previously. Restoring from cloud");
                            arg0.req = platform_cloud_read(_filename);
                            arg0.state = "restore_pull";
                        }
                        break;
                    case 1:
                        __db_trace("Mode=1: Backing up local file then restoring \"", _root + _filename, "\" from cloud");
                        arg0.req = platform_cloud_read(_filename);
                        arg0.state = "restore_pull";
                        break;
                    case 2:
                        __db_trace("Mode=2: Sending local file to Steam Cloud");
                        __db_trace("Attempting to push to Steam Cloud");
                        var _buffer = buffer_load(_root + _filename);
                        var _local_text = buffer_read(_buffer, buffer_string);
                        buffer_delete(_buffer);
                        arg0.req = platform_cloud_write(_filename, _local_text);
                        arg0.state = "restore_post_write";
                        break;
                }
            }
            else
            {
                arg0.req = platform_cloud_read(_filename);
                arg0.state = "restore_pull";
            }
            break;
        case "restore_compare":
            var _steam_text = arg0.req.text;
            var _steam_hash = md5_string_utf8(_steam_text);
            var _cbuffer = buffer_load(_root + _filename);
            var _local_text = buffer_read(_cbuffer, buffer_string);
            var _local_hash = md5_string_utf8(_local_text);
            buffer_delete(_cbuffer);
            if (_local_hash != _steam_hash)
            {
                __db_trace("Mode=0 & hash collision: Alerting user");
                global.database_cloud_conflict = 2;
                arg0.state = "file_done";
            }
            else
            {
                __db_trace("Mode=0: Restoring from cloud");
                arg0.state = "restore_pull";
            }
            break;
        case "restore_pull":
            arg0.cloud_text = arg0.req.text;
            if (file_exists(_root + _filename))
            {
                __db_trace("Backing up \"", _root + _filename, "\"");
                db_create_backup(_filename, "backup/backup_");
            }
            else
            {
                __db_trace("\"", _root + _filename, "\" doesn't exist locally");
            }
            __db_trace("Restoring \"", _root + _filename, "\" from Steam Cloud");
            var _wbuffer = buffer_create(string_byte_length(arg0.cloud_text), buffer_fixed, 1);
            buffer_write(_wbuffer, buffer_text, arg0.cloud_text);
            buffer_save(_wbuffer, _root + _filename);
            buffer_delete(_wbuffer);
            arg0.state = "file_done";
            break;
        case "restore_post_write":
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
