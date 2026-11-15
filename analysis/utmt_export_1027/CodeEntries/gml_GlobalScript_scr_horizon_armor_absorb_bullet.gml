function scr_horizon_armor_absorb_bullet(arg0)
{
    if (arg0 != "armor_horizon" && arg0 != "armor_horizon_boss")
    {
        return false;
    }
    if (scr_chance(15))
    {
        return true;
    }
}
