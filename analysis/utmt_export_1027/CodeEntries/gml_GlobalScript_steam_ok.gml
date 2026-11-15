function steam_ok()
{
    if (!os_is_network_connected(0))
    {
        return 
        {
            value: -1,
            error: "No Internet"
        };
    }
    if (!platform_is(UnknownEnum.Value_1))
    {
        return 
        {
            value: -2,
            error: "Steam not active",
            detail: platform_not_steam_reason()
        };
    }
    if (!platform_user_logged_on())
    {
        return 
        {
            value: -3,
            error: "Steam not logged in"
        };
    }
    return 
    {
        value: true,
        error: ""
    };
}

enum UnknownEnum
{
    Value_1 = 1
}
