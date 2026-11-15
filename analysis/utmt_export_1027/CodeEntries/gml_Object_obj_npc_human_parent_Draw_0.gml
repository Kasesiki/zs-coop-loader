event_inherited();
if (!on_screen)
{
    exit;
}
var rot = weapon_pointing_direction;
var offsetx_arma = 0;
var offsety_arma = 0;
var offset_arma = 2;
if (alarm[1] >= (item_weapon_get_rate_of_fire(arma_now) - 2))
{
    offsetx_arma = -lengthdir_x(offset_arma, rot);
    offsety_arma = -lengthdir_y(offset_arma, rot);
}
if (image_alpha > 0)
{
    draw_sprite_ext(s_shadow, 0, x, y + 8, 1, 1, 0, c_black, 0.5 * image_alpha);
}
if (shader_hit == "BULLET_HIT_SHADER_NORMAL")
{
    shader_set(shd_flash_hit);
}
if (shader_hit == "BULLET_HIT_SHADER_GLANCE")
{
    shader_set(shd_flash_hit_glance);
}
if (shader_hit == "BULLET_HIT_SHADER_NORMAL_BLOCKED" || shader_hit == "BULLET_HIT_SHADER_GLANCE_BLOCKED")
{
    shader_set(shd_flash_hit_blocked);
    var _texture = sprite_get_texture(sprite_index, image_index);
    var _texture_w = texture_get_texel_width(_texture);
    var _texture_h = texture_get_texel_height(_texture);
    shader_set_uniform_f(shader_hit_size, _texture_w, _texture_h);
    if (shader_hit == "BULLET_HIT_SHADER_NORMAL_BLOCKED")
    {
        var _col = 16777215;
        shader_set_uniform_f(shader_outline_color, color_get_red(_col) / 255, color_get_green(_col) / 255, color_get_blue(_col) / 255);
    }
    if (shader_hit == "BULLET_HIT_SHADER_GLANCE_BLOCKED")
    {
        var _col = 255;
        shader_set_uniform_f(shader_outline_color, color_get_red(_col) / 255, color_get_green(_col) / 255, color_get_blue(_col) / 255);
    }
}
if (target_for_image_scale < x)
{
    image_xscale = -1;
}
else
{
    image_xscale = 1;
}
var _backpack_sprite = item_backpack_get_sprite(backpack_now);
var _backpack_fat = ai_loot_backpack_is_fat(id);
if (_backpack_fat && (!sprite_exists(_backpack_sprite) || _backpack_sprite == s_vuoto))
{
    _backpack_sprite = s_item_backpack1_game;
}
if (sprite_exists(_backpack_sprite))
{
    var offset_backpack;
    if (sprite_index == sprite_idle)
    {
        offset_backpack = (image_index > 1) ? 1 : 0;
    }
    else
    {
        offset_backpack = (image_index > 2) ? 1 : 0;
    }
    _backpack_fat = _backpack_fat && sprite_get_number(_backpack_sprite) > 1;
    var _backpack_push = _backpack_fat ? (-2 * sign(image_xscale)) : 0;
    draw_sprite_ext(_backpack_sprite, _backpack_fat ? 1 : 0, x + _backpack_push, y + offset_backpack, image_xscale, 1, false, c_white, image_alpha);
}
if (target_for_image_scale < x)
{
    image_xscale = -1;
    rot = weapon_pointing_direction + 180;
    draw_self();
}
else
{
    image_xscale = 1;
    rot = weapon_pointing_direction;
    draw_self();
}
shader_reset();
draw_skill_npc_above();
if (global.hud_glance_sysytem || is_in_shooting_range())
{
    var _dis = point_distance(x, y, player_get_local().x, player_get_local().y);
    var _dis2 = point_distance(x, y, obj_cursor.aa_x, obj_cursor.aa_y);
    var _player = player_get_local();
    var _glance_angle = glance_angle(player_loadout_get_ammo_item(_player, _player.weapon_slot_now), _player.arma_now, npc_get_sweet_angle(npc_id), _dis, _dis2);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(x + global.language_font_offset.x, (y - 20) + global.language_font_offset.y, language_get_string("ui.shootingrange.hit") + " " + string(round((_glance_angle / npc_get_sweet_angle(npc_id)) * 100)));
}
if (global.show_npc_recoil)
{
    if (instance_exists(target))
    {
        var _xx = NPCrecoil.cross_center_x;
        var _yy = NPCrecoil.cross_center_y;
        draw_circle(_xx, _yy, NPCrecoil.radius_now, true);
        draw_circle_color(_xx, _yy, NPCrecoil.radius_min, c_red, c_red, true);
        draw_circle_color(_xx, _yy, NPCrecoil.radius_max, c_red, c_red, true);
        draw_sprite(s_bullet_shell, 0, _xx + NPCrecoil.cross_x, _yy + NPCrecoil.cross_y);
    }
}
if (global.show_npc_state)
{
    var _debug_colour = draw_get_color();
    var _debug_alpha = draw_get_alpha();
    var _debug_font = draw_get_font();
    var _debug_halign = draw_get_halign();
    var _debug_valign = draw_get_valign();
    language_set_font(UnknownEnum.Value_0);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    var _t = "Idle";
    var _awareness_colour = 8421504;
    switch (human_state_now)
    {
        case UnknownEnum.Value_0:
            _t = "Patrol";
            break;
        case UnknownEnum.Value_1:
            _t = "Idle";
            break;
        case UnknownEnum.Value_11:
            _t = "Shoot";
            break;
        case UnknownEnum.Value_20:
            _t = "Reload";
            break;
        case UnknownEnum.Value_23:
            _t = "Listen";
            break;
        case UnknownEnum.Value_16:
            _t = "Chase";
            break;
        case UnknownEnum.Value_17:
            _t = "Close in";
            break;
        case UnknownEnum.Value_26:
            _t = "Spread out";
            break;
        case UnknownEnum.Value_18:
            _t = "Assist";
            break;
        case UnknownEnum.Value_12:
            _t = "Cover";
            break;
        case UnknownEnum.Value_13:
            _t = "Hit cover";
            break;
        case UnknownEnum.Value_14:
            _t = "Relocate";
            break;
        case UnknownEnum.Value_30:
            _t = "Evade";
            break;
        case UnknownEnum.Value_31:
            _t = "Flashed";
            break;
        case UnknownEnum.Value_32:
            _t = "Grenade";
            break;
        case UnknownEnum.Value_15:
            _t = "Reposition";
            break;
        case UnknownEnum.Value_25:
            _t = "Aim / move";
            break;
        case UnknownEnum.Value_24:
            _t = "Aim";
            break;
        case UnknownEnum.Value_19:
            _t = "Search";
            break;
        case UnknownEnum.Value_27:
            _t = "Hit cover";
            break;
        case UnknownEnum.Value_21:
            _t = "Look";
            break;
        case UnknownEnum.Value_36:
            _t = "Watch";
            break;
        case UnknownEnum.Value_37:
            _t = "Warn";
            break;
        case UnknownEnum.Value_9:
            _t = "Return";
            break;
        case UnknownEnum.Value_28:
            _t = "Check body";
            break;
        case UnknownEnum.Value_33:
            _t = "Shelter";
            break;
        case UnknownEnum.Value_3:
            _t = "Drink";
            break;
        case UnknownEnum.Value_4:
            _t = "Smoke";
            break;
        case UnknownEnum.Value_2:
            _t = "Eat";
            break;
        case UnknownEnum.Value_5:
            _t = "Work";
            break;
        case UnknownEnum.Value_8:
            _t = "Guitar";
            break;
        case UnknownEnum.Value_7:
            _t = "Campfire";
            break;
        case UnknownEnum.Value_6:
            _t = "Guard";
            break;
        case UnknownEnum.Value_10:
            _t = "Patrol";
            break;
        case UnknownEnum.Value_29:
            _t = "Space out";
            break;
    }
    if (is_struct(ai_execution))
    {
        var _e = ai_execution;
        var _ctx = _e.tree_context;
        var _index = _ctx._active_action;
        var _active = (_index < 0) ? "" : _ctx.tree.nodes[_index].name;
        var _data = (_index < 0) ? {} : _ctx._slots[_index].data;
        var _migrated = ai_human_migrated(id);
        _t = _migrated ? ai_human_debug_label(_e, _active, _data) : "Test AI";
        if (state != "human_general")
        {
            _t = "Scripted";
        }
        if (hp <= 0)
        {
            _t = "Dead";
        }
        if (_migrated && hp > 0 && state == "human_general")
        {
            _awareness_colour = !_e.knowledge.valid ? 8421504 : (_e.knowledge.visible ? 65280 : 4235519);
            if (variable_struct_exists(_data, "route_mode") && _data.route_mode && _data.route_phase != "fight" && is_struct(_data.route_plan) && variable_struct_exists(_data.route_plan, "points"))
            {
                __ai_human_route_draw(_data);
            }
            var _commands = _e.commands;
            if (__ai_commands_owned(_e, _commands.token) && (_commands.moving || _commands.path_status == "yielding" || _commands.path_status == "deferred"))
            {
                draw_set_color(c_aqua);
                draw_set_alpha(0.35);
                draw_line(x, y, _commands.goal_x, _commands.goal_y);
                draw_set_alpha(1);
                draw_set_color(c_black);
                draw_circle(_commands.goal_x, _commands.goal_y, 4, false);
                draw_set_color(c_aqua);
                draw_circle(_commands.goal_x, _commands.goal_y, 2.5, false);
            }
            if (keyboard_check(vk_alt) && point_distance(x, y, obj_cursor.aa_x, obj_cursor.aa_y) <= 24 && instance_nearest(obj_cursor.aa_x, obj_cursor.aa_y, obj_npc_human_parent) == id)
            {
                ai_human_debug_details(_e, _active, _data);
            }
        }
    }
    var _label_x = x + global.language_font_offset.x;
    var _label_y = (y - 20) + global.language_font_offset.y;
    var _half_width = string_width(_t) / 2;
    draw_set_alpha(1);
    draw_set_color(_awareness_colour);
    draw_circle(_label_x - _half_width - 5, _label_y + 4, 2, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_label_x, _label_y, _t);
    draw_set_font(_debug_font);
    draw_set_halign(_debug_halign);
    draw_set_valign(_debug_valign);
    draw_set_color(_debug_colour);
    draw_set_alpha(_debug_alpha);
}
if (global.show_reflexes_npc)
{
    draw_text(x + global.language_font_offset.x, (y - 28) + global.language_font_offset.y, "now: " + string(round(riflessi)));
    draw_text(x + global.language_font_offset.x, (y - 38) + global.language_font_offset.y, "max: " + string(round(riflessi_max)));
    draw_text(x + global.language_font_offset.x, (y - 48) + global.language_font_offset.y, "dis: " + string(round(reflexes_distance)));
    draw_text(x + global.language_font_offset.x, (y - 58) + global.language_font_offset.y, "angle: " + string(round(reflexes_angle)));
    draw_circle(last_seen_x, last_seen_y, reflex_min_distance_last_known, true);
    if (ai_human_migrated(id))
    {
        ai_human_debug_vision(id);
    }
    else if (instance_exists(obj_light_controller))
    {
        var alert_distance = npc_get_alert_visual_distance(npc_id);
        var alert_angle = npc_get_alert_radius(npc_id);
        var lc = obj_light_controller;
        var t_hm = time_get_hours_fraction();
        var k = 1;
        if (lc.ciclo_now == UnknownEnum.Value_3)
        {
            alert_distance = npc_get_alert_visual_distance(npc_id) / k;
            alert_angle = npc_get_alert_radius(npc_id) / k;
        }
        if (lc.ciclo_now == UnknownEnum.Value_0)
        {
            var hours_sunrise = lc.ciclo_time[UnknownEnum.Value_1] - lc.ciclo_time[UnknownEnum.Value_0];
            var amount = (t_hm - lc.ciclo_time[UnknownEnum.Value_0]) / hours_sunrise;
            alert_angle = lerp(npc_get_alert_radius(npc_id) / k, npc_get_alert_radius(npc_id), amount);
            alert_distance = lerp(npc_get_alert_visual_distance(npc_id) / k, npc_get_alert_visual_distance(npc_id), amount);
        }
        if (lc.ciclo_now == UnknownEnum.Value_2)
        {
            var hours_sunrise = lc.ciclo_time[UnknownEnum.Value_3] - lc.ciclo_time[UnknownEnum.Value_2];
            var amount = (t_hm - lc.ciclo_time[UnknownEnum.Value_2]) / hours_sunrise;
            alert_angle = lerp(npc_get_alert_radius(npc_id), npc_get_alert_radius(npc_id) / k, amount);
            alert_distance = lerp(npc_get_alert_visual_distance(npc_id), npc_get_alert_visual_distance(npc_id) / k, amount);
        }
        alert_distance = scr_npc_oval_view(alert_distance, weapon_pointing_direction);
        var x2 = x + lengthdir_x(alert_distance, weapon_pointing_direction + (alert_angle / 2));
        var y2 = y + lengthdir_y(alert_distance, weapon_pointing_direction + (alert_angle / 2));
        var x3 = x + lengthdir_x(alert_distance, weapon_pointing_direction - (alert_angle / 2));
        var y3 = y + lengthdir_y(alert_distance, weapon_pointing_direction - (alert_angle / 2));
        draw_triangle(x, y, x2, y2, x3, y3, true);
    }
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_4,
    Value_5,
    Value_6,
    Value_7,
    Value_8,
    Value_9,
    Value_10,
    Value_11,
    Value_12,
    Value_13,
    Value_14,
    Value_15,
    Value_16,
    Value_17,
    Value_18,
    Value_19,
    Value_20,
    Value_21,
    Value_23 = 23,
    Value_24,
    Value_25,
    Value_26,
    Value_27,
    Value_28,
    Value_29,
    Value_30,
    Value_31,
    Value_32,
    Value_33,
    Value_36 = 36,
    Value_37
}
