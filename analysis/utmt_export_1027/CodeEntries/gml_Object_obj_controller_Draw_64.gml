display_set_gui_size(480, 270);
language_set_font(UnknownEnum.Value_0);
if (!player_exists_local())
{
    exit;
}
var camx = camera_get_view_x(view_camera[0]);
var camy = camera_get_view_y(view_camera[0]);
var _player = player_get_local();
var _stim_x = 160;
if (global.show_fps == true)
{
    show_debug_overlay(true);
}
else
{
    show_debug_overlay(false);
}
if (player_local_state_is(scr_player_state_move))
{
    if (global.change_ammo_now == true)
    {
        var _tipi_ammo = ds_list_size(global.list_ammo_id);
        if (_tipi_ammo > 0)
        {
            language_set_font(UnknownEnum.Value_0);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            var xx = _player.x - camx;
            var yy = _player.y - camy - 16;
            for (var i = 0; i < _tipi_ammo; i++)
            {
                var subi = 0;
                var cc = 16777215;
                if (global.change_ammo_scelta == i)
                {
                    subi = 1;
                    cc = 9564927;
                }
                var _ammo_name = item_get_name(ds_list_find_value(global.list_ammo_id, i));
                var _ammo_qnt = ds_list_find_value(global.list_ammo_qnt, i);
                var _t = _ammo_name + " (" + string(_ammo_qnt) + ")";
                var _drawn_at = scr_draw_text_outlined(xx + global.language_font_offset.x, ((yy + global.language_font_offset.y) - (16 * i)) + 5, _t, cc, 0, 1, 1);
            }
        }
    }
}
var _offset_jam = 0;
if (player_local_state_is(scr_player_state_move))
{
    if (player_loadout_get_jammed(_player, _player.weapon_slot_now))
    {
        if (item_exists(_player.arma_now))
        {
            language_set_font(UnknownEnum.Value_0);
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            var xx = _player.x - camx;
            var yy = _player.y - camy - 16;
            _offset_jam = 8;
            draw_text_outlined_with_control(xx + global.language_font_offset.x, yy + global.language_font_offset.y, language_get_string("faction.inter.jam"), UnknownEnum.Value_26);
        }
    }
}
if (player_local_state_is(scr_player_state_move, scr_player_state_consumable_animation))
{
    if (!global.debug_hide_hud && player_exists_local())
    {
        var _bleed = _player.bleed;
        var _alpha = 0;
        if (_bleed >= 0)
        {
            _alpha = 0.3;
        }
        if (_bleed >= 1)
        {
            _alpha = 0.6;
        }
        if (_bleed >= 2)
        {
            _alpha = 0.85;
        }
        if (_bleed >= 0.2)
        {
            var _scale = camera_get_view_width(view_camera[0]) / 480;
            draw_sprite_ext(s_hud_bleed, 0, 0, 0, _scale, _scale, 0, c_white, _alpha);
        }
    }
}
if (player_local_state_is(scr_player_state_move, scr_player_state_inventory, scr_player_state_consumable_animation))
{
    if (!player_get_local_var("aiming", false) && !global.debug_hide_hud && player_exists_local())
    {
        var hp = max(0, _player.hp);
        var hp_max = _player.hp_max_total;
        var startx = 5;
        var starty = 5;
        var bar_w_max = 37;
        var bar_w = (bar_w_max / hp_max) * hp;
        var c1 = 8421504;
        draw_rectangle_color(startx + 23, starty + 2, startx + 61, starty + 13, c1, c1, c1, c1, false);
        draw_rectangle_color(startx + 23, starty + 18, startx + 61, starty + 22, c1, c1, c1, c1, false);
        var _wound = _player.wound;
        if (_wound >= 1)
        {
            c1 = 4210752;
            var bar_wound_w = (bar_w_max / hp_max) * _wound;
            draw_rectangle_color((startx + 61) - bar_wound_w, starty + 2, startx + 61, starty + 13, c1, c1, c1, c1, false);
        }
        draw_sprite(s_hp_bar, 0, startx, starty);
        draw_sprite_part_ext(s_hp_bar, 1, 24, 2, 1, 12, startx + 24, starty + 2, ceil(bar_w), 1, c_white, 1);
        if (hp == hp_max)
        {
            draw_sprite_part(s_hp_bar, 1, 61, 2, 1, 12, startx + 61, starty + 2);
        }
        var stamina = max(0, _player.stamina);
        var stamina_max = _player.stamina_max_total;
        startx = 5;
        starty = 5;
        bar_w_max = 37;
        if (stamina_max >= 0)
        {
            bar_w = (bar_w_max / stamina_max) * stamina;
            draw_sprite_part_ext(s_hp_bar, 1, 24, 18, 1, 5, startx + 24, starty + 18, ceil(bar_w), 1, c_white, 1);
            if (stamina == stamina_max)
            {
                draw_sprite_part(s_hp_bar, 1, 61, 18, 1, 5, startx + 61, starty + 18);
            }
        }
        if (_player.bleed > 0)
        {
            var _xx = 70;
            var _yy = 6;
            draw_sprite(s_bleed_icon, 0, _xx, _yy);
            language_set_font(UnknownEnum.Value_0);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(_xx + global.language_font_offset.x + 8, _yy + global.language_font_offset.y + 10, string(ceil(_player.bleed) div 1));
            if (scr_mouse_over_hud(camx + _xx, camy + _yy, 16, 16))
            {
                var _t = language_get_string("ui.bleeding") + " [" + string(_player.bleed div 1) + "]";
                _w = string_width(_t) + 4;
                var _h = 12;
                language_set_font(UnknownEnum.Value_0);
                scr_draw_box(s_box_testo_pop_up, (_xx - (_w / 2)) + 8, _yy + 24, _w, _h, 1);
                draw_text(_xx + global.language_font_offset.x + 8, _yy + global.language_font_offset.y + 24 + (_h / 2), _t);
            }
        }
        language_set_font(UnknownEnum.Value_0);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        if (!player_get_local_var("aiming", false))
        {
            for (var i = 0; i < ds_list_size(global.list_status_id); i++)
            {
                var oo = ds_list_find_value(global.list_status_id, i);
                draw_sprite_ext(global.status_sprite[oo], 0, global.status_x + (global.status_w * i) + (global.status_off * i), global.status_y, 1, 1, 0, global.status_color[global.status_state_now[oo]], 1);
            }
            var _ax = global.status_x + ((global.status_w + global.status_off) * ds_list_size(global.list_status_id));
            var _dur_gap_added = false;
            _stim_x = max(160, _ax);
            _ax = _stim_x + (array_length(global.injector_active) * 20);
            if (settings_get("show_durability"))
            {
                var _dur_tooltip = function(arg0, arg1, arg2, arg3)
                {
                    language_set_font(UnknownEnum.Value_0);
                    var _tw = max(string_width(arg2), string_width(arg3)) + 4;
                    scr_draw_box(s_box_testo_pop_up, (arg0 + 8) - (_tw / 2), arg1 + 18, _tw, 24, 1);
                    draw_text_ext(arg0 + global.language_font_offset.x + 8, arg1 + global.language_font_offset.y + 15 + 1, arg2, 10, _tw);
                    draw_text_ext(arg0 + global.language_font_offset.x + 8, arg1 + global.language_font_offset.y + 27 + 1, arg3, 10, _tw);
                };
                
                var _wloot = player_loadout_get_loot(_player, _player.weapon_slot_now);
                if (item_get_category(loot_get_item(_wloot)) == "weapon")
                {
                    var _wdur = _wloot.durability;
                    if (_wdur < 50)
                    {
                        if (!_dur_gap_added)
                        {
                            _ax += 2;
                            _dur_gap_added = true;
                        }
                        var _wcol = (_wdur < 20) ? 3158240 : ((_wdur < 35) ? 1216767 : 1694975);
                        draw_sprite_ext(s_status_weapon, 0, _ax, global.status_y, 1, 1, 0, _wcol, 1);
                        if (scr_mouse_over_hud(_ax + camx, global.status_y + camy, 16, 16) && !mouse_check_button(mb_right))
                        {
                            var _wkey = (_wdur < 20) ? "hud.durability.weapon_failing" : ((_wdur < 35) ? "hud.durability.weapon_damaged" : "hud.durability.weapon_worn");
                            var _wtitle = string_replace(language_get_string(_wkey), "[DUR]", string(floor(_wdur)));
                            var _wl2;
                            if (difficulty_get("weapon_jam_enabled"))
                            {
                                var _jam = ((-_wdur / 10) + 10) * 0.2;
                                if (skill_hunter_obtained("nojamthanks"))
                                {
                                    _jam *= struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("nojamthanks")), variable_get_hash("jam_chance_reduction"));
                                }
                                _wl2 = string_replace(language_get_string("hud.durability.jam_chance"), "[VAL]", string_format(_jam, 1, 1));
                            }
                            else
                            {
                                _wl2 = language_get_string("hud.durability.reduced_accuracy");
                            }
                            _dur_tooltip(_ax, global.status_y, _wtitle, _wl2);
                        }
                        _ax += (global.status_w + global.status_off);
                    }
                }
                var _aloot = player_loadout_get_loot(_player, "armor slot");
                if (loot_get_item(_aloot) != "no_item")
                {
                    var _adur = _aloot.durability;
                    if (_adur < 70)
                    {
                        if (!_dur_gap_added)
                        {
                            _ax += 2;
                            _dur_gap_added = true;
                        }
                        var _acol = (_adur < 35) ? 3158240 : ((_adur < 50) ? 1216767 : 1694975);
                        draw_sprite_ext(s_status_armor, 0, _ax, global.status_y, 1, 1, 0, _acol, 1);
                        if (scr_mouse_over_hud(_ax + camx, global.status_y + camy, 16, 16) && !mouse_check_button(mb_right))
                        {
                            var _akey = (_adur < 35) ? "hud.durability.armor_broken" : ((_adur < 50) ? "hud.durability.armor_damaged" : "hud.durability.armor_worn");
                            var _atitle = string_replace(language_get_string(_akey), "[DUR]", string(floor(_adur)));
                            var _pen = clamp(-log10(max(_adur, 1) / 100) * 2 * 100, 0, 100);
                            var _al2 = string_replace(language_get_string("hud.durability.penetration_chance"), "[VAL]", string(round(_pen)));
                            _dur_tooltip(_ax, global.status_y, _atitle, _al2);
                        }
                        _ax += (global.status_w + global.status_off);
                    }
                }
            }
            if (settings_get("toggle_sprint") && player_local_state_is(scr_player_state_move) && player_get_local_var("sprint_is_active", false))
            {
                if (!_dur_gap_added)
                {
                    _ax += 2;
                    _dur_gap_added = true;
                }
                draw_sprite_ext(s_status_sprint, 0, _ax, global.status_y, 1, 1, 0, c_white, 1);
            }
            for (var i = 0; i < ds_list_size(global.list_status_id); i++)
            {
                var oo = ds_list_find_value(global.list_status_id, i);
                var xx = global.status_x + (global.status_w * i) + (global.status_off * i);
                if (scr_mouse_over_hud(xx + camx, global.status_y + camy, 16, 16))
                {
                    if (!mouse_check_button(mb_right))
                    {
                        var w_ = 80;
                        var h_ = 12;
                        var t_name = language_get_string(global.status_des[oo][global.status_state_now[oo]]);
                        var t1 = "";
                        var t_amount;
                        if (oo == UnknownEnum.Value_0)
                        {
                            var _amount = global.status_f1[UnknownEnum.Value_0][global.status_state_now[oo]];
                            if (_amount < 0)
                            {
                                _amount *= global.sk_k[UnknownEnum.Value_73];
                            }
                            else
                            {
                                _amount *= global.sk_k[UnknownEnum.Value_72];
                            }
                            t1 = ((_amount > 0) ? "+" : "") + string(_amount * 100) + "% " + language_get_string("player.status.stamina_regeneration");
                            t_amount = _player.fatigue;
                        }
                        if (oo == UnknownEnum.Value_1)
                        {
                            var _amount = global.status_f1[UnknownEnum.Value_1][global.status_state_now[oo]];
                            if (_amount < 0)
                            {
                                _amount *= global.sk_k[UnknownEnum.Value_73];
                            }
                            else
                            {
                                _amount *= global.sk_k[UnknownEnum.Value_72];
                            }
                            t1 = ((_amount > 0) ? "+" : "") + string(_amount) + "kg " + language_get_string("player.status.max_weight");
                            t_amount = _player.energy;
                        }
                        if (oo == UnknownEnum.Value_2)
                        {
                            var _amount = global.status_f1[UnknownEnum.Value_2][global.status_state_now[oo]];
                            if (_amount < 0)
                            {
                                _amount *= global.sk_k[UnknownEnum.Value_73];
                            }
                            else
                            {
                                _amount *= global.sk_k[UnknownEnum.Value_72];
                            }
                            t1 = ((_amount > 0) ? "+" : "") + string(_amount) + "% " + language_get_string("modules_description.looting_speed");
                            t_amount = _player.thirst;
                        }
                        if (oo == UnknownEnum.Value_3)
                        {
                            t1 = "";
                            t_amount = abs(_player.radiation_accumulata);
                        }
                        if (oo != UnknownEnum.Value_3)
                        {
                            t_amount = round(t_amount);
                        }
                        var t_value_max = string(t_amount) + "/" + string(global.status_value_max[oo]);
                        var t_ = t_name + " " + t_value_max;
                        if (t1 != "")
                        {
                            h_ = 24;
                        }
                        var off_h = 2;
                        var off_w = 2;
                        var t_w_s = string_width(t_);
                        var t_w_e = string_width(t1);
                        w_ = (off_w * 2) + max(t_w_s, t_w_e);
                        language_set_font(UnknownEnum.Value_0);
                        scr_draw_box(s_box_testo_pop_up, (xx + 8) - (w_ / 2), global.status_y + 18, w_, h_, 1);
                        draw_text_ext(xx + global.language_font_offset.x + 8, global.status_y + global.language_font_offset.y + 15 + 1, t_, 10, w_);
                        language_set_font(UnknownEnum.Value_0);
                        draw_text_ext(xx + global.language_font_offset.x + 8, global.status_y + global.language_font_offset.y + 27 + 1, t1, 10, w_);
                    }
                }
            }
        }
        var sx = _stim_x;
        var _w = 20;
        for (var i = 0; i < array_length(global.injector_active); i++)
        {
            var _xx = sx + (_w * i);
            var _id = global.injector_active[i].id;
            var _timer = floor(global.injector_active[i].timer / 60);
            draw_sprite_ext(item_get_sprite_inv(_id), 0, _xx, global.status_y, 1, 1, 0, c_white, 1);
            language_set_font(UnknownEnum.Value_0);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            scr_draw_text_outlined(_xx + 8, global.status_y + 3, string(_timer), 16777215, 0, 1, 1);
            if (scr_mouse_over_hud(camx + _xx, camy + global.status_y, 16, 16))
            {
            }
        }
        var ammo_magazine = player_loadout_get_magazine_size(_player, _player.weapon_slot_now);
        var ammo_now = player_loadout_get_ammo(_player, _player.weapon_slot_now);
        var _ammo_id_now = player_loadout_get_ammo_item(_player, _player.weapon_slot_now);
        var s_ammo = s_ammo_counter_small;
        var sh = sprite_get_height(s_ammo);
        var sw = sprite_get_width(s_ammo);
        var offy = 0;
        var _y = 268;
        var _x = 0;
        var _s_id_h = 0;
        if (settings_get("show_ammo_icon"))
        {
            _s_id_h = sprite_get_height(item_get_sprite_inv(_ammo_id_now));
            draw_sprite(item_get_sprite_inv(_ammo_id_now), 0, _x, _y - _s_id_h);
        }
        shader_reset();
        _x += 16;
        if (player_loadout_get_fire_mode(player_get_local(), player_get_local().weapon_slot_now) == "automatic")
        {
            draw_sprite(s_hud_fire_mode_auto, 0, _x, _y);
        }
        else
        {
            draw_sprite(s_hud_fire_mode_single, 0, _x, _y);
        }
        _y -= (_s_id_h + sh + 2);
        for (var i = 0; i < ammo_magazine; i++)
        {
            var offx = 0;
            var sub;
            if (i < ammo_now)
            {
                sub = 0;
            }
            else
            {
                sub = 1;
            }
            draw_sprite(s_ammo, sub, 2 + offx, _y - ((sh - 1) * offy));
            if (global.ammo_counter_i_fired == true && i == ammo_now)
            {
                global.ammo_counter_i_fired = false;
                var ff = instance_create_depth(camx, camy, 0, obj_ammo_counter_fired);
                ff.sprite_index = s_ammo_counter_fired_small;
                ff.dx = 2 + offx;
                ff.dy = _y - ((sh - 1) * offy);
            }
            offy++;
        }
    }
}
harm_warning_draw_and_age();
if (settings_get("show_quickbar"))
{
    if (player_local_state_is(scr_player_state_move, scr_player_state_inventory, scr_player_state_consumable_animation))
    {
        if (!player_get_local_var("aiming", false) && !global.debug_hide_hud && player_exists_local())
        {
            var _off = 8;
            var _arr = ["quick slot 1", "quick slot 2", "quick slot 3", "quick slot 4", "quick slot 5", "quick slot 6"];
            var _n_slot = array_length(_arr);
            var _startx = 240 - (((_n_slot * 16) + ((_n_slot - 1) * _off)) / 2);
            var _starty = 250;
            for (var i = 0; i < _n_slot; i++)
            {
                var _x = _startx + (16 * i) + (_off * i);
                var _loot = inventory_find_loot(_arr[i]);
                if (!is_undefined(_loot))
                {
                    var _item_id = _loot.item;
                    if (item_exists(_item_id))
                    {
                        draw_sprite_ext(s_hud_quickbar_slot, 0, _x, _starty, 1, 1, 0, c_white, show_quickbar_alpha);
                        draw_sprite_ext(item_get_sprite_inv(_item_id), 0, _x, _starty, 1, 1, 0, c_white, show_quickbar_alpha);
                        draw_set_halign(fa_center);
                        draw_set_valign(fa_bottom);
                        draw_set_font(font_quest);
                        var _action;
                        switch (_arr[i])
                        {
                            case "quick slot 1":
                                _action = UnknownEnum.Value_17;
                                break;
                            case "quick slot 2":
                                _action = UnknownEnum.Value_18;
                                break;
                            case "quick slot 3":
                                _action = UnknownEnum.Value_19;
                                break;
                            case "quick slot 4":
                                _action = UnknownEnum.Value_20;
                                break;
                            case "quick slot 5":
                                _action = UnknownEnum.Value_21;
                                break;
                            case "quick slot 6":
                                _action = UnknownEnum.Value_22;
                                break;
                        }
                        if (!obj_gamepad.last_input_keyboard)
                        {
                            var _prev_alpha = draw_get_alpha();
                            draw_set_alpha(show_quickbar_alpha);
                            draw_gamepad_action_button(_action, _x + 8, _starty - 7, 1, false, 12632256);
                            draw_set_alpha(_prev_alpha);
                        }
                        else
                        {
                            var _string = "[" + scr_key_map(global.kb_now[_action]) + "]";
                            scr_draw_text_outlined_ext(_x + 8, _starty + 17, _string, 16777215, 0, 0.5, 0.5, show_quickbar_alpha);
                        }
                    }
                }
            }
        }
    }
}
if (_player.arms_holder != undefined)
{
    var _item_id = _player.arms_holder.item_id;
    if (item_fits_category(_item_id, "grenade"))
    {
        if (item_grenade_get_throw_type(_item_id) != "GRENADE_throw_no_move")
        {
            var _min = item_grenade_get_throw_min(_item_id);
            var _max = item_grenade_get_throw_max(_item_id);
            var _dis = point_distance(x, y, obj_cursor.aa_x, obj_cursor.aa_y);
            _dis = clamp(_dis, _min, _max);
            var _dir = point_direction(x, y, obj_cursor.aa_x, obj_cursor.aa_y);
            var _base = 4;
            var _offset_from_p = 8;
            var x1 = ((x + lengthdir_x(_base / 2, _dir + 90)) - camx) + lengthdir_x(_offset_from_p, _dir);
            var y1 = ((y + lengthdir_y(_base / 2, _dir + 90)) - camy) + lengthdir_y(_offset_from_p, _dir);
            var x2 = ((x + lengthdir_x(_base / 2, _dir - 90)) - camx) + lengthdir_x(_offset_from_p, _dir);
            var y2 = ((y + lengthdir_y(_base / 2, _dir - 90)) - camy) + lengthdir_y(_offset_from_p, _dir);
            var x3 = (x + lengthdir_x(_dis, _dir)) - camx;
            var y3 = (y + lengthdir_y(_dis, _dir)) - camy;
            var _c = 16777215;
            var _a = 0.6;
            draw_set_alpha(_a);
            draw_triangle_color(x1, y1, x2, y2, x3, y3, _c, _c, _c, false);
            draw_set_alpha(1);
        }
    }
}
if (player_local_state_is(scr_player_state_move) || player_local_state_is(scr_player_state_dummy))
{
    var _can_draw = true;
    if (instance_exists(obj_npc_draw_text))
    {
        with (obj_npc_draw_text)
        {
            if (id_che_parla == _player.id && suppress_prompts)
            {
                _can_draw = false;
            }
        }
    }
    if (global.change_ammo_now == true)
    {
        _can_draw = false;
    }
    if (_can_draw == true)
    {
        if (ds_list_size(global.list_interact) > 0)
        {
            language_set_font(UnknownEnum.Value_0);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            var xx = _player.x - camx;
            var yy = _player.y - camy - 16;
            var _above = true;
            for (var i = 0; i < ds_list_size(global.list_interact); i++)
            {
                var subi = 0;
                var cc = 16777215;
                if (global.p_int_instance_id == i)
                {
                    subi = 1;
                    cc = 9564927;
                }
                var tt = @@array_get@@(p_int_text, ds_list_find_value(global.list_interact, i));
                if (ds_list_find_value(global.list_interact, i) == UnknownEnum.Value_10)
                {
                    var _quest_pos = ds_list_find_value(global.list_interact_id, i);
                    var _quest_id = global.quest_state[_quest_pos].id;
                    var _task_pos = ds_list_find_value(global.list_interact_task_pos, i);
                    if (variable_struct_get(global.quest_database, _quest_id).objective[_task_pos].text_prompt != "")
                    {
                        tt = variable_struct_get(global.quest_database, _quest_id).objective[_task_pos].text_prompt;
                    }
                }
                if (ds_list_find_value(global.list_interact, i) == UnknownEnum.Value_5)
                {
                    if (is_in_raid())
                    {
                        if (_player.y > obj_map_generator.map_height)
                        {
                            tt = "Exit";
                        }
                        if (instance_exists(ds_list_find_value(global.list_interact_id, i)))
                        {
                            if (ds_list_find_value(global.list_interact_id, i).custom_text != "")
                            {
                                tt = ds_list_find_value(global.list_interact_id, i).custom_text;
                            }
                        }
                    }
                }
                var _claim_mark = "";
                if (ds_list_find_value(global.list_interact, i) == UnknownEnum.Value_1)
                {
                    var _chest_id = ds_list_find_value(global.list_interact_id, i);
                    if (instance_exists(_chest_id))
                    {
                        if (_chest_id.already_looted == true)
                        {
                            cc = 7105644;
                        }
                        if (ai_roaming_body_is_marked(_chest_id))
                        {
                            cc = 6974166;
                            if (ai_roaming_body_needs_warning(_chest_id))
                            {
                                _claim_mark = "! ";
                            }
                        }
                    }
                }
                var _button = UnknownEnum.Value_6;
                var _animated = true;
                if (!obj_gamepad.last_input_keyboard)
                {
                    if (subi == 0)
                    {
                        if (_above)
                        {
                            _button = UnknownEnum.Value_36;
                            _animated = false;
                        }
                        else
                        {
                            _button = UnknownEnum.Value_35;
                            _animated = false;
                        }
                    }
                }
                var _drawn_at = draw_text_outlined_with_control(xx + global.language_font_offset.x, ((yy + global.language_font_offset.y) - (16 * i)) + 5, _claim_mark + language_get_string(tt), _button, cc, _animated);
                if (subi == 1)
                {
                    if (ds_list_size(global.list_interact) > 1)
                    {
                        draw_sprite_ext(s_hud_selector, 0, _drawn_at[0] - (_drawn_at[2] / 2) - 5, _drawn_at[1] - 2, 1, 1, 0, #FFF291, 1);
                        _above = false;
                    }
                }
            }
        }
    }
}
display_set_gui_size(1920, 1080);
__uiGlobal().__defaultOnion.Draw();
display_set_gui_size(480, 270);
with (obj_action_prompt)
{
    event_user(0);
}
if (global.general_debug)
{
    var _show_debug = true;
    if (player_exists_local() && is_in_raid() && player_local_state_is(scr_player_state_free_camera))
    {
        _show_debug = false;
    }
    if (_show_debug == true)
    {
        language_set_font(UnknownEnum.Value_0);
        draw_set_halign(fa_right);
        draw_set_valign(fa_top);
        var _menu_open = debug_menu_is_open();
        var _text_x = _menu_open ? 470 : 400;
        var _text_y = _menu_open ? 185 : 1;
        var _text = "";
        if (!_menu_open)
        {
            _text += "DEBUG [F1]\n";
        }
        if (global.show_debug_position)
        {
            _text += ("seed: " + string(global.map_seed) + "\n");
            if (player_exists_local())
            {
                _text += ("player: " + string(floor(_player.x)) + "," + string(floor(_player.y)) + "\n");
            }
        }
        draw_text(_text_x, _text_y, _text);
        if (global.show_roaming_debug && is_in_raid())
        {
            draw_text_transformed(_text_x, _text_y + string_height(_text), ai_roaming_debug_text(), 0.5, 0.5, 0);
        }
    }
    if (keyboard_check_direct(vk_f2))
    {
        scr_draw_box(s_box_testo2, 25, 25, 430, 220, 1);
        language_set_font(UnknownEnum.Value_0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        for (var i = 0; i < array_length(global.sk_k); i++)
        {
            var xx = 0;
            var hh = 0;
            if (i >= 18 && i < 36)
            {
                xx = 130;
                hh = 18;
            }
            if (i >= 36 && i < 54)
            {
                xx = 260;
                hh = 36;
            }
            var t = global.sk_na[i] + " " + string(global.sk_k[i]);
            draw_text(30 + global.language_font_offset.x + xx, 30 + global.language_font_offset.y + (12 * (i - hh)), t);
        }
    }
    if (keyboard_check_direct(vk_f3))
    {
        scr_draw_box(s_box_testo2, 25, 25, 430, 220, 1);
        draw_set_halign(fa_left);
        for (var i = 0; i < array_length(global.sk_id); i++)
        {
            var get_id = global.sk_id[i];
            draw_text(50 + global.language_font_offset.x, 50 + global.language_font_offset.y + (10 * i), string(global.sk_lvl[get_id]) + "  " + global.sk_name[get_id]);
        }
    }
}
var collisione = false;
if (!player_local_state_is(scr_player_state_start, scr_player_state_free_camera))
{
    with (player_get_local())
    {
        if (place_meeting(x, y, obj_solid))
        {
            collisione = true;
        }
    }
}
if (collisione)
{
    var t_ = text_split(language_get_string("misc.debug.you_are_stuck_hold_ctrl_and_press_wasd"), 360, true);
    language_set_font(UnknownEnum.Value_0);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    scr_draw_text_outlined(240, 230 - (string_height(t_) - string_height("M")), t_, 16777215, 0, 1, 1);
}
if (global.general_debug)
{
}
var _running_i = 0;
if (is_in_shooting_range())
{
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _text = "ui.shootingrange.to_place_a_dummy";
    if (!obj_gamepad.last_input_keyboard)
    {
        draw_text_outlined_with_control(240, 254, language_get_string(_text), UnknownEnum.Value_29, 16777215, true);
    }
    else
    {
        var _string = "[SPACE] ";
        scr_draw_text_outlined(240, 254, language_get_string(_string) + language_get_string(_text), 16777215, 0, 1, 1);
    }
}
var _start_y;
if ((global.hud_glance_sysytem || is_in_shooting_range()) && player_state_is(0, scr_player_state_move))
{
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    _start_y = 100;
    draw_rectangle_color(-1, _start_y - 4, 110, _start_y + 50 + 4, c_black, c_black, c_black, c_black, false);
    var i = 0;
    draw_text(10 + global.language_font_offset.x, _start_y + global.language_font_offset.y + (10 * i), language_get_string("ui.shootingrange.recoil"));
    i++;
    draw_text(10 + global.language_font_offset.x, _start_y + global.language_font_offset.y + (10 * i), language_get_string("ui.shootingrange.move") + " " + string(player_get_local().recoil_from_movement));
    i++;
    draw_text(10 + global.language_font_offset.x, _start_y + global.language_font_offset.y + (10 * i), language_get_string("ui.shootingrange.shot") + " " + string(player_get_local().recoil_from_shooting));
    i++;
    draw_text(10 + global.language_font_offset.x, _start_y + global.language_font_offset.y + (10 * i), language_get_string("ui.shootingrange.total") + " " + string(player_get_local().recoil_total));
    i++;
    draw_text(10 + global.language_font_offset.x, _start_y + global.language_font_offset.y + (10 * i), language_get_string("ui.shootingrange.precision") + " " + string(player_get_local().total_precision));
    i++;
    i++;
    _running_i = i;
}
if ((global.hud_damage_sysytem || is_in_shooting_range()) && player_state_is(0, scr_player_state_move))
{
    if (item_get_category(player_get_local().arma_now) == "weapon")
    {
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        _player = player_get_local();
        var i = _running_i;
        _start_y += (10 * i);
        draw_rectangle_color(-1, _start_y - 4, 110, _start_y + 50 + 4, c_black, c_black, c_black, c_black, false);
        var _base = item_weapon_get_modded_stats(_player.arma_now, player_loadout_get_mod_container(_player, _player.weapon_slot_now)).damage;
        draw_text(10, 100 + (10 * i), language_get_string("ui.shootingrange.base_dmg") + " " + string(item_weapon_get_modded_stats(_player.arma_now, player_loadout_get_mod_container(_player, _player.weapon_slot_now)).damage));
        i++;
        var _mul = _player.weapon_mastery.get_mastery_bonus(item_weapon_get_type(_player.arma_now), "damage");
        draw_text(10, 100 + (10 * i), language_get_string("ui.shootingrange.mastery") + " " + string(_base) + " x " + string(_mul));
        i++;
        _base *= _mul;
        _mul = _player.scoped_damage_multiplier;
        draw_text(10, 100 + (10 * i), language_get_string("ui.shootingrange.scoped") + " " + string(_base) + " x " + string(_mul));
        i++;
        _base *= _mul;
        _mul = _player.skills_damage_multiplier;
        draw_text(10, 100 + (10 * i), language_get_string("ui.shootingrange.skills") + " " + string(_base) + " x " + string(_mul));
        i++;
        draw_text(10, 100 + (10 * i), language_get_string("ui.shootingrange.final_dmg") + " " + string(_player.now_damage));
        i++;
    }
}
if (global.general_debug)
{
    if (!global.debug_hide_hud)
    {
    }
}
if (is_in_raid())
{
    if (player_exists_local() && instance_exists(obj_map_generator))
    {
        if (player_local_state_is(scr_player_state_move))
        {
            if (_player.y < obj_map_generator.map_height)
            {
                if (_player.can_run_after_exit_building == true)
                {
                    var size_ = ds_list_size(global.list_minimap_marker_x);
                    if (size_ > 0)
                    {
                        for (var i = 0; i < size_; i++)
                        {
                            var xx = (ds_list_find_value(global.list_minimap_marker_x, i) * 16) / 4;
                            var yy = (ds_list_find_value(global.list_minimap_marker_y, i) * 16) / 4;
                            var dir_ = point_direction(x, y, xx, yy);
                            var x1 = x;
                            var y1 = y;
                            var off = 10;
                            if (!point_in_rectangle(xx, yy, camx + off, camy + off, (camx + 480) - off, (camy + 270) - off))
                            {
                                repeat (25)
                                {
                                    x1 += lengthdir_x(15, dir_);
                                    y1 += lengthdir_y(15, dir_);
                                    x1 = clamp(x1, camx + off, (camx + 480) - off);
                                    y1 = clamp(y1, camy + off, (camy + 270) - off);
                                    if (!point_in_rectangle(x1, y1, camx + off, camy + off, (camx + 480) - off, (camy + 270) - off))
                                    {
                                        break;
                                    }
                                }
                                draw_sprite_ext(s_minimap_marker, 0, x1 - camx, y1 - camy, 1, 1, dir_ + 90, c_white, 1);
                            }
                            else
                            {
                                draw_sprite_ext(s_minimap_marker, 0, xx - camx, yy - camy, 1, 1, 0, c_white, 1);
                            }
                        }
                    }
                }
            }
        }
    }
}
if (settings_get("display_npc_marker") && is_in_hub() && player_get_local().x < 1278)
{
    if (player_local_state_is(scr_player_state_move))
    {
        for (var i = 0; i < array_length(arr_npc_marker); i++)
        {
            if (is_struct(arr_npc_marker[i]) && teleport_allowed(arr_npc_marker[i].text))
            {
                var _marker = arr_npc_marker[i];
                var npc_x = _marker.x;
                var npc_y = _marker.y;
                var dir = point_direction(x, y, npc_x, npc_y);
                var _draw = true;
                if (!is_inside_bunker() && _marker.y < 1146)
                {
                    _draw = false;
                }
                if (_draw)
                {
                    if (!point_in_rectangle(npc_x, npc_y, camx, camy, camx + 480, camy + 270))
                    {
                        var clipped = clip_to_view_edge(x, y, npc_x, npc_y, camx, camy, 480, 270, 16);
                        var draw_x = clipped[0];
                        var draw_y = clipped[1];
                        if (!is_undefined(_marker.draw_x))
                        {
                            _marker.draw_x = lerp(_marker.draw_x, draw_x, 0.25);
                            _marker.draw_y = lerp(_marker.draw_y, draw_y, 0.25);
                        }
                        else
                        {
                            _marker.draw_x = draw_x;
                            _marker.draw_y = draw_y;
                        }
                        draw_sprite_ext(s_minimap_marker, 0, _marker.draw_x - camx, _marker.draw_y - camy, 1, 1, dir + 90, c_white, 1);
                        var text = _marker.text;
                        language_set_font(UnknownEnum.Value_0);
                        draw_set_halign(fa_center);
                        draw_set_valign(fa_middle);
                        var text_offset_y = 16;
                        var tx = clamp(_marker.draw_x, camx + 32, (camx + 480) - 32);
                        var ty = clamp(_marker.draw_y - text_offset_y, camy + 16, (camy + 270) - 32);
                        scr_draw_text_outlined(tx - camx, ty - camy, language_get_string(text), 16777215, 0, 1, 1);
                    }
                    else
                    {
                        draw_sprite_ext(s_minimap_marker, 0, npc_x - camx, npc_y - camy, 1, 1, 0, c_white, 1);
                        var _text = _marker.text;
                        language_set_font(UnknownEnum.Value_0);
                        draw_set_halign(fa_center);
                        draw_set_valign(fa_middle);
                        scr_draw_text_outlined(npc_x - camx, npc_y - camy - 15, language_get_string(_text), 16777215, 0, 1, 1);
                    }
                }
            }
        }
    }
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_5 = 5,
    Value_6,
    Value_10 = 10,
    Value_17 = 17,
    Value_18,
    Value_19,
    Value_20,
    Value_21,
    Value_22,
    Value_26 = 26,
    Value_29 = 29,
    Value_35 = 35,
    Value_36,
    Value_72 = 72,
    Value_73
}
