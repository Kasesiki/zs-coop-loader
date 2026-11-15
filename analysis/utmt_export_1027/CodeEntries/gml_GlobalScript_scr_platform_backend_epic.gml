function PlatformBackendEpic(arg0) constructor
{
    kind = UnknownEnum.Value_2;
    args = arg0;
    LOGIN_TIMEOUT_MS = 30000;
    AUTH_WAIT_MS = 600000;
    AUTH_PENDING_LOG_MS = 30000;
    _auth_started_at = 0;
    _auth_pending_next_log = 0;
    _auth_login_id = undefined;
    _auth_sdk_retrying = false;
    _fail_stage = "";
    _fail_status = undefined;
    _fail_offline = false;
    _consent_toast_due = false;
    _using_cloud_rerecord_due = false;
    epic_account_id = args.epicuserid;
    if (epic_account_id == "" && (args.has_epic_portal || args.epicdev || false))
    {
        var _cache = game_save_id + "epic_last_user.txt";
        if (file_exists(_cache))
        {
            var _buf = buffer_load(_cache);
            if (_buf != -1)
            {
                epic_account_id = buffer_read(_buf, buffer_string);
                buffer_delete(_buf);
            }
        }
    }
    account_id = "";
    _product_user_id = "";
    access_token = "";
    login_state = UnknownEnum.Value_0;
    state_deadline = 0;
    pending = ds_map_create();
    _unmatched_keys_logged = false;
    STAT_NAMES = ["playerdeaths", "totalkills", "raidsstarted", "containersopened", "animalskilled", "enemieskilled", "itemsrepaired", "questscompleted", "tradescompleted", "ghoulskilled", "hiddenstasheslooted", "blinkskilled", "dailyquestscompleted"];
    store = 
    {
        loaded: false,
        dirty: false,
        unlocked: {},
        stats: {},
        pending_unlocks: []
    };
    STORE_DB = "local settings";
    SEC_ACH = "epic_achievements";
    SEC_STATS = "epic_stats";
    SEC_PENDING = "epic_pending_unlocks";
    STORE_SAVE_MS = 5000;
    STAT_INGEST_MS = 2000;
    INGEST_BACKOFF_MS = 30000;
    INGEST_BACKOFF_MAX = 300000;
    _store_last_save = 0;
    _stat_ingest_last = 0;
    _store_open_warned = false;
    _stats_dirty = {};
    _unlock_logged = {};
    _stat_ingest_logged = {};
    PDS_DIR = game_save_id + "pds/";
    PDS_TIMEOUT_MS = 60000;
    PDS_MIN_INTERVAL_MS = 10000;
    _pds_dir_ready = false;
    pds_queue = [];
    pds_active = undefined;
    _pds_write_last = {};
    PDS_BUSY_RETRY_MS = 2000;
    PDS_CANCEL_GUARD_MS = 15000;
    _pds_cancelling = {};
    _pds_busy_logged = {};
    CONNECT_REFRESH_FALLBACK_MS = 3000000;
    AUTH_REFRESH_RETRY_MS = 60000;
    REFRESH_TIMEOUT_MS = 30000;
    AUTH_HEAL_DEBOUNCE_MS = 30000;
    _connect_notify_auth_exp_id = -1;
    _connect_notify_login_status_id = -1;
    _connect_notifies_subscribed = false;
    _connect_login_time = 0;
    _refresh_in_progress = false;
    _refresh_started_at = 0;
    _refresh_retry_at = 0;
    _last_relogin_time = 0;
    _refresh_count = 0;
    _auth_heal_last = 0;
    __logged = {};
    
    __noop = function(arg0)
    {
        if (!variable_struct_exists(__logged, arg0))
        {
            variable_struct_set(__logged, arg0, true);
            show_debug_message("[platform] epic: " + arg0 + " no-op (not wired)");
        }
    };
    
    __log = function(arg0)
    {
        __platform_log("[platform] epic: " + arg0);
    };
    
    __state_name = function(arg0)
    {
        switch (arg0)
        {
            case UnknownEnum.Value_0:
                return "NONE";
            case UnknownEnum.Value_1:
                return "AUTH_PENDING";
            case UnknownEnum.Value_2:
                return "CONNECT_PENDING";
            case UnknownEnum.Value_3:
                return "CREATE_PENDING";
            case UnknownEnum.Value_4:
                return "READY";
            case UnknownEnum.Value_5:
                return "FAILED";
            default:
                return string(arg0);
        }
    };
    
    __write_account_cache = function()
    {
        if (epic_account_id == "")
        {
            exit;
        }
        var _buf = buffer_create(1, buffer_grow, 1);
        buffer_write(_buf, buffer_string, epic_account_id);
        buffer_save(_buf, game_save_id + "epic_last_user.txt");
        buffer_delete(_buf);
    };
    
    if (epic_account_id != "")
    {
        __write_account_cache();
    }
    
    register = function(arg0, arg1, arg2, arg3 = undefined)
    {
        ds_map_set(pending, arg0, 
        {
            type_prefix: arg1,
            on_done: arg2,
            ctx: arg3
        });
    };
    
    on_async = function(arg0)
    {
        var _type = string(ds_map_find_value(arg0, "type"));
        if (_type == "eos_connect_add_notify_auth_expiration")
        {
            __on_auth_expiration(arg0);
            exit;
        }
        if (_type == "eos_connect_add_notify_login_status_changed")
        {
            __on_login_status_changed(arg0);
            exit;
        }
        if (is_undefined(ds_map_find_value(arg0, "status")))
        {
            exit;
        }
        if (ds_map_find_value(arg0, "status") == 19)
        {
            __log(string(ds_map_find_value(arg0, "type")) + " will retry (sdk)");
            if (!is_undefined(_auth_login_id) && ds_map_find_value(arg0, "identifier") == _auth_login_id)
            {
                _auth_sdk_retrying = true;
            }
            exit;
        }
        var _id = ds_map_find_value(arg0, "identifier");
        if (!is_undefined(_id) && ds_map_exists(pending, _id))
        {
            var _e = ds_map_find_value(pending, _id);
            if (string_pos(_e.type_prefix, string(ds_map_find_value(arg0, "type"))) == 1)
            {
                var _cb = _e.on_done;
                ds_map_delete(pending, _id);
                _cb(arg0, _e.ctx);
                exit;
            }
        }
        show_debug_message("[platform] epic: unmatched async type=" + string(ds_map_find_value(arg0, "type")) + " id=" + string(_id));
        if (!_unmatched_keys_logged)
        {
            _unmatched_keys_logged = true;
            show_debug_message("[platform] epic: registry keys=" + string(ds_map_keys_to_array(pending)));
        }
    };
    
    __enter = function(arg0)
    {
        login_state = arg0;
        if (arg0 == UnknownEnum.Value_1)
        {
            state_deadline = current_time + AUTH_WAIT_MS;
            _auth_started_at = current_time;
            _auth_pending_next_log = current_time + AUTH_PENDING_LOG_MS;
        }
        else
        {
            state_deadline = current_time + LOGIN_TIMEOUT_MS;
        }
    };
    
    __ready = function()
    {
        login_state = UnknownEnum.Value_4;
        _connect_login_time = current_time;
        __connect_subscribe();
        __log("READY puid=" + _product_user_id);
        __reconcile_begin();
        if (variable_global_exists("__platform_using_cloud_recorded") && global.__platform_using_cloud_recorded == false)
        {
            _using_cloud_rerecord_due = true;
        }
    };
    
    __fail = function(arg0)
    {
        login_state = UnknownEnum.Value_5;
        __log("FAILED: " + arg0);
    };
    
    __fail_result = function(arg0, arg1)
    {
        _fail_stage = arg0;
        _fail_status = arg1;
        _fail_offline = arg1 == 1;
        __fail(arg0 + " (" + string(arg1) + ")");
        if (arg0 == "auth" && (arg1 == 1014 || arg1 == 17))
        {
            _consent_toast_due = true;
        }
    };
    
    start_login = function()
    {
        if (args.auth_type == "exchangecode" && args.auth_password != "")
        {
            __log("AUTH_PENDING (exchange-code login)");
            var _id = eos_auth_login(1, 1, "", args.auth_password, -1);
            args.auth_password = "";
            __enter(UnknownEnum.Value_1);
            register(_id, "eos_auth_login", __on_auth_done);
            _auth_login_id = _id;
        }
        else if (false || args.epicdev)
        {
            __log("AUTH_PENDING (dev login host=localhost:6300)");
            var _id = eos_auth_login(4, 1, "localhost:6300", "michael", -1);
            args.auth_password = "";
            __enter(UnknownEnum.Value_1);
            register(_id, "eos_auth_login", __on_auth_done);
            _auth_login_id = _id;
        }
        else if (global.__platform_launched_by_epic && args.auth_password == "")
        {
            __log("no exchange code from launcher (offline mode?)");
            __fail_result("auth", 1);
        }
        else
        {
            __fail("no credentials");
        }
    };
    
    __on_auth_done = function(arg0)
    {
        _auth_sdk_retrying = false;
        if (login_state != UnknownEnum.Value_1)
        {
            __log("late auth callback ignored (" + string(ds_map_find_value(arg0, "status")) + ", state=" + __state_name(login_state) + ")");
            exit;
        }
        if (ds_map_find_value(arg0, "status") == 0)
        {
            account_id = string(ds_map_find_value(arg0, "account_id"));
            if (epic_account_id == "")
            {
                epic_account_id = account_id;
                __write_account_cache();
            }
            var _t = eos_auth_copy_user_auth_token(account_id);
            access_token = (is_struct(_t) && variable_struct_exists(_t, "access_token")) ? _t.access_token : "";
            __log("CONNECT_PENDING account_id=" + account_id);
            var _id = eos_connect_login(0, access_token, "");
            __enter(UnknownEnum.Value_2);
            register(_id, "eos_connect_login", __on_connect_done);
        }
        else
        {
            __fail_result("auth", ds_map_find_value(arg0, "status"));
        }
    };
    
    __on_connect_done = function(arg0)
    {
        if (login_state != UnknownEnum.Value_2)
        {
            exit;
        }
        var _st = ds_map_find_value(arg0, "status");
        if (_st == 0)
        {
            _product_user_id = string(ds_map_find_value(arg0, "local_user_id"));
            __ready();
        }
        else if (_st == 3)
        {
            __log("CREATE_PENDING (invalid user -> create_user)");
            var _id = eos_connect_create_user();
            __enter(UnknownEnum.Value_3);
            register(_id, "eos_connect_create_user", __on_create_done);
        }
        else
        {
            __fail_result("connect", _st);
        }
    };
    
    __on_create_done = function(arg0)
    {
        if (login_state != UnknownEnum.Value_3)
        {
            exit;
        }
        if (ds_map_find_value(arg0, "status") == 0)
        {
            _product_user_id = string(ds_map_find_value(arg0, "local_user_id"));
            __ready();
        }
        else
        {
            __fail_result("create_user", ds_map_find_value(arg0, "status"));
        }
    };
    
    __connect_subscribe = function()
    {
        if (_connect_notifies_subscribed)
        {
            exit;
        }
        _connect_notify_auth_exp_id = eos_connect_add_notify_auth_expiration();
        _connect_notify_login_status_id = eos_connect_add_notify_login_status_changed();
        _connect_notifies_subscribed = true;
        __log("connect notifies subscribed (auth_exp=" + string(_connect_notify_auth_exp_id) + " login_status=" + string(_connect_notify_login_status_id) + ")");
    };
    
    __connect_refresh = function(arg0)
    {
        if (_refresh_in_progress)
        {
            exit;
        }
        if (login_state != UnknownEnum.Value_4)
        {
            exit;
        }
        if (account_id == "")
        {
            __log("refresh skipped: no account_id (" + arg0 + ")");
            exit;
        }
        var _since = (_last_relogin_time == 0) ? -1 : ((current_time - _last_relogin_time) div 60000);
        _last_relogin_time = current_time;
        _refresh_count++;
        __log("connect re-login #" + string(_refresh_count) + " via " + arg0 + "; mins since previous=" + ((_since < 0) ? "n/a" : string(_since)));
        var _t = eos_auth_copy_user_auth_token(account_id);
        access_token = (is_struct(_t) && variable_struct_exists(_t, "access_token")) ? _t.access_token : "";
        if (access_token == "")
        {
            _refresh_retry_at = current_time + AUTH_REFRESH_RETRY_MS;
            __log("refresh: auth token copy empty; retry in " + string(AUTH_REFRESH_RETRY_MS div 1000) + "s");
            exit;
        }
        _refresh_in_progress = true;
        _refresh_started_at = current_time;
        var _id = eos_connect_login(0, access_token, "");
        register(_id, "eos_connect_login", __on_refresh_done);
    };
    
    __on_refresh_done = function(arg0)
    {
        if (!_refresh_in_progress)
        {
            __log("late refresh callback ignored");
            exit;
        }
        _refresh_in_progress = false;
        var _st = ds_map_find_value(arg0, "status");
        if (_st == 0)
        {
            var _new_puid = string(ds_map_find_value(arg0, "local_user_id"));
            var _unchanged = _new_puid == _product_user_id;
            if (_new_puid != "")
            {
                _product_user_id = _new_puid;
            }
            _connect_login_time = current_time;
            _refresh_retry_at = 0;
            __log("connect re-login ok, puid unchanged=" + string(_unchanged));
            __reconcile_replay_pending();
        }
        else
        {
            _refresh_retry_at = current_time + AUTH_REFRESH_RETRY_MS;
            __log("connect re-login failed (" + string(_st) + "); retry in " + string(AUTH_REFRESH_RETRY_MS div 1000) + "s");
        }
    };
    
    __on_auth_expiration = function(arg0)
    {
        __log("connect token expiring; re-login");
        __connect_refresh("auth-expiration");
    };
    
    __on_login_status_changed = function(arg0)
    {
        var _cur = ds_map_find_value(arg0, "current_status");
        var _prev = ds_map_find_value(arg0, "previous_status");
        __log("connect login status " + string(_prev) + " -> " + string(_cur));
        if (_cur == 0 && login_state == UnknownEnum.Value_4)
        {
            __connect_refresh("login-status-not-logged-in");
        }
    };
    
    __auth_heal = function(arg0)
    {
        if (_auth_heal_last != 0 && (current_time - _auth_heal_last) < AUTH_HEAL_DEBOUNCE_MS)
        {
            exit;
        }
        _auth_heal_last = current_time;
        __log("InvalidAuth on " + arg0 + "; healing (re-login)");
        __connect_refresh("invalid-auth:" + arg0);
    };
    
    update = function()
    {
        eos_platform_tick();
        if (login_state == UnknownEnum.Value_0)
        {
            start_login();
        }
        if (login_state == UnknownEnum.Value_1 && current_time >= _auth_pending_next_log)
        {
            _auth_pending_next_log += AUTH_PENDING_LOG_MS;
            __log("auth pending " + string((current_time - _auth_started_at) div 1000) + "s (consent dialog may be open; network=" + (_auth_sdk_retrying ? "retrying" : "ok") + ")");
        }
        if (login_state == UnknownEnum.Value_1 || login_state == UnknownEnum.Value_2 || login_state == UnknownEnum.Value_3)
        {
            if (current_time > state_deadline)
            {
                var _auth_wait_expired = login_state == UnknownEnum.Value_1;
                __fail("timeout in " + __state_name(login_state));
                if (_auth_wait_expired)
                {
                    _fail_offline = _auth_sdk_retrying;
                    if (!_fail_offline)
                    {
                        _consent_toast_due = true;
                    }
                }
            }
        }
        if (_using_cloud_rerecord_due && global.database_alias == undefined)
        {
            _using_cloud_rerecord_due = false;
            db_open("local settings");
            platform_record_using_cloud();
            db_close();
            __log("using_cloud re-recorded after late READY: " + string(global.__platform_using_cloud_recorded));
        }
        if (_refresh_in_progress && (current_time - _refresh_started_at) > REFRESH_TIMEOUT_MS)
        {
            __log("connect re-login timed out; retry in 60 s");
            _refresh_in_progress = false;
            _refresh_retry_at = current_time + AUTH_REFRESH_RETRY_MS;
        }
        if (login_state == UnknownEnum.Value_4 && !_refresh_in_progress)
        {
            if (_refresh_retry_at == 0 && _connect_login_time != 0 && (current_time - _connect_login_time) >= CONNECT_REFRESH_FALLBACK_MS)
            {
                __connect_refresh("fallback-50min");
            }
            else if (_refresh_retry_at != 0 && current_time >= _refresh_retry_at)
            {
                _refresh_retry_at = 0;
                __connect_refresh("retry");
            }
        }
        if (ready() && (current_time - _stat_ingest_last) >= STAT_INGEST_MS)
        {
            _stat_ingest_last = current_time;
            __ingest_dirty_stats();
        }
        if (store.dirty && (current_time - _store_last_save) >= STORE_SAVE_MS)
        {
            __store_save();
        }
        __pds_pump();
    };
    
    shutdown = function()
    {
        if (ds_exists(pending, ds_type_map))
        {
            ds_map_destroy(pending);
        }
        if (_connect_notifies_subscribed)
        {
            eos_connect_remove_notify_auth_expiration(_connect_notify_auth_exp_id);
            eos_connect_remove_notify_login_status_changed(_connect_notify_login_status_id);
            _connect_notifies_subscribed = false;
        }
        __log("shutdown: eos_shutdown");
        var _r = eos_shutdown();
        __log("shutdown: eos_shutdown result=" + string(_r));
    };
    
    __store_db_ready = function()
    {
        if (!variable_global_exists("database_struct"))
        {
            return false;
        }
        var _db = variable_struct_get(global.database_struct, STORE_DB);
        return is_struct(_db) && _db.loaded;
    };
    
    __store_load = function()
    {
        if (store.loaded)
        {
            exit;
        }
        if (!__store_db_ready())
        {
            exit;
        }
        var _mem_had = array_length(variable_struct_get_names(store.unlocked)) > 0 || array_length(variable_struct_get_names(store.stats)) > 0 || array_length(store.pending_unlocks) > 0;
        var _disk_ach = json_parse(db_read_ext(STORE_DB, SEC_ACH, "json", "{}"));
        var _disk_sta = json_parse(db_read_ext(STORE_DB, SEC_STATS, "json", "{}"));
        var _disk_pen = json_parse(db_read_ext(STORE_DB, SEC_PENDING, "json", "[]"));
        var _i = 0;
        var _j = 0;
        var _names = variable_struct_get_names(_disk_ach);
        for (_i = 0; _i < array_length(_names); _i++)
        {
            if (!variable_struct_exists(store.unlocked, _names[_i]))
            {
                variable_struct_set(store.unlocked, @@array_get@@(_names, _i), variable_struct_get(_disk_ach, @@array_get@@(_names, _i)));
            }
        }
        _names = variable_struct_get_names(_disk_sta);
        for (_i = 0; _i < array_length(_names); _i++)
        {
            var _m = variable_struct_get(store.stats, @@array_get@@(_names, _i));
            if (is_undefined(_m))
            {
                _m = 0;
            }
            variable_struct_set(store.stats, @@array_get@@(_names, _i), max(_m, variable_struct_get(_disk_sta, @@array_get@@(_names, _i))));
        }
        for (_i = 0; _i < array_length(_disk_pen); _i++)
        {
            var _dup = false;
            for (_j = 0; _j < array_length(store.pending_unlocks); _j++)
            {
                if (store.pending_unlocks[_j] == _disk_pen[_i])
                {
                    _dup = true;
                    break;
                }
            }
            if (!_dup)
            {
                array_push(store.pending_unlocks, _disk_pen[_i]);
            }
        }
        store.loaded = true;
        if (_mem_had)
        {
            store.dirty = true;
        }
        __log("store loaded (unlocked=" + string(array_length(variable_struct_get_names(store.unlocked))) + " stats=" + string(array_length(variable_struct_get_names(store.stats))) + " pending=" + string(array_length(store.pending_unlocks)) + ")");
    };
    
    __store_save = function()
    {
        if (!__store_db_ready())
        {
            exit;
        }
        if (global.database_alias != undefined)
        {
            if (!_store_open_warned)
            {
                _store_open_warned = true;
                __log("store save deferred: db \"" + string(global.database_alias) + "\" already open");
            }
            exit;
        }
        db_open(STORE_DB);
        db_write(SEC_ACH, "json", json_stringify(store.unlocked));
        db_write(SEC_STATS, "json", json_stringify(store.stats));
        db_write(SEC_PENDING, "json", json_stringify(store.pending_unlocks));
        db_close();
        store.dirty = false;
        _store_last_save = current_time;
    };
    
    __ingest_stat = function(arg0)
    {
        if (!ready())
        {
            exit;
        }
        var _total = variable_struct_get(store.stats, arg0);
        if (is_undefined(_total))
        {
            _total = 0;
        }
        var _id = eos_stats_ingest_stat(_product_user_id, _product_user_id, arg0, _total);
        register(_id, "eos_stats_ingest_stat", __on_ingest_done, 
        {
            key: arg0
        });
    };
    
    __on_ingest_done = function(arg0, arg1)
    {
        var _key = arg1.key;
        if (ds_map_find_value(arg0, "status") == 0)
        {
            var _total = variable_struct_get(store.stats, _key);
            if (is_undefined(_total))
            {
                _total = 0;
            }
            __log("stat ingest " + _key + "=" + string(_total) + " ok");
            variable_struct_remove(_stats_dirty, _key);
            variable_struct_remove(_stat_ingest_logged, _key);
        }
        else
        {
            if (ds_map_find_value(arg0, "status") == 4)
            {
                __auth_heal("stat ingest " + _key);
            }
            if (variable_struct_exists(_stats_dirty, _key))
            {
                var _e = variable_struct_get(_stats_dirty, _key);
                _e.backoff = (_e.backoff <= 0) ? INGEST_BACKOFF_MS : min(_e.backoff * 2, INGEST_BACKOFF_MAX);
                _e.next_attempt = current_time + _e.backoff;
                if (!variable_struct_exists(_stat_ingest_logged, _key))
                {
                    variable_struct_set(_stat_ingest_logged, _key, true);
                    __log("stat ingest failed: " + _key + " (" + string(ds_map_find_value(arg0, "status")) + "); backoff " + string(_e.backoff) + " ms");
                }
            }
        }
    };
    
    __ingest_dirty_stats = function()
    {
        var _names = variable_struct_get_names(_stats_dirty);
        for (var _i = 0; _i < array_length(_names); _i++)
        {
            if (current_time >= variable_struct_get(_stats_dirty, @@array_get@@(_names, _i)).next_attempt)
            {
                __ingest_stat(_names[_i]);
            }
        }
    };
    
    flush = function()
    {
        if (store.dirty)
        {
            __store_save();
        }
        if (ready())
        {
            __ingest_dirty_stats();
        }
        for (var _i = 0; _i < array_length(pds_queue); _i++)
        {
            pds_queue[_i].not_before = 0;
        }
    };
    
    __reconcile_begin = function()
    {
        __store_load();
        __log("reconcile: begin");
        var _id = eos_stats_query_stats(_product_user_id, _product_user_id, -1, -1);
        register(_id, "eos_stats_query_stats", __reconcile_after_stats_query);
    };
    
    __reconcile_after_stats_query = function(arg0)
    {
        if (ds_map_find_value(arg0, "status") == 0)
        {
            var _line = "reconcile: stats";
            for (var _i = 0; _i < array_length(STAT_NAMES); _i++)
            {
                var _name = STAT_NAMES[_i];
                var _s = eos_stats_copy_stat_by_name(_product_user_id, _name);
                var _server = (is_struct(_s) && variable_struct_exists(_s, "value")) ? _s.value : 0;
                var _local = variable_struct_get(store.stats, _name);
                if (is_undefined(_local))
                {
                    _local = 0;
                }
                var _merged = max(_local, _server);
                if (is_undefined(variable_struct_get(store.stats, _name)) || _merged != _local)
                {
                    variable_struct_set(store.stats, _name, _merged);
                    store.dirty = true;
                }
                _line += (" " + _name + "=" + string(_local) + "/" + string(_server) + "→" + string(_merged));
            }
            __log(_line);
        }
        else
        {
            __log("reconcile: stats query failed (" + string(ds_map_find_value(arg0, "status")) + ")");
        }
        __reconcile_push_stats();
        var _id = eos_achievements_query_definitions(_product_user_id);
        register(_id, "eos_achievements_query_definitions", __reconcile_after_ach_defs);
    };
    
    __reconcile_push_stats = function()
    {
        for (var _i = 0; _i < array_length(STAT_NAMES); _i++)
        {
            var _name = STAT_NAMES[_i];
            var _total = variable_struct_get(store.stats, _name);
            if (!is_undefined(_total) && _total > 0)
            {
                __ingest_stat(_name);
            }
        }
    };
    
    __reconcile_after_ach_defs = function(arg0)
    {
        if (ds_map_find_value(arg0, "status") != 0)
        {
            __log("reconcile: achievement definitions query failed (" + string(ds_map_find_value(arg0, "status")) + ")");
            __store_save();
            exit;
        }
        __log("reconcile: definitions: " + string(eos_achievements_get_achievement_definition_count()));
        var _id = eos_achievements_query_player_achievements(_product_user_id, _product_user_id);
        register(_id, "eos_achievements_query_player_achievements", __reconcile_after_player_ach);
    };
    
    __reconcile_after_player_ach = function(arg0)
    {
        if (ds_map_find_value(arg0, "status") == 0)
        {
            var _new = 0;
            var _count = eos_achievements_get_achievement_definition_count();
            for (var _i = 0; _i < _count; _i++)
            {
                var _def = eos_achievements_copy_achievement_definition_v2_by_index(_i);
                if (!is_struct(_def) || !variable_struct_exists(_def, "achievement_id"))
                {
                    continue;
                }
                var _aid = _def.achievement_id;
                var _pa = eos_achievements_copy_player_achievement_by_achievement_id(_product_user_id, _product_user_id, _aid);
                if (is_struct(_pa) && variable_struct_exists(_pa, "unlock_time") && _pa.unlock_time != -1)
                {
                    if (!variable_struct_exists(store.unlocked, _aid))
                    {
                        variable_struct_set(store.unlocked, _aid, _pa.unlock_time);
                        store.dirty = true;
                        _new++;
                    }
                }
            }
            __log("reconcile: union: " + string(_new) + " new");
        }
        else
        {
            __log("reconcile: player achievements query failed (" + string(ds_map_find_value(arg0, "status")) + ")");
        }
        __reconcile_replay_pending();
        __store_save();
        __log("reconcile: complete");
    };
    
    __reconcile_replay_pending = function()
    {
        var _queue = store.pending_unlocks;
        for (var _i = 0; _i < array_length(_queue); _i++)
        {
            var _key = _queue[_i];
            var _id = eos_achievements_unlock_achievement(_product_user_id, _key);
            register(_id, "eos_achievements_unlock_achievement", __on_unlock_done, 
            {
                key: _key,
                replay: true
            });
        }
    };
    
    __pending_remove = function(arg0)
    {
        var _out = [];
        var _removed = false;
        for (var _i = 0; _i < array_length(store.pending_unlocks); _i++)
        {
            if (store.pending_unlocks[_i] != arg0)
            {
                array_push(_out, store.pending_unlocks[_i]);
            }
            else
            {
                _removed = true;
            }
        }
        if (_removed)
        {
            store.pending_unlocks = _out;
            store.dirty = true;
        }
    };
    
    ready = function()
    {
        return login_state == UnknownEnum.Value_4;
    };
    
    login_settled = function()
    {
        return login_state == UnknownEnum.Value_4 || login_state == UnknownEnum.Value_5;
    };
    
    product_user_id = function()
    {
        return _product_user_id;
    };
    
    user_logged_on = function()
    {
        return ready();
    };
    
    user_id = function()
    {
        return (epic_account_id != "") ? epic_account_id : "offline";
    };
    
    persona_name = function()
    {
        return (args.epicusername != "") ? args.epicusername : "Epic User";
    };
    
    achievements_available = function()
    {
        return true;
    };
    
    cloud_available = function()
    {
        return ready();
    };
    
    cloud_status = function()
    {
        if (login_state == UnknownEnum.Value_4)
        {
            return "ready";
        }
        if (login_state == UnknownEnum.Value_1 || login_state == UnknownEnum.Value_2 || login_state == UnknownEnum.Value_3)
        {
            return _auth_sdk_retrying ? "offline" : "consent_pending";
        }
        if (login_state == UnknownEnum.Value_5)
        {
            if (_fail_offline)
            {
                return "offline";
            }
            if (_fail_stage == "auth" && (_fail_status == 1014 || _fail_status == 17))
            {
                return "consent_declined";
            }
            return "failed";
        }
        return "failed";
    };
    
    consent_toast_take = function()
    {
        if (!_consent_toast_due)
        {
            return false;
        }
        _consent_toast_due = false;
        return true;
    };
    
    is_steam_deck = function()
    {
        return false;
    };
    
    ugc_available = function()
    {
        return false;
    };
    
    news_available = function()
    {
        return false;
    };
    
    input_available = function()
    {
        return false;
    };
    
    overlay_active = function()
    {
        return false;
    };
    
    achievement_id = function(arg0)
    {
        return arg0;
    };
    
    achievement_is_unlocked = function(arg0)
    {
        __store_load();
        return variable_struct_exists(store.unlocked, arg0);
    };
    
    achievement_unlock = function(arg0)
    {
        __store_load();
        if (variable_struct_exists(store.unlocked, arg0))
        {
            exit;
        }
        variable_struct_set(store.unlocked, arg0, 1);
        store.dirty = true;
        if (ready())
        {
            __unlock_on_server(arg0);
        }
        else
        {
            __pending_add(arg0);
        }
    };
    
    __unlock_on_server = function(arg0)
    {
        var _id = eos_achievements_unlock_achievement(_product_user_id, arg0);
        register(_id, "eos_achievements_unlock_achievement", __on_unlock_done, 
        {
            key: arg0
        });
    };
    
    __on_unlock_done = function(arg0, arg1)
    {
        var _key = arg1.key;
        var _st = ds_map_find_value(arg0, "status");
        if (_st == 0)
        {
            __pending_remove(_key);
        }
        else
        {
            if (_st == 4)
            {
                __auth_heal("achievement unlock " + _key);
            }
            __pending_add(_key);
            if (!variable_struct_exists(_unlock_logged, _key))
            {
                variable_struct_set(_unlock_logged, _key, true);
                __log("achievement server-unlock failed, queued: " + _key + " (" + string(_st) + ")");
            }
        }
        if (is_struct(arg1) && variable_struct_exists(arg1, "replay") && arg1.replay)
        {
            __log("reconcile: replay " + _key + ": " + ((_st == 0) ? "ok" : ("fail " + string(_st))));
        }
    };
    
    __pending_add = function(arg0)
    {
        for (var _i = 0; _i < array_length(store.pending_unlocks); _i++)
        {
            if (store.pending_unlocks[_i] == arg0)
            {
                exit;
            }
        }
        array_push(store.pending_unlocks, arg0);
        store.dirty = true;
    };
    
    stat_increment = function(arg0, arg1)
    {
        __store_load();
        var _cur = variable_struct_get(store.stats, arg0);
        if (is_undefined(_cur))
        {
            _cur = 0;
        }
        variable_struct_set(store.stats, arg0, _cur + arg1);
        store.dirty = true;
        if (!variable_struct_exists(_stats_dirty, arg0))
        {
            variable_struct_set(_stats_dirty, arg0, 
            {
                next_attempt: 0,
                backoff: 0
            });
        }
    };
    
    debug_reset_stats = function()
    {
        __store_load();
        store.stats = {};
        store.dirty = true;
        __log("server stats reset via portal Player search only");
    };
    
    debug_reset_stats_and_achievements = function()
    {
        __store_load();
        store.stats = {};
        store.unlocked = {};
        store.pending_unlocks = [];
        store.dirty = true;
        __log("server stats reset via portal Player search only");
    };
    
    cloud_exists = function(arg0)
    {
        return __pds_enqueue(arg0, "exists", undefined);
    };
    
    cloud_read = function(arg0)
    {
        return __pds_enqueue(arg0, "read", PDS_DIR + "dl_" + arg0.name);
    };
    
    cloud_write = function(arg0)
    {
        if (!ready())
        {
            arg0.ok = false;
            arg0.error = "not logged in";
            arg0.done = true;
            return arg0;
        }
        __pds_ensure_dir();
        var _q = __pds_find_queued_write(arg0.name);
        if (_q != undefined)
        {
            _q.req.text = arg0.text;
            array_push(_q.riders, arg0);
            __log("pds write " + string(arg0.name) + " coalesced (+" + string(array_length(_q.riders)) + " riders)");
            return arg0;
        }
        var _nb = 0;
        if (variable_struct_exists(_pds_write_last, arg0.name))
        {
            var _last = variable_struct_get(_pds_write_last, arg0.name);
            if ((current_time - _last) < PDS_MIN_INTERVAL_MS)
            {
                _nb = _last + PDS_MIN_INTERVAL_MS;
            }
        }
        array_push(pds_queue, 
        {
            req: arg0,
            op: "write",
            staging: PDS_DIR + "up_" + arg0.name,
            riders: [],
            not_before: _nb
        });
        return arg0;
    };
    
    cloud_delete = function(arg0)
    {
        return __pds_enqueue(arg0, "delete", undefined);
    };
    
    cloud_quota = function()
    {
        return undefined;
    };
    
    __pds_ensure_dir = function()
    {
        if (_pds_dir_ready)
        {
            exit;
        }
        directory_create(PDS_DIR);
        _pds_dir_ready = true;
    };
    
    __pds_enqueue = function(arg0, arg1, arg2)
    {
        if (!ready())
        {
            arg0.ok = false;
            arg0.error = "not logged in";
            arg0.done = true;
            return arg0;
        }
        __pds_ensure_dir();
        array_push(pds_queue, 
        {
            req: arg0,
            op: arg1,
            staging: arg2,
            riders: [],
            not_before: 0
        });
        return arg0;
    };
    
    __pds_find_queued_write = function(arg0)
    {
        for (var _i = 0; _i < array_length(pds_queue); _i++)
        {
            var _e = pds_queue[_i];
            if (_e.op == "write" && _e.req.name == arg0)
            {
                return _e;
            }
        }
        return undefined;
    };
    
    __pds_stage_write = function(arg0, arg1)
    {
        var _buf = buffer_create(1, buffer_grow, 1);
        buffer_write(_buf, buffer_text, arg1);
        buffer_save(_buf, arg0);
        buffer_delete(_buf);
    };
    
    __pds_load_text = function(arg0)
    {
        if (!file_exists(arg0))
        {
            return "";
        }
        var _buf = buffer_load(arg0);
        if (_buf == -1)
        {
            return "";
        }
        var _t = buffer_read(_buf, buffer_text);
        buffer_delete(_buf);
        return _t;
    };
    
    __pds_pump = function()
    {
        if (pds_active != undefined)
        {
            if (current_time > pds_active.deadline)
            {
                var _a = pds_active;
                _a.req.ok = false;
                _a.req.error = "timeout";
                if (_a.op == "read" || _a.op == "write")
                {
                    eos_player_data_storage_file_transfer_request_cancel_request(_a.req.name);
                    __log("pds " + _a.op + " " + string(_a.req.name) + " timeout -> cancel_request");
                    variable_struct_set(_pds_cancelling, _a.req.name, current_time);
                }
                __pds_finish(_a);
            }
            exit;
        }
        if (array_length(pds_queue) == 0)
        {
            exit;
        }
        var _cnames = variable_struct_get_names(_pds_cancelling);
        for (var _c = 0; _c < array_length(_cnames); _c++)
        {
            if ((current_time - variable_struct_get(_pds_cancelling, @@array_get@@(_cnames, _c))) >= PDS_CANCEL_GUARD_MS)
            {
                __pds_leave_cancelling(_cnames[_c], string(PDS_CANCEL_GUARD_MS div 1000) + "s elapsed");
            }
        }
        var _idx = -1;
        for (var _i = 0; _i < array_length(pds_queue); _i++)
        {
            if (pds_queue[_i].not_before > current_time)
            {
                continue;
            }
            if (variable_struct_exists(_pds_cancelling, pds_queue[_i].req.name))
            {
                continue;
            }
            _idx = _i;
            break;
        }
        if (_idx == -1)
        {
            exit;
        }
        var _e = pds_queue[_idx];
        array_delete(pds_queue, _idx, 1);
        _e.started = current_time;
        _e.deadline = current_time + PDS_TIMEOUT_MS;
        _e.status = undefined;
        _e.finished = false;
        pds_active = _e;
        __pds_start(_e);
    };
    
    __pds_start = function(arg0)
    {
        var _req = arg0.req;
        var _id = -1;
        switch (arg0.op)
        {
            case "exists":
                _id = eos_player_data_storage_query_file(_product_user_id, _req.name);
                register(_id, "eos_player_data_storage_query_file", __on_pds_exists, 
                {
                    entry: arg0
                });
                break;
            case "read":
                if (file_exists(arg0.staging))
                {
                    file_delete(arg0.staging);
                }
                _id = eos_player_data_storage_read_file(_product_user_id, _req.name, arg0.staging);
                if (_id == -2)
                {
                    __pds_busy_requeue(arg0);
                    exit;
                }
                register(_id, "eos_player_data_storage_read_file", __on_pds_read, 
                {
                    entry: arg0
                });
                break;
            case "write":
                __pds_stage_write(arg0.staging, _req.text);
                _id = eos_player_data_storage_write_file(_product_user_id, _req.name, arg0.staging);
                if (_id == -2)
                {
                    __pds_busy_requeue(arg0);
                    exit;
                }
                register(_id, "eos_player_data_storage_write_file", __on_pds_write, 
                {
                    entry: arg0
                });
                break;
            case "delete":
                _id = eos_player_data_storage_delete_file(_product_user_id, _req.name);
                register(_id, "eos_player_data_storage_delete_file", __on_pds_delete, 
                {
                    entry: arg0
                });
                break;
        }
    };
    
    __pds_busy_requeue = function(arg0)
    {
        if (pds_active == arg0)
        {
            pds_active = undefined;
        }
        arg0.not_before = current_time + PDS_BUSY_RETRY_MS;
        array_push(pds_queue, arg0);
        if (!variable_struct_exists(_pds_busy_logged, arg0.req.name))
        {
            variable_struct_set(_pds_busy_logged, arg0.req.name, true);
            __log("pds " + arg0.op + " " + string(arg0.req.name) + " busy; requeued");
        }
    };
    
    __pds_leave_cancelling = function(arg0, arg1)
    {
        if (variable_struct_exists(_pds_cancelling, arg0))
        {
            variable_struct_remove(_pds_cancelling, arg0);
            __log("pds " + string(arg0) + " left cancelling set: " + arg1);
        }
    };
    
    __pds_finish = function(arg0)
    {
        if (arg0.finished)
        {
            exit;
        }
        arg0.finished = true;
        var _res = arg0.req.ok ? "ok" : ("fail " + (is_undefined(arg0.status) ? "timeout" : string(arg0.status)));
        __log("pds " + arg0.op + " " + string(arg0.req.name) + " " + _res + " " + string(current_time - arg0.started) + "ms");
        if (arg0.staging != undefined && file_exists(arg0.staging))
        {
            file_delete(arg0.staging);
        }
        if (arg0.op == "write")
        {
            variable_struct_set(_pds_write_last, arg0.req.name, current_time);
            for (var _i = 0; _i < array_length(arg0.riders); _i++)
            {
                var _rider = arg0.riders[_i];
                _rider.ok = arg0.req.ok;
                _rider.error = arg0.req.error;
                _rider.done = true;
            }
        }
        if (variable_struct_exists(_pds_busy_logged, arg0.req.name))
        {
            variable_struct_remove(_pds_busy_logged, arg0.req.name);
        }
        arg0.req.done = true;
        if (pds_active == arg0)
        {
            pds_active = undefined;
        }
    };
    
    __pds_requeue = function(arg0, arg1)
    {
        __auth_heal("pds " + arg0.op + " " + string(arg0.req.name));
        if (arg0.finished)
        {
            return false;
        }
        if (variable_struct_exists(arg0, "auth_retried") && arg0.auth_retried)
        {
            return false;
        }
        arg0.auth_retried = true;
        arg0.not_before = current_time + AUTH_HEAL_DEBOUNCE_MS;
        if (pds_active == arg0)
        {
            pds_active = undefined;
        }
        array_push(pds_queue, arg0);
        __log("pds " + arg0.op + " " + string(arg0.req.name) + " requeued after InvalidAuth");
        return true;
    };
    
    __on_pds_exists = function(arg0, arg1)
    {
        var _e = arg1.entry;
        if (_e.finished)
        {
            exit;
        }
        var _st = ds_map_find_value(arg0, "status");
        _e.status = _st;
        if (_st == 0)
        {
            _e.req.exists = true;
            _e.req.ok = true;
        }
        else if (_st == 18)
        {
            _e.req.exists = false;
            _e.req.ok = true;
        }
        else if (_st == 4 && __pds_requeue(_e, "exists"))
        {
            exit;
        }
        else
        {
            _e.req.ok = false;
            _e.req.error = "query (" + string(_st) + ")";
        }
        __pds_finish(_e);
    };
    
    __on_pds_read = function(arg0, arg1)
    {
        var _e = arg1.entry;
        __pds_leave_cancelling(_e.req.name, "completion " + string(ds_map_find_value(arg0, "status")));
        if (_e.finished)
        {
            exit;
        }
        var _st = ds_map_find_value(arg0, "status");
        _e.status = _st;
        if (_st == 0)
        {
            _e.req.text = __pds_load_text(_e.staging);
            _e.req.ok = true;
        }
        else if (_st == 18)
        {
            _e.req.ok = false;
            _e.req.error = "missing";
        }
        else if (_st == 4 && __pds_requeue(_e, "read"))
        {
            exit;
        }
        else
        {
            _e.req.ok = false;
            _e.req.error = "read (" + string(_st) + ")";
        }
        __pds_finish(_e);
    };
    
    __on_pds_write = function(arg0, arg1)
    {
        var _e = arg1.entry;
        __pds_leave_cancelling(_e.req.name, "completion " + string(ds_map_find_value(arg0, "status")));
        if (_e.finished)
        {
            exit;
        }
        var _st = ds_map_find_value(arg0, "status");
        _e.status = _st;
        if (_st == 4 && __pds_requeue(_e, "write"))
        {
            exit;
        }
        _e.req.ok = _st == 0;
        if (!_e.req.ok)
        {
            _e.req.error = "write (" + string(_st) + ")";
        }
        __pds_finish(_e);
    };
    
    __on_pds_delete = function(arg0, arg1)
    {
        var _e = arg1.entry;
        if (_e.finished)
        {
            exit;
        }
        var _st = ds_map_find_value(arg0, "status");
        _e.status = _st;
        if (_st == 4 && __pds_requeue(_e, "delete"))
        {
            exit;
        }
        _e.req.ok = _st == 0 || _st == 18;
        if (!_e.req.ok)
        {
            _e.req.error = "delete (" + string(_st) + ")";
        }
        __pds_finish(_e);
    };
    
    input_init = function()
    {
        __noop("input_init");
    };
    
    controller_type = function()
    {
        var _desc = "";
        for (var _i = 0; _i <= 11; _i++)
        {
            if (gamepad_is_connected(_i))
            {
                _desc = gamepad_get_description(_i);
            }
        }
        return 
        {
            family: __platform_gamepad_family_from_description(_desc),
            is_steam_deck: false,
            handles: []
        };
    };
    
    store_url_zs2 = function()
    {
        return "https://store.epicgames.com/p/zero-sievert-2-b3d2b8";
    };
    
    survey_url = function()
    {
        return "https://forms.gle/fbfxaUqoLiDwzJdu9";
    };
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_4,
    Value_5
}
