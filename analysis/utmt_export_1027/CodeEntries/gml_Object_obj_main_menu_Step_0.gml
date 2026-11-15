if (keybind_active)
{
    keybind_update();
}
else if (black_overlay_alpha <= 0.6 && game_in_focus())
{
    ui_handle_input(1);
}
if (!audio_group_is_loaded(audiogroup_main_menu))
{
    audio_group_load(audiogroup_main_menu);
}
if (!audio_group_is_loaded(audiogroup_ui_rad_button))
{
    audio_group_load(audiogroup_ui_rad_button);
}
if (!audio_group_is_loaded(audiogroup_pda_open))
{
    audio_group_load(audiogroup_pda_open);
}
if (!audio_group_is_loaded(audiogroup_pda))
{
    audio_group_load(audiogroup_pda);
}
if (!audio_is_playing(snd_main_menu_2) && audio_group_is_loaded(audiogroup_main_menu))
{
    audio_play_sound(snd_main_menu_2, 20, false);
}
__uiGlobal().__defaultOnion.Step();
if (room == r_menu && black_overlay_alpha <= 0 && platform_cloud_consent_toast_take())
{
    scr_draw_text_with_box("platform.cloud_consent_toast", true, 480);
}
if (db_cloud_sync_in_progress())
{
    db_cloud_sync_step();
}
if (!window_focused && game_in_focus())
{
    if (room == r_menu)
    {
        mm_init_slot_metadata();
        var _root = uiLayerGetRoot("root");
        if (uiFindRelaxed(_root, "saveslot frame") != undefined)
        {
            uiFind(_root, "sidebar frame").ReplaceFromFile("ZS_vanilla/ui/mm_sidebar_saveslots.ui");
        }
    }
    else if (false && global.database_cloud_conflict == 0)
    {
        if (db_cloud_enabled() && db_get_save_hash("shared") != db_cloud_get_hash(db_get_filename("shared")))
        {
            db_cloud_sync_all(1);
            settings_reload_and_apply();
            reload_main_menu();
        }
    }
}
window_focused = game_in_focus();
