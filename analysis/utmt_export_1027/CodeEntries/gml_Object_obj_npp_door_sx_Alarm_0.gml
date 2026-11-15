if (!last_quest_npp_door_setup_done)
{
    event_inherited();
    last_quest_npp_door_setup_done = true;
}
last_quest_npp_door_update_state(id, -1);
alarm[0] = 30;
