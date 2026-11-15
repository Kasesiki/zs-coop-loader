if (!variable_instance_exists(id, "corpse_sprite"))
{
    corpse_sprite = choose(s_pg_scientist_1_dead, s_pg_scientist_2_dead, s_pg_scientist_3_dead);
}
sprite_index = corpse_sprite;
