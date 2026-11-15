function db_cloud_sync(arg0)
{
    var _filename = arg0.files[arg0.index];
    switch (arg0.state)
    {
        case "sync_begin":
            __db_trace("Trying to sync \"", _filename, "\"");
            arg0.req = platform_cloud_exists(_filename);
            arg0.state = "sync_dispatch";
            break;
        case "sync_dispatch":
            if (1 && arg0.req.exists)
            {
                arg0.state = "restore_begin";
            }
            else
            {
                arg0.state = "cleanup_begin";
            }
            break;
    }
}
