function player_step_debug_keys()
{
    if (!global.general_debug)
    {
        exit;
    }
    debug_menu_handle_keys();
}
