function player_action_change_weapon(arg0)
{
    if (weapon_slot_now != arg0)
    {
        if (!switching_weapon)
        {
            weapon_slot_before_switch = weapon_slot_now;
        }
        reloading = false;
        alarm[0] = 1;
        action = true;
        switching_weapon = true;
        next_weapon_slot = arg0;
        switching_fase = 0;
    }
}
