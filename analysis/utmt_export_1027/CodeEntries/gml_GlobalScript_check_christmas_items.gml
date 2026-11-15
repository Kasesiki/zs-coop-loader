function check_christmas_items()
{
    exit;
    var _santa_ak = false;
    var _santa_armor = false;
    var _santa_backpack = false;
    var _santa_grenade = false;
    if (inventory_item_exists("santa_ak"))
    {
        _santa_ak = true;
    }
    if (inventory_item_exists("armor_natale"))
    {
        _santa_armor = true;
    }
    if (inventory_item_exists("backpack_santa"))
    {
        _santa_backpack = true;
    }
    if (inventory_item_exists("grenade_christmas"))
    {
        _santa_grenade = true;
    }
    db_open("shared settings");
    if (_santa_ak)
    {
        db_write("Christmas event items", "santa ak", true);
    }
    if (_santa_armor)
    {
        db_write("Christmas event items", "santa armor", true);
    }
    if (_santa_backpack)
    {
        db_write("Christmas event items", "santa backpack", true);
    }
    if (_santa_grenade)
    {
        db_write("Christmas event items", "santa grenade", true);
    }
    db_close();
}
