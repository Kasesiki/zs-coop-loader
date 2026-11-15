if (loadout_wait > 0 && player_exists_local())
{
    if (--loadout_wait == 0)
    {
        dev_default_loadout();
    }
}
if (++poll_timer >= 15)
{
    poll_timer = 0;
    dev_bridge_poll();
}
dev_queue_step();
dev_lootdemo_step();
