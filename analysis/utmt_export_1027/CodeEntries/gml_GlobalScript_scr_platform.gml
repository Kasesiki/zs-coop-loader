function __platform_log(arg0)
{
    show_debug_message(arg0);
    var _f = file_text_open_append(game_save_id + "platform.log");
    if (_f == -1)
    {
        exit;
    }
    file_text_write_string(_f, date_datetime_string(date_current_datetime()) + " +" + string(current_time) + "ms  " + arg0);
    file_text_writeln(_f);
    file_text_close(_f);
}

function platform_init()
{
    if (variable_global_exists("platform_initialised") && global.platform_initialised == true)
    {
        exit;
    }
    var _logf = file_text_open_write(game_save_id + "platform.log");
    if (_logf != -1)
    {
        file_text_close(_logf);
    }
    global.platform_initialised = false;
    global.__platform_target = UnknownEnum.Value_0;
    global.platform_backend = undefined;
    global.platform_cloud_request_counter = 0;
    global.platform_cloud_inflight = [];
    global.platform_frame = 0;
    global.platform_quit_pending = false;
    global.platform_quit_deadline = 0;
    var _args = 
    {
        has_epic_portal: false,
        epicuserid: "",
        epicusername: "",
        epicsandboxid: "",
        epicdeploymentid: "",
        auth_type: "",
        auth_password: "",
        epicdev: false,
        epiclocale: ""
    };
    var _argc = parameter_count();
    for (var _i = 0; _i < _argc; _i++)
    {
        var _a = parameter_string(_i);
        if (string_pos("-EpicPortal", _a) == 1)
        {
            _args.has_epic_portal = true;
        }
        else if (string_pos("-epicdev", _a) == 1)
        {
            _args.epicdev = true;
        }
        else if (string_pos("-epicuserid=", _a) == 1)
        {
            _args.epicuserid = string_delete(_a, 1, 12);
        }
        else if (string_pos("-epicusername=", _a) == 1)
        {
            _args.epicusername = string_delete(_a, 1, 14);
        }
        else if (string_pos("-epicsandboxid=", _a) == 1)
        {
            _args.epicsandboxid = string_delete(_a, 1, 15);
        }
        else if (string_pos("-epicdeploymentid=", _a) == 1)
        {
            _args.epicdeploymentid = string_delete(_a, 1, 18);
        }
        else if (string_pos("-AUTH_TYPE=", _a) == 1)
        {
            _args.auth_type = string_delete(_a, 1, 11);
        }
        else if (string_pos("-AUTH_PASSWORD=", _a) == 1)
        {
            _args.auth_password = string_delete(_a, 1, 15);
        }
        else if (string_pos("-epiclocale=", _a) == 1)
        {
            _args.epiclocale = string_delete(_a, 1, 12);
        }
    }
    global.platform_epic_args = _args;
    __platform_log("[platform] args: EpicPortal=" + string(_args.has_epic_portal) + " epicuserid=" + string(_args.epicuserid) + " epicusername=" + string(_args.epicusername) + " epicsandboxid=" + string(_args.epicsandboxid) + " epicdeploymentid=" + string(_args.epicdeploymentid) + " epiclocale=" + string(_args.epiclocale) + " AUTH_TYPE=" + string(_args.auth_type) + " AUTH_PASSWORD=" + ((_args.auth_password == "") ? "" : "<redacted>") + " epicdev=" + string(_args.epicdev));
    global.__platform_launched_by_epic = _args.has_epic_portal || _args.auth_type == "exchangecode" || _args.epicuserid != "";
    if (global.__platform_launched_by_epic || false || _args.epicdev)
    {
        global.__platform_target = UnknownEnum.Value_2;
        global.platform_backend = new PlatformBackendEpic(_args);
    }
    else if (steam_initialised())
    {
        global.__platform_target = UnknownEnum.Value_1;
        global.platform_backend = new PlatformBackendSteam();
    }
    else
    {
        global.__platform_target = UnknownEnum.Value_0;
        global.platform_backend = new PlatformBackendNull();
    }
    __platform_log("[platform] init: target = " + string(global.__platform_target) + " (0=NONE 1=STEAM 2=EPIC 3=GOG 4=XBOX 5=PS)");
    __platform_record_steam_status(_args);
    __platform_ensure_pump();
    global.platform_initialised = true;
}

function __platform_record_steam_status(arg0)
{
    var _steam_started = steam_initialised();
    var _has_epic_marker = file_exists(program_directory + "store.epic");
    var _has_steam_appid_txt = file_exists(program_directory + "steam_appid.txt");
    __platform_log("[platform] steam: initialised=" + string(_steam_started) + " store.epic=" + string(_has_epic_marker) + " steam_appid.txt=" + string(_has_steam_appid_txt) + " exe_dir=" + program_directory);
    global.__platform_not_steam_reason = "";
    global.__platform_steam_failed = false;
    if (global.__platform_target == UnknownEnum.Value_2)
    {
        var _signals = [];
        if (arg0.has_epic_portal)
        {
            array_push(_signals, "-EpicPortal");
        }
        if (arg0.auth_type == "exchangecode")
        {
            array_push(_signals, "-AUTH_TYPE=exchangecode");
        }
        if (arg0.epicuserid != "")
        {
            array_push(_signals, "-epicuserid");
        }
        if (arg0.epicdev)
        {
            array_push(_signals, "-epicdev");
        }
        global.__platform_not_steam_reason = "Epic launch detected";
        __platform_log("[platform] not on Steam: Epic launch detected (" + string_join_ext(", ", _signals) + ")");
    }
    else if (global.__platform_target == UnknownEnum.Value_0)
    {
        global.__platform_steam_failed = !_has_epic_marker;
        global.__platform_not_steam_reason = _has_epic_marker ? "Steam did not start; store.epic found" : "Steam did not start";
        __platform_log("[platform] not on Steam: " + global.__platform_not_steam_reason);
    }
}

function __platform_ensure_pump()
{
    if (!(variable_global_exists("platform_room_live") && global.platform_room_live))
    {
        return false;
    }
    instance_activate_object(obj_platform_pump);
    if (instance_exists(obj_platform_pump))
    {
        return true;
    }
    if (variable_global_exists("platform_pump_created") && global.platform_pump_created)
    {
        __platform_log("[platform] pump: RECREATED — investigate caller=" + string(debug_get_callstack(6)));
    }
    try
    {
        instance_create_depth(0, 0, 0, obj_platform_pump);
    }
    catch (_e)
    {
        return false;
    }
    global.platform_pump_created = true;
    __platform_log("[platform] pump: instance created");
    return true;
}

function __platform_ensure()
{
    if (!(variable_global_exists("platform_initialised") && global.platform_initialised == true))
    {
        platform_init();
    }
    __platform_ensure_pump();
}

function platform_update()
{
    __platform_ensure();
    global.platform_backend.update();
    global.platform_frame += 1;
    var _inflight = global.platform_cloud_inflight;
    var _n = array_length(_inflight);
    if (_n > 0)
    {
        var _kept = [];
        for (var _i = 0; _i < _n; _i++)
        {
            var _r = _inflight[_i];
            if (_r.done)
            {
                if (is_method(_r.on_done))
                {
                    _r.on_done(_r);
                }
            }
            else
            {
                array_push(_kept, _r);
            }
        }
        global.platform_cloud_inflight = _kept;
    }
}

function platform_shutdown()
{
    if (variable_global_exists("platform_shutdown_done") && global.platform_shutdown_done)
    {
        __platform_log("[platform] shutdown: already done");
        exit;
    }
    global.platform_shutdown_done = true;
    __platform_log("[platform] shutdown: begin");
    __platform_ensure();
    var _b = global.platform_backend;
    if (variable_struct_exists(_b, "shutdown"))
    {
        _b.shutdown();
    }
}

function platform_flush()
{
    __platform_ensure();
    var _b = global.platform_backend;
    if (variable_struct_exists(_b, "flush"))
    {
        _b.flush();
    }
}

function platform_target()
{
    __platform_ensure();
    return global.__platform_target;
}

function platform_is(arg0)
{
    __platform_ensure();
    return global.__platform_target == arg0;
}

function platform_not_steam_reason()
{
    __platform_ensure();
    return global.__platform_not_steam_reason;
}

function platform_steam_failed()
{
    __platform_ensure();
    return global.__platform_steam_failed;
}

function platform_ready()
{
    __platform_ensure();
    return global.platform_backend.ready();
}

function platform_user_id()
{
    __platform_ensure();
    return global.platform_backend.user_id();
}

function platform_persona_name()
{
    __platform_ensure();
    return global.platform_backend.persona_name();
}

function platform_achievements_available()
{
    __platform_ensure();
    return true && global.platform_backend.achievements_available();
}

function platform_achievement_unlock(arg0)
{
    __platform_ensure();
    global.platform_backend.achievement_unlock(arg0);
}

function platform_achievement_is_unlocked(arg0)
{
    __platform_ensure();
    return global.platform_backend.achievement_is_unlocked(arg0);
}

function platform_achievement_id(arg0)
{
    __platform_ensure();
    return global.platform_backend.achievement_id(arg0);
}

function platform_stat_increment(arg0, arg1 = 1)
{
    __platform_ensure();
    global.platform_backend.stat_increment(arg0, arg1);
}

function platform_debug_reset_stats()
{
    __platform_ensure();
    global.platform_backend.debug_reset_stats();
}

function platform_debug_reset_stats_and_achievements()
{
    __platform_ensure();
    global.platform_backend.debug_reset_stats_and_achievements();
}

function platform_cloud_available()
{
    __platform_ensure();
    return global.platform_backend.cloud_available();
}

function platform_cloud_status()
{
    __platform_ensure();
    return global.platform_backend.cloud_status();
}

function platform_cloud_consent_toast_take()
{
    __platform_ensure();
    var _b = global.platform_backend;
    return variable_struct_exists(_b, "consent_toast_take") ? _b.consent_toast_take() : false;
}

function platform_record_using_cloud()
{
    if (global.database_cloud_conflict != 0)
    {
        exit;
    }
    var _using = db_cloud_enabled();
    db_write("cloud", "using_cloud", _using);
    global.__platform_using_cloud_recorded = _using;
}

function platform_is_steam_deck()
{
    __platform_ensure();
    return global.platform_backend.is_steam_deck();
}

function platform_ugc_available()
{
    __platform_ensure();
    return global.platform_backend.ugc_available();
}

function platform_news_available()
{
    __platform_ensure();
    return global.platform_backend.news_available();
}

function platform_input_available()
{
    __platform_ensure();
    return global.platform_backend.input_available();
}

function platform_overlay_active()
{
    __platform_ensure();
    return global.platform_backend.overlay_active();
}

function platform_user_logged_on()
{
    __platform_ensure();
    return global.platform_backend.user_logged_on();
}

function platform_input_init()
{
    __platform_ensure();
    global.platform_backend.input_init();
}

function platform_input_controller_type()
{
    __platform_ensure();
    return global.platform_backend.controller_type();
}

function platform_store_url_zs2()
{
    __platform_ensure();
    return global.platform_backend.store_url_zs2();
}

function platform_survey_url()
{
    __platform_ensure();
    return global.platform_backend.survey_url();
}

function platform_login_settled()
{
    __platform_ensure();
    var _b = global.platform_backend;
    return variable_struct_exists(_b, "login_settled") ? _b.login_settled() : true;
}

function platform_product_user_id()
{
    __platform_ensure();
    var _b = global.platform_backend;
    return variable_struct_exists(_b, "product_user_id") ? _b.product_user_id() : "";
}

function platform_launched_by_epic()
{
    __platform_ensure();
    return variable_global_exists("__platform_launched_by_epic") && global.__platform_launched_by_epic;
}

function PlatformCloudRequest(arg0, arg1) constructor
{
    global.platform_cloud_request_counter += 1;
    id = global.platform_cloud_request_counter;
    op = arg0;
    name = arg1;
    done = false;
    ok = false;
    exists = false;
    text = "";
    error = "";
    on_done = undefined;
}

function __platform_cloud_track(arg0)
{
    if (!arg0.done)
    {
        array_push(global.platform_cloud_inflight, arg0);
    }
}

function platform_cloud_exists(arg0)
{
    __platform_ensure();
    var _req = new PlatformCloudRequest("exists", arg0);
    global.platform_backend.cloud_exists(_req);
    __platform_cloud_track(_req);
    return _req;
}

function platform_cloud_read(arg0)
{
    __platform_ensure();
    var _req = new PlatformCloudRequest("read", arg0);
    global.platform_backend.cloud_read(_req);
    __platform_cloud_track(_req);
    return _req;
}

function platform_cloud_write(arg0, arg1)
{
    __platform_ensure();
    var _req = new PlatformCloudRequest("write", arg0);
    _req.text = arg1;
    global.platform_backend.cloud_write(_req);
    __platform_cloud_track(_req);
    return _req;
}

function platform_cloud_delete(arg0)
{
    __platform_ensure();
    var _req = new PlatformCloudRequest("delete", arg0);
    global.platform_backend.cloud_delete(_req);
    __platform_cloud_track(_req);
    return _req;
}

function platform_cloud_quota()
{
    __platform_ensure();
    return global.platform_backend.cloud_quota();
}

function platform_cloud_pending()
{
    __platform_ensure();
    var _count = 0;
    var _inflight = global.platform_cloud_inflight;
    var _n = array_length(_inflight);
    for (var _i = 0; _i < _n; _i++)
    {
        if (!_inflight[_i].done)
        {
            _count += 1;
        }
    }
    return _count;
}

function platform_request_quit(arg0 = 600)
{
    __platform_ensure();
    if (platform_cloud_pending() == 0)
    {
        if (platform_target() != UnknownEnum.Value_1)
        {
            platform_shutdown();
        }
        game_end();
        exit;
    }
    global.platform_quit_pending = true;
    global.platform_quit_deadline = global.platform_frame + arg0;
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2
}
