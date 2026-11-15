function ai_investigation_create(arg0)
{
    arg0.investigation = 
    {
        active: false,
        engaged: false,
        first_pending: true,
        next_try: 0,
        checked: [],
        goal: undefined,
        phase: "idle",
        plan: undefined,
        reason: "idle"
    };
}

function __ai_investigation_player(arg0)
{
    var _target = arg0.knowledge.target;
    return arg0.knowledge.valid && instance_exists(_target) && (_target.object_index == obj_player_parent || object_is_ancestor(_target.object_index, obj_player_parent));
}

function ai_investigation_enabled_for(arg0)
{
    return arg0.profile.config.investigation.enabled && __ai_investigation_player(arg0);
}

function ai_investigation_reset(arg0)
{
    if (!variable_struct_exists(arg0, "investigation"))
    {
        exit;
    }
    arg0.investigation.plan = undefined;
    arg0.investigation.checked = [];
    arg0.investigation.next_try = 0;
    arg0.investigation.engaged = false;
    arg0.investigation.first_pending = true;
}

function __ai_investigation_fresh(arg0, arg1)
{
    var _age = max(0, ai_world_get().frame - arg1.frame) / 60;
    return arg0.knowledge.valid && arg1.target == arg0.knowledge.target && _age < min(arg1.lifetime, arg0.profile.config.investigation.memory_seconds) && ((arg0.now - _age) + 0.000001) >= arg0.knowledge.observed_at;
}

function ai_investigation_checked(arg0, arg1, arg2)
{
    if (!variable_struct_exists(arg0, "investigation") || !arg0.profile.config.investigation.enabled || !__ai_investigation_player(arg0))
    {
        return false;
    }
    var _entries = arg0.investigation.checked;
    var _focus = ai_contact_focus(arg0);
    var _frame = (_focus == arg0.knowledge) ? -1 : (__ai_hearing_source(_focus) ? _focus.frame : (ai_world_get().frame - (max(0, arg0.now - _focus.sampled_at) * 60)));
    for (var _i = 0; _i < array_length(_entries); _i++)
    {
        var _entry = _entries[_i];
        if (_frame > (_entry.frame + 0.000001) && point_distance(_entry.x, _entry.y, _focus.x, _focus.y) <= (_entry.radius + _focus.uncertainty))
        {
            continue;
        }
        if (__ai_investigation_fresh(arg0, _entry) && point_distance(arg1, arg2, _entry.x, _entry.y) <= (min(_entry.radius, arg0.profile.config.investigation.checked_radius_px) + 0.000001) && __ai_perception_in_view(_entry.ox, _entry.oy, arg1, arg2, _entry.direction, _entry.view) && __ai_spatial_clear_line(_entry.ox, _entry.oy, arg1, arg2))
        {
            return true;
        }
    }
    return false;
}

function __ai_investigation_store(arg0, arg1)
{
    var _entries = arg0.investigation.checked;
    for (var _i = 0; _i < array_length(_entries); _i++)
    {
        var _old = _entries[_i];
        if (_old.owner == arg1.owner && _old.frame == arg1.frame && _old.x == arg1.x && _old.y == arg1.y)
        {
            return false;
        }
    }
    while (array_length(_entries) >= arg0.profile.config.investigation.memory_limit)
    {
        array_delete(_entries, 0, 1);
    }
    array_push(_entries, arg1);
    arg0.investigation.checked = _entries;
    return true;
}

function ai_investigation_check(arg0, arg1, arg2)
{
    if (!variable_struct_exists(arg0, "investigation") || !arg0.profile.config.investigation.enabled || !__ai_investigation_player(arg0) || arg0.knowledge.visible || arg0.npc.grenade_flash)
    {
        return false;
    }
    var _view = __ai_perception_view(arg0.npc);
    if (!_view.enabled || !__ai_perception_in_view(arg0.npc.x, arg0.npc.y, arg1, arg2, arg0.npc.weapon_pointing_direction, _view) || !ai_world_position_valid(arg0, arg1, arg2) || !__ai_spatial_clear_line(arg0.npc.x, arg0.npc.y, arg1, arg2))
    {
        return false;
    }
    var _seen = __ai_perception_probe(arg0, arg0.knowledge.target, _view);
    if (is_struct(_seen))
    {
        __ai_perception_sight(arg0, arg0.knowledge.target, _seen);
        return false;
    }
    var _c = arg0.profile.config.investigation;
    var _radius = _c.checked_radius_px;
    while (_radius >= 2 && collision_rectangle(min(arg0.npc.x, arg1 - _radius), min(arg0.npc.y, arg2 - _radius), max(arg0.npc.x, arg1 + _radius), max(arg0.npc.y, arg2 + _radius), obj_solid, true, false))
    {
        _radius *= 0.5;
    }
    if (_radius < 2)
    {
        _radius = 0;
    }
    return __ai_investigation_store(arg0, 
    {
        target: arg0.knowledge.target,
        x: arg1,
        y: arg2,
        ox: arg0.npc.x,
        oy: arg0.npc.y,
        direction: arg0.npc.weapon_pointing_direction,
        view: _view,
        frame: ai_world_get().frame,
        owner: arg0.npc,
        shared: false,
        radius: _radius,
        lifetime: _c.memory_seconds
    });
}

function ai_investigation_share(arg0, arg1)
{
    if (!variable_struct_exists(arg0, "investigation") || !variable_struct_exists(arg1, "investigation") || !arg0.profile.config.investigation.enabled || !arg1.profile.config.investigation.enabled || !__ai_team_members(arg0, arg1) || !__ai_investigation_player(arg1) || arg1.knowledge.visible)
    {
        exit;
    }
    var _threshold = max(arg0.profile.config.investigation.share_teamwork_min, arg1.profile.config.investigation.share_teamwork_min);
    if (arg0.profile.personality.traits.teamwork < _threshold || arg1.profile.personality.traits.teamwork < _threshold || (variable_instance_exists(arg0.npc, "can_talk") && !arg0.npc.can_talk))
    {
        exit;
    }
    var _entries = arg0.investigation.checked;
    var _sent = 0;
    var _i = array_length(_entries) - 1;
    while (_i >= 0 && _sent < 2)
    {
        var _entry = _entries[_i];
        if (_entry.shared || !__ai_investigation_fresh(arg1, _entry))
        {
        }
        else
        {
            _sent++;
            var _copy = variable_clone(_entry);
            _copy.shared = true;
            __ai_investigation_store(arg1, _copy);
        }
        _i--;
    }
}

function ai_investigation_candidate(arg0, arg1)
{
    var _offsets = [0, 45, -45, 90, -90, 180];
    var _pocket = arg1 div 8;
    var _angle = arg0.search_direction + _offsets[_pocket % 6];
    var _radius = (arg0.config.pocket_radius_px * (1 + (_pocket div 6))) / 3;
    arg0.watch_x = arg0.threat_x + lengthdir_x(_radius, _angle);
    arg0.watch_y = arg0.threat_y + lengthdir_y(_radius, _angle);
    var _toward = point_direction(arg0.watch_x, arg0.watch_y, arg0.origin_x, arg0.origin_y);
    var _sides = [45, -45, 90, -90];
    var _distance = (arg0.config.viewpoint_radius_px * (1 + ((arg1 % 8) div 4))) / 2;
    return [arg0.watch_x + lengthdir_x(_distance, _toward + _sides[arg1 % 4]), arg0.watch_y + lengthdir_y(_distance, _toward + _sides[arg1 % 4])];
}

function ai_investigation_candidate_valid(arg0, arg1, arg2, arg3)
{
    var _plan = arg0.investigation.plan;
    if (is_struct(_plan))
    {
        for (var _n = 0; _n < array_length(_plan.failed); _n++)
        {
            if (point_distance(arg2, arg3, _plan.failed[_n].x, _plan.failed[_n].y) < 16)
            {
                return false;
            }
        }
    }
    return ai_world_position_valid(arg0, arg1.watch_x, arg1.watch_y) && (arg1.open_pockets || !__ai_spatial_clear_line(arg1.origin_x, arg1.origin_y, arg1.watch_x, arg1.watch_y)) && !ai_investigation_checked(arg0, arg1.watch_x, arg1.watch_y) && point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3) >= 16 && __ai_spatial_clear_line(arg2, arg3, arg1.watch_x, arg1.watch_y);
}

function ai_investigation_fire_opportunity(arg0)
{
    var _k = arg0.knowledge;
    if (!_k.valid || !_k.visible)
    {
        return false;
    }
    var _distance = point_distance(arg0.npc.x, arg0.npc.y, _k.x, _k.y);
    return _distance <= arg0.profile.config.relocation.route_close_px || ai_perception_aimed_at(arg0) || (arg0.perception.visible_steps >= 12 && _distance <= (arg0.combat.weapon_range * arg0.profile.config.spacing.far_ratio));
}

function ai_investigation_committed(arg0)
{
    var _p = arg0.investigation.plan;
    return is_struct(_p) && arg0.knowledge.valid && _p.target == arg0.knowledge.target && arg0.now < arg0.perception.search_until && !ai_investigation_fire_opportunity(arg0);
}

function ai_investigation_ready(arg0)
{
    var _e = arg0.user_data;
    var _i = _e.investigation;
    var _c = _e.profile.config.investigation;
    if (ai_investigation_committed(_e))
    {
        return __ai_human_ready(_e) && _e.now >= _e.withdrawal.until;
    }
    if (!_c.enabled || !__ai_human_ready(_e) || !__ai_investigation_player(_e) || _e.knowledge.visible || _e.now < _e.withdrawal.until || !_e.combat.lost_contact.chase_allowed || _e.combat.pursuit_allowed == false)
    {
        return false;
    }
    if (_i.active)
    {
        return true;
    }
    return _e.now >= _i.next_try && _e.now >= _e.combat.lost_contact.hold_until && (_e.perception.search_until <= 0 || _e.now < _e.perception.search_until) && ai_team_can_push(_e);
}

function ai_investigation_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    var _e = arg0.user_data;
    var _k = ai_contact_focus(_e);
    var _i = _e.investigation;
    var _resume = is_struct(_i.plan) && _i.plan.target == _k.target && _e.now < _e.perception.search_until;
    if (_resume)
    {
        arg1.data = _i.plan;
    }
    var _d = arg1.data;
    _i.active = true;
    _d.allowed = __ai_human_pursuit_allowed(_e);
    if (_d.allowed)
    {
        _i.engaged = true;
    }
    if (!_resume)
    {
        _d.target = _k.target;
        _d.threat = ai_movement_snapshot(_e);
        _d.threat.open_pockets = false;
        _d.result = undefined;
        _d.failed = [];
        _d.look_started = -1;
        _d.retry_at = _e.now;
        _d.until = _e.now + _e.profile.config.investigation.move_seconds;
        _d.sprint = _i.first_pending && _e.profile.config.investigation.first_inspection_sprint;
        _d.inspections = 0;
        if (_e.perception.search_until <= 0)
        {
            _e.perception.search_until = max(_e.now, _e.combat.lost_contact.search_at) + _e.profile.config.pursuit.search_seconds;
        }
    }
    _d.reclaim = _resume && is_struct(_d.result);
    _d.look_started = -1;
    if (_d.reclaim)
    {
        _d.result = variable_clone(_d.result);
        _d.result.token = arg1.token;
        _d.result.expires = _e.now + _e.profile.config.queries.retry_seconds;
        _d.until = min(_e.perception.search_until, _e.now + _e.profile.config.investigation.move_seconds + (point_distance(_e.npc.x, _e.npc.y, _d.result.x, _d.result.y) / max(0.1, __ai_human_speed(_e) * 60)));
    }
    _i.plan = _d;
    _i.goal = _d.result;
    _i.phase = is_struct(_d.result) ? "move" : "query";
    _i.reason = _resume ? "resume_inspection" : "pursue_hidden_area";
}

function __ai_investigation_next(arg0, arg1, arg2, arg3 = "inspected")
{
    var _d = arg1.data;
    var _i = arg0.investigation;
    if (arg3 != "inspected" && arg3 != "destination_busy" && is_struct(_d.result))
    {
        if (array_length(_d.failed) >= 8)
        {
            array_delete(_d.failed, 0, 1);
        }
        array_push(_d.failed, 
        {
            x: _d.result.x,
            y: _d.result.y
        });
    }
    ai_commands_stop(arg0, arg1.token);
    ai_spatial_release(arg0);
    if (arg2 > 0)
    {
        ai_team_release(arg0);
    }
    _d.result = undefined;
    _d.reclaim = false;
    _d.look_started = -1;
    _d.busy_since = -1;
    _d.retry_at = arg0.now + arg2;
    _d.until = _d.retry_at + arg0.profile.config.investigation.move_seconds;
    var _next = ai_movement_snapshot(arg0);
    if (_next.revision != _d.threat.revision || _next.x != _d.threat.x || _next.y != _d.threat.y || _next.tracking_serial != _d.threat.tracking_serial)
    {
        _d.threat = _next;
        _d.threat.open_pockets = false;
    }
    _d.tracking_correction = undefined;
    if (variable_struct_exists(_d, "tracking_attempt"))
    {
        variable_struct_remove(_d, "tracking_attempt");
    }
    _i.goal = undefined;
    _i.phase = (arg2 > 0) ? "watch" : "query";
    _i.reason = arg3;
}

function ai_investigation_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _d = arg1.data;
    var _k = _e.knowledge;
    var _i = _e.investigation;
    if (!_d.allowed || !_k.valid || _k.target != _d.target)
    {
        return UnknownEnum.Value_1;
    }
    if (ai_investigation_fire_opportunity(_e))
    {
        _i.reason = "useful_sight";
        return UnknownEnum.Value_1;
    }
    if (_e.now >= _e.perception.search_until)
    {
        if (_k.visible)
        {
            _i.plan = undefined;
            _e.perception.search_until = 0;
        }
        else
        {
            ai_perception_forget(_e, "investigation_complete");
        }
        return UnknownEnum.Value_1;
    }
    var _c = _e.profile.config.investigation;
    if (_e.now < _d.retry_at)
    {
        ai_commands_aim(_e, arg1.token, _d.threat.x, _d.threat.y);
        return UnknownEnum.Value_0;
    }
    if (_e.now >= _d.until)
    {
        __ai_investigation_next(_e, arg1, 0, "travel_timeout");
        return UnknownEnum.Value_0;
    }
    if (_e.team.push_slot < 0 && !ai_team_begin_push(_e, arg1.token))
    {
        ai_commands_stop(_e, arg1.token);
        _i.reason = "waiting_for_ally";
        return UnknownEnum.Value_0;
    }
    if (_d.reclaim)
    {
        _d.result.expires = _e.now + _e.profile.config.queries.retry_seconds;
        if (!ai_spatial_claim(_e, _d.result, arg1.token))
        {
            _valid = ai_spatial_progress(_e, arg1, _d.result);
            if (_valid != "waiting")
            {
                __ai_investigation_next(_e, arg1, 0, (_valid == "busy") ? "destination_busy" : "resume_blocked");
            }
            return UnknownEnum.Value_0;
        }
        _d.reclaim = false;
    }
    if (is_undefined(_d.result))
    {
        _i.phase = "query";
        _r = ai_spatial_query(_e, "investigate", arg1.token, _d.threat);
        if (_r.status == "DEFERRED")
        {
            return UnknownEnum.Value_0;
        }
        if (_r.status != "FOUND" || !ai_spatial_claim(_e, _r, arg1.token))
        {
            var _open = _d.threat.open_pockets;
            __ai_investigation_next(_e, arg1, _open ? _c.retry_seconds : 0, "no_reachable_pocket");
            _d.threat.open_pockets = !_open;
            return UnknownEnum.Value_0;
        }
        _d.result = _r;
        _d.run = _d.sprint || _r.route_length >= 48;
        _d.until = min(_e.perception.search_until, _e.now + ai_commands_travel_seconds(_e, _r, _d.run, _c.move_seconds) + _c.inspect_seconds);
        _i.goal = _r;
        _i.phase = "move";
        _i.reason = "committed_viewpoint";
    }
    if (_d.look_started < 0 && ai_spatial_tracking_correct(_e, arg1, "investigate", _d.run, _c.move_seconds, _c.inspect_seconds))
    {
        _i.goal = _d.result;
        _i.reason = "tracking_correction";
    }
    var _r = _d.result;
    var _valid = ai_spatial_progress(_e, arg1, _r);
    if (_valid == "waiting")
    {
        _i.reason = "passing_ally";
        return UnknownEnum.Value_0;
    }
    if (_valid != "valid")
    {
        __ai_investigation_next(_e, arg1, 0, (_valid == "busy") ? "destination_busy" : "destination_blocked");
        return UnknownEnum.Value_0;
    }
    ai_commands_aim(_e, arg1.token, _k.visible ? _k.x : _r.watch_x, _k.visible ? _k.y : _r.watch_y);
    var _move = ai_commands_move_position(_e, arg1.token, _r, ai_commands_transfer_speed(_e, _r, _d.run));
    if (_move == "failed")
    {
        __ai_investigation_next(_e, arg1, 0, "path_failed");
        return UnknownEnum.Value_0;
    }
    if (_move != "arrived")
    {
        return UnknownEnum.Value_0;
    }
    _i.first_pending = false;
    _d.sprint = false;
    ai_commands_stop(_e, arg1.token);
    _i.phase = "look";
    if (_k.visible)
    {
        _i.plan = undefined;
        _e.perception.search_until = 0;
        _i.reason = "target_located";
        return UnknownEnum.Value_1;
    }
    if (abs(angle_difference(point_direction(_e.npc.x, _e.npc.y, _r.watch_x, _r.watch_y), _e.npc.weapon_pointing_direction)) > 15)
    {
        _d.look_started = -1;
        return UnknownEnum.Value_0;
    }
    if (_d.look_started < 0)
    {
        _d.look_started = _e.now;
    }
    if ((_e.now - _d.look_started) < _c.inspect_seconds)
    {
        return UnknownEnum.Value_0;
    }
    if (_k.visible)
    {
        return UnknownEnum.Value_0;
    }
    var _checked = ai_investigation_check(_e, _r.watch_x, _r.watch_y);
    if (_e.knowledge.visible)
    {
        return UnknownEnum.Value_0;
    }
    _d.inspections++;
    __ai_investigation_next(_e, arg1, 0, _checked ? "inspected" : "inspection_blocked");
    return UnknownEnum.Value_0;
}

function ai_investigation_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    var _i = _e.investigation;
    _i.active = false;
    _i.goal = undefined;
    _i.phase = "idle";
    var _resume = __ai_profile_contains(["preempted", "guard_failed", "sight_reacquired", "success"], arg2) && is_struct(_i.plan) && _e.knowledge.valid && _i.plan.target == _e.knowledge.target && _e.now < _e.perception.search_until;
    if (!_resume)
    {
        _i.plan = undefined;
    }
    _i.next_try = _resume ? _e.now : (_e.now + _e.profile.config.investigation.retry_seconds);
    ai_spatial_release(_e);
    ai_team_release(_e);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function ai_investigation_draw(arg0)
{
    var _colour = draw_get_color();
    var _alpha = draw_get_alpha();
    var _goal = arg0.investigation.goal;
    if (is_struct(_goal))
    {
        draw_set_color(c_yellow);
        draw_set_alpha(0.8);
        draw_circle(_goal.watch_x, _goal.watch_y, 5, true);
        draw_set_color(c_aqua);
        draw_circle(_goal.x, _goal.y, 4, true);
        draw_line(_goal.x, _goal.y, _goal.watch_x, _goal.watch_y);
    }
    var _entries = arg0.investigation.checked;
    for (var _i = 0; _i < array_length(_entries); _i++)
    {
        var _entry = _entries[_i];
        if (!__ai_investigation_fresh(arg0, _entry))
        {
            continue;
        }
        draw_set_alpha(0.6);
        draw_set_color(_entry.shared ? c_lime : c_green);
        draw_circle(_entry.x, _entry.y, 3, true);
    }
    draw_set_color(_colour);
    draw_set_alpha(_alpha);
}

function ai_cover_current(arg0)
{
    if (!variable_struct_exists(arg0, "cover_assessment") || !is_struct(arg0.cover_assessment))
    {
        return undefined;
    }
    var _a = arg0.cover_assessment;
    var _c = arg0.profile.config.cover_assessment;
    var _k = arg0.knowledge;
    if (!_c.enabled || !_k.valid || _a.target != _k.target || !is_struct(_a.result) || (arg0.now - _k.observed_at) > _c.evidence_seconds || point_distance(_a.anchor_x, _a.anchor_y, _k.x, _k.y) > 16 || ((ai_world_get().frame - _a.result.frame) / 60) > (_c.refresh_seconds * 2))
    {
        return undefined;
    }
    return _a.result;
}

function __ai_cover_cache(arg0)
{
    if (!variable_struct_exists(arg0, "cover_cache"))
    {
        arg0.cover_cache = array_create(16, undefined);
        arg0.cover_cursor = 0;
    }
}

function __ai_cover_finish(arg0, arg1, arg2)
{
    var _c = arg0.profile.config.cover_assessment;
    var _kind = "open";
    var _near = 0;
    var _span = 0;
    if (arg2.invalid)
    {
        _kind = "unclear";
    }
    else
    {
        for (var _i = 0; _i < array_length(arg2.components); _i++)
        {
            var _part = arg2.components[_i];
            if (_part.distance > _c.near_radius_px)
            {
                continue;
            }
            _near++;
            _span = max(_span, _part.span);
            if (_kind == "open")
            {
                _kind = "isolated";
            }
            if (_part.span >= _c.continuous_span_px || _part.wraps)
            {
                _kind = "continuous";
            }
        }
    }
    arg1.result = 
    {
        kind: _kind,
        x: arg1.x,
        y: arg1.y,
        frame: arg2.frame,
        solid_cells: arg2.solid_cells,
        near_components: _near,
        largest_span: _span,
        pocket: arg1.pocket
    };
    arg1.cells = undefined;
    arg1.phase = "done";
    arg1.next_at = arg0.now + _c.refresh_seconds;
}

function __ai_cover_components(arg0)
{
    var _parts = [];
    var _cells = arg0.cells;
    var _count = array_length(_cells);
    var _queue = array_create(_count, 0);
    var _size = arg0.cell_size;
    for (var _i = 0; _i < _count; _i++)
    {
        if (_cells[_i] != 1)
        {
            continue;
        }
        var _head = 0;
        var _tail = 1;
        var _distance = 1000000000;
        var _left = room_width;
        var _right = 0;
        var _top = room_height;
        var _bottom = 0;
        _queue[0] = _i;
        _cells[_i] = 2;
        while (_head < _tail)
        {
            var _index = _queue[_head++];
            var _col = _index % arg0.columns;
            var _row = _index div arg0.columns;
            var _x = arg0.grid_x + (_col * _size);
            var _y = arg0.grid_y + (_row * _size);
            _left = min(_left, _x);
            _right = max(_right, _x + _size);
            _top = min(_top, _y);
            _bottom = max(_bottom, _y + _size);
            _distance = min(_distance, point_distance(arg0.x, arg0.y, clamp(arg0.x, _x, _x + _size), clamp(arg0.y, _y, _y + _size)));
            for (var _side = 0; _side < 4; _side++)
            {
                var _next = -1;
                if (_side == 0 && _col > 0)
                {
                    _next = _index - 1;
                }
                if (_side == 1 && (_col + 1) < arg0.columns)
                {
                    _next = _index + 1;
                }
                if (_side == 2 && _row > 0)
                {
                    _next = _index - arg0.columns;
                }
                if (_side == 3 && (_row + 1) < arg0.rows)
                {
                    _next = _index + arg0.columns;
                }
                if (_next >= 0 && _cells[_next] == 1)
                {
                    _cells[_next] = 2;
                    _queue[_tail++] = _next;
                }
            }
        }
        array_push(_parts, 
        {
            distance: _distance,
            span: max(_right - _left, _bottom - _top),
            wraps: _left < (arg0.x - _size) && _right > (arg0.x + _size) && _top < (arg0.y - _size) && _bottom > (arg0.y + _size)
        });
    }
    return _parts;
}

function ai_cover_step(arg0)
{
    var _c = arg0.profile.config.cover_assessment;
    var _k = arg0.knowledge;
    if (!_c.enabled || !__ai_investigation_player(arg0) || arg0.npc.grenade_flash || (arg0.now - _k.observed_at) > _c.evidence_seconds)
    {
        exit;
    }
    var _world = ai_world_get();
    __ai_cover_cache(_world);
    if (!variable_struct_exists(arg0, "cover_assessment"))
    {
        arg0.cover_assessment = undefined;
    }
    var _a = arg0.cover_assessment;
    if (!is_struct(_a) || _a.target != _k.target || point_distance(_a.anchor_x, _a.anchor_y, _k.x, _k.y) > 16 || (_a.phase == "done" && arg0.now >= _a.next_at))
    {
        _a = 
        {
            target: _k.target,
            anchor_x: _k.x,
            anchor_y: _k.y,
            x: _k.x,
            y: _k.y,
            origin_x: arg0.npc.x,
            origin_y: arg0.npc.y,
            pocket: false,
            cursor: 0,
            phase: _k.visible ? "cache" : "pocket",
            solid_cells: 0,
            until: arg0.now + 2,
            next_at: 0,
            result: undefined,
            direction: arg0.perception.escape_valid ? arg0.perception.escape_direction : point_direction(_k.engagement_x, _k.engagement_y, _k.x, _k.y)
        };
        var _goal = arg0.investigation.goal;
        if (!_k.visible && is_struct(_goal) && point_distance(_goal.watch_x, _goal.watch_y, _k.x, _k.y) <= _c.radius_px)
        {
            _a.x = _goal.watch_x;
            _a.y = _goal.watch_y;
            _a.pocket = true;
            _a.phase = "cache";
        }
        arg0.cover_assessment = _a;
    }
    if (_a.phase == "done")
    {
        exit;
    }
    if (arg0.now >= _a.until)
    {
        _a.cells = undefined;
        _a.phase = "done";
        _a.next_at = arg0.now + _c.refresh_seconds;
        exit;
    }
    for (var _work = 0; _work < 4; _work++)
    {
        if (!ai_world_take_candidate(arg0))
        {
            exit;
        }
        if (_a.phase == "pocket")
        {
            var _request = 
            {
                search_direction: _a.direction,
                threat_x: _a.anchor_x,
                threat_y: _a.anchor_y,
                origin_x: _a.origin_x,
                origin_y: _a.origin_y,
                config: 
                {
                    pocket_radius_px: _c.radius_px,
                    viewpoint_radius_px: 32
                }
            };
            ai_investigation_candidate(_request, _a.cursor * 8);
            var _x = _request.watch_x;
            var _y = _request.watch_y;
            if (_x >= 4 && _y >= 4 && _x < (room_width - 4) && _y < (room_height - 4) && !collision_circle(_x, _y, 4, obj_solid, true, false) && !__ai_spatial_clear_line(_a.origin_x, _a.origin_y, _x, _y) && !ai_investigation_checked(arg0, _x, _y))
            {
                _a.x = _x;
                _a.y = _y;
                _a.pocket = true;
                _a.phase = "cache";
            }
            else
            {
                _a.cursor++;
                if (_a.cursor >= 18)
                {
                    _a.phase = "cache";
                }
            }
        }
        else
        {
            if (_a.phase == "cache")
            {
                if (collision_circle(_a.x, _a.y, 4, obj_solid, true, false))
                {
                    __ai_cover_finish(arg0, _a, 
                    {
                        invalid: true,
                        solid_cells: 0,
                        components: [],
                        frame: _world.frame
                    });
                    exit;
                }
                for (var _i = 0; _i < 16; _i++)
                {
                    var _cached = _world.cover_cache[_i];
                    if (is_struct(_cached) && _cached.radius == _c.radius_px && _cached.x == _a.x && _cached.y == _a.y && ((_world.frame - _cached.frame) / 60) <= _c.refresh_seconds)
                    {
                        __ai_cover_finish(arg0, _a, _cached);
                        exit;
                    }
                }
                _a.cell_size = 16 * max(1, ceil(_c.radius_px / 128));
                _a.grid_x = floor((_a.x - _c.radius_px) / _a.cell_size) * _a.cell_size;
                _a.grid_y = floor((_a.y - _c.radius_px) / _a.cell_size) * _a.cell_size;
                _a.columns = ceil(((_a.x + _c.radius_px) - _a.grid_x) / _a.cell_size);
                _a.rows = ceil(((_a.y + _c.radius_px) - _a.grid_y) / _a.cell_size);
                _a.cells = array_create(_a.columns * _a.rows, 0);
                _a.phase = "cells";
                _a.cursor = 0;
            }
            var _count = array_length(_a.cells);
            var _size = _a.cell_size;
            repeat (8)
            {
                if (_a.cursor >= _count)
                {
                    break;
                }
                var _x = _a.grid_x + ((_a.cursor % _a.columns) * _size);
                var _y = _a.grid_y + ((_a.cursor div _a.columns) * _size);
                if (point_distance(_a.x, _a.y, _x + (_size / 2), _y + (_size / 2)) <= _c.radius_px && _x >= 0 && _y >= 0 && (_x + _size) <= room_width && (_y + _size) <= room_height && collision_rectangle(_x, _y, (_x + _size) - 1, (_y + _size) - 1, obj_solid, true, false))
                {
                    _a.cells[_a.cursor] = 1;
                    _a.solid_cells++;
                }
                _a.cursor++;
            }
            if (_a.cursor >= _count)
            {
                var _geometry = 
                {
                    x: _a.x,
                    y: _a.y,
                    radius: _c.radius_px,
                    invalid: false,
                    solid_cells: _a.solid_cells,
                    components: __ai_cover_components(_a),
                    frame: _world.frame
                };
                _world.cover_cache[_world.cover_cursor] = _geometry;
                _world.cover_cursor = (_world.cover_cursor + 1) % 16;
                __ai_cover_finish(arg0, _a, _geometry);
                exit;
            }
        }
    }
}

function ai_cover_draw(arg0)
{
    var _r = ai_cover_current(arg0);
    if (!is_struct(_r))
    {
        exit;
    }
    var _colour = draw_get_color();
    var _alpha = draw_get_alpha();
    draw_set_color((_r.kind == "isolated") ? c_orange : ((_r.kind == "continuous") ? c_purple : ((_r.kind == "open") ? c_lime : c_gray)));
    draw_set_alpha(0.6);
    draw_circle(_r.x, _r.y, arg0.profile.config.cover_assessment.radius_px, true);
    draw_set_alpha(1);
    draw_text(_r.x + 6, _r.y + 6, "cover: " + _r.kind + (_r.pocket ? " ?" : "") + " [" + string(_r.near_components) + " nearby]");
    draw_set_color(_colour);
    draw_set_alpha(_alpha);
}

enum UnknownEnum
{
    Value_0,
    Value_1
}
