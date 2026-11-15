if (!variable_instance_exists(id, "corpse_sprite"))
{
    corpse_sprite = choose(s_cc_standard_0_dead, s_cc_standard_1_dead, s_cc_standard_2_dead, s_cc_standard_3_dead, s_cc_cyclops_dead);
}
sprite_index = corpse_sprite;
