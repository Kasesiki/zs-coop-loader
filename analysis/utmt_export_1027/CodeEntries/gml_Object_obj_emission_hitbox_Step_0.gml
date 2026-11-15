x += hspd;
if (player_meeting_local(x, y))
{
    if (!player_hitted)
    {
        if (!player_get_local().emission_riparato)
        {
            player_hitted = true;
            global.last_damage_source = "emission";
            player_damage_local(50);
        }
    }
}
