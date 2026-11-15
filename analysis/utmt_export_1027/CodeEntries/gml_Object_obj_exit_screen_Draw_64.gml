display_set_gui_size(480, 270);
var camx = camera_get_view_x(view_camera[0]);
var camy = camera_get_view_y(view_camera[0]);
draw_sprite_ext(s_particles_1px, 0, -1, -1, 482, 272, 0, c_black, a);
if (a >= 1)
{
    var sw = sprite_get_width(s_hud_exp_bar);
    var sh = sprite_get_height(s_hud_exp_bar);
    var xx = 240 - (sw / 2);
    var yy = 90;
    var c_glow = 28171;
    if (survived == false)
    {
        c_glow = 255;
    }
    for (var i = 0; i < ((sw / 10) + 1); i++)
    {
        draw_sprite_ext(s_glow_256x256, 0, xx + (10 * i), yy + (sh / 2), 0.5, 0.5, 0, c_glow, 0.25);
    }
    language_set_font(UnknownEnum.Value_0);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    xx = 240 + global.language_font_offset.x;
    yy = 35 + global.language_font_offset.y;
    var t = "ui.survived";
    var c1 = 65280;
    var c2 = 0;
    if (survived == false)
    {
        t = "ui.killed_in_action";
        c1 = 255;
    }
    scr_draw_text_outlined(xx, yy, language_get_string(t), c1, c2, 3, 3);
    draw_set_halign(fa_left);
    t = "+" + string(round(exp_numero));
    c1 = 65280;
    c2 = 0;
    if (survived == false)
    {
        c1 = 255;
    }
    yy = 70;
    scr_draw_text_outlined(xx - 18, yy, t, c1, c2, 2, 2);
    t = language_get_string("ui.experience");
    draw_set_halign(fa_center);
    c1 = 16777215;
    c2 = 0;
    yy = 90;
    scr_draw_text_outlined(xx, yy, t, c1, c2, 1, 1);
    sw = sprite_get_width(s_hud_exp_bar);
    sh = sprite_get_height(s_hud_exp_bar);
    xx = 240 - (sw / 2);
    yy = 100;
    var exp_da_livello_succ = experience_get_for_level(global.xp_level_now);
    language_set_font(UnknownEnum.Value_0);
    draw_set_valign(fa_top);
    draw_set_halign(fa_right);
    scr_draw_text_outlined(xx - 7, yy - 6, (exp_da_livello_succ != undefined) ? string(global.xp_level_now + 1) : string(global.xp_level_now), 16777215, 0, 2, 2);
    draw_set_halign(fa_left);
    scr_draw_text_outlined(xx + sw + 7, yy - 6, (exp_da_livello_succ != undefined) ? string(global.xp_level_now + 2) : language_get_string("stats.experience.max"), 16777215, 0, 2, 2);
    var exp_da_livello = global.xp;
    var rect_esp_x = (exp_da_livello * (sw - 6)) / (exp_da_livello_succ ?? 1);
    draw_rectangle_color(xx + 3, yy + 2, xx + rect_esp_x, (yy + sh) - 4, c_white, c_white, c_white, c_white, false);
    draw_sprite(s_hud_exp_bar, 0, xx, yy);
    var _next_level_xp = experience_get_for_level(global.xp_level_now);
    draw_set_halign(fa_left);
    scr_draw_text_outlined(xx, yy + sh + 1, language_get_string("ui.current_lower") + ": " + ((_next_level_xp == undefined) ? "0" : string(floor(global.xp))), 16777215, 0, 1, 1);
    draw_set_halign(fa_right);
    scr_draw_text_outlined(xx + sw, yy + sh + 1, language_get_string("ui.next_level_lower") + ": " + ((_next_level_xp == undefined) ? language_get_string("stats.experience.max") : string(_next_level_xp)), 16777215, 0, 1, 1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    c1 = 16777215;
    c2 = 0;
    var text_next = language_get_string("general.next");
    if (can_go_hub == false)
    {
        text_next = language_get_string("ui.skip");
    }
    button_next_w = (string_width(text_next) * 2) + 24;
    if (button_next_hover == false)
    {
        for (var i = 0; i < ((button_next_w / 8) + 1); i++)
        {
            draw_sprite_ext(s_glow_256x256, 0, (button_next_x - (button_next_w / 2)) + (8 * i), button_next_y, 0.25, 0.25, 0, #3D3D3D, 0.25);
        }
        draw_text_transformed_color(button_next_x + global.language_font_offset.x, button_next_y + global.language_font_offset.y, text_next, 2, 2, 0, c1, c1, c1, c1, 1);
    }
    else
    {
        for (var i = 0; i < ((button_next_w / 8) + 1); i++)
        {
            draw_sprite_ext(s_glow_256x256, 0, (button_next_x - (button_next_w / 2)) + (8 * i), button_next_y, 0.25, 0.25, 0, c_white, 0.25);
        }
        draw_text_transformed_color(button_next_x + global.language_font_offset.x, button_next_y + global.language_font_offset.y, text_next, 2, 2, 0, c2, c2, c2, c2, 1);
    }
    if (survived == true && obj_map_generator.area != UnknownEnum.Value_10)
    {
        language_set_font(UnknownEnum.Value_0);
        draw_set_valign(fa_middle);
        draw_set_halign(fa_center);
        var _t = language_get_string("ui.approx_roubles_made") + ": " + string(value_made);
        draw_text_color(240 + global.language_font_offset.x, 160 + global.language_font_offset.y, _t, c_white, c_white, c_white, c_white, 1);
    }
    if (survived == false)
    {
        language_set_font(UnknownEnum.Value_0);
        draw_set_valign(fa_middle);
        draw_set_halign(fa_center);
        var _line_step = 15;
        var _lines = [];
        var _cause_tag = global.last_damage_source;
        var _is_combat = _cause_tag == "human_gunfire" || _cause_tag == "mutant_ranged" || _cause_tag == "mutant_melee";
        if (_is_combat && global.who_killed_player.npc_name != "")
        {
            var _killer_name = global.who_killed_player.npc_name;
            array_push(_lines, language_get_string("ui.killed_by") + ": " + language_get_string(_killer_name));
            if (global.who_killed_player.weapon_id != "no_weapon")
            {
                array_push(_lines, language_get_string("general.weapon") + ": " + item_get_name(global.who_killed_player.weapon_id));
                array_push(_lines, language_get_string("chest.ammo_title") + ": " + item_get_name(global.who_killed_player.ammo_id));
            }
        }
        else
        {
            var _cause_desc = "ui.death_cause_unknown";
            switch (_cause_tag)
            {
                case "anomaly":
                    _cause_desc = "ui.death_cause_anomaly";
                    break;
                case "grenade":
                    _cause_desc = "ui.death_cause_explosion";
                    break;
                case "quest_explosion":
                    _cause_desc = "ui.death_cause_explosion";
                    break;
                case "emission":
                    _cause_desc = "ui.death_cause_blowout";
                    break;
                case "crush":
                    _cause_desc = "ui.death_cause_crush";
                    break;
                case "instakill_interact":
                    _cause_desc = "ui.death_cause_environment";
                    break;
                case "instakill_void":
                    _cause_desc = "ui.death_cause_environment";
                    break;
                case "bleed":
                    _cause_desc = "ui.death_cause_bled_out";
                    break;
            }
            array_push(_lines, language_get_string(_cause_desc));
        }
        var _surv_sec = floor(global.last_run_survival / 1000);
        var _surv_str = string(_surv_sec div 60) + ":" + (((_surv_sec % 60) < 10) ? ("0" + string(_surv_sec % 60)) : string(_surv_sec % 60));
        array_push(_lines, language_get_string("ui.death_survival_time") + "  " + _surv_str);
        var _band_top = yy + sh + 1 + string_height("0");
        var _band_bottom = button_next_y - (button_next_h / 2);
        var _n = array_length(_lines);
        var _y = floor(_band_top + ((_band_bottom - _band_top - ((_n - 1) * _line_step)) / 2));
        for (var _i = 0; _i < _n; _i++)
        {
            draw_text_color(240 + global.language_font_offset.x, _y + global.language_font_offset.y, _lines[_i], c_white, c_white, c_white, c_white, 1);
            _y += _line_step;
        }
    }
    if (!!obj_gamepad.last_input_keyboard)
    {
        draw_sprite(s_mouse, 4, mouse_x - camx, mouse_y - camy);
    }
}
display_set_gui_size(1920, 1080);

enum UnknownEnum
{
    Value_0,
    Value_10 = 10
}
