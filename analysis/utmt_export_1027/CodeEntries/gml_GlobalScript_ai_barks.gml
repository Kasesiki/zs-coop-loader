function ai_barks_defaults()
{
    return 
    {
        settings: 
        {
            same_kind_repeat_seconds: 8,
            squad_echo_radius_px: 200,
            urgent_kinds: ["grenade_out", "danger", "flash", "aimed_at_neutral", "aimed_at_ally"],
            danger_barks_per_grenade: 2,
            heard_through_walls_kinds: [],
            hearing_radius_px: 280,
            unseen_alpha: 0.55
        },
        factions: 
        {
            default: 
            {
                cooldown_scale: 1,
                lines: 
                {
                    contact: ["npc.text.here", "npc.text.he_s_here"],
                    reload_spotted: ["npc.text.here", "npc.text.he_s_here"],
                    push: ["npc.text.i_m_pushing", "npc.text.i_m_chasing", "npc.text.coward", "npc.text.go_go_go", "npc.text.yeah_keep_running_bitch"],
                    reload: ["npc.text.reload"],
                    danger: ["npc.text.grenade", "npc.text.fuck_a_grenade", "npc.text.run", "npc.text.get_out_of_here"],
                    flash: ["npc.text.aaaaaaa", "npc.text.i_am_blinded", "npc.text.i_can_t_see_anything", "npc.text.my_eyes"],
                    aimed_at_neutral: ["npc.text.be_careful_what_you_do", "npc.text.don_t_screw_up_hunter", "npc.text.put_down_that_weapon", "npc.text.watch_out_hunter", "npc.text.be_careful_with_that"],
                    aimed_at_ally: ["npc.text.be_careful_with_that", "npc.text.watch_out_hunter"],
                    body_warning: ["npc.bark.default.body_warning_1"],
                    body_looting: ["npc.bark.default.body_looting_1"]
                }
            }
        }
    };
}

function ai_barks_read_file(arg0)
{
    if (!file_exists(arg0))
    {
        return undefined;
    }
    try
    {
        var _buffer = buffer_load(arg0);
        var _json_text = buffer_read(_buffer, buffer_text);
        buffer_delete(_buffer);
        var _json = json_parse(_json_text);
        if (!is_struct(_json) || struct_get_from_hash(_json, variable_get_hash("usage")) != "ai_barks" || !is_struct(struct_get_from_hash(_json, variable_get_hash("data"))))
        {
            show_debug_message("Barks: \"" + arg0 + "\" is not an ai_barks file, ignored");
            return undefined;
        }
        return _json.data;
    }
    catch (_error)
    {
        show_debug_message("Barks: could not read \"" + arg0 + "\". " + string(_error));
        return undefined;
    }
}

function ai_barks_clean_lines(arg0, arg1)
{
    var _clean_lines_by_kind = {};
    if (!is_struct(arg0))
    {
        return _clean_lines_by_kind;
    }
    var _kind_names = variable_struct_get_names(arg0);
    for (var _kind_index = 0; _kind_index < array_length(_kind_names); _kind_index++)
    {
        var _kind = _kind_names[_kind_index];
        var _lines = variable_struct_get(arg0, _kind);
        if (!is_array(_lines))
        {
            show_debug_message("Barks: \"" + arg1 + "." + _kind + "\" is not a list of lines, ignored");
        }
        else
        {
            var _clean_lines = [];
            for (var _line_index = 0; _line_index < array_length(_lines); _line_index++)
            {
                var _line = _lines[_line_index];
                if (is_string(_line) && string_length(_line) > 0)
                {
                    array_push(_clean_lines, _line);
                }
            }
            variable_struct_set(_clean_lines_by_kind, _kind, _clean_lines);
        }
    }
    return _clean_lines_by_kind;
}

function ai_barks_copy_speaking_rules(arg0, arg1)
{
    if (!is_struct(arg1))
    {
        exit;
    }
    var _repeat_seconds = struct_get_from_hash(arg1, variable_get_hash("same_kind_repeat_seconds"));
    if (is_numeric(_repeat_seconds) && _repeat_seconds >= 0)
    {
        arg0.same_kind_repeat_seconds = _repeat_seconds;
    }
    var _echo_radius_px = struct_get_from_hash(arg1, variable_get_hash("squad_echo_radius_px"));
    if (is_numeric(_echo_radius_px) && _echo_radius_px >= 0)
    {
        arg0.squad_echo_radius_px = _echo_radius_px;
    }
    var _urgent_kinds = struct_get_from_hash(arg1, variable_get_hash("urgent_kinds"));
    if (is_array(_urgent_kinds))
    {
        arg0.urgent_kinds = _urgent_kinds;
    }
    var _danger_barks_per_grenade = struct_get_from_hash(arg1, variable_get_hash("danger_barks_per_grenade"));
    if (is_numeric(_danger_barks_per_grenade) && _danger_barks_per_grenade >= 0)
    {
        arg0.danger_barks_per_grenade = floor(_danger_barks_per_grenade);
    }
    var _heard_kinds = struct_get_from_hash(arg1, variable_get_hash("heard_through_walls_kinds"));
    if (is_array(_heard_kinds))
    {
        arg0.heard_through_walls_kinds = _heard_kinds;
    }
    var _hearing_radius_px = struct_get_from_hash(arg1, variable_get_hash("hearing_radius_px"));
    if (is_numeric(_hearing_radius_px) && _hearing_radius_px >= 0)
    {
        arg0.hearing_radius_px = _hearing_radius_px;
    }
    var _unseen_alpha = struct_get_from_hash(arg1, variable_get_hash("unseen_alpha"));
    if (is_numeric(_unseen_alpha) && _unseen_alpha >= 0 && _unseen_alpha <= 1)
    {
        arg0.unseen_alpha = _unseen_alpha;
    }
}

function ai_barks_apply_data(arg0, arg1)
{
    ai_barks_copy_speaking_rules(arg0.settings, struct_get_from_hash(arg1, variable_get_hash("settings")));
    var _file_factions = struct_get_from_hash(arg1, variable_get_hash("factions"));
    if (!is_struct(_file_factions))
    {
        exit;
    }
    var _faction_names = variable_struct_get_names(_file_factions);
    for (var _faction_index = 0; _faction_index < array_length(_faction_names); _faction_index++)
    {
        var _faction_name = _faction_names[_faction_index];
        var _file_faction = variable_struct_get(_file_factions, _faction_name);
        if (!is_struct(_file_faction))
        {
            continue;
        }
        var _faction = variable_struct_get(arg0.factions, _faction_name);
        if (!is_struct(_faction))
        {
            _faction = 
            {
                cooldown_scale: 1,
                lines: {}
            };
            variable_struct_set(arg0.factions, _faction_name, _faction);
        }
        var _cooldown_scale = struct_get_from_hash(_file_faction, variable_get_hash("cooldown_scale"));
        if (is_numeric(_cooldown_scale) && _cooldown_scale > 0)
        {
            _faction.cooldown_scale = _cooldown_scale;
        }
        ai_barks_copy_speaking_rules(_faction, _file_faction);
        var _file_lines = ai_barks_clean_lines(struct_get_from_hash(_file_faction, variable_get_hash("lines")), _faction_name);
        var _kind_names = variable_struct_get_names(_file_lines);
        for (var _kind_index = 0; _kind_index < array_length(_kind_names); _kind_index++)
        {
            var _kind = _kind_names[_kind_index];
            variable_struct_set(_faction.lines, _kind, variable_struct_get(_file_lines, _kind));
        }
    }
}

function ai_barks_load(arg0 = "ZS_vanilla/gamedata/ai_barks.json")
{
    var _barks = ai_barks_defaults();
    var _file_data = ai_barks_read_file(arg0);
    if (is_struct(_file_data))
    {
        ai_barks_apply_data(_barks, _file_data);
    }
    else
    {
        show_debug_message("Barks: using the built-in generic lines");
    }
    global.ai_barks = _barks;
    return _barks;
}

function ai_barks_get()
{
    if (!variable_global_exists("ai_barks") || !is_struct(global.ai_barks))
    {
        ai_barks_load();
    }
    return global.ai_barks;
}

function ai_barks_mod_autoload()
{
    var _barks = ai_barks_load();
    for (var _mod_index = 0; _mod_index < array_length(global.Mods_Order); _mod_index++)
    {
        var _mod_name = global.Mods_Order[_mod_index];
        var _mod = variable_struct_get(global.Mods_Data, _mod_name);
        if (!is_struct(_mod))
        {
            continue;
        }
        var _mod_file_data = ai_barks_read_file(_mod.file_path + "/gamedata/ai_barks.json");
        if (is_struct(_mod_file_data))
        {
            ai_barks_apply_data(_barks, _mod_file_data);
        }
    }
}

function ai_barks_faction(arg0)
{
    var _factions = ai_barks_get().factions;
    if (is_string(arg0) && variable_struct_exists(_factions, arg0))
    {
        return variable_struct_get(_factions, arg0);
    }
    return struct_get_from_hash(_factions, variable_get_hash("default"));
}

function ai_barks_lines(arg0, arg1)
{
    var _lines = variable_struct_get(ai_barks_faction(arg0).lines, arg1);
    return is_array(_lines) ? _lines : [];
}

function ai_barks_lines_or_default(arg0, arg1)
{
    var _faction_lines = ai_barks_lines(arg0, arg1);
    if (array_length(_faction_lines) > 0)
    {
        return _faction_lines;
    }
    return ai_barks_lines("default", arg1);
}

function ai_barks_cooldown_scale(arg0)
{
    return ai_barks_faction(arg0).cooldown_scale;
}

function ai_barks_speaking_rule(arg0, arg1)
{
    var _faction = ai_barks_faction(arg0);
    if (variable_struct_exists(_faction, arg1))
    {
        return variable_struct_get(_faction, arg1);
    }
    return variable_struct_get(ai_barks_get().settings, arg1);
}

function ai_barks_kind_listed(arg0, arg1, arg2)
{
    var _listed_kinds = ai_barks_speaking_rule(arg0, arg1);
    for (var _kind_index = 0; _kind_index < array_length(_listed_kinds); _kind_index++)
    {
        if (_listed_kinds[_kind_index] == arg2)
        {
            return true;
        }
    }
    return false;
}

function ai_barks_is_urgent(arg0, arg1)
{
    return ai_barks_kind_listed(arg0, "urgent_kinds", arg1);
}

function ai_barks_is_heard_through_walls(arg0, arg1)
{
    return ai_barks_kind_listed(arg0, "heard_through_walls_kinds", arg1);
}

function ai_barks_pick_line(arg0, arg1 = "")
{
    var _line_count = array_length(arg0);
    if (_line_count == 0)
    {
        return "";
    }
    var _line = arg0[irandom(_line_count - 1)];
    if (_line_count > 1 && _line == arg1)
    {
        var _line_index = 0;
        while (arg0[_line_index] != _line)
        {
            _line_index += 1;
        }
        _line = arg0[(_line_index + 1) % _line_count];
    }
    return _line;
}
