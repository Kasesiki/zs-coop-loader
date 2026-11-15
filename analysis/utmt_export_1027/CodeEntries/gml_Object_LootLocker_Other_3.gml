if (!db_read_ext("shared settings", "Game analytics", "collect_data", false) || true)
{
    if (platform_is(UnknownEnum.Value_1))
    {
        steam_shutdown();
    }
    exit;
}
if (platform_is(UnknownEnum.Value_1) && auth_ticket_handle >= 0)
{
    steam_user_cancel_auth_ticket(auth_ticket_handle);
}
if (platform_is(UnknownEnum.Value_1))
{
    steam_shutdown();
}

enum UnknownEnum
{
    Value_1 = 1
}
