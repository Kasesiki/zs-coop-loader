function radio_save()
{
    db_open("general");
    db_write("radio", "on", global.radio_struct.on);
    db_write("radio", "track_now", global.radio_struct.track_now);
    db_write("radio", "volume", global.radio_struct.volume);
    db_write("radio", "unlocked", global.radio_struct.unlocked);
    db_write("radio", "loop_track", global.radio_struct.loop_track);
    db_close();
}
