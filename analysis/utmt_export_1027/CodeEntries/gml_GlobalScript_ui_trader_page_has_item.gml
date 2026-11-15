function ui_trader_page_has_item(arg0)
{
    var _loot_array = uiGetData().trader_target.loot_array;
    var _i = 0;
    repeat (array_length(_loot_array))
    {
        var _loot = _loot_array[_i];
        if (_loot.page == arg0)
        {
            return true;
        }
        _i++;
    }
    return false;
}
