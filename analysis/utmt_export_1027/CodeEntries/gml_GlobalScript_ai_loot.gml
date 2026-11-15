function ai_loot_npc_has(arg0, arg1)
{
    return instance_exists(arg0) ? variable_instance_exists(arg0, arg1) : true;
}

function ai_loot_bag(arg0)
{
    if (!ai_loot_npc_has(arg0, "carried_loot") || !is_array(arg0.carried_loot))
    {
        arg0.carried_loot = [];
    }
    return arg0.carried_loot;
}

function ai_loot_discarded(arg0)
{
    if (!ai_loot_npc_has(arg0, "roaming_discarded_loot") || !is_array(arg0.roaming_discarded_loot))
    {
        arg0.roaming_discarded_loot = [];
    }
    return arg0.roaming_discarded_loot;
}

function ai_loot_bag_item_count(arg0)
{
    var _bag = ai_loot_bag(arg0);
    var _count = 0;
    for (var _index = 0; _index < array_length(_bag); _index++)
    {
        var _loot = _bag[_index];
        if (is_struct(_loot) && item_exists(_loot.item) && _loot.quantity > 0)
        {
            _count++;
        }
    }
    return _count;
}

function ai_loot_backpack_is_fat(arg0)
{
    return ai_loot_bag_item_count(arg0) >= 3;
}

function ai_loot_bag_count_category(arg0, arg1)
{
    var _count = 0;
    for (var _index = 0; _index < array_length(arg0); _index++)
    {
        var _loot = arg0[_index];
        if (is_struct(_loot) && item_exists(_loot.item) && item_get_category(_loot.item) == arg1)
        {
            _count++;
        }
    }
    return _count;
}

function ai_loot_bag_worst_index(arg0, arg1)
{
    var _worst_index = -1;
    var _worst_value = 0;
    for (var _index = 0; _index < array_length(arg0); _index++)
    {
        var _loot = arg0[_index];
        if (!is_struct(_loot) || !item_exists(_loot.item) || item_get_category(_loot.item) != arg1)
        {
            continue;
        }
        var _value = loot_get_value(_loot);
        if (_worst_index < 0 || _value < _worst_value)
        {
            _worst_index = _index;
            _worst_value = _value;
        }
    }
    return _worst_index;
}

function ai_loot_tier_get(arg0)
{
    if (!ai_loot_npc_has(arg0, "roaming_loot_tier"))
    {
        arg0.roaming_loot_tier = "";
    }
    if (!is_string(arg0.roaming_loot_tier) || arg0.roaming_loot_tier == "")
    {
        arg0.roaming_loot_tier = npc_get_chest_dropped(arg0.npc_id);
    }
    return arg0.roaming_loot_tier;
}

function ai_loot_tier_word(arg0)
{
    if (!is_string(arg0))
    {
        return "";
    }
    var _words = ["rookie", "intermediate", "skilled", "expert", "veteran", "master"];
    for (var _index = 0; _index < array_length(_words); _index++)
    {
        if (string_pos("_" + _words[_index] + "_", arg0) > 0)
        {
            return _words[_index];
        }
    }
    return "";
}

function ai_loot_string_ends_with(arg0, arg1)
{
    var _text_length = string_length(arg0);
    var _suffix_length = string_length(arg1);
    if (_suffix_length > _text_length)
    {
        return false;
    }
    return string_copy(arg0, (_text_length - _suffix_length) + 1, _suffix_length) == arg1;
}

function ai_loot_tier_bump(arg0)
{
    var _chest_type = ai_loot_tier_get(arg0);
    if (!is_string(_chest_type))
    {
        return false;
    }
    var _levels = ["low", "normal", "high", "very_high"];
    var _level_index = array_length(_levels) - 2;
    while (_level_index >= 0)
    {
        var _suffix = "_" + _levels[_level_index];
        if (!ai_loot_string_ends_with(_chest_type, _suffix))
        {
        }
        else
        {
            var _next_type = string_copy(_chest_type, 1, string_length(_chest_type) - string_length(_suffix)) + "_" + _levels[_level_index + 1];
            if (!variable_struct_exists(global.chest_data, _next_type))
            {
                return false;
            }
            arg0.roaming_loot_tier = _next_type;
            return true;
        }
        _level_index--;
    }
    return false;
}

function ai_loot_rules(arg0, arg1)
{
    var _rules = 
    {
        priority: arg0.priority,
        never_categories: arg0.never_categories,
        never_item_prefixes: arg0.never_item_prefixes,
        take_other_calibers: arg0.take_other_calibers,
        max_item_weight: arg0.max_item_weight,
        spare_equipment_max: arg0.spare_equipment_max,
        budget_bonus: variable_struct_exists(arg0, "budget_bonus") ? arg0.budget_bonus : 0
    };
    var _override = (is_struct(arg0.factions) && is_string(arg1)) ? variable_struct_get(arg0.factions, arg1) : undefined;
    if (is_struct(_override))
    {
        var _field_names = variable_struct_get_names(_rules);
        for (var _index = 0; _index < array_length(_field_names); _index++)
        {
            var _field_name = _field_names[_index];
            if (!variable_struct_exists(_override, _field_name))
            {
                continue;
            }
            var _default_value = variable_struct_get(_rules, _field_name);
            var _override_value = variable_struct_get(_override, _field_name);
            var _same_type = (is_array(_default_value) && is_array(_override_value)) || (is_numeric(_default_value) && is_numeric(_override_value)) || (is_bool(_default_value) && is_bool(_override_value));
            if (_same_type)
            {
                variable_struct_set(_rules, _field_name, _override_value);
            }
        }
    }
    ai_loot_rules_apply_difficulty(_rules, arg0, arg1);
    return _rules;
}

function ai_loot_difficulty_category_groups()
{
    return [
    {
        setting: "npc_loot_weapons",
        categories: ["weapon"]
    }, 
    {
        setting: "npc_loot_armor",
        categories: ["armor"]
    }, 
    {
        setting: "npc_loot_backpacks",
        categories: ["backpack"]
    }, 
    {
        setting: "npc_loot_attachments",
        categories: ["w_mod"]
    }, 
    {
        setting: "npc_loot_ammo",
        categories: ["ammo", "grenade"]
    }, 
    {
        setting: "npc_loot_medical",
        categories: ["medication", "injector"]
    }, 
    {
        setting: "npc_loot_valuables",
        categories: ["barter", "repair_weapon", "repair_armor", "headset", "cassette", "container", "consumable"]
    }];
}

function ai_loot_rules_apply_difficulty(arg0, arg1, arg2)
{
    var _groups = ai_loot_difficulty_category_groups();
    var _left_out = [];
    for (var _group_index = 0; _group_index < array_length(_groups); _group_index++)
    {
        if (!difficulty_get(_groups[_group_index].setting))
        {
            _left_out = array_concat(_left_out, _groups[_group_index].categories);
        }
    }
    if (array_length(_left_out) > 0)
    {
        var _priority = [];
        for (var _index = 0; _index < array_length(arg0.priority); _index++)
        {
            if (!array_contains(_left_out, arg0.priority[_index]))
            {
                array_push(_priority, arg0.priority[_index]);
            }
        }
        arg0.priority = _priority;
    }
    var _faction_spare_offset = arg0.spare_equipment_max - arg1.spare_equipment_max;
    arg0.spare_equipment_max = max(0, difficulty_get("npc_spare_equipment") + _faction_spare_offset);
    if (array_contains(["Loners", "scavenger"], arg2))
    {
        arg0.budget_bonus = difficulty_get("npc_hunter_extra_loot");
    }
}

function ai_loot_is_equipment(arg0)
{
    return array_contains(["weapon", "armor", "backpack"], arg0);
}

function ai_loot_budget(arg0, arg1, arg2)
{
    var _tier_word = ai_loot_tier_word(ai_loot_tier_get(arg0));
    var _budget = arg1.budget_default;
    if (_tier_word != "" && is_struct(arg1.budget_by_tier) && variable_struct_exists(arg1.budget_by_tier, _tier_word))
    {
        _budget = variable_struct_get(arg1.budget_by_tier, _tier_word);
    }
    _budget = floor(max(0, _budget + arg2.budget_bonus) * difficulty_get("npc_loot_amount"));
    var _bag = ai_loot_bag(arg0);
    for (var _index = 0; _index < array_length(_bag); _index++)
    {
        var _loot = _bag[_index];
        if (is_struct(_loot) && item_exists(_loot.item) && !ai_loot_is_equipment(item_get_category(_loot.item)))
        {
            _budget--;
        }
    }
    return max(0, _budget);
}

function ai_loot_overlook_chance(arg0, arg1)
{
    var _tier_word = ai_loot_tier_word(ai_loot_tier_get(arg0));
    if (_tier_word == "" || !is_struct(arg1.overlook_chance_by_tier) || !variable_struct_exists(arg1.overlook_chance_by_tier, _tier_word))
    {
        return 0;
    }
    return variable_struct_get(arg1.overlook_chance_by_tier, _tier_word);
}

function ai_loot_priority_index(arg0, arg1)
{
    for (var _index = 0; _index < array_length(arg0.priority); _index++)
    {
        if (arg0.priority[_index] == arg1)
        {
            return _index;
        }
    }
    return -1;
}

function ai_loot_is_never_taken(arg0, arg1)
{
    if (item_get_quest_item(arg1))
    {
        return true;
    }
    if (array_contains(arg0.never_categories, item_get_category(arg1)))
    {
        return true;
    }
    for (var _index = 0; _index < array_length(arg0.never_item_prefixes); _index++)
    {
        var _prefix = arg0.never_item_prefixes[_index];
        if (string_length(_prefix) > 0 && string_copy(arg1, 1, string_length(_prefix)) == _prefix)
        {
            return true;
        }
    }
    return false;
}

function ai_loot_wants_ammo(arg0, arg1, arg2)
{
    if (arg1.take_other_calibers)
    {
        return true;
    }
    if (!ai_loot_npc_has(arg0, "arma_now") || !item_exists(arg0.arma_now) || item_get_category(arg0.arma_now) != "weapon")
    {
        return false;
    }
    return item_ammo_get_caliber(arg2) == item_weapon_get_caliber(arg0.arma_now);
}

function ai_loot_same_footprint(arg0, arg1)
{
    var _sprite_a = item_get_sprite_inv(arg0);
    var _sprite_b = item_get_sprite_inv(arg1);
    return sprite_get_width(_sprite_a) == sprite_get_width(_sprite_b) && sprite_get_height(_sprite_a) == sprite_get_height(_sprite_b);
}

function ai_loot_value_per_weight(arg0)
{
    return loot_get_value(arg0) / max(0.1, item_get_weight(arg0.item) * max(1, arg0.quantity));
}

function ai_loot_plan(arg0, arg1, arg2, arg3, arg4)
{
    var _plan = [];
    if (!is_array(arg1) || array_length(arg1) == 0)
    {
        return _plan;
    }
    var _loot_amount = difficulty_get("npc_loot_amount");
    if (_loot_amount <= 0)
    {
        return _plan;
    }
    var _rules = ai_loot_rules(arg2, arg3);
    var _budget = ai_loot_budget(arg0, arg2, _rules);
    var _spare_equipment_max = _rules.spare_equipment_max;
    var _overlook_chance = ai_loot_overlook_chance(arg0, arg2);
    var _bag = ai_loot_bag(arg0);
    var _spares_planned = 
    {
        weapon: 0,
        armor: 0,
        backpack: 0
    };
    var _wounded = arg4 && ai_loot_npc_has(arg0, "hp") && ai_loot_npc_has(arg0, "npc_id") && arg0.hp < ((npc_get_hp(arg0.npc_id) * difficulty_get("enemy_human_hp") * arg2.heal_below_hp_percent) / 100);
    for (var _index = 0; _index < array_length(arg1); _index++)
    {
        var _loot = arg1[_index];
        if (!is_struct(_loot) || !item_exists(_loot.item) || _loot.quantity <= 0)
        {
            continue;
        }
        var _item = _loot.item;
        var _category = item_get_category(_item);
        if (ai_loot_is_never_taken(_rules, _item))
        {
            continue;
        }
        var _priority = ai_loot_priority_index(_rules, _category);
        if (ai_loot_is_equipment(_category))
        {
            var _wanted = _priority >= 0 && ai_loot_amount_allows(_loot_amount);
            var _spares = ai_loot_bag_count_category(_bag, _category) + variable_struct_get(_spares_planned, _category);
            if (_wanted && _spares < _spare_equipment_max)
            {
                array_push(_plan, 
                {
                    kind: "take",
                    loot: _loot,
                    category: _category,
                    priority: _priority,
                    value: ai_loot_value_per_weight(_loot)
                });
                variable_struct_set(_spares_planned, _category, _spares + 1);
                continue;
            }
            if (_wanted)
            {
                var _worst_index = ai_loot_bag_worst_index(_bag, _category);
                if (_worst_index >= 0 && loot_get_value(_loot) > loot_get_value(_bag[_worst_index]) && ai_loot_same_footprint(_item, _bag[_worst_index].item))
                {
                    array_push(_plan, 
                    {
                        kind: "swap",
                        loot: _loot,
                        category: _category,
                        priority: _priority,
                        bag_index: _worst_index,
                        value: ai_loot_value_per_weight(_loot)
                    });
                    continue;
                }
            }
            if (_category == "weapon" && is_struct(struct_get_from_hash(_loot, variable_get_hash("mods"))))
            {
                ai_loot_plan_weapon_mods(_plan, _rules, _loot, _loot_amount);
            }
        }
        else if (_priority < 0)
        {
        }
        else if (_category == "ammo" && !ai_loot_wants_ammo(arg0, _rules, _item))
        {
        }
        else if (item_get_weight(_item) > _rules.max_item_weight)
        {
        }
        else if (_overlook_chance > 0 && scr_chance(_overlook_chance))
        {
        }
        else
        {
            var _kind = "take";
            if (_wounded && _category == "medication" && item_med_get_hp(_item) > 0)
            {
                _kind = "use";
                _wounded = false;
            }
            array_push(_plan, 
            {
                kind: _kind,
                loot: _loot,
                category: _category,
                priority: _priority,
                value: ai_loot_value_per_weight(_loot)
            });
        }
    }
    array_sort(_plan, function(arg0, arg1)
    {
        if (arg0.priority != arg1.priority)
        {
            return arg0.priority - arg1.priority;
        }
        return arg1.value - arg0.value;
    });
    var _kept = [];
    for (var _index = 0; _index < array_length(_plan); _index++)
    {
        var _entry = _plan[_index];
        var _counts = _entry.kind == "take" && !ai_loot_is_equipment(_entry.category);
        if (_counts)
        {
            if (_budget <= 0)
            {
                continue;
            }
            _budget--;
        }
        array_push(_kept, _entry);
    }
    return _kept;
}

function ai_loot_mod_can_come_off(arg0, arg1)
{
    if (!is_struct(struct_get_from_hash(arg0, variable_get_hash("mods"))))
    {
        return false;
    }
    if (!array_contains(global.moddable_pos_in_raid, arg1))
    {
        return false;
    }
    if (!loot_mod_cont_exists(arg0.mods, arg1))
    {
        return false;
    }
    if (!loot_weapon_get_position_moddable(arg0, arg1))
    {
        return false;
    }
    if (item_weapon_pos_get_needed(arg0.item, arg1))
    {
        return false;
    }
    var _mods_after = loot_mod_cont_duplicate(arg0.mods);
    loot_mod_cont_delete(_mods_after, arg1);
    return item_weapon_can_fire(arg0.item, _mods_after);
}

function ai_loot_amount_allows(arg0)
{
    return arg0 >= 1 || (arg0 > 0 && scr_chance(arg0 * 100));
}

function ai_loot_plan_weapon_mods(arg0, arg1, arg2, arg3 = 1)
{
    var _priority = ai_loot_priority_index(arg1, "w_mod");
    if (_priority < 0)
    {
        exit;
    }
    var _positions = global.moddable_pos_in_raid;
    for (var _index = 0; _index < array_length(_positions); _index++)
    {
        var _mod_pos = _positions[_index];
        if (!ai_loot_mod_can_come_off(arg2, _mod_pos))
        {
            continue;
        }
        if (!ai_loot_amount_allows(arg3))
        {
            continue;
        }
        var _mod_item = loot_mod_cont_get(arg2.mods, _mod_pos);
        if (ai_loot_is_never_taken(arg1, _mod_item) || item_get_weight(_mod_item) > arg1.max_item_weight)
        {
            continue;
        }
        array_push(arg0, 
        {
            kind: "mod",
            loot: arg2,
            mod_pos: _mod_pos,
            item: _mod_item,
            category: "w_mod",
            priority: _priority,
            value: item_get_value(_mod_item) / max(0.1, item_get_weight(_mod_item))
        });
    }
}

function ai_loot_plan_item_ids(arg0)
{
    var _ids = [];
    for (var _index = 0; _index < array_length(arg0); _index++)
    {
        var _entry = arg0[_index];
        array_push(_ids, (_entry.kind == "mod") ? _entry.item : _entry.loot.item);
    }
    return _ids;
}

function ai_loot_plan_keep_ids(arg0, arg1)
{
    if (!is_array(arg1))
    {
        return arg0;
    }
    var _remaining = variable_clone(arg1);
    var _kept = [];
    for (var _index = 0; _index < array_length(arg0); _index++)
    {
        var _entry = arg0[_index];
        var _item = (_entry.kind == "mod") ? _entry.item : _entry.loot.item;
        var _found = -1;
        for (var _id_index = 0; _id_index < array_length(_remaining); _id_index++)
        {
            if (_remaining[_id_index] == _item)
            {
                _found = _id_index;
                break;
            }
        }
        if (_found < 0)
        {
            continue;
        }
        array_delete(_remaining, _found, 1);
        array_push(_kept, _entry);
    }
    return _kept;
}

function ai_loot_struct_for_bag(arg0)
{
    var _copy = loot_duplicate(arg0);
    _copy.x = 0;
    _copy.y = 0;
    _copy.rotation = 0;
    _copy.placement = "other inventory";
    return _copy;
}

function ai_loot_apply_entry(arg0, arg1, arg2)
{
    var _bag = ai_loot_bag(arg0);
    var _loot = arg2.loot;
    switch (arg2.kind)
    {
        case "take":
            if (!item_exists(_loot.item) || _loot.quantity <= 0)
            {
                return "";
            }
            var _taken_item = _loot.item;
            array_push(_bag, ai_loot_struct_for_bag(_loot));
            loot_clear(_loot);
            return _taken_item;
        case "swap":
            if (!item_exists(_loot.item) || _loot.quantity <= 0 || arg2.bag_index >= array_length(_bag))
            {
                return "";
            }
            var _lesser = _bag[arg2.bag_index];
            if (!is_struct(_lesser) || !item_exists(_lesser.item))
            {
                return "";
            }
            var _taken = ai_loot_struct_for_bag(_loot);
            _lesser.x = _loot.x;
            _lesser.y = _loot.y;
            _lesser.rotation = _loot.rotation;
            _lesser.placement = _loot.placement;
            loot_clear(_loot);
            _bag[arg2.bag_index] = _taken;
            arg2.discarded = _lesser;
            return _taken.item;
        case "mod":
            if (!ai_loot_mod_can_come_off(_loot, arg2.mod_pos))
            {
                return "";
            }
            var _mod_item = loot_mod_cont_get(_loot.mods, arg2.mod_pos);
            var _mod_loot = new class_loot(_mod_item, 1, 0, 0, 0, "other inventory");
            loot_set_from_chest(_mod_loot, false, 100, false);
            loot_mod_cont_delete(_loot.mods, arg2.mod_pos);
            array_push(_bag, _mod_loot);
            return _mod_item;
        case "use":
            if (!item_exists(_loot.item) || _loot.quantity <= 0)
            {
                return "";
            }
            var _max_hp = npc_get_hp(arg0.npc_id) * difficulty_get("enemy_human_hp");
            arg0.hp = min(_max_hp, arg0.hp + item_med_get_hp(_loot.item));
            var _used_item = _loot.item;
            _loot.quantity -= 1;
            if (_loot.quantity <= 0)
            {
                loot_clear(_loot);
            }
            return _used_item;
    }
    return "";
}

function ai_loot_body_items(arg0)
{
    db_open("all loot");
    var _items = db_read("chest_" + string(arg0), "items", undefined);
    db_close();
    return is_array(_items) ? _items : [];
}

function ai_loot_body_write_items(arg0, arg1)
{
    db_open("all loot");
    db_write("chest_" + string(arg0), "items", arg1);
    db_close();
}

function ai_loot_body_plan(arg0, arg1, arg2, arg3)
{
    return ai_loot_plan(arg0, ai_loot_body_items(arg1), arg2, arg3, true);
}

function ai_loot_body_take(arg0, arg1, arg2)
{
    var _items = ai_loot_body_items(arg1);
    if (array_length(_items) == 0)
    {
        return false;
    }
    var _slot = array_get_index(_items, arg2.loot);
    if (_slot < 0)
    {
        return false;
    }
    var _moved = ai_loot_apply_entry(arg0, _items, arg2);
    if (_moved == "")
    {
        return false;
    }
    var _discarded = struct_get_from_hash(arg2, variable_get_hash("discarded"));
    if (is_struct(_discarded) && array_length(ai_loot_discard_near_body(arg1, [_discarded])) > 0)
    {
        _items[_slot] = _discarded;
    }
    ai_loot_body_write_items(arg1, _items);
    return true;
}

function ai_loot_discard_near_body(arg0, arg1)
{
    if (!instance_exists(arg0) || !is_array(arg1) || array_length(arg1) == 0)
    {
        return arg1;
    }
    var _pile = -4;
    if (variable_instance_exists(arg0, "discard_pile") && arg0.discard_pile != -4)
    {
        instance_activate_object(arg0.discard_pile);
        if (instance_exists(arg0.discard_pile))
        {
            _pile = arg0.discard_pile;
        }
    }
    var _pile_items = (_pile != -4) ? ai_loot_body_items(_pile) : [];
    var _grid = new class_loot_grid(8, 11);
    _grid.PlaceFromInventoryLootArray(_pile_items);
    var _unplaced = [];
    var _placed_count = 0;
    for (var _index = 0; _index < array_length(arg1); _index++)
    {
        var _loot = arg1[_index];
        if (!is_struct(_loot) || !item_exists(_loot.item) || _loot.quantity <= 0)
        {
            continue;
        }
        var _position = _grid.TryPlace(_loot.item);
        if (!is_struct(_position) || _position.rot != 0)
        {
            array_push(_unplaced, _loot);
        }
        else
        {
            _loot.x = 16 * _position.x;
            _loot.y = 16 * _position.y;
            _loot.rotation = 0;
            _loot.placement = "other inventory";
            _grid.Place(_position.x, _position.y, _loot);
            array_push(_pile_items, _loot);
            _placed_count++;
        }
    }
    _grid.Destroy();
    if (_placed_count == 0)
    {
        return _unplaced;
    }
    if (_pile == -4)
    {
        var _spot = ai_roaming_pick_cell_near(arg0.x, arg0.y, 16, 32);
        if (is_undefined(_spot))
        {
            _spot = 
            {
                x: arg0.x + 8,
                y: arg0.y
            };
        }
        _pile = instance_create_depth(_spot.x, _spot.y, -_spot.y, obj_chest_general);
        _pile.tipo = "discard";
        arg0.discard_pile = _pile;
    }
    db_open("all loot");
    var _pile_name = "chest_" + string(_pile);
    db_write(_pile_name, "chest_x", _pile.x);
    db_write(_pile_name, "chest_y", _pile.y);
    db_write(_pile_name, "items", _pile_items);
    db_close();
    return _unplaced;
}

function ai_loot_struct_from_equipment(arg0, arg1)
{
    var _loot = new class_loot(arg1, 1, 0, 0, 0, "other inventory");
    var _category = item_get_category(arg1);
    if (_category == "weapon")
    {
        var _mods = loot_mod_cont_create();
        if (ai_loot_npc_has(arg0, "mod_container") && is_struct(arg0.mod_container))
        {
            loot_mod_cont_copy_to(arg0.mod_container, _mods);
        }
        if (!item_weapon_can_fire(arg1, _mods))
        {
            loot_mod_cont_copy_from_default(_mods, arg1);
        }
        var _ammo = ai_loot_npc_has(arg0, "ammo_id_now") ? arg0.ammo_id_now : "no_item";
        if (!item_exists(_ammo) || item_ammo_get_caliber(_ammo) != item_weapon_get_caliber(arg1))
        {
            _ammo = item_weapon_get_ammo(arg1);
        }
        loot_set_from_chest(_loot, false, irandom_range(difficulty_get("loot_weapon_dur_min"), difficulty_get("loot_weapon_dur_max")), false);
        loot_add_weapon_data(_loot, _ammo, irandom(item_weapon_get_magazine(arg1) div 2), item_weapon_get_fire_mode(arg1), _mods);
    }
    else if (_category == "armor")
    {
        var _durability = armor_get_durability_on_drop(arg1);
        loot_set_from_chest(_loot, false, irandom_range(_durability.minimum, _durability.maximum), false);
    }
    else
    {
        loot_set_from_chest(_loot, false, 100, false);
    }
    return _loot;
}

function ai_loot_take_from_npc(arg0, arg1, arg2, arg3)
{
    var _gone = 
    {
        weapon: false,
        armor: false,
        backpack: false
    };
    var _candidates = [];
    var _equipment = [];
    if (ai_loot_npc_has(arg1, "arma_now") && item_exists(arg1.arma_now) && item_get_category(arg1.arma_now) == "weapon")
    {
        var _weapon = ai_loot_struct_from_equipment(arg1, arg1.arma_now);
        array_push(_candidates, _weapon);
        array_push(_equipment, _weapon);
    }
    if (ai_loot_npc_has(arg1, "armor_id") && item_exists(arg1.armor_id) && item_get_category(arg1.armor_id) == "armor")
    {
        if (scr_chance(armor_get_chance_to_drop(arg1.armor_id)))
        {
            var _armor = ai_loot_struct_from_equipment(arg1, arg1.armor_id);
            array_push(_candidates, _armor);
            array_push(_equipment, _armor);
        }
        else
        {
            _gone.armor = true;
        }
    }
    if (ai_loot_npc_has(arg1, "backpack_now") && item_exists(arg1.backpack_now) && item_get_category(arg1.backpack_now) == "backpack")
    {
        var _backpack = ai_loot_struct_from_equipment(arg1, arg1.backpack_now);
        array_push(_candidates, _backpack);
        array_push(_equipment, _backpack);
    }
    var _loser_bag = ai_loot_bag(arg1);
    for (var _index = 0; _index < array_length(_loser_bag); _index++)
    {
        array_push(_candidates, _loser_bag[_index]);
    }
    var _plan = ai_loot_plan(arg0, _candidates, arg2, arg3, false);
    for (var _index = 0; _index < array_length(_plan); _index++)
    {
        var _entry = _plan[_index];
        var _was_equipment = array_contains(_equipment, _entry.loot);
        var _bag_slot = array_get_index(_loser_bag, _entry.loot);
        var _moved = ai_loot_apply_entry(arg0, _candidates, _entry);
        if (_moved == "")
        {
            continue;
        }
        switch (_entry.kind)
        {
            case "take":
            case "swap":
                if (_was_equipment)
                {
                    variable_struct_set(_gone, _entry.category, true);
                }
                if (_bag_slot >= 0)
                {
                    array_delete(_loser_bag, _bag_slot, 1);
                }
                if (_entry.kind == "swap" && is_struct(struct_get_from_hash(_entry, variable_get_hash("discarded"))))
                {
                    array_push(ai_loot_discarded(arg1), _entry.discarded);
                }
                break;
            case "mod":
                if (_was_equipment && ai_loot_npc_has(arg1, "mod_container") && is_struct(arg1.mod_container))
                {
                    loot_mod_cont_delete(arg1.mod_container, _entry.mod_pos);
                }
                break;
        }
    }
    return _gone;
}
