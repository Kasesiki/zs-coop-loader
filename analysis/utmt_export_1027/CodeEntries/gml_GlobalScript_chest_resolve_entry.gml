function chest_resolve_entry(arg0)
{
    if (!variable_struct_exists(global.chest_data, arg0))
    {
        trace("chest_resolve_entry: chest \"", arg0, "\" not found in global.chest_data");
        return false;
    }
    var _chest = variable_struct_get(global.chest_data, arg0);
    if (_chest.items == "{hidden_stash}")
    {
        _chest.items = [];
        chest_setup_hidden_stash(_chest);
    }
    else if (_chest.items == "{human_general}")
    {
        _chest.items = [];
        chest_setup_human_general(_chest);
    }
    if (is_string(_chest.sprite))
    {
        _chest.sprite = __MODS_SpriteGet(_chest.sprite);
    }
    return true;
}
