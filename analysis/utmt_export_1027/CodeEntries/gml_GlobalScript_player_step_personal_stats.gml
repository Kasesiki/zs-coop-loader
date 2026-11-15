function player_step_personal_stats()
{
    if (is_nan(stamina))
    {
        stamina = 0;
    }
    if (!instance_exists(obj_exit_screen))
    {
        if (global.sk_lvl[UnknownEnum.Value_21] >= 0 && energy >= 50 && thirst >= 50)
        {
            global.sk_k[UnknownEnum.Value_38] = 10 + (2 * global.sk_lvl[UnknownEnum.Value_21]);
            global.sk_k[UnknownEnum.Value_39] = 15 + (2 * global.sk_lvl[UnknownEnum.Value_21]);
        }
        stamina_max_total = 100 + global.sk_k[UnknownEnum.Value_0] + global.sk_k[UnknownEnum.Value_39] + global.injector_factor[UnknownEnum.Value_4];
        if (sprint_exhausted_timer > 0)
        {
            sprint_exhausted_timer--;
        }
        else
        {
            stamina += ((0.18 * global.sk_k[UnknownEnum.Value_6]) + global.injector_factor[UnknownEnum.Value_5]);
        }
        if (!player_state_is(mp_index, scr_player_state_start, scr_player_state_free_camera))
        {
            fatigue -= 0.0005138888888888889;
        }
        fatigue = clamp(fatigue, fatigue_max, fatigue_start);
        stamina_max = clamp(stamina_max_total + min(0, fatigue), 0, stamina_max_total);
        stamina = clamp(stamina, 0, stamina_max);
        wound = clamp(wound, 0, 40);
        bleed -= global.injector_factor[UnknownEnum.Value_2];
        if (global.injector_factor[UnknownEnum.Value_3] > 0)
        {
            bleed = 0;
        }
        if (bleed <= 0.1)
        {
            bleed = 0;
        }
        bleed = clamp(bleed, 0, 3);
        hp_regen = global.injector_factor[UnknownEnum.Value_1];
        hp_max_total = ceil(difficulty_get("pro_player_health") + global.sk_k[UnknownEnum.Value_43] + global.sk_k[UnknownEnum.Value_38] + global.injector_factor[UnknownEnum.Value_0]);
        var _bleed_amount = (arms_holder != undefined && item_get_category(arms_holder.item_id) == "medication") ? 0 : bleed;
        var _hp_before_bleed = hp;
        hp -= (ceil(_bleed_amount) * 0.02);
        if (_bleed_amount > 0 && _hp_before_bleed > 0 && hp <= 0)
        {
            global.last_damage_source = "bleed";
        }
        mods_player_heal(id, hp_regen + global.sk_k[UnknownEnum.Value_46]);
        hp_max = hp_max_total - wound;
        hp_max = clamp(hp_max, 0, hp_max_total - wound);
        hp = clamp(hp, is_in_hub() ? 10 : 0, hp_max);
        var _ignore_rad = false;
        if (instance_exists(obj_map_generator) && obj_map_generator.area == UnknownEnum.Value_10)
        {
            _ignore_rad = true;
        }
        var difesa_rad = item_armor_get_radiation(armor_now);
        if (!_ignore_rad && room == room1)
        {
            var rx = clamp(x div 8, 1, obj_map_generator.grid_rw - 2);
            var ry = clamp((y + 8) div 8, 1, obj_map_generator.grid_rh - 2);
            radiation_nella_pos_attuale = ds_grid_get(obj_map_generator.grid_radiation, rx, ry) - difesa_rad;
        }
        else
        {
            radiation_nella_pos_attuale = 0;
        }
        var _radiation_delta = radiation_nella_pos_attuale / 216000;
        _radiation_delta = clamp(_radiation_delta, 0, 1000);
        if (skill_hunter_obtained("stalker"))
        {
            _radiation_delta *= struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("stalker")), variable_get_hash("radiation_reduction_multiplier"));
        }
        radiation += _radiation_delta;
        radiation_accumulata += _radiation_delta;
        radiation_accumulata += global.sk_k[UnknownEnum.Value_47];
        radiation_accumulata -= global.injector_factor[UnknownEnum.Value_7];
        radiation_accumulata = clamp(radiation_accumulata, 0, global.status_value_max[UnknownEnum.Value_3]);
        if (is_in_raid())
        {
            if (!_ignore_rad)
            {
                var rx = clamp(x div 8, 1, obj_map_generator.grid_rw - 2);
                var ry = clamp((y + 8) div 8, 1, obj_map_generator.grid_rh - 2);
                player_play_radiation_sound(ds_grid_get(obj_map_generator.grid_radiation, rx, ry) - (global.injector_factor[UnknownEnum.Value_8] + difesa_rad));
            }
        }
        if (!player_state_is(mp_index, scr_player_state_start, scr_player_state_free_camera))
        {
            if (!is_in_hub())
            {
                energy -= (0.0005 * global.sk_k[UnknownEnum.Value_56] * difficulty_get("pro_hunger_thirst_rate"));
                thirst -= (0.0006666666666666666 * global.sk_k[UnknownEnum.Value_57] * difficulty_get("pro_hunger_thirst_rate"));
            }
            energy -= -global.injector_factor[UnknownEnum.Value_10];
            thirst -= -global.injector_factor[UnknownEnum.Value_12];
        }
        for (var i = 0; i < array_length(global.sk_id); i++)
        {
            var get_id = global.sk_id[i];
            if (global.sk_lvl[get_id] != -1)
            {
                global.sk_lvl[get_id] = clamp(global.sk_lvl[get_id], 0, global.sk_lvl_max[get_id] + 0.001);
            }
        }
        if (hp < 20 && !player_state_is(mp_index, scr_player_state_dead))
        {
            if (!audio_is_playing(snd_heart))
            {
                audio_play_sound(snd_heart, 2, false);
            }
        }
        player_harm_bark_step();
        frames_since_last_swap_weapon++;
    }
    energy = clamp(energy, 0, 100);
    thirst = clamp(thirst, 0, 100);
    if (global.xp_level_now >= array_length(struct_get_from_hash(global.xp_data, variable_get_hash("levels"))))
    {
        global.xp = 0;
    }
}

function player_harm_bark_step()
{
    if (!settings_get("harm_warnings") || is_in_hub() || player_state_is(mp_index, scr_player_state_start))
    {
        harm_bark_queue_flush();
        exit;
    }
    for (var _i = 0; _i <= UnknownEnum.Value_8; _i++)
    {
        if (harm_bark_cd[_i] > 0)
        {
            harm_bark_cd[_i] -= 1;
        }
    }
    var _bleed_healing = arms_holder != undefined && item_get_category(arms_holder.item_id) == "medication";
    var _bleed_danger = bleed > 0 && !_bleed_healing;
    var _bleed_tier = floor(bleed);
    if (_bleed_danger && (!harm_bark_was[UnknownEnum.Value_0] || _bleed_tier > harm_bark_bleed_tier))
    {
        __harm_bark_fire(UnknownEnum.Value_0, snd_player_bleed, UnknownEnum.Value_38);
        harm_bark_bleed_tier = _bleed_tier;
    }
    harm_bark_was[UnknownEnum.Value_0] = _bleed_danger;
    if (!_bleed_danger)
    {
        harm_bark_bleed_tier = 0;
    }
    __harm_bark_edge(UnknownEnum.Value_1, energy < 20, snd_player_hunger, UnknownEnum.Value_39);
    __harm_bark_edge(UnknownEnum.Value_2, thirst < 20, snd_player_thirst, UnknownEnum.Value_40);
    __harm_bark_edge(UnknownEnum.Value_3, fatigue < 20, snd_player_fatigue, UnknownEnum.Value_41);
    var _rad_danger = radiation_sound == snd_radiation_medium || radiation_sound == snd_radiation_high;
    __harm_bark_edge(UnknownEnum.Value_4, _rad_danger, -4, UnknownEnum.Value_42);
    __harm_bark_edge(UnknownEnum.Value_5, hp < 20 && !(instance_exists(obj_map_generator) && obj_map_generator.area == UnknownEnum.Value_10), -4, UnknownEnum.Value_43);
    var _wound_danger = wound > 0;
    var _wound_band = floor(wound / 10);
    if (_wound_danger && (!harm_bark_was[UnknownEnum.Value_6] || _wound_band > harm_bark_wound_band))
    {
        __harm_bark_fire(UnknownEnum.Value_6, snd_player_wound, UnknownEnum.Value_44);
        harm_bark_wound_band = _wound_band;
    }
    harm_bark_was[UnknownEnum.Value_6] = _wound_danger;
    if (!_wound_danger)
    {
        harm_bark_wound_band = 0;
    }
    var _aloot = player_loadout_get_loot(id, "armor slot");
    var _astate = 0;
    if (loot_get_item(_aloot) != "no_item")
    {
        var _adur = _aloot.durability;
        if (_adur < 35)
        {
            _astate = 2;
        }
        else if (_adur < 50)
        {
            _astate = 1;
        }
    }
    if (_astate > 0 && (_astate > harm_bark_armor_state || harm_bark_cd[UnknownEnum.Value_7] <= 0))
    {
        harm_bark_enqueue((_astate == 2) ? UnknownEnum.Value_46 : UnknownEnum.Value_45);
        harm_bark_cd[UnknownEnum.Value_7] = 18000;
    }
    harm_bark_armor_state = _astate;
    var _wloot = player_loadout_get_loot(id, weapon_slot_now);
    var _wstate = 0;
    if (item_get_category(loot_get_item(_wloot)) == "weapon")
    {
        var _wdur = _wloot.durability;
        if (_wdur < 20)
        {
            _wstate = 2;
        }
        else if (_wdur < 35)
        {
            _wstate = 1;
        }
    }
    if (_wstate > 0 && (_wstate > harm_bark_weapon_state || harm_bark_cd[UnknownEnum.Value_8] <= 0))
    {
        harm_bark_enqueue((_wstate == 2) ? UnknownEnum.Value_48 : UnknownEnum.Value_47);
        harm_bark_cd[UnknownEnum.Value_8] = 18000;
    }
    harm_bark_weapon_state = _wstate;
    harm_bark_queue_pump();
}

function __harm_bark_edge(arg0, arg1, arg2, arg3)
{
    if (arg1 && !harm_bark_was[arg0])
    {
        __harm_bark_fire(arg0, arg2, arg3);
    }
    harm_bark_was[arg0] = arg1;
}

function __harm_bark_fire(arg0, arg1, arg2)
{
    if (harm_bark_cd[arg0] > 0)
    {
        exit;
    }
    harm_bark_cd[arg0] = (arg0 == UnknownEnum.Value_4) ? 600 : 120;
    if (arg1 != -4)
    {
        audio_play_sound(arg1, 4, false);
    }
    harm_bark_enqueue(arg2);
}

function harm_warning_push(arg0)
{
    if (!variable_global_exists("harm_warnings"))
    {
        global.harm_warnings = [];
    }
    for (var _i = 0; _i < array_length(global.harm_warnings); _i++)
    {
        if (global.harm_warnings[_i].text == arg0)
        {
            global.harm_warnings[_i].life = 180;
            exit;
        }
    }
    array_push(global.harm_warnings, 
    {
        text: arg0,
        life: 180,
        life_max: 180
    });
}

function harm_warning_draw_and_age()
{
    if (!variable_global_exists("harm_warnings"))
    {
        exit;
    }
    if (array_length(global.harm_warnings) == 0)
    {
        exit;
    }
    language_set_font(UnknownEnum.Value_0);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _row = 0;
    var _i = 0;
    while (_i < array_length(global.harm_warnings))
    {
        var _m = global.harm_warnings[_i];
        _m.life -= 1;
        if (_m.life <= 0)
        {
            array_delete(global.harm_warnings, _i, 1);
        }
        else
        {
            var _a = clamp(_m.life / _m.life_max, 0, 1);
            draw_set_color(c_red);
            draw_set_alpha(_a);
            draw_text(87 + global.language_font_offset.x, 50 + global.language_font_offset.y + (_row * 11), _m.text);
            _row += 1;
            _i += 1;
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function harm_bark_enqueue(arg0)
{
    if (!variable_global_exists("harm_bark_queue"))
    {
        global.harm_bark_queue = [];
    }
    for (var _i = 0; _i < array_length(global.harm_bark_queue); _i++)
    {
        if (global.harm_bark_queue[_i] == arg0)
        {
            exit;
        }
    }
    array_push(global.harm_bark_queue, arg0);
}

function harm_bark_queue_pump()
{
    if (!variable_global_exists("harm_bark_queue"))
    {
        exit;
    }
    if (array_length(global.harm_bark_queue) == 0)
    {
        exit;
    }
    var _player = player_get_local();
    if (!instance_exists(_player))
    {
        exit;
    }
    var _busy = false;
    with (obj_npc_draw_text)
    {
        if (id_npc == _player)
        {
            _busy = true;
        }
    }
    if (_busy)
    {
        exit;
    }
    var _key = global.harm_bark_queue[0];
    array_delete(global.harm_bark_queue, 0, 1);
    scr_draw_npc_text(_player, _key);
}

function harm_bark_queue_flush()
{
    if (variable_global_exists("harm_bark_queue"))
    {
        global.harm_bark_queue = [];
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
    Value_10 = 10,
    Value_12 = 12,
    Value_21 = 21,
    Value_38 = 38,
    Value_39,
    Value_40,
    Value_41,
    Value_42,
    Value_43,
    Value_44,
    Value_45,
    Value_46,
    Value_47,
    Value_48,
    Value_56 = 56,
    Value_57
}
