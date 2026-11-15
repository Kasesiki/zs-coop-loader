function ai_assignments_supported(arg0)
{
    return ai_human_supported(arg0);
}

function ai_assignments_create(arg0)
{
    arg0.order = 
    {
        kind: "none",
        target: noone,
        until: 0,
        refresh_at: 0,
        x: 0,
        y: 0
    };
    ai_withdrawal_reset(arg0);
}

function ai_assignments_pending(arg0)
{
    var _e = arg0.user_data;
    return _e.npc.force_moving_towards_player || _e.order.kind != "none";
}

function ai_assignments_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _npc = _e.npc;
    _e.order.kind = "forced_hunt";
    _e.order.target = variable_instance_exists(_npc, "target") ? _npc.target : -4;
    _e.order.until = _e.now + 15;
    _e.order.refresh_at = 0;
    _npc.force_moving_towards_player = false;
}

function ai_assignments_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _npc = _e.npc;
    var _order = _e.order;
    if (_e.now >= _order.until)
    {
        return UnknownEnum.Value_2;
    }
    if (_e.knowledge.valid && _e.knowledge.visible)
    {
        return UnknownEnum.Value_1;
    }
    if (!instance_exists(_order.target))
    {
        return UnknownEnum.Value_2;
    }
    if (_e.now >= _order.refresh_at)
    {
        _order.x = _order.target.x;
        _order.y = _order.target.y;
        _order.refresh_at = _e.now + 0.5;
    }
    var _move = ai_commands_move(_e, arg1.token, _order.x, _order.y, __ai_human_speed(_e), 2);
    if (_move == "failed")
    {
        return UnknownEnum.Value_2;
    }
    if (_move == "arrived")
    {
        return UnknownEnum.Value_1;
    }
    return UnknownEnum.Value_0;
}

function ai_assignments_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    _e.order.kind = "none";
    _e.npc.force_moving_towards_player = false;
    __ai_human_action_exit(arg0, arg1, arg2);
}

function ai_withdrawal_reset(arg0)
{
    arg0.withdrawal = 
    {
        room_id: room,
        active: false,
        engaged: false,
        until: 0,
        retry_at: 0,
        target: noone,
        threat: undefined,
        heard_frame: -1,
        observed_at: -1000,
        need_move: false,
        reason: "none",
        phase: "none"
    };
}

function __ai_withdrawal_enabled(arg0)
{
    var _profile = arg0.profile.config.profile;
    return arg0.profile.config.abandonment.enabled && (_profile == "hunter" || _profile == "bandit");
}

function ai_withdrawal_cancel(arg0, arg1)
{
    var _w = arg0.withdrawal;
    var _target = _w.target;
    var _retain = _w.active && _w.room_id == room && (arg1 == "culled" || arg1 == "resumed_after_gap");
    ai_withdrawal_reset(arg0);
    if (_retain)
    {
        arg0.withdrawal.active = true;
        arg0.withdrawal.target = _target;
        arg0.withdrawal.phase = "hold";
        arg0.withdrawal.reason = arg1;
    }
}

function ai_withdrawal_ready(arg0)
{
    var _e = arg0.user_data;
    if (!__ai_withdrawal_enabled(_e) || _e.combat.peek_return || ai_scene_assignments_force_shoot(_e))
    {
        return false;
    }
    var _ratio = _e.npc.hp / max(1, npc_get_hp(_e.npc.npc_id));
    var _c = _e.profile.config.abandonment;
    return _ratio > 0 && _e.withdrawal.active ? (_ratio <= min(1, _c.health_ratio + _c.recovery_margin)) : (_e.knowledge.valid && _ratio <= _c.health_ratio);
}

function __ai_withdrawal_capture(arg0, arg1)
{
    var _w = arg0.withdrawal;
    _w.target = arg1.target;
    _w.threat = 
    {
        valid: true,
        visible: false,
        target: arg1.target,
        x: arg1.x,
        y: arg1.y,
        revision: arg1.revision
    };
    _w.need_move = true;
}

function ai_withdrawal_step(arg0)
{
    var _w = arg0.withdrawal;
    var _was = _w.active;
    var _k = arg0.knowledge;
    if (_w.room_id != room || !__ai_withdrawal_enabled(arg0) || (_w.active && (arg0.npc.hp / max(1, npc_get_hp(arg0.npc.npc_id))) > min(1, arg0.profile.config.abandonment.health_ratio + arg0.profile.config.abandonment.recovery_margin)))
    {
        if (_was || _w.room_id != room)
        {
            ai_withdrawal_reset(arg0);
        }
        return _was;
    }
    if (!_w.active)
    {
        if (!ai_withdrawal_ready(arg0.tree_context))
        {
            return false;
        }
        _w.active = true;
        _w.reason = "low_health";
        __ai_withdrawal_capture(arg0, ai_contact_focus(arg0));
    }
    _w.until = arg0.now + arg0.profile.config.abandonment.cooldown_seconds;
    if (_k.valid && (_k.target != _w.target || _k.observed_at > _w.observed_at))
    {
        __ai_withdrawal_capture(arg0, ai_contact_focus(arg0));
        _w.observed_at = _k.observed_at;
    }
    var _clue = arg0.perception.hearing.clue;
    if (__ai_hearing_fresh(arg0, _clue) && _clue.frame > _w.heard_frame)
    {
        __ai_withdrawal_capture(arg0, _clue);
        _w.heard_frame = _clue.frame;
        _w.reason = "heard_pursuer";
    }
    else if (!_k.valid && !__ai_hearing_fresh(arg0, _clue))
    {
        _w.threat = undefined;
        _w.need_move = false;
    }
    return !_was;
}

function __ai_withdrawal_can_fight(arg0)
{
    var _k = arg0.knowledge;
    return _k.valid && _k.visible && !arg0.npc.reloading && arg0.npc.ammo_now > 0 && !arg0.npc.grenade_flash && point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y) <= (arg0.combat.weapon_range * arg0.profile.config.abandonment.fight_range_ratio) && ai_commands_camera_step(arg0);
}

function ai_withdrawal_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    ai_withdrawal_step(_e);
    _e.withdrawal.engaged = true;
    ai_compat_callout(_e.npc, "retreat");
    arg1.data.result = undefined;
    arg1.data.threat = undefined;
    arg1.data.until = 0;
    arg1.data.busy_since = -1;
}

function __ai_withdrawal_stop(arg0, arg1, arg2, arg3)
{
    ai_commands_stop(arg0, arg1.token);
    ai_spatial_release(arg0);
    arg1.data.result = undefined;
    arg1.data.threat = undefined;
    arg0.withdrawal.retry_at = arg0.now + arg3;
    arg0.withdrawal.reason = arg2;
}

function ai_withdrawal_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _w = _e.withdrawal;
    var _d = arg1.data;
    var _c = _e.profile.config.abandonment;
    if (!ai_withdrawal_ready(arg0))
    {
        return UnknownEnum.Value_1;
    }
    if (_e.npc.grenade_flash)
    {
        ai_commands_stop(_e, arg1.token);
        return UnknownEnum.Value_0;
    }
    if (__ai_withdrawal_can_fight(_e))
    {
        if (_w.phase != "fight")
        {
            __ai_withdrawal_stop(_e, arg1, "visible_fight", 0);
        }
        _w.phase = "fight";
        _w.need_move = true;
        ai_commands_stop(_e, arg1.token);
        ai_commands_aim(_e, arg1.token, _e.knowledge.x, _e.knowledge.y);
        ai_commands_fire(_e, arg1.token, _e.knowledge);
        return UnknownEnum.Value_0;
    }
    if (_w.phase == "fight")
    {
        _w.retry_at = 0;
    }
    _w.phase = "hold";
    if (_e.npc.ammo_now <= 0 || _e.npc.reloading)
    {
        ai_commands_reload(_e, arg1.token, false);
    }
    if (is_struct(_d.result))
    {
        if (is_struct(_w.threat) && (_w.threat.target != _d.threat.target || point_distance(_d.result.x, _d.result.y, _w.threat.x, _w.threat.y) < (point_distance(_e.npc.x, _e.npc.y, _w.threat.x, _w.threat.y) - 16)))
        {
            _w.need_move = true;
            __ai_withdrawal_stop(_e, arg1, "escape_direction_changed", 0);
        }
        else
        {
            var _valid = ai_spatial_progress(_e, arg1, _d.result);
            if (_valid == "waiting" && _e.now < _d.until)
            {
                return UnknownEnum.Value_0;
            }
            if (_valid != "valid" || _e.now >= _d.until)
            {
                _w.need_move = true;
                __ai_withdrawal_stop(_e, arg1, "escape_blocked", _c.retry_seconds);
            }
            else
            {
                _w.phase = "move";
                var _move = ai_commands_move_position(_e, arg1.token, _d.result, ai_commands_transfer_speed(_e, _d.result, true), 3);
                if (_move == "arrived")
                {
                    var _near = is_struct(_w.threat) && point_distance(_e.npc.x, _e.npc.y, _w.threat.x, _w.threat.y) < _c.safe_distance_px;
                    _w.need_move = _w.need_move || _near;
                    __ai_withdrawal_stop(_e, arg1, "escaped_leg", _c.settle_seconds);
                }
                else if (_move == "failed")
                {
                    _w.need_move = true;
                    __ai_withdrawal_stop(_e, arg1, "escape_blocked", _c.retry_seconds);
                }
                return UnknownEnum.Value_0;
            }
        }
    }
    ai_commands_stop(_e, arg1.token);
    if (is_struct(_w.threat))
    {
        ai_commands_aim(_e, arg1.token, _w.threat.x, _w.threat.y);
    }
    if (_e.knowledge.visible)
    {
        ai_commands_fire(_e, arg1.token, _e.knowledge);
    }
    if (!_w.need_move || !is_struct(_w.threat) || _e.now < _w.retry_at)
    {
        return UnknownEnum.Value_0;
    }
    if (!is_struct(_d.threat))
    {
        _d.threat = variable_clone(_w.threat);
    }
    _w.phase = "query";
    var _result = ai_spatial_query(_e, "flee", arg1.token, _d.threat);
    if (_result.status == "DEFERRED")
    {
        return UnknownEnum.Value_0;
    }
    if (_result.status != "FOUND" || !ai_spatial_claim(_e, _result, arg1.token))
    {
        __ai_withdrawal_stop(_e, arg1, "no_escape_path", _c.retry_seconds);
        return UnknownEnum.Value_0;
    }
    _d.result = _result;
    _d.until = _e.now + ai_commands_travel_seconds(_e, _result, true, 1);
    _w.need_move = false;
    _w.phase = "move";
    _w.reason = "escape_from_threat";
    return UnknownEnum.Value_0;
}

function ai_withdrawal_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    _e.withdrawal.engaged = false;
    ai_spatial_release(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2
}
