function dev_log(arg0)
{
    trace("[dev] ", arg0);
    var _f = file_text_open_append("dev/out.txt");
    file_text_write_string(_f, arg0);
    file_text_writeln(_f);
    file_text_close(_f);
}

function dev_slot_info(arg0)
{
    switch (arg0)
    {
        case "w1":
            return 
            {
                pos: "weapon slot 1",
                placement: "weapon slot 1"
            };
        case "w2":
            return 
            {
                pos: "weapon slot 2",
                placement: "weapon slot 2"
            };
        case "armor":
            return 
            {
                pos: "armor slot",
                placement: "armor slot"
            };
        case "headset":
            return 
            {
                pos: "headset slot",
                placement: "headset slot"
            };
        case "backpack":
            return 
            {
                pos: "backpack slot",
                placement: "backpack slot"
            };
        case "q1":
            return 
            {
                pos: "quick slot 1",
                placement: "quick slot 1"
            };
        case "q2":
            return 
            {
                pos: "quick slot 2",
                placement: "quick slot 2"
            };
        case "q3":
            return 
            {
                pos: "quick slot 3",
                placement: "quick slot 3"
            };
        case "q4":
            return 
            {
                pos: "quick slot 4",
                placement: "quick slot 4"
            };
        case "q5":
            return 
            {
                pos: "quick slot 5",
                placement: "quick slot 5"
            };
        case "q6":
            return 
            {
                pos: "quick slot 6",
                placement: "quick slot 6"
            };
    }
    return undefined;
}

function dev_slot_is_empty(arg0)
{
    return player_loadout_get_loot(player_get_local(), arg0.placement) == undefined;
}

function dev_item_known(arg0)
{
    return is_string(arg0) && is_struct(variable_struct_get(global.item_data, arg0));
}

function dev_give(arg0, arg1)
{
    if (!dev_item_known(arg0))
    {
        dev_log("ERR give: unknown item '" + string(arg0) + "' (see docs/ITEMS.md)");
        return false;
    }
    if (!player_exists_local())
    {
        dev_log("ERR give: no player");
        return false;
    }
    if (__uiGlobal().__defaultOnion.LayerExists("inventory layer"))
    {
        dev_log("ERR give: the inventory screen is open, close it first");
        return false;
    }
    inventory_add_item(arg0, arg1);
    player_init_load_items();
    dev_log("OK give " + arg0 + " x" + string(arg1));
    return true;
}

function dev_find_bag_element(arg0)
{
    var _root = uiLayerGetRoot("inventory layer");
    var _elements = uiFindAllType(_root, "class_ui_item");
    var _found = undefined;
    for (var i = 0; i < array_length(_elements); i++)
    {
        var _parent = _elements[i].Get("parent");
        if (is_struct(_parent) && _parent.identifier == "player inventory" && _elements[i].__lootStruct.item == arg0)
        {
            _found = _elements[i];
        }
    }
    return _found;
}

function dev_ui_place(arg0, arg1, arg2)
{
    var _slot = uiFind(uiLayerGetRoot("inventory layer"), arg1);
    if (instanceof(_slot) == "class_ui_item_slot")
    {
        if (_slot.HasChildren())
        {
            var _old = _slot.__children[0];
            if (_old.AutoPlace(arg2, true, true) == true)
            {
                _old.__lootStruct.placement = "player inventory";
            }
        }
        var _ok = _slot.AutoPlace(arg0);
        if (_ok)
        {
            ui_inventory_check_weight();
        }
        return _ok == true;
    }
    var _grid_ok = arg0.AutoPlace(_slot, false, false) == true;
    if (_grid_ok)
    {
        arg0.__lootStruct.placement = arg1;
    }
    return _grid_ok;
}

function dev_uiprobe(arg0)
{
    if (!dev_inventory_screen_open_for_probe())
    {
        exit;
    }
    var _root = uiLayerGetRoot("inventory layer");
    var _el = uiFindRelaxed(_root, arg0, true);
    if (_el == undefined)
    {
        dev_log("probe '" + arg0 + "': not found");
    }
    else
    {
        var _has_auto = false;
        var _has_find = false;
        var _has_children = false;
        try
        {
            var _f = _el.AutoPlace;
            _has_auto = true;
        }
        catch (_e)
        {
        }
        try
        {
            var _f2 = _el.FindEmptyPlace;
            _has_find = true;
        }
        catch (_e)
        {
        }
        try
        {
            var _f3 = _el.HasChildren;
            _has_children = true;
        }
        catch (_e)
        {
        }
        dev_log("probe '" + arg0 + "': " + instanceof(_el) + " AutoPlace=" + string(_has_auto) + " FindEmptyPlace=" + string(_has_find) + " HasChildren=" + string(_has_children) + " names=" + json_stringify(variable_struct_get_names(_el)));
    }
    ui_inventory_close_all();
}

function dev_inventory_screen_open_for_probe()
{
    if (__uiGlobal().__defaultOnion.LayerExists("inventory layer"))
    {
        dev_log("ERR the inventory screen is open");
        return false;
    }
    player_action_open_inventory();
    return true;
}

function dev_equip(arg0, arg1 = "", arg2 = [])
{
    if (!dev_item_known(arg0))
    {
        dev_log("ERR equip: unknown item '" + string(arg0) + "' (see docs/ITEMS.md)");
        return false;
    }
    if (!player_exists_local())
    {
        dev_log("ERR equip: no player");
        return false;
    }
    if (__uiGlobal().__defaultOnion.LayerExists("inventory layer"))
    {
        dev_log("ERR equip: the inventory screen is open, close it first");
        return false;
    }
    var _category = item_get_category(arg0);
    var _info = (arg1 != "") ? dev_slot_info(arg1) : undefined;
    if (arg1 != "" && _info == undefined)
    {
        dev_log("ERR equip: unknown slot '" + arg1 + "' (w1 w2 armor headset backpack q1..q6)");
        return false;
    }
    inventory_add_item(arg0, 1);
    player_action_open_inventory();
    var _element = dev_find_bag_element(arg0);
    if (_element == undefined)
    {
        ui_inventory_close_all();
        dev_log("ERR equip: " + arg0 + " did not fit in the inventory");
        return false;
    }
    for (var m = 0; m < array_length(arg2); m++)
    {
        var _positions = item_mod_get_position_array(arg2[m]);
        if (item_mod_fits_weapon(arg2[m], arg0) && is_array(_positions) && array_length(_positions) > 0)
        {
            loot_weapon_mod_attach(_element.__lootStruct, arg2[m], _positions[0]);
        }
        else
        {
            dev_log("WARN equip: mod " + string(arg2[m]) + " does not fit " + arg0);
        }
    }
    if (_category == "weapon")
    {
        _element.__lootStruct.ammo_quantity = loot_weapon_get_magazine(_element.__lootStruct, true);
    }
    var _root = uiLayerGetRoot("inventory layer");
    var _placed = false;
    var _bag = uiFind(_root, "player inventory");
    if (_info != undefined)
    {
        _placed = dev_ui_place(_element, _info.placement, _bag);
    }
    else if (_category == "consumable" || _category == "medication" || _category == "injector" || _category == "grenade")
    {
        for (var q = 1; q <= 6 && !_placed; q++)
        {
            _placed = dev_ui_place(_element, dev_slot_info("q" + string(q)).placement, _bag);
        }
    }
    else
    {
        uiOpenExisting(_root);
        _element.__quickMove = true;
        _element.quick_move_sort();
        uiClose();
        _placed = _element.Get("parent").identifier != "player inventory";
    }
    ui_inventory_close_all();
    if (_placed && _category == "weapon")
    {
        inventory_add_item(item_weapon_get_ammo(arg0), 120);
        player_init_load_items();
    }
    dev_log(_placed ? ("OK equip " + arg0 + " -> " + ((_info != undefined) ? arg1 : "auto")) : ("ERR equip: the game would not place " + arg0 + " there"));
    return _placed;
}

function dev_mod(arg0, arg1, arg2 = undefined)
{
    var _info = dev_slot_info(arg0);
    if (_info == undefined)
    {
        dev_log("ERR mod: unknown slot '" + arg0 + "'");
        return false;
    }
    if (!dev_item_known(arg1))
    {
        dev_log("ERR mod: unknown item '" + string(arg1) + "'");
        return false;
    }
    if (!player_exists_local())
    {
        dev_log("ERR mod: no player");
        return false;
    }
    var _loot = player_loadout_get_loot(player_get_local(), _info.placement);
    if (_loot == undefined)
    {
        dev_log("ERR mod: nothing equipped in " + arg0);
        return false;
    }
    if (!item_mod_fits_weapon(arg1, _loot.item))
    {
        dev_log("ERR mod: " + arg1 + " does not fit " + _loot.item);
        return false;
    }
    if (arg2 == undefined)
    {
        var _positions = item_mod_get_position_array(arg1);
        if (!is_array(_positions) || array_length(_positions) == 0)
        {
            dev_log("ERR mod: " + arg1 + " has no mod position");
            return false;
        }
        arg2 = _positions[0];
    }
    if (loot_weapon_mod_attach(_loot, arg1, arg2) == false)
    {
        dev_log("ERR mod: weapon in " + arg0 + " cannot take mods");
        return false;
    }
    player_init_load_items();
    dev_log("OK mod " + arg1 + " -> " + _loot.item + " (" + arg0 + ", position " + string(arg2) + ")");
    return true;
}

function dev_queue_push(arg0)
{
    if (!variable_global_exists("dev_queue"))
    {
        global.dev_queue = [];
    }
    array_push(global.dev_queue, arg0);
}

function dev_queue_step()
{
    if (!variable_global_exists("dev_queue") || array_length(global.dev_queue) == 0)
    {
        exit;
    }
    if (__uiGlobal().__defaultOnion.LayerExists("inventory layer"))
    {
        exit;
    }
    var _line = global.dev_queue[0];
    array_delete(global.dev_queue, 0, 1);
    dev_exec(_line);
}

function dev_default_loadout()
{
    var _path = "dev/loadout.txt";
    if (file_exists(_path))
    {
        dev_run_file(_path, false);
        exit;
    }
    dev_queue_push("equip ak_74 w1");
    dev_queue_push("equip makarov w2");
    dev_queue_push("equip armor_loner_1");
    dev_queue_push("equip backpack1");
    dev_queue_push("equip bandage q1");
    dev_queue_push("equip bread q2");
}

function dev_dump_inventory()
{
    db_open(inventory_target_db());
    var _items = db_read("Inventory", "items", []);
    db_close();
    for (var i = 0; i < array_length(_items); i++)
    {
        var _l = _items[i];
        var _mods = (variable_struct_exists(_l, "mods") && is_struct(_l.mods)) ? json_stringify(_l.mods) : "-";
        dev_log("loot " + string(_l.item) + " placement='" + string(_l.placement) + "' x=" + string(_l.x) + " y=" + string(_l.y) + " rot=" + string(_l.rotation) + " qty=" + string(_l.quantity) + " mods=" + _mods);
    }
    dev_log("OK inv " + string(array_length(_items)));
}

function dev_dump_npcs()
{
    var _count = 0;
    var _player = player_exists_local() ? player_get_local() : -4;
    with (obj_npc_parent)
    {
        var _rel = scr_get_relation(faction, "Player");
        var _alert = variable_instance_exists(id, "alert_player") ? (string(alert_player) + "/" + string(alert_player_max)) : "-";
        var _state = variable_instance_exists(id, "human_state_now") ? string(human_state_now) : "-";
        var _dist = (_player != -4) ? string(round(point_distance(x, y, _player.x, _player.y))) : "-";
        dev_log("npc " + object_get_name(object_index) + " x=" + string(round(x)) + " y=" + string(round(y)) + " faction=" + string(faction) + " relation=" + string(_rel) + " alert=" + _alert + " state=" + _state + " dist=" + _dist);
        _count++;
    }
    dev_log("OK npcs " + string(_count));
}

function dev_exec(arg0)
{
    var _a = string_split(string_trim(arg0), " ", true);
    if (array_length(_a) == 0)
    {
        exit;
    }
    var _cmd = string_lower(_a[0]);
    switch (_cmd)
    {
        case "ping":
            dev_log("OK pong " + room_get_name(room));
            break;
        case "give":
            if (array_length(_a) < 2)
            {
                dev_log("ERR give: usage give <item_id> [qty]");
            }
            else
            {
                dev_give(_a[1], (array_length(_a) > 2) ? real(_a[2]) : 1);
            }
            break;
        case "equip":
            if (array_length(_a) < 2)
            {
                dev_log("ERR equip: usage equip <item_id> [slot]");
            }
            else
            {
                dev_equip(_a[1], (array_length(_a) > 2) ? _a[2] : "");
            }
            break;
        case "mod":
            if (array_length(_a) < 3)
            {
                dev_log("ERR mod: usage mod <slot> <mod_id> [position]");
            }
            else
            {
                dev_mod(_a[1], _a[2], (array_length(_a) > 3) ? _a[3] : undefined);
            }
            break;
        case "loadout":
            dev_default_loadout();
            break;
        case "tp":
            if (array_length(_a) < 3 || !player_exists_local())
            {
                dev_log("ERR tp: usage tp <x> <y> (needs a player)");
                break;
            }
            var _tx = real(_a[1]);
            var _ty = real(_a[2]);
            if (collision_rectangle(_tx - 8, _ty - 8, _tx + 8, _ty + 8, obj_solid, false, true) != -4)
            {
                dev_log("ERR tp: " + _a[1] + "," + _a[2] + " is inside a solid");
                break;
            }
            with (player_get_local())
            {
                x = _tx;
                y = _ty;
            }
            dev_log("OK tp " + _a[1] + " " + _a[2]);
            break;
        case "stamina":
            if (array_length(_a) < 2 || !player_exists_local())
            {
                dev_log("ERR stamina: usage stamina <value> (needs a player)");
                break;
            }
            with (player_get_local())
            {
                stamina = clamp(real(_a[1]), 0, stamina_max);
            }
            dev_log("OK stamina " + _a[1]);
            break;
        case "ghost":
            global.dev_player_invisible = !(array_length(_a) > 1 && string_lower(_a[1]) == "off");
            dev_log("OK ghost " + (global.dev_player_invisible ? "on (NPCs cannot perceive the player)" : "off"));
            break;
        case "lootdemo":
            if (!player_exists_local())
            {
                dev_log("ERR lootdemo: needs a player");
                break;
            }
            var _lx = (array_length(_a) > 2) ? real(_a[1]) : (player_get_local().x + 64);
            var _ly = (array_length(_a) > 2) ? real(_a[2]) : (player_get_local().y - 48);
            global.dev_player_invisible = true;
            var _looter = instance_create_depth(_lx, _ly, -_ly, obj_bandit_preset_rookie);
            _looter.backpack_now = (array_length(_a) > 3) ? _a[3] : "backpack_cc_2";
            ai_roaming_roster_add(
            {
                npc: _looter
            });
            var _victim = instance_create_depth(_lx + 40, _ly + 16, -(_ly + 16), obj_bandit_preset_rookie);
            global.dev_lootdemo_last = _looter;
            global.dev_lootdemo = 
            {
                looter: _looter,
                victim: _victim,
                polls_left: 60,
                killed: false,
                hold_polls_left: 1800,
                grace_polls: 60
            };
            dev_log("OK lootdemo looter=" + string(_looter) + " victim=" + string(_victim) + " at " + string(round(_lx)) + "," + string(round(_ly)) + " (victim is killed by the looter in ~1 s)");
            break;
        case "lootdebug":
            var _dl = variable_global_exists("dev_lootdemo_last") ? global.dev_lootdemo_last : -4;
            dev_log("lootdebug roaming_enabled=" + string(global.roaming_enabled) + " npc_loot_bodies=" + string(difficulty_get("npc_loot_bodies")) + " looting_enabled=" + string(ai_roaming_looting_enabled()) + " claims=" + string(array_length(ai_roaming_state().claims)));
            if (instance_exists(_dl))
            {
                dev_log("lootdebug looter " + string(_dl) + " roaming_group_id=" + (variable_instance_exists(_dl, "roaming_group_id") ? string(_dl.roaming_group_id) : "MISSING") + " roster=" + (variable_instance_exists(_dl, "ai_roster_index") ? string(_dl.ai_roster_index) : "MISSING") + " faction=" + (variable_instance_exists(_dl, "faction") ? string(_dl.faction) : "MISSING") + " has_tree=" + string(ai_roaming_npc_has_behaviour_tree(_dl)) + " owner_record=" + string(!is_undefined(ai_roaming_claim_owner_for(_dl))));
            }
            else
            {
                dev_log("lootdebug looter gone or none spawned");
            }
            with (obj_chest_general)
            {
                dev_log("lootdebug body " + string(id) + " at " + string(round(x)) + "," + string(round(y)) + " claim_index=" + string(ai_roaming_claim_find(id)) + " killer=" + string(variable_instance_exists(id, "id_of_the_killer") ? id_of_the_killer : "-"));
            }
            break;
        case "npcloot":
            var _n_loot = 0;
            with (obj_npc_human_parent)
            {
                var _bag_items = "";
                var _bag_loot = ai_loot_bag(id);
                for (var _b = 0; _b < array_length(_bag_loot); _b++)
                {
                    _bag_items += (((_b > 0) ? ", " : "") + string(_bag_loot[_b].item));
                }
                dev_log("npcloot " + object_get_name(object_index) + " " + string(id) + " bag=" + string(array_length(_bag_loot)) + " fat=" + string(ai_loot_backpack_is_fat(id)) + " backpack=" + string(backpack_now) + " [" + _bag_items + "]");
                _n_loot++;
            }
            dev_log("OK npcloot " + string(_n_loot) + " (fat at >= " + "3" + " items)");
            break;
        case "remove":
            if (array_length(_a) < 2)
            {
                dev_log("ERR remove: usage remove <item_id> [qty]");
            }
            else
            {
                inventory_remove_item(_a[1], (array_length(_a) > 2) ? real(_a[2]) : 9999);
                dev_log("OK remove " + _a[1]);
            }
            break;
        case "weight":
            if (!player_exists_local())
            {
                dev_log("ERR weight: needs a player");
                break;
            }
            with (player_get_local())
            {
                dev_log("OK weight " + string(player_weight) + " / " + string(max_weight) + ((player_weight > max_weight) ? " OVERBURDENED" : " ok"));
            }
            break;
        case "watch":
            global.dev_watch_left = (array_length(_a) > 1) ? real(_a[1]) : 120;
            dev_log("OK watch " + string(global.dev_watch_left) + " frames");
            break;
        case "uiprobe":
            dev_uiprobe(string_delete(string_trim(arg0), 1, 8));
            break;
        case "inv":
            dev_dump_inventory();
            break;
        case "npcs":
            dev_dump_npcs();
            break;
        case "npcvis":
            var _hidden = variable_global_exists("dev_hide_npcs") && global.dev_hide_npcs;
            var _mode = (array_length(_a) > 1) ? string_lower(_a[1]) : "toggle";
            if (_mode == "on")
            {
                _hidden = false;
            }
            else if (_mode == "off")
            {
                _hidden = true;
            }
            else
            {
                _hidden = !_hidden;
            }
            global.dev_hide_npcs = _hidden;
            dev_log("OK npcvis " + (_hidden ? "off (fog of war applies, NPCs only visible in the cone / line of sight)" : "on (NPCs always visible)"));
            break;
        case "aggro":
            var _n = 0;
            with (obj_npc_parent)
            {
                npc_force_moving_towards_player();
                _n++;
            }
            dev_log("OK aggro " + string(_n) + " npcs");
            break;
        case "shot":
            var _name = (array_length(_a) > 1) ? _a[1] : "shot";
            screen_save("dev/" + _name + ".png");
            dev_log("OK shot " + _name);
            break;
        default:
            dev_log("ERR unknown command '" + _cmd + "'");
    }
}

function dev_run_file(arg0, arg1)
{
    var _lines = [];
    var _f = file_text_open_read(arg0);
    while (!file_text_eof(_f))
    {
        array_push(_lines, file_text_read_string(_f));
        file_text_readln(_f);
    }
    file_text_close(_f);
    if (arg1)
    {
        file_delete(arg0);
    }
    for (var i = 0; i < array_length(_lines); i++)
    {
        var _l = string_trim(_lines[i]);
        if (_l == "" || string_char_at(_l, 1) == "#")
        {
            continue;
        }
        dev_queue_push(_l);
    }
}

function dev_lootdemo_step()
{
    if (variable_global_exists("dev_lootdemo") && is_struct(global.dev_lootdemo))
    {
        var _demo = global.dev_lootdemo;
        if (!_demo.killed)
        {
            if (--_demo.polls_left <= 0)
            {
                _demo.killed = true;
                if (instance_exists(_demo.victim) && instance_exists(_demo.looter))
                {
                    npc_damage(_demo.victim, 999999, _demo.looter);
                    dev_log("lootdemo: victim " + string(_demo.victim) + " killed by looter " + string(_demo.looter));
                }
                else
                {
                    dev_log("lootdemo: looter or victim is gone, nothing killed");
                    global.dev_lootdemo = undefined;
                }
            }
        }
        else
        {
            var _roaming_demo = ai_roaming_state();
            _roaming_demo.step_count++;
            _roaming_demo.player_x = undefined;
            ai_roaming_claims_step(_roaming_demo);
            var _claims_demo = _roaming_demo.claims;
            var _held = false;
            for (var _c = 0; _c < array_length(_claims_demo); _c++)
            {
                if (instance_exists(_demo.looter) && _claims_demo[_c].owner_member.npc == _demo.looter)
                {
                    _demo.looter.x = _claims_demo[_c].body_x;
                    _demo.looter.y = _claims_demo[_c].body_y;
                    _held = true;
                }
            }
            if (_held)
            {
                _demo.grace_polls = 0;
            }
            else if (_demo.grace_polls > 0)
            {
                _demo.grace_polls--;
                _held = true;
            }
            if (!_held || --_demo.hold_polls_left <= 0)
            {
                dev_log("lootdemo: done (claim finished or hold timed out)");
                global.dev_lootdemo = undefined;
            }
        }
    }
}

function dev_bridge_poll()
{
    if (variable_global_exists("dev_watch_left") && global.dev_watch_left > 0 && player_exists_local())
    {
        global.dev_watch_left--;
        with (player_get_local())
        {
            dev_log("w stamina=" + string_format(stamina, 1, 2) + " spd=" + string_format(current_spd, 1, 3) + " active=" + string(sprint_is_active) + " exh=" + string(sprint_exhausted_timer) + " x=" + string_format(x, 1, 1) + " y=" + string_format(y, 1, 1));
        }
    }
    var _path = "dev/cmd.txt";
    if (file_exists(_path))
    {
        dev_run_file(_path, true);
    }
}

function dev_launch_room()
{
    static _room = undefined;
    
    if (_room != undefined)
    {
        return _room;
    }
    _room = -1;
    return _room;
    var _name = "";
    for (var i = 1; i < parameter_count(); i++)
    {
        if (parameter_string(i) == "-room" && (i + 1) < parameter_count())
        {
            _name = parameter_string(i + 1);
        }
    }
    if (_name == "" && file_exists("dev/launch.txt"))
    {
        var _f = file_text_open_read("dev/launch.txt");
        var _line = string_trim(file_text_read_string(_f));
        file_text_close(_f);
        file_delete("dev/launch.txt");
        var _parts = string_split(_line, " ", true);
        if (array_length(_parts) >= 2 && string_lower(_parts[0]) == "room")
        {
            _name = _parts[1];
        }
    }
    if (_name != "")
    {
        var _asset = asset_get_index(_name);
        if (_asset != -1 && room_exists(_asset))
        {
            _room = _asset;
        }
        else
        {
            trace("[dev] launch: unknown room '", _name, "'");
        }
    }
    return _room;
}

function dev_launch_requested()
{
    return dev_launch_room() != -1;
}

function dev_enter_room(arg0)
{
    global.slot_selected = 1;
    scr_aggiorna_save_slot(global.slot_selected);
    if (!db_is_loaded("shared") && db_file_exists("shared"))
    {
        db_load("shared");
    }
    saveslot_reload();
    inventory_handle_pre_raid_backup(true);
    inventory_set_target_db_to_raid();
    __uiGlobal().__defaultOnion.Clear();
    room_goto(arg0);
}
