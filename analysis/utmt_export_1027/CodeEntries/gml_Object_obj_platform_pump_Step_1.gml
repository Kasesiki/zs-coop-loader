if (instance_number(obj_platform_pump) > 1)
{
    if (!(variable_global_exists("platform_pump_dup_logged") && global.platform_pump_dup_logged))
    {
        global.platform_pump_dup_logged = true;
        __platform_log("[platform] pump: DUPLICATE (" + string(instance_number(obj_platform_pump)) + ")");
    }
    var _min = id;
    with (obj_platform_pump)
    {
        if (id < _min)
        {
            _min = id;
        }
    }
    if (id != _min)
    {
        instance_destroy();
        exit;
    }
}
platform_update();
if (global.platform_quit_pending)
{
    var _pending = platform_cloud_pending();
    var _idle = _pending == 0;
    var _timeout = global.platform_frame >= global.platform_quit_deadline;
    if (_idle || _timeout)
    {
        if (_timeout && !_idle)
        {
            show_debug_message("[platform] quit: timed out with " + string(_pending) + " requests in flight");
        }
        platform_shutdown();
        game_end();
    }
}
