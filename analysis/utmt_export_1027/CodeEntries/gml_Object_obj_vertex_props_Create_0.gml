if (!variable_global_exists("batch_props"))
{
    global.batch_props = true;
}
gpu_set_ztestenable(true);
if (!variable_global_exists("props_vertex_format"))
{
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    vertex_format_add_custom(vertex_type_float1, vertex_usage_texcoord);
    global.props_vertex_format = vertex_format_end();
}
depth = -1;
uni_props_cutoff = shader_get_uniform(shd_props, "alpha_cutoff");
uni_tree_cutoff = shader_get_uniform(shd_tree, "alpha_cutoff");
uni_tree_occ = shader_get_uniform(shd_tree, "occluders");
uni_tree_occ_cnt = shader_get_uniform(shd_tree, "occ_count");
uni_tree_radius = shader_get_uniform(shd_tree, "fade_radius");
tree_fade = [obj_tree, obj_tree_snow, obj_tree_dead, obj_tree_dead_snow, obj_tree_distrutto, obj_tree_distrutto_snow, obj_tree_swamp];
built = false;
decor_buf = -1;
decor_spr = -1;
tree_buf = -1;
tree_spr = -1;
batch_exclude = [obj_cristallo_viola, obj_cristallo_viola_dopo_missione, obj_faro, obj_flies_1, obj_barrel_acciaio_fire, obj_stick, obj_anomaly_emitter_parent, obj_wall_lamp, obj_wall_lamp_2, obj_headquarter_block_down, obj_headquarter_block_up, obj_npp_door_dx, obj_npp_door_sx, obj_door_lab_close, obj_door_lab_dx, obj_door_lab_sx, obj_rete_porta, obj_gabinetto_porta, obj_nastro_porta_big, obj_nastro_porta_h, obj_nastro_porta_v, obj_train, obj_radio_tower, obj_tree_special, obj_water_h, obj_water_v, obj_water_h2, obj_nastro_fine_dx, obj_nastro_fine_giu, obj_nastro_fine_su, obj_nastro_fine_sx, obj_innaffiatore, obj_erba_alta_swamp, obj_swamp_erba_alta, obj_swamp_erba_bassa];
