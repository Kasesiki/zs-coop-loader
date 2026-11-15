function db_cloud_sync_all(arg0 = 0)
{
    var _files = ["settings_shared.json"];
    var _index = 1;
    repeat (3)
    {
        array_push(_files, "save_shared_" + string(_index) + ".dat");
        _index++;
    }
    global.db_cloud_job = 
    {
        mode: arg0,
        files: _files,
        index: 0,
        state: "sync_begin",
        req: undefined,
        cloud_text: undefined,
        done: false
    };
    if (!db_cloud_enabled())
    {
        global.db_cloud_job.done = true;
    }
}

function db_cloud_sync_step()
{
    if (!db_cloud_sync_in_progress())
    {
        exit;
    }
    var _job = global.db_cloud_job;
    repeat (1000)
    {
        if (is_struct(_job.req) && !_job.req.done)
        {
            exit;
        }
        if (_job.index >= array_length(_job.files))
        {
            _job.done = true;
            exit;
        }
        switch (_job.state)
        {
            case "sync_begin":
            case "sync_dispatch":
                db_cloud_sync(_job);
                break;
            case "restore_begin":
            case "restore_compare":
            case "restore_pull":
            case "restore_post_write":
                db_cloud_try_restore(_job);
                break;
            case "cleanup_begin":
            case "cleanup_post_write":
                db_cloud_clean_up(_job);
                break;
            case "file_done":
                _job.index += 1;
                _job.state = "sync_begin";
                _job.req = undefined;
                _job.cloud_text = undefined;
                break;
            default:
                _job.done = true;
                exit;
        }
    }
}

function db_cloud_sync_is_done()
{
    return !variable_global_exists("db_cloud_job") || !is_struct(global.db_cloud_job) || global.db_cloud_job.done;
}

function db_cloud_sync_in_progress()
{
    return variable_global_exists("db_cloud_job") && is_struct(global.db_cloud_job) && !global.db_cloud_job.done;
}

function db_quit_with_flush()
{
    if (instance_exists(obj_controller))
    {
        db_force_save_flush_soft();
    }
    platform_flush();
    platform_request_quit();
}
