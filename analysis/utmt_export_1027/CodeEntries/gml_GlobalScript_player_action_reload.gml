function player_action_reload()
{
    if (player_loadout_exists(self, weapon_slot_now))
    {
        var _ho_ammo = false;
        var _current_ammo_item = player_loadout_get_ammo_item(self, weapon_slot_now);
        var _current_ammo_total = player_loadout_get_ammo(self, weapon_slot_now);
        var _alternative_ammo_items = [];
        var _alternative_ammo_quantities = [];
        var _alternative_ammo_item = "no_item";
        db_open(inventory_target_db());
        var _loot_array = db_read("Inventory", "items", []);
        db_close();
        var _i = 0;
        repeat (array_length(_loot_array))
        {
            var _loot = _loot_array[_i];
            var _item = _loot.item;
            if (_loot.quantity > 0 && item_ammo_fits_weapon(_item, arma_now))
            {
                if (_item == _current_ammo_item)
                {
                    _ho_ammo = true;
                    _current_ammo_total += _loot.quantity;
                }
                else
                {
                    var _alternative_index = array_find_index_our(_alternative_ammo_items, _item);
                    if (_alternative_index == undefined)
                    {
                        array_push(_alternative_ammo_items, _item);
                        array_push(_alternative_ammo_quantities, _loot.quantity);
                    }
                    else
                    {
                        _alternative_ammo_quantities[_alternative_index] += _loot.quantity;
                    }
                }
            }
            _i++;
        }
        if (!_ho_ammo && settings_get("auto_switch_ammo"))
        {
            var _alternative_ammo_quantity = _current_ammo_total;
            _i = 0;
            repeat (array_length(_alternative_ammo_items))
            {
                var _quantity = _alternative_ammo_quantities[_i];
                if (_quantity > _alternative_ammo_quantity)
                {
                    _alternative_ammo_item = _alternative_ammo_items[_i];
                    _alternative_ammo_quantity = _quantity;
                }
                _i++;
            }
            _ho_ammo = _alternative_ammo_item != "no_item";
        }
        if (_ho_ammo)
        {
            if (!audio_is_playing(snd_jam))
            {
                if (!reloading)
                {
                    if (_alternative_ammo_item != "no_item")
                    {
                        var _current_ammo = player_loadout_get_ammo(self, weapon_slot_now);
                        inventory_add_item(_current_ammo_item, _current_ammo);
                        player_loadout_set_ammo(weapon_slot_now, 0);
                        player_loadout_set_ammo_item(weapon_slot_now, _alternative_ammo_item);
                        var _text = language_get_string("ui.auto_switching_ammo");
                        _text = string_replace(_text, "[ITEM_NAME]", item_get_name(_alternative_ammo_item));
                        scr_draw_text_with_box(_text, false);
                    }
                    if (player_loadout_get_ammo(self, weapon_slot_now) < player_loadout_get_magazine_size(self, weapon_slot_now))
                    {
                        var _sound_time = 60 * audio_sound_length(item_weapon_get_sound_mag_out(arma_now));
                        var _sound_time_total = _sound_time * weapon_mastery.get_mastery_bonus(item_weapon_get_type(arma_now), "reload_speed");
                        alarm[0] = _sound_time_total;
                        reloading = true;
                        state_reload = UnknownEnum.Value_0;
                        if (player_loadout_get_ammo(self, weapon_slot_now) <= 0 && item_weapon_get_reload_type(arma_now) == "magazine")
                        {
                            reload_cocking = true;
                        }
                        audio_play_sound(item_weapon_get_sound_mag_out(arma_now), 10, false);
                        var _struct = struct_get_from_hash(item_get_struct(arma_now), variable_get_hash("weapon"));
                        if (variable_struct_exists(_struct, "scripts"))
                        {
                            var _scripts = struct_get_from_hash(_struct, variable_get_hash("scripts"));
                            if (variable_struct_exists(_scripts, "weapon_reload"))
                            {
                                mods_weapon_perform_event(_scripts, "weapon_reload", id);
                            }
                        }
                    }
                }
            }
        }
        else
        {
            var _text = language_get_string("ui.no_ammo_reload");
            scr_draw_text_with_box(string_replace(_text, "[ITEM_NAME]", item_get_name(_current_ammo_item)));
        }
        return true;
    }
    return false;
}

enum UnknownEnum
{
    Value_0
}
