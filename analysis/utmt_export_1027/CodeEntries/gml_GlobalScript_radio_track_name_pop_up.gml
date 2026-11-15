function radio_track_name_pop_up(arg0)
{
    var _name = radio_get_name(arg0);
    var _artist = radio_get_artists(arg0);
    var _text = _name + " - " + _artist;
    scr_draw_text_with_box(_text);
}
