if (built)
{
    exit;
}
if (!global.batch_props)
{
    exit;
}
if (is_in_raid())
{
    if (!instance_exists(obj_object_shadow))
    {
        exit;
    }
    if (!surface_exists(obj_object_shadow.surface_shadow))
    {
        exit;
    }
}
else if (is_in_hub())
{
    if (!variable_instance_exists(id, "_wait"))
    {
        _wait = 0;
    }
    _wait++;
    if (_wait < 8)
    {
        exit;
    }
}
else
{
    exit;
}
var _excl = batch_exclude;
var _trees = tree_fade;
var _decor = [];
with (obj_decor_parent)
{
    if (!visible)
    {
        continue;
    }
    if (!sprite_exists(sprite_index))
    {
        continue;
    }
    if (object_is_ancestor(object_index, obj_solid))
    {
        continue;
    }
    if (object_is_ancestor(object_index, obj_anomaly_emitter_parent))
    {
        continue;
    }
    if (image_speed != 0)
    {
        continue;
    }
    var _skip = false;
    var _e = 0;
    repeat (array_length(_excl))
    {
        if (object_index == _excl[_e])
        {
            _skip = true;
            break;
        }
        _e++;
    }
    if (_skip)
    {
        continue;
    }
    array_push(_decor, id);
}
var _solid = [];
with (obj_solid)
{
    if (!visible)
    {
        continue;
    }
    if (!sprite_exists(sprite_index))
    {
        continue;
    }
    if (image_speed != 0)
    {
        continue;
    }
    if (object_index == obj_train || object_index == obj_train_hub || object_index == obj_mod_generic_solid)
    {
        continue;
    }
    if (object_is_ancestor(object_index, obj_anomaly_emitter_parent))
    {
        continue;
    }
    var _skip = false;
    var _e = 0;
    repeat (array_length(_excl))
    {
        if (object_index == _excl[_e])
        {
            _skip = true;
            break;
        }
        _e++;
    }
    if (_skip)
    {
        continue;
    }
    array_push(_solid, id);
}
var _props_map = ds_map_create();
var _trees_map = ds_map_create();
var _gs = texturegroup_get_sprites("Dynamic_props");
for (var _i = 0; _i < array_length(_gs); _i++)
{
    ds_map_set(_props_map, @@array_get@@(_gs, _i), true);
}
_gs = texturegroup_get_sprites("Dynamic_trees");
for (var _i = 0; _i < array_length(_gs); _i++)
{
    ds_map_set(_trees_map, @@array_get@@(_gs, _i), true);
}
var _fmt = global.props_vertex_format;
decor_buf = vertex_create_buffer();
vertex_begin(decor_buf, _fmt);
decor_spr = -1;
tree_buf = vertex_create_buffer();
vertex_begin(tree_buf, _fmt);
tree_spr = -1;
var _count = 0;
var _skipped = 0;
var _decor_n = 0;
var _tree_n = 0;
for (var _pass = 0; _pass < 2; _pass++)
{
    var _arr = (_pass == 0) ? _decor : _solid;
    var _n = 0;
    repeat (array_length(_arr))
    {
        var _inst = _arr[_n];
        _n++;
        var _spr = _inst.sprite_index;
        var _img = floor(_inst.image_index);
        var _w = sprite_get_width(_spr);
        var _h = sprite_get_height(_spr);
        var _ox = sprite_get_xoffset(_spr);
        var _oy = sprite_get_yoffset(_spr);
        var _xs = _inst.image_xscale;
        var _left, _right;
        if (_xs >= 0)
        {
            _left = _inst.x - _ox;
            _right = _left + _w;
        }
        else
        {
            _right = _inst.x + _ox;
            _left = _right - _w;
        }
        var _top = _inst.y - _oy;
        var _bottom = _top + _h;
        var _z = variable_instance_exists(_inst, "bake_z_offset") ? (-_inst.y + _inst.bake_z_offset) : _inst.depth;
        var _uv = sprite_get_uvs(_spr, _img);
        var _ul = _uv[0];
        var _ut = _uv[1];
        var _ur = _uv[2];
        var _ub = _uv[3];
        if (_xs < 0)
        {
            var _tmp = _ul;
            _ul = _ur;
            _ur = _tmp;
        }
        var _is_tree = false;
        if (_pass == 0)
        {
            var _oi = _inst.object_index;
            var _tf = 0;
            repeat (array_length(_trees))
            {
                if (_oi == _trees[_tf])
                {
                    _is_tree = true;
                    break;
                }
                _tf++;
            }
        }
        if (_is_tree)
        {
            if (!ds_map_exists(_trees_map, _spr))
            {
                _skipped++;
                continue;
            }
        }
        else if (!ds_map_exists(_props_map, _spr))
        {
            _skipped++;
            continue;
        }
        var _b;
        if (_is_tree)
        {
            _b = tree_buf;
            if (tree_spr == -1)
            {
                tree_spr = _spr;
            }
            _tree_n += 6;
        }
        else
        {
            _b = decor_buf;
            if (decor_spr == -1)
            {
                decor_spr = _spr;
            }
            _decor_n += 6;
        }
        vertex_position_3d(_b, _left, _top, _z);
        vertex_texcoord(_b, _ul, _ut);
        vertex_float1(_b, 0);
        vertex_position_3d(_b, _right, _top, _z);
        vertex_texcoord(_b, _ur, _ut);
        vertex_float1(_b, 0);
        vertex_position_3d(_b, _left, _bottom, _z);
        vertex_texcoord(_b, _ul, _ub);
        vertex_float1(_b, 0);
        vertex_position_3d(_b, _right, _top, _z);
        vertex_texcoord(_b, _ur, _ut);
        vertex_float1(_b, 0);
        vertex_position_3d(_b, _right, _bottom, _z);
        vertex_texcoord(_b, _ur, _ub);
        vertex_float1(_b, 0);
        vertex_position_3d(_b, _left, _bottom, _z);
        vertex_texcoord(_b, _ul, _ub);
        vertex_float1(_b, 0);
        _count++;
        if (_pass == 0)
        {
            instance_destroy(_inst);
        }
        else
        {
            _inst.visible = false;
        }
    }
}
vertex_end(decor_buf);
if (_decor_n > 0)
{
    vertex_freeze(decor_buf);
}
else
{
    vertex_delete_buffer(decor_buf);
    decor_buf = -1;
    decor_spr = -1;
}
vertex_end(tree_buf);
if (_tree_n > 0)
{
    vertex_freeze(tree_buf);
}
else
{
    vertex_delete_buffer(tree_buf);
    tree_buf = -1;
    tree_spr = -1;
}
ds_map_destroy(_props_map);
ds_map_destroy(_trees_map);
built = true;
var _pp = array_length(texturegroup_get_textures("Dynamic_props"));
var _tp = array_length(texturegroup_get_textures("Dynamic_trees"));
trace("[ATLAS] baked ", _count, " props (", array_length(_decor), " decor/trees, ", array_length(_solid), " solids), ", _skipped, " left unbatched (not in texture group) -> Dynamic_props=", _pp, " page(s), Dynamic_trees=", _tp, " page(s)");
if ((_pp > 1 || _tp > 1) && 1 && (debug_mode || (variable_global_exists("general_debug") && global.general_debug)))
{
    show_debug_message("[ATLAS] WARNING: prop texture group spans >1 page (Dynamic_props=" + string(_pp) + ", Dynamic_trees=" + string(_tp) + "). Props on the extra page(s) render unbatched (perf hit); " + "consolidate them onto one page or add per-page buffers to keep batching them.");
}
