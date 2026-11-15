function force_christmas_event_setting_on()
{
    exit;
    db_open("shared settings");
    var _forced = db_read("Christmas event", "already_forced", false);
    db_close();
    if (!_forced)
    {
        settings_set("community_event", true);
        db_open("shared settings");
        db_write("Christmas event", "already_forced", true);
        db_close();
    }
}
