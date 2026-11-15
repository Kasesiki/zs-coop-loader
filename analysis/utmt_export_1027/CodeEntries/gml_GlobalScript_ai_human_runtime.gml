function ai_human_initialize(arg0)
{
    arg0.ai_is_human = false;
    arg0.ai_equipment_ready = false;
    arg0.ai_prepared = false;
    arg0.ai_dev_requested = false;
    arg0.ai_spawn_override = undefined;
    arg0.ai_seed = undefined;
    arg0.ai_execution = undefined;
    arg0.ai_status = "legacy";
    arg0.ai_controller_source = "legacy";
}

function ai_human_dev_enable(arg0, arg1, arg2 = undefined)
{
    if (1 || !instance_exists(arg0) || !arg0.ai_is_human || arg0.ai_prepared)
    {
        return false;
    }
    arg0.ai_dev_requested = true;
    arg0.ai_spawn_override = arg1;
    arg0.ai_seed = arg2;
    return true;
}

function ai_human_dev_enable_personality(arg0, arg1, arg2)
{
    if (1 || !variable_global_exists("ai_profile_data"))
    {
        return false;
    }
    var _profile = __ai_human_field(global.ai_profile_data, arg1);
    var _pool = __ai_human_field(_profile, "personality_pool");
    if (is_array(_pool))
    {
        for (var _i = 0; _i < array_length(_pool); _i++)
        {
            if (__ai_human_field(_pool[_i], "id") != arg2)
            {
                continue;
            }
            var _style = __ai_profile_copy(_pool[_i]);
            _style.weight = 1;
            return ai_human_dev_enable(arg0, 
            {
                tree: "human_basic",
                profile: arg1,
                personality_pool: [_style]
            });
        }
    }
    show_debug_message("AI test preset: missing personality " + arg1 + "/" + arg2);
    return false;
}

function __ai_human_field(arg0, arg1)
{
    return is_struct(arg0) ? variable_struct_get(arg0, arg1) : undefined;
}

function ai_human_supported(arg0)
{
    return arg0.ai_is_human && (!variable_instance_exists(arg0, "faction") || arg0.faction != "Mutants" || (variable_instance_exists(arg0, "npc_id") && arg0.npc_id == "rotking"));
}

function ai_human_prepare(arg0)
{
    if (arg0.ai_prepared)
    {
        exit;
    }
    var _developer = false && arg0.ai_dev_requested;
    var _automatic = ai_human_supported(arg0) && ai_human_rollout_enabled(arg0.npc_id);
    if (!ai_human_supported(arg0) || (!_developer && !_automatic))
    {
        arg0.ai_prepared = true;
        exit;
    }
    if (!ai_human_world_ready())
    {
        arg0.ai_status = "waiting_world";
        exit;
    }
    if (_automatic && !_developer && !arg0.ai_equipment_ready)
    {
        arg0.ai_status = "waiting_setup";
        exit;
    }
    if (arg0.state != "human_general")
    {
        arg0.ai_status = "pending_scene";
        exit;
    }
    arg0.ai_prepared = true;
    if (!arg0.ai_equipment_ready || arg0.hp <= 0)
    {
        arg0.ai_status = "ineligible_initial_state";
        exit;
    }
    var _preset_ai = npc_get_ai_preset(arg0.npc_id);
    var _definition_ai = npc_get_ai_override(arg0.npc_id);
    if (!_developer && !is_struct(_preset_ai) && !is_struct(_definition_ai))
    {
        arg0.ai_status = "missing_ai";
        exit;
    }
    var _seed = arg0.ai_seed;
    if (is_undefined(_seed))
    {
        var _seed_stream = ai_profile_rng(1 + (abs(real(arg0.id)) % 2147483646));
        repeat (4)
        {
            ai_profile_random(_seed_stream);
        }
        _seed = _seed_stream.state;
    }
    var _training_steps_down = difficulty_get("smart_ai") ? 0 : 2;
    var _profile = ai_profile_resolve(global.ai_profile_data, _preset_ai, _definition_ai, _developer ? arg0.ai_spawn_override : undefined, _seed, item_weapon_get_type(arg0.arma_now), _training_steps_down);
    arg0.ai_seed = _profile.seed;
    if (!_profile.valid)
    {
        arg0.ai_status = _profile.valid ? "tree_not_playable" : "invalid_profile";
        var _diagnostics = _profile.diagnostics;
        for (var _i = 0; _i < array_length(_diagnostics); _i++)
        {
            show_debug_message("AI profile " + string(arg0.npc_id) + ": " + _diagnostics[_i]);
        }
        exit;
    }
    if (!_developer && _profile.config.tree != "human_basic")
    {
        arg0.ai_status = "unsupported_tree";
        exit;
    }
    if ((arg0.follow_path || arg0.force_moving_towards_player) && _profile.config.tree != "human_basic")
    {
        arg0.ai_status = "ineligible_initial_state";
        exit;
    }
    if (_profile.config.tree == "human_basic" && !ai_assignments_supported(arg0))
    {
        arg0.ai_status = "preserved_special_assignment";
        exit;
    }
    var _execution = 
    {
        npc: arg0,
        npc_id: arg0.npc_id,
        weapon: arg0.arma_now,
        profile: _profile,
        step: 0,
        last_dispatch_step: -1,
        active: false,
        decision_count: 0,
        update_count: 0,
        enter_count: 0,
        exit_count: 0,
        decision_phase: _profile.seed % _profile.config.schedule.decision_steps,
        tree_context: undefined
    };
    if (_profile.config.tree == "human_basic")
    {
        ai_human_combat_init(_execution);
        _execution.tree_context = ai_bt_context(ai_human_basic_tree(), _execution);
    }
    else
    {
        _execution.tree_context = ai_bt_context(ai_human_test_tree(), _execution);
    }
    arg0.ai_execution = _execution;
    arg0.ai_status = _profile.config.tree;
    arg0.ai_controller_source = _developer ? "developer" : "human_default";
}

function ai_human_test_tree()
{
    static _tree = ai_bt_tree(ai_bt_action("development_idle", __ai_human_idle_enter, __ai_human_idle_update, __ai_human_idle_exit));
    
    return _tree;
}

function __ai_human_idle_enter(arg0, arg1)
{
    arg0.user_data.active = true;
    arg0.user_data.enter_count++;
}

function __ai_human_idle_update(arg0, arg1)
{
    var _execution = arg0.user_data;
    _execution.update_count++;
    with (_execution.npc)
    {
        path_end();
        speed = 0;
        hspd = 0;
        vspd = 0;
        human_state_now = -1;
    }
    return UnknownEnum.Value_0;
}

function __ai_human_idle_exit(arg0, arg1, arg2)
{
    arg0.user_data.active = false;
    arg0.user_data.exit_count++;
}

function ai_human_cancel(arg0, arg1)
{
    if (!variable_instance_exists(arg0, "ai_execution") || is_undefined(arg0.ai_execution))
    {
        exit;
    }
    var _context = arg0.ai_execution.tree_context;
    if (arg0.ai_execution.active)
    {
        ai_bt_abort(_context, arg1);
    }
    if (arg0.ai_execution.profile.config.tree == "human_basic")
    {
        arg0.ai_execution.perception.previous = [];
        arg0.ai_execution.bridge.hit.pending = false;
        arg0.ai_execution.bridge.hit.active = false;
        __ai_human_adapt_reset(arg0.ai_execution);
        arg0.ai_execution.combat.hunter = __ai_hunter_create();
        arg0.ai_execution.combat.hunter_reload = false;
        ai_withdrawal_cancel(arg0.ai_execution, arg1);
        arg0.ai_execution.combat.scatter.pending = false;
        arg0.ai_execution.combat.scatter.panic = false;
        arg0.ai_execution.combat.engaging = false;
        arg0.ai_execution.combat.defense.mode = "none";
        arg0.ai_execution.combat.defense.unsupported_at = -1;
        arg0.ai_execution.perception.flash = undefined;
        arg0.ai_execution.perception.tracking = __ai_tracking_create();
        arg0.ai_execution.team.fighting_ally = -4;
        arg0.ai_execution.team.reload_packet = undefined;
        arg0.ai_execution.team.support = undefined;
        arg0.ai_execution.team.contact_packet = undefined;
        ai_investigation_reset(arg0.ai_execution);
        ai_commands_cancel(arg0.ai_execution);
        ai_spatial_release(arg0.ai_execution);
        ai_team_release(arg0.ai_execution);
        ai_grenade_cancel(arg0.ai_execution);
        ai_routines_cancel(arg0.ai_execution);
        if (arg1 == "dead" || arg1 == "destroyed" || arg1 == "cleanup" || arg1 == "setup_changed" || arg1 == "fixture_cleanup")
        {
            ai_spatial_destroy(arg0.ai_execution);
        }
    }
}

function ai_human_before_step(arg0)
{
    ai_human_prepare(arg0);
    var _execution = arg0.ai_execution;
    if (is_undefined(_execution))
    {
        exit;
    }
    _execution.step++;
    if (_execution.profile.config.tree == "human_basic")
    {
        var _frame = ai_world_get().frame;
        if (_frame > (_execution.bridge.last_frame + 1))
        {
            ai_human_suspend(arg0, "resumed_after_gap");
        }
        _execution.bridge.last_frame = _frame;
        ai_routes_resume(_execution);
    }
    if (arg0.hp <= 0)
    {
        ai_human_cancel(arg0, "dead");
    }
    else if (arg0.npc_id != _execution.npc_id || arg0.arma_now != _execution.weapon)
    {
        ai_human_cancel(arg0, "setup_changed");
        arg0.ai_execution = undefined;
        arg0.ai_status = "setup_changed";
        arg0.ai_prepared = false;
        ai_human_prepare(arg0);
    }
    else if (arg0.state != "human_general" || (_execution.profile.config.tree != "human_basic" && (arg0.follow_path || arg0.force_moving_towards_player)))
    {
        ai_human_cancel(arg0, "external_owner");
    }
}

function ai_human_dispatch(arg0)
{
    var _execution = arg0.ai_execution;
    if (is_undefined(_execution))
    {
        if (!ai_human_supported(arg0) || arg0.state != "human_general")
        {
            return false;
        }
        with (arg0)
        {
            path_end();
            speed = 0;
            hspd = 0;
            vspd = 0;
            human_state_now = -1;
        }
        return true;
    }
    if (arg0.hp <= 0)
    {
        return true;
    }
    if (arg0.state != "human_general" || (_execution.profile.config.tree != "human_basic" && (arg0.follow_path || arg0.force_moving_towards_player)))
    {
        return false;
    }
    if (_execution.last_dispatch_step == _execution.step)
    {
        return true;
    }
    _execution.last_dispatch_step = _execution.step;
    var _interval = _execution.profile.config.schedule.decision_steps;
    var _decision_due = (((_execution.step - 1) + _execution.decision_phase) % _interval) == 0;
    if (_decision_due)
    {
        _execution.decision_count++;
    }
    if (_execution.profile.config.tree == "human_basic")
    {
        _execution.now = _execution.tree_context.now + 0.016666666666666666;
        ai_commands_sample_motion(_execution);
        arg0.NPCrecoil.IncreaseRadius(arg0.NPCrecoil.radius_decreasing_value);
        ai_compat_step(_execution);
        var _had_contact = _execution.knowledge.valid;
        var _was_visible = _execution.knowledge.visible;
        var _old_target = _execution.knowledge.target;
        var _had_shared_contact = __ai_human_contact_fresh(_execution);
        if (!_had_contact)
        {
            _execution.combat.pursuit_allowed = undefined;
            _execution.combat.lost_contact.active = false;
            _execution.combat.lost_contact.next_advance = 0;
        }
        ai_bridge_step(_execution);
        ai_perception_step(_execution);
        ai_hearing_step(_execution);
        ai_team_step(_execution);
        if (ai_withdrawal_step(_execution))
        {
            _decision_due = true;
        }
        ai_commands_camera_step(_execution);
        if (_execution.knowledge.valid && ((_had_contact && _old_target != _execution.knowledge.target) || _execution.perception.resumed_step == _execution.step))
        {
            ai_bt_abort(_execution.tree_context, "target_changed");
            var _new_flash = _execution.combat.adaptation.flash_cue;
            var _new_reload = _execution.combat.adaptation.reload_cue;
            var _new_heal = _execution.combat.adaptation.heal_cue;
            __ai_human_adapt_reset(_execution);
            if (is_struct(_new_flash) && _new_flash.target == _execution.knowledge.target)
            {
                _execution.combat.adaptation.flash_cue = _new_flash;
            }
            if (is_struct(_new_reload) && _new_reload.target == _execution.knowledge.target)
            {
                _execution.combat.adaptation.reload_cue = _new_reload;
            }
            if (is_struct(_new_heal) && _new_heal.target == _execution.knowledge.target)
            {
                _execution.combat.adaptation.heal_cue = _new_heal;
            }
            _execution.combat.cover = undefined;
            _execution.combat.pursuit_allowed = undefined;
            _execution.combat.lost_contact.active = false;
            _execution.combat.blocked_until = 0;
            _execution.cover_assessment = undefined;
            _decision_due = true;
        }
        __ai_hunter_step(_execution);
        __ai_human_lost_contact_step(_execution);
        __ai_human_scatter_step(_execution);
        __ai_human_defense_step(_execution);
        if (!_had_shared_contact && __ai_human_contact_fresh(_execution))
        {
            _decision_due = true;
            _execution.combat.blocked_until = 0;
        }
        if (__ai_human_can_scatter(_execution.tree_context))
        {
            _decision_due = true;
        }
        if (__ai_human_opening_ready(_execution.tree_context) || __ai_human_can_suppress(_execution.tree_context))
        {
            _decision_due = true;
        }
        if (__ai_human_urgent_opening(_execution))
        {
            _decision_due = true;
        }
        if (_execution.knowledge.visible && (!_was_visible || (is_struct(_execution.investigation.plan) && ai_investigation_fire_opportunity(_execution))))
        {
            var _node = _execution.tree_context._active_action;
            if (_node >= 0)
            {
                var _action = _execution.tree_context.tree.nodes[_node].name;
                var _preparation = _execution.tree_context._slots[_node].data;
                var _uncommitted_preparation = _action == "prepare_advance" && _preparation.hidden && (_preparation.mode == "assess" || _preparation.mode == "magazine");
                var _keep_inspection = (ai_investigation_committed(_execution) && (_action == "investigate" || _action == "chase" || _action == "prepare_advance")) || (_action == "find_angle" && (!ai_investigation_fire_opportunity(_execution) || (variable_struct_exists(_preparation, "gain_local") && !_preparation.gain_local)));
                if (!_keep_inspection && (_uncommitted_preparation || __ai_profile_contains(["hold_angle", "find_angle", "interception", "chase", "investigate", "search", "hold_position"], _action)))
                {
                    ai_bt_abort(_execution.tree_context, "sight_reacquired");
                }
            }
            _decision_due = true;
            if (!_had_contact)
            {
                _execution.combat.blocked_until = 0;
            }
        }
        if (__ai_human_hit_step(_execution) || ai_compat_danger(_execution) || arg0.force_moving_towards_player)
        {
            _decision_due = true;
        }
    }
    ai_bt_tick(_execution.tree_context, _execution.step, _decision_due);
    if (_execution.profile.config.tree == "human_basic")
    {
        ai_cover_step(_execution);
    }
    return true;
}

function ai_human_debug_label(arg0, arg1, arg2)
{
    if (variable_struct_exists(arg2, "fighting") && arg2.fighting)
    {
        return "Fight";
    }
    if (variable_struct_exists(arg2, "route_mode") && arg2.route_mode && arg2.route_phase == "fight")
    {
        return "Fight";
    }
    switch (arg1)
    {
        case "":
            return (arg0.tree_context.last_result == UnknownEnum.Value_2) ? "Retry" : "Decide";
        case "choose_tactic":
            return "Decide";
        case "shoot":
            return "Shoot";
        case "reload":
            return "Reload";
        case "scatter":
            return "Scatter";
        case "relocation":
        case "peek_reposition":
            return "Relocate";
        case "find_angle":
            return "Find angle";
        case "flank":
            return "Flank";
        case "hit_reaction":
            return "Hit cover";
        case "suppression_cover":
            return "Cover";
        case "defensive_reposition":
            return "Fall back";
        case "shoot_retreat":
            return (arg2.phase == "fire") ? "Fire burst" : ((arg2.phase == "settle") ? "Settle" : "Retreat");
        case "panic":
            return "Panic";
        case "withdraw":
            return (arg0.withdrawal.phase == "fight") ? "Fight" : ((arg0.withdrawal.phase == "hold") ? "Hide" : "Flee");
        case "hold_angle":
        case "hold_position":
            return "Hold";
        case "reload_push":
        case "heal_push":
        case "flash_push":
            return "Push";
        case "covering_fire":
            return "Cover fire";
        case "grenade":
            return "Grenade";
        case "interception":
            return "Intercept";
        case "chase":
            return "Chase";
        case "investigate":
            return "Investigate";
        case "search":
            return "Search";
        case "return_assignment":
            return "Return";
        case "assignment":
            return "Assigned";
        case "scene_assignment":
            return "Scripted";
        case "prepare_advance":
            return (arg2.mode == "reload") ? "Reload" : ((arg2.mode == "grenade") ? "Grenade" : "Prepare");
        case "combat_move":
            return (arg2.tactic == "strafe") ? "Strafe" : "Space out";
        case "position":
            return (arg0.combat.tactic == "cover") ? "Cover" : "Reposition";
        case "peek":
            if (arg2.phase == "return")
            {
                return "Peek back";
            }
            if (arg2.phase == "out")
            {
                return "Peek out";
            }
            if (arg2.phase == "exposed")
            {
                return arg2.fire ? "Peek fire" : "Peek look";
            }
            return "Peek wait";
        case "danger":
            return (arg0.compat.mode == "flash") ? "Flashed" : ((arg0.compat.mode == "emission") ? "Shelter" : ((arg0.compat.mode == "shelter") ? "Grenade cover" : "Evade"));
        case "idle":
            return (arg0.now < arg0.combat.blocked_until) ? "Retry" : "Idle";
        case "aim_reaction":
            return "Warn";
        case "route":
            if (variable_struct_exists(arg0.route, "pace_kind") && arg0.route.pace_kind != "walk")
            {
                return (arg0.route.pace_kind == "sprint") ? "Sprint" : "Run";
            }
            return (arg0.now < arg0.routines.scan_until) ? "Scan" : "Patrol";
        case "routine":
            switch (arg0.routines.kind)
            {
                case "patrol":
                case "idle":
                    return (arg0.now < arg0.routines.scan_until) ? "Scan" : ((arg0.routines.kind == "patrol") ? "Patrol" : "Idle");
                case "investigate_body":
                    return "Check body";
                case "separate":
                    return "Spread out";
                case "campfire":
                    return "Campfire";
                case "guitar":
                    return "Guitar";
                case "drink":
                    return "Drink";
                case "smoke":
                    return "Smoke";
                case "eat":
                    return "Eat";
            }
            return "Idle";
    }
    return "Act";
}

function ai_human_debug_vision(arg0)
{
    var _view = __ai_perception_view(arg0);
    if (!_view.enabled)
    {
        exit;
    }
    var _start = arg0.weapon_pointing_direction - (_view.angle / 2);
    var _px = arg0.x + lengthdir_x(_view.distance, _start);
    var _py = arg0.y + lengthdir_y(_view.distance, _start);
    draw_line(arg0.x, arg0.y, _px, _py);
    for (var _segment = 1; _segment <= 24; _segment++)
    {
        var _angle = _start + ((_view.angle * _segment) / 24);
        var _nx = arg0.x + lengthdir_x(_view.distance, _angle);
        var _ny = arg0.y + lengthdir_y(_view.distance, _angle);
        draw_line(_px, _py, _nx, _ny);
        _px = _nx;
        _py = _ny;
    }
    draw_line(arg0.x, arg0.y, _px, _py);
    draw_circle(arg0.x, arg0.y, _view.minimum, true);
}

function ai_human_debug_details(arg0, arg1, arg2)
{
    var _npc = arg0.npc;
    var _k = arg0.knowledge;
    draw_set_color(c_white);
    draw_set_alpha(0.25);
    ai_human_debug_vision(_npc);
    draw_set_alpha(1);
    ai_investigation_draw(arg0);
    ai_cover_draw(arg0);
    ai_hearing_draw(arg0);
    ai_tracking_draw(arg0);
    if (_k.valid)
    {
        var _focus = ai_contact_focus(arg0);
        draw_set_color(_k.visible ? c_lime : c_orange);
        draw_set_alpha(0.5);
        draw_line(_npc.x, _npc.y, _focus.x, _focus.y);
        draw_set_alpha(1);
        draw_circle(_focus.x, _focus.y, 4, true);
    }
    draw_set_color(c_white);
    draw_circle(_npc.x, _npc.y, 12, true);
    var _phase = variable_struct_exists(arg2, "phase") ? arg2.phase : "";
    if (variable_struct_exists(arg2, "route_mode") && arg2.route_mode)
    {
        _phase = arg2.route_phase;
    }
    var _contact = !_k.valid ? "unaware" : (_k.visible ? "sees target" : "memory");
    if (_k.valid && !_k.visible)
    {
        _contact += (" " + string_format(max(0, arg0.now - _k.observed_at), 1, 1) + "s");
    }
    if (!_k.valid)
    {
        _contact += (" / alert " + string(round(100 * clamp(_npc.alert_player / max(1, _npc.alert_player_max), 0, 1))) + "%");
    }
    var _text = arg0.profile.config.training + " / " + arg0.profile.personality.style + "\nAction: " + ((arg1 == "") ? "transition" : arg1) + ((_phase == "") ? "" : (" / " + _phase)) + "\nContact: " + _contact + " / path: " + arg0.commands.path_status + "\nChoice: " + arg0.combat.decision_reason;
    if (arg0.withdrawal.active)
    {
        _text += ("\nEscape: " + arg0.withdrawal.phase + " / " + arg0.withdrawal.reason);
    }
    if (array_length(arg0.perception.previous) > 0)
    {
        _text += ("\nPrevious contacts: " + string(array_length(arg0.perception.previous)));
    }
    if (arg0.investigation.active)
    {
        _text += ("\nSearch: " + arg0.investigation.phase + " / " + arg0.investigation.reason);
    }
    if (arg1 == "hold_position")
    {
        var _lost = arg0.combat.lost_contact;
        _text += ("\nHold: " + (!_lost.chase_allowed ? "chase declined" : ((arg0.now < _lost.hold_until) ? "watching" : ((arg0.now < _lost.next_advance) ? "advance pause" : "ally advancing"))));
    }
    if (_k.valid)
    {
        _text += ("\nGrenade: " + arg0.grenade.reason + " / cover: " + arg0.combat.defense.reason);
    }
    if (_k.visible)
    {
        _text += ("\nReaction: " + arg0.commands.reflex_reason + " / " + string_format(arg0.commands.reflex_required / 60, 0, 2) + "s");
        var _settle = __ai_commands_settle_remaining(arg0);
        if (_settle > 0)
        {
            _text += (" / settling " + string(round(_settle * 100)) + "%");
        }
        if (arg0.now < arg0.commands.trigger_pause_until)
        {
            _text += " / burst pause";
        }
        var _lead = point_distance(0, 0, arg0.commands.lead_x, arg0.commands.lead_y);
        if (_lead >= 0.5)
        {
            _text += (" / lead " + string(round(_lead)) + "px");
        }
    }
    if (_k.valid && arg0.commands.camera_fire.reason != "not_player")
    {
        _text += ("\nCamera fire: " + arg0.commands.camera_fire.reason);
    }
    if (arg1 == "" && arg0.tree_context.last_result == UnknownEnum.Value_2)
    {
        _text += ("\nRetry: " + string(arg0.tree_context.last_reason));
    }
    var _width = 224;
    var _line = 10;
    var _height = string_height_ext(_text, _line, _width);
    var _left = _npc.x + 18;
    var _top = _npc.y + 14;
    draw_set_color(c_black);
    draw_set_alpha(0.85);
    draw_rectangle(_left - 4, _top - 3, _left + _width + 4, _top + _height + 3, false);
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(_left, _top, _text, _line, _width);
    draw_set_halign(fa_center);
}

enum UnknownEnum
{
    Value_0,
    Value_2 = 2
}
