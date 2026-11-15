uiAddBoxType("UiVersionText", class_ui_version_text);

function class_ui_version_text() : uiClassText() constructor
{
    liveVersionLabel = false;
    Set("font", font_get_name(font_munro_32px));
    __cloudStatus = platform_cloud_status();
    CallbackSet(UnknownEnum.Value_12, function()
    {
        if (liveVersionLabel)
        {
            var _cloudStatus = platform_cloud_status();
            if (_cloudStatus != __cloudStatus)
            {
                __cloudStatus = _cloudStatus;
                Set("label", ui_full_version_string());
            }
        }
        color = 4259071;
        if (!platform_ready() && (current_time % 1000) < 500)
        {
            color = 255;
        }
        if (!db_cloud_enabled() && (current_time % 500) < 250)
        {
            color = 32767;
        }
        uiCallInherited();
    });
}

function ui_full_version_string()
{
    var _string = "v: " + concat(1, ".", 4, ".", 13);
    if (platform_steam_failed())
    {
        _string += (" - " + language_get_string("steam.no_steam"));
    }
    switch (platform_cloud_status())
    {
        case "ready":
            break;
        case "consent_pending":
            _string += (" - " + language_get_string("platform.cloud_consent_pending"));
            break;
        case "consent_declined":
            _string += (" - " + language_get_string("platform.cloud_consent_declined"));
            break;
        case "offline":
            _string += (" - " + language_get_string("platform.cloud_offline"));
            break;
        default:
            _string += (" - " + language_get_string("when_cloud_saving_is_disabled.no_cloud"));
            break;
    }
    __platform_log("[platform] GetFullVersionString: cloud_available=" + string(platform_cloud_available()) + " ready=" + string(platform_ready()));
    return _string;
}

enum UnknownEnum
{
    Value_12 = 12
}
