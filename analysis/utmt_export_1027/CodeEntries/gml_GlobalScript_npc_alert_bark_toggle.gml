function npc_bark_get()
{
    return global.npc_alert_bark_on;
}

function npc_bark_set(arg0)
{
    global.npc_alert_bark_on = arg0;
    db_open("shared");
    db_write("audio", "npc_alert_bark", arg0);
    db_close();
}
