function db_force_save(arg0)
{
    static _buffer = buffer_create(1024, buffer_grow, 1);
    
    var _database = variable_struct_get(global.database_struct, arg0);
    if (!is_struct(_database))
    {
        __db_error("Database \"", arg0, "\" has not been created with db_create()");
        exit;
    }
    if (!_database.allow_save)
    {
        __db_error("Trying to save unsaveable database \"", arg0, "\"");
        exit;
    }
    var _filename = _database.filename;
    if (_filename == undefined)
    {
        __db_error("Database \"", arg0, "\" has not has its filename set");
        exit;
    }
    if (_database.create_backups)
    {
        db_create_backup(_filename, "backup/backup_");
    }
    __db_trace("Saving database \"", arg0, "\" to \"", _filename, "\"");
    var _payload = 
    {
        data: _database.data,
        format: "json",
        timestamp: string_format(date_current_datetime(), 0, 10),
        save_version: concat(concat(1, ".", 4, ".", 13), " development"),
        version_major: 1,
        version_minor: 4,
        version_patch: 13
    };
    buffer_seek(_buffer, buffer_seek_start, 0);
    if (_database.pretty_output)
    {
        SnapBufferWriteJSON(_buffer, _payload, true, true, true);
    }
    else
    {
        buffer_write(_buffer, buffer_text, json_stringify(_payload));
    }
    var _live_path = global.database_savedata_root + _filename;
    var _temp_path = _live_path + ".tmp";
    if (file_exists(_temp_path))
    {
        file_delete(_temp_path);
    }
    buffer_save_ext(_buffer, _temp_path, 0, buffer_tell(_buffer));
    if (file_exists(_temp_path))
    {
        if (file_exists(_live_path))
        {
            file_delete(_live_path);
        }
        file_rename(_temp_path, _live_path);
    }
    else
    {
        __db_trace("Warning! Temp file write failed for \"", _filename, "\", keeping existing save");
    }
    if (db_cloud_enabled() && _database.cloud)
    {
        _database.save_hash = buffer_md5(_buffer, 0, buffer_tell(_buffer));
        __db_trace("Attempting to push to Steam Cloud");
        var _json_string = buffer_peek(_buffer, 0, buffer_string);
        var _req = platform_cloud_write(_filename, _json_string);
        
        var _check = function(arg0)
        {
            __db_trace("result = ", arg0.ok ? 1 : 0, " ", arg0.error);
            if (global.strict_steam_mode && !arg0.ok)
            {
                show_message("Steam Cloud write failed");
            }
        };
        
        if (_req.done)
        {
            _check(_req);
        }
        else
        {
            _req.on_done = _check;
        }
    }
}
