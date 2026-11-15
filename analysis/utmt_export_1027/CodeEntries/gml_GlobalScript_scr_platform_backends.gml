function PlatformBackendSteam() constructor
{
    kind = UnknownEnum.Value_1;
    
    update = function()
    {
        steam_update();
    };
    
    shutdown = function()
    {
        steam_shutdown();
    };
    
    ready = function()
    {
        return steam_initialised();
    };
    
    user_id = function()
    {
        return string(steam_get_user_account_id());
    };
    
    persona_name = function()
    {
        return (steam_get_user_account_id() > 0) ? steam_get_persona_name() : "Unknown";
    };
    
    achievements_available = function()
    {
        return true;
    };
    
    achievement_unlock = function(arg0)
    {
        steam_set_achievement(arg0);
    };
    
    achievement_is_unlocked = function(arg0)
    {
        return steam_get_achievement(arg0);
    };
    
    achievement_id = function(arg0)
    {
        return arg0;
    };
    
    stat_increment = function(arg0, arg1)
    {
        steam_set_stat_int(arg0, steam_get_stat_int(arg0) + arg1);
        trace("Steam stat incremented: " + arg0);
    };
    
    debug_reset_stats = function()
    {
        steam_reset_all_stats();
    };
    
    debug_reset_stats_and_achievements = function()
    {
        steam_reset_all_stats_achievements();
    };
    
    cloud_available = function()
    {
        return steam_is_cloud_enabled_for_app() && steam_is_cloud_enabled_for_account();
    };
    
    cloud_status = function()
    {
        return cloud_available() ? "ready" : "disabled";
    };
    
    cloud_exists = function(arg0)
    {
        arg0.exists = steam_file_exists(arg0.name);
        arg0.ok = true;
        arg0.done = true;
        return arg0;
    };
    
    cloud_read = function(arg0)
    {
        if (!steam_file_exists(arg0.name))
        {
            arg0.ok = false;
            arg0.error = "missing";
        }
        else
        {
            arg0.text = steam_file_read(arg0.name);
            arg0.ok = true;
        }
        arg0.done = true;
        return arg0;
    };
    
    cloud_write = function(arg0)
    {
        var _r = steam_file_write(arg0.name, arg0.text, string_length(arg0.text));
        arg0.ok = _r > 0;
        if (!arg0.ok)
        {
            arg0.error = "steam_file_write=" + string(_r);
        }
        arg0.done = true;
        return arg0;
    };
    
    cloud_delete = function(arg0)
    {
        arg0.ok = steam_file_delete(arg0.name);
        arg0.done = true;
        return arg0;
    };
    
    cloud_quota = function()
    {
        return 
        {
            total: steam_get_quota_total(),
            free: steam_get_quota_free()
        };
    };
    
    overlay_active = function()
    {
        return steam_is_overlay_activated();
    };
    
    user_logged_on = function()
    {
        return steam_is_user_logged_on();
    };
    
    is_steam_deck = function()
    {
        return steam_utils_is_steam_running_on_steam_deck();
    };
    
    ugc_available = function()
    {
        return true;
    };
    
    news_available = function()
    {
        return true;
    };
    
    input_available = function()
    {
        return true;
    };
    
    input_init = function()
    {
        steam_input_init(true);
    };
    
    controller_type = function()
    {
        steam_input_run_frame();
        var _handles = steam_input_get_connected_controllers();
        if (is_undefined(_handles) || array_length(_handles) <= 0)
        {
            return 
            {
                family: 0,
                is_steam_deck: false,
                handles: []
            };
        }
        var _type = steam_input_get_input_type_for_handle(_handles[array_length(_handles) - 1]);
        var _family;
        switch (_type)
        {
            case 2:
            case 3:
            case 4:
                _family = 0;
                break;
            case 12:
            case 5:
            case 13:
                _family = 1;
                break;
            case 8:
            case 9:
            case 10:
                _family = 2;
                break;
            case 6:
            case 7:
            case 11:
            case 1:
            case 14:
            default:
                _family = 0;
                break;
        }
        return 
        {
            family: _family,
            is_steam_deck: _type == 14,
            handles: _handles
        };
    };
    
    store_url_zs2 = function()
    {
        return "https://store.steampowered.com/app/4210060/ZERO_Sievert_2/";
    };
    
    survey_url = function()
    {
        return "https://forms.gle/6oN4kAxKyxf5Rcbv5";
    };
}

function PlatformBackendNull() constructor
{
    kind = UnknownEnum.Value_0;
    __logged = {};
    
    __noop = function(arg0)
    {
        if (!variable_struct_exists(__logged, arg0))
        {
            variable_struct_set(__logged, arg0, true);
            show_debug_message("[platform] " + arg0 + " no-op (backend NONE)");
        }
    };
    
    update = function()
    {
        __noop("update");
    };
    
    shutdown = function()
    {
        __noop("shutdown");
    };
    
    ready = function()
    {
        return false;
    };
    
    user_id = function()
    {
        return "offline";
    };
    
    persona_name = function()
    {
        return "Unknown";
    };
    
    achievements_available = function()
    {
        return false;
    };
    
    achievement_unlock = function(arg0)
    {
        __noop("achievement_unlock");
    };
    
    achievement_is_unlocked = function(arg0)
    {
        return false;
    };
    
    achievement_id = function(arg0)
    {
        return arg0;
    };
    
    stat_increment = function(arg0, arg1)
    {
        __noop("stat_increment");
    };
    
    debug_reset_stats = function()
    {
        __noop("debug_reset_stats");
    };
    
    debug_reset_stats_and_achievements = function()
    {
        __noop("debug_reset_stats_and_achievements");
    };
    
    cloud_available = function()
    {
        return false;
    };
    
    cloud_status = function()
    {
        return "disabled";
    };
    
    cloud_exists = function(arg0)
    {
        __noop("cloud_exists");
        arg0.ok = false;
        arg0.error = "no backend";
        arg0.done = true;
        return arg0;
    };
    
    cloud_read = function(arg0)
    {
        __noop("cloud_read");
        arg0.ok = false;
        arg0.error = "no backend";
        arg0.done = true;
        return arg0;
    };
    
    cloud_write = function(arg0)
    {
        __noop("cloud_write");
        arg0.ok = false;
        arg0.error = "no backend";
        arg0.done = true;
        return arg0;
    };
    
    cloud_delete = function(arg0)
    {
        __noop("cloud_delete");
        arg0.ok = false;
        arg0.error = "no backend";
        arg0.done = true;
        return arg0;
    };
    
    cloud_quota = function()
    {
        __noop("cloud_quota");
        return undefined;
    };
    
    overlay_active = function()
    {
        return false;
    };
    
    user_logged_on = function()
    {
        return false;
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
        return "";
    };
    
    survey_url = function()
    {
        return "";
    };
}

function __platform_gamepad_family_from_description(arg0)
{
    var _d = string_lower(arg0);
    if (string_pos("xbox", _d) > 0 || string_pos("xinput", _d) > 0)
    {
        return 0;
    }
    if (string_pos("ps", _d) > 0 || string_pos("dualshock", _d) > 0 || string_pos("dualsense", _d) > 0 || string_pos("sony", _d) > 0 || string_pos("playstation", _d) > 0 || string_pos("wireless controller", _d) > 0)
    {
        return 1;
    }
    if (string_pos("switch", _d) > 0 || string_pos("pro controller", _d) > 0 || string_pos("joy-con", _d) > 0 || string_pos("nintendo", _d) > 0)
    {
        return 2;
    }
    return 0;
}

enum UnknownEnum
{
    Value_0,
    Value_1
}
