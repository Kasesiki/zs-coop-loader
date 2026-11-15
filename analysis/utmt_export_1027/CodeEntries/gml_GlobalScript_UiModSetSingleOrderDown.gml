function UiModSetSingleOrderDown(arg0)
{
    var _mod_name = modding_utility_num_to_string(arg0);
    return modding_utility_changeOrder(_mod_name, mods_load_order_position(_mod_name) + 1);
}
