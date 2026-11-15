function inventory_use_quick_slot(arg0)
{
    if (player_get_local_var("reloading"))
    {
        exit;
    }
    if (!player_exists_local())
    {
        exit;
    }
    if (player_get_state() == scr_player_state_weapon_look)
    {
        exit;
    }
    var _player = player_get_local();
    var _loot = inventory_find_loot(arg0);
    if (is_struct(_loot))
    {
        var _found = false;
        var _item = loot_get_item(_loot);
        switch (item_get_category(_item))
        {
            case "medication":
                _found = true;
                _player.arms_holder = new class_player_arms(_player, _item, item_med_get_animation(_item));
                break;
            case "consumable":
                _found = true;
                _item = _loot.item;
                var _factor = (struct_get_from_hash(_loot, variable_get_hash("created_from_player")) ?? false) ? global.sk_k[UnknownEnum.Value_36] : 1;
                if (is_in_hub() && !settings_get("bunker_animation"))
                {
                    _player.energy += _factor * item_consumable_get_energy(_item);
                    _player.thirst += _factor * item_consumable_get_thirst(_item);
                    _player.fatigue += _factor * item_consumable_get_fatigue(_item);
                    _player.radiation_accumulata += _factor * item_consumable_get_radiation(_item);
                    scr_draw_text_with_box(item_get_name(_item) + " consumed");
                }
                else
                {
                    var _arms_holder = new class_player_arms(_player, _item, item_consumable_get_animation(_item));
                    _arms_holder.r_energy = _factor * item_consumable_get_energy(_item);
                    _arms_holder.r_thirst = _factor * item_consumable_get_thirst(_item);
                    _arms_holder.r_fatigue = _factor * item_consumable_get_fatigue(_item);
                    _arms_holder.r_radiation = _factor * item_consumable_get_radiation(_item);
                    _player.arms_holder = _arms_holder;
                }
                break;
            case "injector":
                _found = true;
                var _already_active = false;
                for (var i = 0; i < array_length(global.injector_active); i++)
                {
                    if (global.injector_active[i].id == _item)
                    {
                        _already_active = true;
                        global.injector_active[i].timer = item_inj_get_duration(_item);
                    }
                }
                if (!_already_active)
                {
                    var _struct = 
                    {
                        id: _item,
                        timer: item_inj_get_duration(_item)
                    };
                    array_push(global.injector_active, _struct);
                    with (_player)
                    {
                        hp_max += item_inj_get_max_hp(_item);
                        bleed_immune += item_inj_get_bleed_immune(_item);
                        stamina_max += item_inj_get_stamina_max(_item);
                        radiation_defence += item_inj_get_rad_def(_item);
                        energy += item_inj_get_hunger(_item);
                        thirst += item_inj_get_thirst(_item);
                    }
                }
                break;
            case "grenade":
                if (!is_in_hub())
                {
                    _found = true;
                    _player.arms_holder = new class_player_arms(_player, _item, item_grenade_get_animation(_item));
                    var _sound = choose(snd_grenade_pin_1, snd_grenade_pin_2, snd_grenade_pin_3);
                    audio_play_sound_on(_player.emitter_walk, _sound, false, 18);
                }
                break;
        }
        if (_found)
        {
            loot_decrement(_loot);
            if (is_in_hub())
            {
                db_force_save_soft("pre_raid");
            }
        }
    }
}

enum UnknownEnum
{
    Value_36 = 36
}
