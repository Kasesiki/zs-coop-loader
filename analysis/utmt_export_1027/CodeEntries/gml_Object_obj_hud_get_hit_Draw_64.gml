if (player_get_local_var("aiming", false))
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    display_set_gui_size(480, 270);
    var _scale = camera_get_view_width(view_camera[0]) / 480;
    draw_sprite_ext(s_hud_bleed, 0, 0, 0, _scale, _scale, 0, c_white, a);
    display_set_gui_size(_gui_w, _gui_h);
}
