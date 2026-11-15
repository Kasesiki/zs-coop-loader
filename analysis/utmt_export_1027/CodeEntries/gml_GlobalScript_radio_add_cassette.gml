function radio_add_cassette()
{
    var _item_cassette = radio_find_first_cassette_in_inventory();
    if (!item_exists(_item_cassette))
    {
        scr_draw_text_with_box("No Casssette found");
        return -4;
    }
    inventory_remove_item(_item_cassette, 1);
    var _track_id = radio_cassette_get_track_id(_item_cassette);
    radio_unlock_track(_track_id);
    scr_draw_text_with_box("Track Unlocked");
    return _track_id;
}
