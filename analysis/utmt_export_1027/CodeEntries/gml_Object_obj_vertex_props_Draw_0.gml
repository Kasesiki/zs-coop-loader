if (!global.batch_props)
{
    exit;
}
if (!built)
{
    exit;
}
var _prev_ztest = gpu_get_ztestenable();
var _prev_zwrite = gpu_get_zwriteenable();
var _prev_blend = gpu_get_blendenable();
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_blendenable(false);
if (decor_spr != -1)
{
    shader_set(shd_props);
    shader_set_uniform_f(uni_props_cutoff, 0.5);
    vertex_submit(decor_buf, pr_trianglelist, sprite_get_texture(decor_spr, 0));
    shader_reset();
}
if (tree_spr != -1)
{
    var _occ = array_create(16, 0);
    var _cnt = 0;
    if (instance_exists(obj_player))
    {
        _occ[0] = obj_player.x;
        _occ[1] = obj_player.y;
        _cnt = 1;
    }
    if (instance_exists(obj_mouse))
    {
        _occ[_cnt * 2] = obj_mouse.x;
        _occ[(_cnt * 2) + 1] = obj_mouse.y;
        _cnt++;
    }
    with (obj_npc_parent)
    {
        if (_cnt >= 8)
        {
            break;
        }
        _occ[_cnt * 2] = x;
        _occ[(_cnt * 2) + 1] = y;
        _cnt++;
    }
    shader_set(shd_tree);
    shader_set_uniform_f(uni_tree_cutoff, 0.5);
    shader_set_uniform_f_array(uni_tree_occ, _occ);
    shader_set_uniform_f(uni_tree_occ_cnt, _cnt);
    shader_set_uniform_f(uni_tree_radius, 40);
    vertex_submit(tree_buf, pr_trianglelist, sprite_get_texture(tree_spr, 0));
    shader_reset();
}
gpu_set_ztestenable(_prev_ztest);
gpu_set_zwriteenable(_prev_zwrite);
gpu_set_blendenable(_prev_blend);
