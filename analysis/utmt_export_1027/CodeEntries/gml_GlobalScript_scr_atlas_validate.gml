function scr_atlas_validate(arg0, arg1, arg2 = 0)
{
    if (texturegroup_get_status(arg0) == 0)
    {
        texturegroup_load(arg0, true);
    }
    var _assigned = texturegroup_get_sprites(arg0);
    var _set = ds_map_create();
    var _i = 0;
    repeat (array_length(_assigned))
    {
        ds_map_set(_set, @@array_get@@(_assigned, _i), true);
        _i++;
    }
    var _missing = 0;
    _i = 0;
    repeat (array_length(arg1))
    {
        var _spr = arg1[_i];
        _i++;
        if (is_undefined(_spr))
        {
            continue;
        }
        if (!sprite_exists(_spr))
        {
            continue;
        }
        if (!ds_map_exists(_set, _spr))
        {
            _missing++;
            trace("[ATLAS] ERROR: sprite '", sprite_get_name(_spr), "' is NOT on texture group '", arg0, "' -> it packs onto Default and will break the batch.");
        }
    }
    ds_map_destroy(_set);
    var _pages = array_length(texturegroup_get_textures(arg0));
    trace("[ATLAS] group '", arg0, "': expected=", array_length(arg1), " missing=", _missing, " pages=", _pages);
    if (arg2 > 0 && _pages > arg2)
    {
        trace("[ATLAS] WARNING: group '", arg0, "' packs into ", _pages, " pages but the batch handles only ", arg2, ".");
    }
    return 
    {
        missing: _missing,
        pages: _pages
    };
}
