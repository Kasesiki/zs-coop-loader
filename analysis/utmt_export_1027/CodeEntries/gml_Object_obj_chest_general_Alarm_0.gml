if (loot_generation_started)
{
    exit;
}
loot_generation_started = true;
depth = -y + 6;
chest_sprite = chest_sprite ?? chest_get_sprite(tipo);
sprite_index = chest_sprite;
if (instance_exists(obj_faro) && tipo == "ghoul")
{
    if (point_distance(x, y, obj_faro.x, obj_faro.y) < 300)
    {
        instance_create_depth(x, y, depth, obj_ghoul_dead);
        instance_destroy();
        exit;
    }
}
if (tipo != "discard")
{
    var _loot_array = [];
    var _carried_count = 0;
    var _target_item_count = irandom_range(chest_get_item_count_min(tipo), chest_get_item_count_max(tipo));
    _target_item_count = ceil(_target_item_count * global.sk_k[UnknownEnum.Value_8] * difficulty_get("loot_item_amount"));
    if (instance_exists(obj_map_generator) && obj_map_generator.area == UnknownEnum.Value_10)
    {
        _target_item_count = chest_get_item_count_min(tipo);
    }
    if (chest_get_item_count_max(tipo) == 1)
    {
        _target_item_count = 1;
    }
    var _chosen_item_array = [];
    var _chest_item_array = chest_get_item_array(tipo);
    var _chance_uncommon = chest_get_chance_uncommon(tipo);
    var _chance_rare = chest_get_chance_rare(tipo);
    var _chance_epic = chest_get_chance_epic(tipo);
    var _chance_legendary = chest_get_chance_legendary(tipo);
    var _is_drop = chest_is_drop(tipo);
    var _special_items_array = chest_get_special_items_array(tipo);
    var _max_durability = chest_get_always_max_durability(tipo);
    var _always_seen = chest_get_always_seen(tipo);
    var _decay_items = chest_get_decay_items(tipo) && scr_chance(30);
    var _fixed_chest = false;
    if (tipo == "prologue_equipment" || tipo == "prologue_medkit_box")
    {
        _fixed_chest = true;
    }
    if (_fixed_chest == false)
    {
        var _i = 0;
        repeat (_target_item_count)
        {
            var _chosen_rarity = "common";
            if (scr_chance(_chance_uncommon))
            {
                _chosen_rarity = "uncommon";
            }
            if (scr_chance(_chance_rare))
            {
                _chosen_rarity = "rare";
            }
            if (scr_chance(_chance_epic))
            {
                _chosen_rarity = "epic";
            }
            if (scr_chance(_chance_legendary))
            {
                _chosen_rarity = "legendary";
            }
            var _found_items_array = [];
            _i = 0;
            repeat (array_length(_chest_item_array))
            {
                var _item_struct = _chest_item_array[_i];
                var _rarity = struct_get_from_hash(_item_struct, variable_get_hash("rarity")) ?? "common";
                if (_rarity == _chosen_rarity)
                {
                    array_push(_found_items_array, _item_struct.item);
                }
                _i++;
            }
            if (array_length(_found_items_array) <= 0)
            {
                trace("Could not find any items for chest type ", tipo, ", rarity = ", _chosen_rarity);
            }
            else
            {
                array_push(_chosen_item_array, _found_items_array[irandom(array_length(_found_items_array) - 1)]);
            }
            _i++;
        }
        if (tipo == "air_drop_natale")
        {
            var _item = choose("armor_natale", "backpack_santa", "santa_ak");
            _chosen_item_array[0] = _item;
            _chosen_item_array[1] = _item;
            if (scr_chance(50))
            {
                while (_chosen_item_array[0] == _chosen_item_array[1])
                {
                    _chosen_item_array[1] = choose("armor_natale", "backpack_santa", "santa_ak");
                }
            }
        }
        if (create_item_in_chest && item_exists(armor_drop))
        {
            var _armour_is_in_special_array = false;
            var _special_items_count = array_length(_special_items_array);
            for (var i = 0; i < _special_items_count; i++)
            {
                if (_special_items_array[i].item == armor_drop)
                {
                    _armour_is_in_special_array = true;
                    break;
                }
            }
            if (!_armour_is_in_special_array)
            {
                var _chance_drop = armor_get_chance_to_drop(armor_drop);
                show_debug_message("ARMOR DROP CHANCE CLASS " + string(item_armor_get_class(armor_drop)) + " : " + string(_chance_drop));
                if (scr_chance(_chance_drop))
                {
                    array_push(_chosen_item_array, armor_drop);
                }
            }
        }
        if (create_item_in_chest && item_exists(backpack_drop))
        {
            array_push(_chosen_item_array, backpack_drop);
        }
        var _special_index = 0;
        var _own_ammo = "no_item";
        if (create_item_in_chest && _is_drop)
        {
            if (item_exists(arma_drop))
            {
                _chosen_item_array[_special_index] = arma_drop;
                _special_index++;
            }
            if (item_exists(ammo_drop))
            {
                var _new_ammo = scr_npc_get_ammo_drop(ammo_drop, chest_npc_id);
                if (item_exists(_new_ammo))
                {
                    _own_ammo = _new_ammo;
                    _chosen_item_array[_special_index] = _new_ammo;
                    _special_index++;
                }
            }
        }
        _i = 0;
        repeat (array_length(_special_items_array))
        {
            var _item_struct = _special_items_array[_i];
            var _chance = struct_get_from_hash(_item_struct, variable_get_hash("chance"));
            if (scr_chance(_chance ?? 100))
            {
                _chosen_item_array[_special_index] = _item_struct.item;
                _special_index++;
            }
            _i++;
        }
        if (strip_equipment)
        {
            strip_weapon = true;
            strip_armor = true;
            strip_backpack = true;
        }
        if (strip_weapon || strip_armor || strip_backpack)
        {
            var _strip_index = array_length(_chosen_item_array) - 1;
            while (_strip_index >= 0)
            {
                var _strip_item_id = _chosen_item_array[_strip_index];
                if (!is_string(_strip_item_id))
                {
                }
                else
                {
                    var _strip_category = item_get_category(_strip_item_id);
                    if ((strip_weapon && _strip_category == "weapon") || (strip_armor && _strip_category == "armor") || (strip_backpack && _strip_category == "backpack"))
                    {
                        array_delete(_chosen_item_array, _strip_index, 1);
                    }
                }
                _strip_index--;
            }
        }
        if (create_item_in_chest)
        {
            var _own_equipment = [_is_drop ? arma_drop : "no_item", _own_ammo, armor_drop, backpack_drop];
            var _own_first = [];
            for (var _own_index = 0; _own_index < array_length(_own_equipment); _own_index++)
            {
                var _own_item = _own_equipment[_own_index];
                if (!item_exists(_own_item))
                {
                    continue;
                }
                var _found_index = array_get_index(_chosen_item_array, _own_item);
                if (_found_index < 0)
                {
                    continue;
                }
                array_delete(_chosen_item_array, _found_index, 1);
                array_push(_own_first, _own_item);
            }
            _chosen_item_array = array_concat(_own_first, _chosen_item_array);
        }
        var _loot_grid = new class_loot_grid(8, 11);
        if (is_array(extra_items))
        {
            for (var _carried_index = 0; _carried_index < array_length(extra_items); _carried_index++)
            {
                var _carried = extra_items[_carried_index];
                if (!is_struct(_carried) || !item_exists(_carried.item) || _carried.quantity <= 0)
                {
                    continue;
                }
                var _carried_position = _loot_grid.TryPlaceFromBottomRight(_carried.item);
                if (!is_struct(_carried_position))
                {
                    _carried_position = _loot_grid.TryPlace(_carried.item);
                }
                if (!is_struct(_carried_position))
                {
                    continue;
                }
                _carried.x = 16 * _carried_position.x;
                _carried.y = 16 * _carried_position.y;
                _carried.rotation = _carried_position.rot;
                _carried.placement = "other inventory";
                _loot_grid.Place(_carried_position.x, _carried_position.y, _carried, _carried_position.rot);
                array_push(_loot_array, _carried);
                _carried_count++;
            }
        }
        extra_items = [];
        _i = 0;
        repeat (array_length(_chosen_item_array))
        {
            var _item_id = _chosen_item_array[_i];
            if (!is_string(_item_id))
            {
                trace_error("Chest type \"", tipo, "\" generated non-string item ID (index=", _i, ", value=", _item_id, ")");
                _i++;
            }
            else
            {
                var _stack_max = item_get_stack_max(_item_id);
                var _quantity;
                if (_stack_max == 1)
                {
                    _quantity = 1;
                }
                else
                {
                    _quantity = ceil(irandom(_stack_max / 2));
                    if (item_get_category(_item_id) == "ammo")
                    {
                        _quantity = ceil(clamp(_quantity, _stack_max * 0.08, _stack_max * 0.25));
                        if (tipo == "air_drop")
                        {
                            quantity = ceil(_stack_max / 2);
                        }
                        if (_is_drop)
                        {
                            _quantity *= difficulty_get("loot_npc_drop_ammo");
                        }
                    }
                    if (_item_id == "roubles")
                    {
                        _quantity = irandom_range(50, 150);
                        if (skill_hunter_obtained("stickyfinger"))
                        {
                            _quantity *= 5;
                        }
                    }
                    _quantity *= difficulty_get("loot_amount_single_item");
                    _quantity = ceil(_quantity);
                    _quantity = clamp(_quantity, 1, 999);
                }
                if (_quantity > 0)
                {
                    var _position = _loot_grid.TryPlace(_item_id);
                    if (is_struct(_position))
                    {
                        var _loot = new class_loot(_item_id, _quantity, 16 * _position.x, 16 * _position.y, _position.rot, "other inventory");
                        if (item_get_category(_item_id) == "weapon")
                        {
                            var _mod_container = loot_mod_cont_create();
                            var _ammo_id;
                            if (_is_drop)
                            {
                                _ammo_id = ammo_drop;
                                loot_mod_cont_copy_to(mod_container, _mod_container);
                                if (!item_weapon_can_fire(_item_id, _mod_container))
                                {
                                    trace("Dropped weapon \"", _item_id, "\" cannot fire, fixing");
                                    loot_mod_cont_copy_from_default(_mod_container, _item_id);
                                }
                                if (item_ammo_get_caliber(_ammo_id) != item_weapon_get_caliber(_item_id))
                                {
                                    trace("Dropped ammo \"", _ammo_id, "\" invalid for weapon \"", _item_id, "\", fixing");
                                    _ammo_id = item_weapon_get_ammo(_item_id);
                                }
                            }
                            else
                            {
                                _ammo_id = item_weapon_get_ammo(_item_id);
                                loot_mod_cont_copy_from_default(_mod_container, _item_id);
                            }
                            loot_set_from_chest(_loot, _always_seen, _max_durability ? 100 : irandom_range(difficulty_get("loot_weapon_dur_min"), difficulty_get("loot_weapon_dur_max")), false);
                            loot_add_weapon_data(_loot, _ammo_id, irandom(item_weapon_get_magazine(_item_id) div 2), item_weapon_get_fire_mode(_item_id), _mod_container);
                            trace("Spawned weapon for chest ", object_get_name(object_index), ":", self);
                            trace("name_chest = ", name_chest);
                            trace("_item_id = ", _item_id);
                            trace(SnapToJSON(mod_container, true, true));
                        }
                        else if (item_get_category(_item_id) == "armor" && _item_id == armor_drop)
                        {
                            var _struct_dur = armor_get_durability_on_drop(armor_drop);
                            var _dur = irandom_range(_struct_dur.minimum, _struct_dur.maximum);
                            loot_set_from_chest(_loot, _always_seen, _dur, false);
                        }
                        else
                        {
                            loot_set_from_chest(_loot, _always_seen, 100, false);
                        }
                        _loot_grid.Place(_position.x, _position.y, _loot, _position.rot);
                        array_push(_loot_array, _loot);
                    }
                }
                _i++;
            }
        }
        _loot_grid.Destroy();
    }
    else
    {
        if (tipo == "prologue_equipment")
        {
            _loot_array = prologue_chest_from_loadout(true);
        }
        if (tipo == "prologue_medkit_box")
        {
            _loot_array = prologue_chest_from_loadout(false);
        }
    }
    var _decay_chance = 60;
    if (!create_item_in_chest)
    {
        _decay_items = true;
        _decay_chance = 75;
    }
    if (_decay_items)
    {
        var _i = _carried_count;
        repeat (array_length(_loot_array) - _carried_count)
        {
            if (scr_chance(_decay_chance))
            {
                loot_clear(_loot_array[_i]);
            }
            _i++;
        }
    }
    var _chest_instance = id;
    mods_perform_event("loot_generated", [_chest_instance, tipo, _loot_array], _chest_instance);
    if (!instance_exists(_chest_instance))
    {
        exit;
    }
    db_open("all loot");
    db_write("chest_" + string(id), "chest_x", x);
    db_write("chest_" + string(id), "chest_y", y);
    db_write("chest_" + string(id), "items", _loot_array);
    db_close();
}

enum UnknownEnum
{
    Value_8 = 8,
    Value_10 = 10
}
