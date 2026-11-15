function stash_sprite_set(arg0, arg1)
{
    global.stash_sprite[arg0] = arg1;
    var _current_stash_page = 0;
    with (uiGetData())
    {
        _current_stash_page = stash_page;
    }
    var _loot_name = language_get_string("ui.stash") + " " + string(arg0 + 1);
    if (stash_get_sprite_index(arg0) != 0)
    {
        _loot_name = language_get_string(stash_get_name(global.stash_sprite[arg0]));
    }
    if (_current_stash_page == arg0)
    {
        with (uiGetData())
        {
            loot_name = _loot_name;
        }
    }
}
