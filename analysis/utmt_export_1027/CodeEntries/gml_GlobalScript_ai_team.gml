function ai_team_create(arg0)
{
    arg0.team = 
    {
        last_step: -1,
        next_report: 0,
        next_callout: 0,
        cursor: 0,
        contact_packet: undefined,
        contact_remaining: 0,
        support: undefined,
        serial: 0,
        received: [],
        received_cursor: 0,
        legacy_received: [],
        legacy_cursor: 0,
        push_slot: -1,
        reload_packet: undefined,
        reload_cursor: 0,
        reload_remaining: 0,
        reload_report_at: 0,
        nearby: noone,
        fighting_ally: noone,
        nearby_cursor: 0,
        nearby_next: 0,
        approach_neighbors: [],
        fired: undefined,
        flank_checks: 0,
        flank_check_step: -1,
        scans: 0,
        delivered: 0,
        reports: 0,
        last_reason: "initial"
    };
}

function ai_team_nearby_ally(arg0)
{
    var _other = __ai_team_execution(arg0.team.nearby);
    return (is_struct(_other) && __ai_team_members(arg0, _other)) ? _other : undefined;
}

function __ai_team_can_support_combat(arg0, arg1)
{
    if (!is_struct(arg1) || !variable_struct_exists(arg1, "active") || !arg1.active || !__ai_team_members(arg0, arg1))
    {
        return false;
    }
    var _c = arg0.profile.config.defensive_reposition;
    return arg0.knowledge.valid && arg1.knowledge.valid && arg0.knowledge.target == arg1.knowledge.target && !arg1.npc.grenade_flash && !arg1.npc.reloading && arg1.npc.ammo_now > 0 && (arg1.knowledge.visible || (arg1.now - arg1.knowledge.observed_at) <= _c.support_memory_seconds) && point_distance(arg0.npc.x, arg0.npc.y, arg1.npc.x, arg1.npc.y) <= _c.support_radius_px;
}

function ai_team_combat_ally(arg0)
{
    var _other = __ai_team_execution(arg0.team.fighting_ally);
    return __ai_team_can_support_combat(arg0, _other) ? _other : undefined;
}

function __ai_team_nearby_step(arg0)
{
    if (!arg0.knowledge.valid || arg0.now < arg0.team.nearby_next)
    {
        exit;
    }
    arg0.team.nearby_next = arg0.now + 0.1;
    var _other = ai_team_nearby_ally(arg0);
    if (is_undefined(_other))
    {
        arg0.team.nearby = -4;
    }
    if (is_undefined(ai_team_combat_ally(arg0)))
    {
        arg0.team.fighting_ally = -4;
    }
    var _distance = is_undefined(_other) ? 1000000000 : point_distance(arg0.npc.x, arg0.npc.y, _other.npc.x, _other.npc.y);
    var _count = instance_number(obj_npc_parent);
    var _limit = min(4, _count, 12 - arg0.team.scans);
    for (var _i = 0; _i < _limit; _i++)
    {
        var _npc = instance_find(obj_npc_parent, (arg0.team.nearby_cursor + _i) % _count);
        arg0.team.scans++;
        var _candidate = __ai_team_execution(_npc);
        if (!is_struct(_candidate) || !__ai_team_members(arg0, _candidate))
        {
            continue;
        }
        __ai_team_approach_note(arg0, _candidate);
        if (__ai_team_can_support_combat(arg0, _candidate))
        {
            arg0.team.fighting_ally = _npc;
        }
        ai_investigation_share(_candidate, arg0);
        ai_hearing_share(arg0, _candidate);
        ai_hearing_share(_candidate, arg0);
        ai_team_flash_share(arg0, _candidate);
        ai_team_flash_share(_candidate, arg0);
        var _d = point_distance(arg0.npc.x, arg0.npc.y, _npc.x, _npc.y);
        if (_d < _distance)
        {
            _distance = _d;
            arg0.team.nearby = _npc;
        }
    }
    if (_count > 0)
    {
        arg0.team.nearby_cursor = (arg0.team.nearby_cursor + _limit) % _count;
    }
}

function ai_team_flash_share(arg0, arg1)
{
    if (!variable_struct_exists(arg1, "combat") || !variable_struct_exists(arg0.perception, "flash") || !variable_struct_exists(arg1.perception, "flash") || !variable_struct_exists(arg1.combat, "adaptation"))
    {
        return false;
    }
    var _flash = arg0.perception.flash;
    var _old = arg1.perception.flash;
    var _config = arg1.profile.config.flash_push;
    if (!is_struct(_flash) || !_flash.active || _flash.shared || !_config.enabled || !arg0.profile.config.flash_push.enabled || arg0.npc.grenade_flash || arg1.npc.grenade_flash || !__ai_team_members(arg0, arg1) || !arg1.knowledge.valid || arg1.knowledge.target != _flash.target || arg1.knowledge.visible || arg1.profile.personality.traits.teamwork < _config.report_teamwork_min || arg0.profile.personality.traits.teamwork < arg0.profile.config.flash_push.report_teamwork_min)
    {
        return false;
    }
    var _age = max(0, ai_world_get().frame - _flash.frame) / 60;
    if (_age >= _flash.remaining || _age > arg1.now || _age > min(arg0.profile.config.communication.report_max_age_seconds, arg1.profile.config.communication.report_max_age_seconds))
    {
        return false;
    }
    if (is_struct(_old) && _old.target == _flash.target && (_old.frame >= _flash.frame || (_old.active && _old.effect == _flash.effect)))
    {
        return false;
    }
    arg1.perception.flash = 
    {
        target: _flash.target,
        effect: _flash.effect,
        active: true,
        shared: true,
        x: _flash.x,
        y: _flash.y,
        frame: _flash.frame,
        remaining: _flash.remaining
    };
    return __ai_human_opportunity_notice(arg1, "flash_push", _flash.target, _flash.x, _flash.y, _age, true, _flash.remaining);
}

function __ai_team_execution(arg0)
{
    if (!instance_exists(arg0) || !variable_instance_exists(arg0, "ai_execution"))
    {
        return undefined;
    }
    var _e = arg0.ai_execution;
    if (!is_struct(_e) || !variable_struct_exists(_e, "team") || _e.npc != arg0 || _e.profile.config.tree != "human_basic" || arg0.hp <= 0 || arg0.state != "human_general" || arg0.force_moving_towards_player)
    {
        return undefined;
    }
    return _e;
}

function __ai_team_id(arg0)
{
    return variable_instance_exists(arg0, "ai_team_id") ? arg0.ai_team_id : undefined;
}

function __ai_team_members(arg0, arg1)
{
    if (arg0 == arg1 || arg0.npc.faction != arg1.npc.faction)
    {
        return false;
    }
    if (faction_get_rep_temp(arg0.npc.faction, arg1.npc.faction) < 250)
    {
        return false;
    }
    var _a_id = __ai_team_id(arg0.npc);
    var _b_id = __ai_team_id(arg1.npc);
    if (arg0.profile.config.profile == "hunter" || arg1.profile.config.profile == "hunter")
    {
        if (is_undefined(_a_id) || is_undefined(_b_id) || _a_id != _b_id)
        {
            return false;
        }
    }
    else if (!is_undefined(_a_id) && !is_undefined(_b_id) && _a_id != _b_id)
    {
        return false;
    }
    return point_distance(arg0.npc.x, arg0.npc.y, arg1.npc.x, arg1.npc.y) <= min(arg0.profile.config.communication.radius_px, arg1.profile.config.communication.radius_px);
}

function ai_team_announce_death(arg0)
{
    if (!ai_human_migrated(arg0) || arg0.hp > 0)
    {
        exit;
    }
    var _dead_execution = arg0.ai_execution;
    with (obj_npc_parent)
    {
        if (id == arg0)
        {
            continue;
        }
        var _witness_execution = __ai_team_execution(id);
        if (is_undefined(_witness_execution) || !__ai_team_members(_witness_execution, _dead_execution))
        {
            continue;
        }
        if (collision_line(x, y, arg0.x, arg0.y, obj_solid, true, false) != -4)
        {
            continue;
        }
        ai_compat_callout(id, "ally_down");
    }
}

function __ai_team_deliver(arg0, arg1, arg2)
{
    if (!__ai_team_members(arg0, arg1))
    {
        return false;
    }
    var _age = arg2.age + (max(0, ai_world_get().frame - arg2.frame) / 60);
    var _max_age = min(arg0.profile.config.communication.report_max_age_seconds, arg1.profile.config.communication.report_max_age_seconds);
    if (_age > _max_age || (arg1.now - _age) < 0 || arg1.knowledge.visible)
    {
        return false;
    }
    var _seen = arg1.team.received;
    for (var _i = 0; _i < array_length(_seen); _i++)
    {
        if (_seen[_i].sender == arg0.npc && _seen[_i].serial == arg2.serial && _seen[_i].frame == arg2.frame)
        {
            return false;
        }
    }
    if (!ai_perception_observe(arg1, arg2.target, arg2.x, arg2.y, "ally_report", arg1.now - _age, arg2.uncertainty))
    {
        return false;
    }
    var _entry = 
    {
        sender: arg0.npc,
        serial: arg2.serial,
        frame: arg2.frame
    };
    if (array_length(_seen) < 16)
    {
        array_push(_seen, _entry);
    }
    else
    {
        _seen[arg1.team.received_cursor] = _entry;
    }
    arg1.team.received = _seen;
    arg1.team.received_cursor = (arg1.team.received_cursor + 1) % 16;
    if (variable_struct_exists(arg2, "direct_sight") && arg2.direct_sight)
    {
        arg1.team.support = 
        {
            target: arg2.target,
            frame: arg2.frame,
            age: arg2.age
        };
        ai_tracking_sighting(arg1, true);
    }
    arg1.team.last_reason = "received";
    __ai_team_approach_note(arg1, arg0);
    return true;
}

function __ai_team_approach_note(arg0, arg1)
{
    if ((!arg0.profile.config.approach.enabled && !arg0.profile.config.flank_opportunity.enabled) || !arg1.knowledge.valid || !arg0.knowledge.valid || arg1.knowledge.target != arg0.knowledge.target)
    {
        exit;
    }
    var _list = arg0.team.approach_neighbors;
    var _frame = ai_world_get().frame;
    var _i = array_length(_list) - 1;
    while (_i >= 0)
    {
        if (_list[_i].npc == arg1.npc || (_frame - _list[_i].frame) > 60)
        {
            array_delete(_list, _i, 1);
        }
        _i--;
    }
    if (array_length(_list) >= 6)
    {
        array_delete(_list, 0, 1);
    }
    array_push(_list, 
    {
        npc: arg1.npc,
        frame: _frame
    });
    arg0.team.approach_neighbors = _list;
}

function ai_team_approach_neighbors(arg0)
{
    var _result = [];
    var _ids = [];
    var _world = __ai_team_slots();
    var _list = arg0.team.approach_neighbors;
    for (var _i = 0; _i < (32 + array_length(_list)); _i++)
    {
        var _npc = -4;
        if (_i < 32)
        {
            var _lease = _world.pushers[_i];
            if (__ai_team_lease_valid(_lease, _world.frame))
            {
                _npc = _lease.npc;
            }
        }
        else if ((_world.frame - _list[_i - 32].frame) <= 60)
        {
            _npc = _list[_i - 32].npc;
        }
        if (__ai_profile_contains(_ids, _npc))
        {
            continue;
        }
        var _other = __ai_team_execution(_npc);
        if (!is_struct(_other) || !__ai_team_members(arg0, _other) || !_other.knowledge.valid || _other.knowledge.target != arg0.knowledge.target)
        {
            continue;
        }
        array_push(_ids, _npc);
        var _entry = 
        {
            x: _npc.x,
            y: _npc.y,
            goal: false,
            gx: 0,
            gy: 0
        };
        var _key = (variable_struct_exists(_other, "spatial") && is_struct(_other.spatial)) ? _other.spatial.claim_key : undefined;
        if (!is_undefined(_key))
        {
            var _claim = variable_struct_get(_world.claims, _key);
            if (is_struct(_claim) && _claim.owner == _npc && _claim.expires >= _world.frame && __ai_commands_active(_other, _claim.token))
            {
                _entry.goal = true;
                _entry.gx = _claim.x;
                _entry.gy = _claim.y;
            }
        }
        array_push(_result, _entry);
        if (array_length(_result) >= 6)
        {
            break;
        }
    }
    return _result;
}

function __ai_team_slots()
{
    var _world = ai_world_get();
    if (!variable_struct_exists(_world, "pushers"))
    {
        _world.pushers = array_create(32, undefined);
    }
    return _world;
}

function ai_team_note_fire(arg0)
{
    if (!variable_struct_exists(arg0, "team"))
    {
        exit;
    }
    var _old = arg0.team.fired;
    var _frame = ai_world_get().frame;
    var _since = (is_struct(_old) && _old.target == arg0.knowledge.target && (_frame - _old.frame) <= (arg0.profile.config.flank_opportunity.ally_fire_seconds * 60)) ? _old.since_frame : _frame;
    arg0.team.fired = 
    {
        target: arg0.knowledge.target,
        frame: _frame,
        since_frame: _since
    };
}

function __ai_team_flank_count(arg0, arg1)
{
    if (arg0.team.flank_check_step != arg0.step)
    {
        arg0.team.flank_checks = 0;
        arg0.team.flank_check_step = arg0.step;
    }
    arg0.team.flank_checks += arg1;
}

function __ai_team_flank_peer(arg0, arg1)
{
    __ai_team_flank_count(arg0, 1);
    if ((ai_world_get().frame - arg1.frame) > 60)
    {
        return undefined;
    }
    var _other = __ai_team_execution(arg1.npc);
    if (!is_struct(_other) || !__ai_team_members(arg0, _other) || !_other.knowledge.valid || _other.knowledge.target != arg0.knowledge.target)
    {
        return undefined;
    }
    return _other;
}

function ai_team_covering_fire(arg0)
{
    var _list = arg0.team.approach_neighbors;
    var _frame = ai_world_get().frame;
    var _best = undefined;
    for (var _i = 0; _i < array_length(_list); _i++)
    {
        var _other = __ai_team_flank_peer(arg0, _list[_i]);
        if (!is_struct(_other) || _other.npc.reloading || _other.npc.grenade_flash || _other.npc.ammo_now <= 0)
        {
            continue;
        }
        var _f = _other.team.fired;
        if (!is_struct(_f) || _f.target != arg0.knowledge.target || (_frame - _f.frame) > (arg0.profile.config.flank_opportunity.ally_fire_seconds * 60))
        {
            continue;
        }
        if (!is_struct(_best) || _f.frame > _best.frame)
        {
            _best = 
            {
                npc: _other.npc,
                frame: _f.frame,
                since_frame: _f.since_frame
            };
        }
    }
    return _best;
}

function ai_team_observed_aim_ally(arg0, arg1, arg2, arg3)
{
    var _list = arg0.team.approach_neighbors;
    var _best = -4;
    var _angle = arg0.profile.config.flank_opportunity.aim_cone_degrees;
    if (abs(angle_difference(arg3, point_direction(arg1, arg2, arg0.npc.x, arg0.npc.y))) <= _angle)
    {
        return -4;
    }
    for (var _i = 0; _i < array_length(_list); _i++)
    {
        var _other = __ai_team_flank_peer(arg0, _list[_i]);
        if (!is_struct(_other))
        {
            continue;
        }
        var _difference = abs(angle_difference(arg3, point_direction(arg1, arg2, _other.npc.x, _other.npc.y)));
        if (_difference <= _angle)
        {
            _angle = _difference;
            _best = _other.npc;
        }
    }
    return _best;
}

function ai_team_relocation_wait_frame(arg0)
{
    var _world = ai_world_get();
    var _until = _world.frame;
    if (!arg0.profile.config.flank_opportunity.enabled)
    {
        return _until;
    }
    if (!variable_struct_exists(_world, "relocation_starts"))
    {
        _world.relocation_starts = array_create(32, undefined);
    }
    for (var _i = 0; _i < 32; _i++)
    {
        __ai_team_flank_count(arg0, 1);
        var _r = _world.relocation_starts[_i];
        if (!is_struct(_r) || _r.expires <= _world.frame)
        {
            continue;
        }
        var _other = __ai_team_execution(_r.npc);
        if (!is_struct(_other) || !_other.knowledge.valid || _other.knowledge.target != _r.target)
        {
            _world.relocation_starts[_i] = undefined;
        }
        else if (_r.target == arg0.knowledge.target && __ai_team_members(arg0, _other))
        {
            _until = max(_until, _r.expires);
        }
    }
    return _until;
}

function ai_team_relocation_begin(arg0, arg1)
{
    if (!arg0.profile.config.flank_opportunity.enabled)
    {
        return true;
    }
    if (!__ai_commands_active(arg0, arg1) || !arg0.knowledge.valid)
    {
        return false;
    }
    var _world = ai_world_get();
    if (ai_team_relocation_wait_frame(arg0) > _world.frame)
    {
        return false;
    }
    for (var _i = 0; _i < 32; _i++)
    {
        var _r = _world.relocation_starts[_i];
        if (is_struct(_r) && _r.expires > _world.frame)
        {
            continue;
        }
        _world.relocation_starts[_i] = 
        {
            npc: arg0.npc,
            token: arg1,
            target: arg0.knowledge.target,
            expires: _world.frame + ceil(arg0.profile.config.flank_opportunity.stagger_seconds * 60)
        };
        return true;
    }
    return false;
}

function ai_team_relocation_finish(arg0, arg1, arg2)
{
    var _world = ai_world_get();
    if (arg2 || !variable_struct_exists(_world, "relocation_starts"))
    {
        exit;
    }
    for (var _i = 0; _i < 32; _i++)
    {
        var _r = _world.relocation_starts[_i];
        if (is_struct(_r) && _r.npc == arg0.npc && _r.token == arg1)
        {
            _world.relocation_starts[_i] = undefined;
        }
    }
}

function __ai_team_lease_valid(arg0, arg1)
{
    if (!is_struct(arg0) || arg0.expires <= arg1)
    {
        return false;
    }
    var _e = __ai_team_execution(arg0.npc);
    return is_struct(_e) && _e == arg0.execution && _e.knowledge.valid && _e.knowledge.target == arg0.target && __ai_commands_active(_e, arg0.token);
}

function __ai_team_scatter_limit(arg0)
{
    return (!variable_struct_exists(arg0, "combat") || arg0.combat.scatter.repeating) ? arg0.profile.config.scatter.max_simultaneous : arg0.profile.config.scatter.opening_max_simultaneous;
}

function __ai_team_push_capacity(arg0, arg1 = "advance")
{
    if (is_undefined(__ai_team_execution(arg0.npc)) || !arg0.knowledge.valid)
    {
        return false;
    }
    var _world = __ai_team_slots();
    var _count = 0;
    var _free = false;
    var _limit = (arg1 == "scatter") ? __ai_team_scatter_limit(arg0) : arg0.profile.config.communication.max_pushers;
    for (var _i = 0; _i < 32; _i++)
    {
        var _lease = _world.pushers[_i];
        if (!__ai_team_lease_valid(_lease, _world.frame))
        {
            _world.pushers[_i] = undefined;
            _free = true;
        }
        else
        {
            var _lease_kind = variable_struct_exists(_lease, "kind") ? _lease.kind : "advance";
            if (_lease_kind != arg1)
            {
            }
            else
            {
                if (_lease.execution == arg0)
                {
                    return true;
                }
                if (_lease.target == arg0.knowledge.target && __ai_team_members(arg0, _lease.execution))
                {
                    _count++;
                    _limit = min(_limit, (arg1 == "scatter") ? __ai_team_scatter_limit(_lease.execution) : _lease.execution.profile.config.communication.max_pushers);
                }
            }
        }
    }
    return _free && _count < _limit;
}

function ai_team_can_push(arg0)
{
    return __ai_team_push_capacity(arg0);
}

function ai_team_support_active(arg0)
{
    var _s = arg0.team.support;
    return is_struct(_s) && arg0.knowledge.valid && _s.target == arg0.knowledge.target && (_s.age + (max(0, ai_world_get().frame - _s.frame) / 60)) < arg0.profile.config.communication.engagement_seconds;
}

function ai_team_support_step(arg0)
{
    if (!ai_team_support_active(arg0) || arg0.knowledge.visible)
    {
        exit;
    }
    var _s = arg0.team.support;
    var _c = arg0.profile.config.pursuit;
    var _observed = arg0.now - _s.age - (max(0, ai_world_get().frame - _s.frame) / 60);
    var _lost = arg0.combat.lost_contact;
    _lost.search_at = max(_lost.search_at, _observed + _c.lost_contact_seconds);
    if (arg0.perception.search_until > 0)
    {
        arg0.perception.search_until = max(arg0.perception.search_until, _observed + _c.lost_contact_seconds + _c.search_seconds);
    }
    if (arg0.profile.personality.traits.teamwork >= arg0.profile.config.communication.join_teamwork_min && arg0.combat.pursuit_allowed != false)
    {
        _lost.chase_allowed = true;
        var _stop = _c.stop_distance_px * lerp(1.5, 0.75, arg0.profile.personality.traits.aggression);
        if (point_distance(arg0.npc.x, arg0.npc.y, arg0.knowledge.x, arg0.knowledge.y) > (_stop + 8))
        {
            arg0.combat.chase_done = -1;
        }
    }
}

function ai_team_begin_push(arg0, arg1, arg2 = "advance")
{
    if (!__ai_commands_active(arg0, arg1) || !__ai_team_push_capacity(arg0, arg2))
    {
        return false;
    }
    var _world = __ai_team_slots();
    ai_team_release(arg0);
    for (var _i = 0; _i < 32; _i++)
    {
        if (!is_undefined(_world.pushers[_i]))
        {
            continue;
        }
        _world.pushers[_i] = 
        {
            npc: arg0.npc,
            execution: arg0,
            token: arg1,
            target: arg0.knowledge.target,
            kind: arg2,
            expires: _world.frame + 60
        };
        arg0.team.push_slot = _i;
        return true;
    }
    return false;
}

function ai_team_release(arg0)
{
    if (!variable_struct_exists(arg0, "team"))
    {
        exit;
    }
    var _world = __ai_team_slots();
    var _slot = arg0.team.push_slot;
    if (_slot >= 0 && _slot < 32 && is_struct(_world.pushers[_slot]) && _world.pushers[_slot].execution == arg0)
    {
        _world.pushers[_slot] = undefined;
    }
    arg0.team.push_slot = -1;
}

function ai_team_step(arg0)
{
    var _team = arg0.team;
    if (_team.last_step == arg0.step)
    {
        exit;
    }
    _team.last_step = arg0.step;
    _team.scans = 0;
    __ai_team_flank_count(arg0, 0);
    _team.delivered = 0;
    __ai_team_reload_step(arg0);
    var _world = __ai_team_slots();
    var _slot = _team.push_slot;
    if (_slot >= 0)
    {
        var _lease = _world.pushers[_slot];
        if (__ai_team_lease_valid(_lease, _world.frame) && _lease.execution == arg0)
        {
            _lease.expires = _world.frame + 60;
        }
        else
        {
            ai_team_release(arg0);
        }
    }
    if (is_undefined(__ai_team_execution(arg0.npc)))
    {
        exit;
    }
    var _k = arg0.knowledge;
    var _config = arg0.profile.config.communication;
    if ((!is_struct(_team.contact_packet) || _team.contact_remaining <= 0) && arg0.now >= _team.next_report && _k.valid && _k.visible && _k.source == "sight" && (arg0.now - _k.observed_at) <= 0.016667666666666667)
    {
        _team.next_report = arg0.now + _config.sight_update_seconds;
        _team.serial++;
        _team.reports++;
        _team.contact_packet = 
        {
            direct_sight: true,
            serial: _team.serial,
            frame: _world.frame,
            age: max(0, arg0.now - _k.observed_at),
            target: _k.target,
            x: _k.x,
            y: _k.y,
            uncertainty: 0
        };
        _team.contact_remaining = instance_number(obj_npc_parent);
    }
    var _packet = _team.contact_packet;
    if (!is_struct(_packet) || _team.contact_remaining <= 0 || _team.scans >= 12)
    {
        __ai_team_nearby_step(arg0);
        exit;
    }
    if ((_packet.age + (max(0, _world.frame - _packet.frame) / 60)) > _config.report_max_age_seconds)
    {
        _team.contact_packet = undefined;
        __ai_team_nearby_step(arg0);
        exit;
    }
    var _count = instance_number(obj_npc_parent);
    var _limit = min(12 - _team.scans, _count, _team.contact_remaining);
    for (var _i = 0; _i < _limit; _i++)
    {
        var _npc = instance_find(obj_npc_parent, (_team.cursor + _i) % _count);
        _team.scans++;
        var _receiver = __ai_team_execution(_npc);
        if (is_struct(_receiver) && __ai_team_deliver(arg0, _receiver, _packet))
        {
            _team.delivered++;
        }
    }
    if (_count > 0)
    {
        _team.cursor = (_team.cursor + _limit) % _count;
    }
    _team.contact_remaining -= _limit;
    if (_count == 0 || _team.contact_remaining <= 0)
    {
        _team.contact_packet = undefined;
    }
    if (_team.delivered > 0 && arg0.now >= _team.next_callout)
    {
        _team.next_callout = arg0.now + _config.callout_cooldown_seconds;
        ai_compat_callout(arg0.npc, "contact");
    }
    __ai_team_nearby_step(arg0);
}

function ai_team_reload_report(arg0, arg1, arg2, arg3)
{
    if (!variable_struct_exists(arg0, "team") || is_undefined(__ai_team_execution(arg0.npc)) || arg0.now < arg0.team.reload_report_at || (variable_instance_exists(arg0.npc, "can_talk") && !arg0.npc.can_talk))
    {
        exit;
    }
    arg0.team.reload_report_at = arg0.now + arg0.profile.config.reload_push.cooldown_seconds;
    var _angle = ai_profile_random(arg0.rng) * 360;
    var _offset = sqrt(ai_profile_random(arg0.rng)) * arg0.profile.config.communication.uncertainty_px;
    arg0.team.reload_packet = 
    {
        target: arg1,
        x: arg2 + lengthdir_x(_offset, _angle),
        y: arg3 + lengthdir_y(_offset, _angle),
        frame: ai_world_get().frame
    };
    arg0.team.reload_remaining = instance_number(obj_npc_parent);
    ai_compat_callout(arg0.npc, "reload_spotted");
}

function __ai_team_reload_deliver(arg0, arg1, arg2)
{
    if (!variable_struct_exists(arg1, "combat") || !variable_struct_exists(arg1.combat, "adaptation") || !__ai_team_members(arg0, arg1) || arg1.knowledge.visible || !__ai_perception_hostile(arg1.npc, arg2.target) || (arg1.knowledge.valid && arg1.knowledge.target != arg2.target))
    {
        return false;
    }
    if (arg1.perception.reload_target == arg2.target && !arg1.perception.reload_seen && arg1.perception.reload_frame >= arg2.frame)
    {
        return false;
    }
    var _age = max(0, ai_world_get().frame - arg2.frame) / 60;
    if (_age > min(arg0.profile.config.communication.report_max_age_seconds, arg1.profile.config.communication.report_max_age_seconds) || _age >= arg1.profile.config.reload_push.opportunity_seconds || _age > arg1.now)
    {
        return false;
    }
    var _uncertainty = arg1.profile.config.communication.uncertainty_px;
    ai_perception_observe(arg1, arg2.target, arg2.x, arg2.y, "ally_report", arg1.now - _age, _uncertainty);
    return __ai_human_reload_notice(arg1, arg2.target, arg2.x, arg2.y, _age, true);
}

function __ai_team_reload_step(arg0)
{
    var _team = arg0.team;
    if (!is_struct(_team.reload_packet) || _team.reload_remaining <= 0)
    {
        exit;
    }
    if (is_undefined(__ai_team_execution(arg0.npc)))
    {
        _team.reload_packet = undefined;
        exit;
    }
    var _count = instance_number(obj_npc_parent);
    var _limit = min(12, _count, _team.reload_remaining);
    for (var _i = 0; _i < _limit; _i++)
    {
        _team.scans++;
        var _npc = instance_find(obj_npc_parent, (_team.reload_cursor + _i) % max(1, _count));
        var _receiver = __ai_team_execution(_npc);
        if (is_struct(_receiver))
        {
            __ai_team_reload_deliver(arg0, _receiver, _team.reload_packet);
        }
    }
    _team.reload_cursor = (_team.reload_cursor + _limit) % max(1, _count);
    _team.reload_remaining -= _limit;
    if (_count == 0 || _team.reload_remaining <= 0)
    {
        _team.reload_packet = undefined;
    }
}

function ai_team_legacy_report(arg0, arg1)
{
    if (!instance_exists(arg1) || !variable_instance_exists(arg1, "ai_execution"))
    {
        return false;
    }
    var _e = arg1.ai_execution;
    if (!is_struct(_e) || _e.profile.config.tree != "human_basic")
    {
        return false;
    }
    if (is_undefined(__ai_team_execution(arg1)) || !instance_exists(arg0) || arg0 == arg1 || arg0.hp <= 0 || arg0.faction != arg1.faction || (arg0.state != "human_general" && arg0.state != "human_alert" && arg0.state != "human_shoot") || arg0.follow_path || arg0.force_moving_towards_player)
    {
        return true;
    }
    if (faction_get_rep_temp(arg0.faction, arg1.faction) < 250)
    {
        return true;
    }
    var _source_id = __ai_team_id(arg0);
    var _receiver_id = __ai_team_id(arg1);
    if (_e.profile.config.profile == "hunter")
    {
        if (is_undefined(_source_id) || is_undefined(_receiver_id) || _source_id != _receiver_id)
        {
            return true;
        }
    }
    else if (!is_undefined(_source_id) && !is_undefined(_receiver_id) && _source_id != _receiver_id)
    {
        return true;
    }
    if (point_distance(arg0.x, arg0.y, arg1.x, arg1.y) > _e.profile.config.communication.radius_px || _e.knowledge.visible)
    {
        return true;
    }
    var _world = ai_world_get();
    var _seen = _e.team.legacy_received;
    for (var _i = 0; _i < array_length(_seen); _i++)
    {
        if (_seen[_i].sender == arg0 && _world.frame < _seen[_i].next_frame)
        {
            return true;
        }
    }
    if (!variable_instance_exists(arg0, "ai_legacy_report_frame") || arg0.ai_legacy_report_frame != _world.frame)
    {
        arg0.ai_legacy_report_frame = _world.frame;
        arg0.ai_legacy_report_snapshot = ai_compat_legacy_observation(arg0);
        arg0.ai_legacy_report_offset_angle = ai_profile_random(_e.rng) * 360;
        arg0.ai_legacy_report_offset_radius = sqrt(ai_profile_random(_e.rng));
    }
    var _snapshot = arg0.ai_legacy_report_snapshot;
    if (!is_struct(_snapshot))
    {
        return true;
    }
    var _uncertainty = _e.profile.config.communication.uncertainty_px;
    var _distance = arg0.ai_legacy_report_offset_radius * _uncertainty;
    var _entry = 
    {
        sender: arg0,
        next_frame: _world.frame + ceil(_e.profile.config.communication.report_cooldown_seconds * 60)
    };
    if (array_length(_seen) < 16)
    {
        array_push(_seen, _entry);
    }
    else
    {
        _seen[_e.team.legacy_cursor] = _entry;
    }
    _e.team.legacy_received = _seen;
    _e.team.legacy_cursor = (_e.team.legacy_cursor + 1) % 16;
    if (ai_perception_observe(_e, _snapshot.target, _snapshot.x + lengthdir_x(_distance, arg0.ai_legacy_report_offset_angle), _snapshot.y + lengthdir_y(_distance, arg0.ai_legacy_report_offset_angle), "ally_report", _e.now, _uncertainty))
    {
        _e.team.last_reason = "legacy_received";
        if (!variable_instance_exists(arg0, "ai_legacy_callout_frame") || _world.frame >= arg0.ai_legacy_callout_frame)
        {
            arg0.ai_legacy_callout_frame = _world.frame + ceil(_e.profile.config.communication.callout_cooldown_seconds * 60);
            ai_compat_callout(arg0, "contact");
        }
    }
    return true;
}

function ai_team_advancing_ally(arg0)
{
    var _world = __ai_team_slots();
    for (var _i = 0; _i < 32; _i++)
    {
        var _lease = _world.pushers[_i];
        if (!__ai_team_lease_valid(_lease, _world.frame) || _lease.execution == arg0 || _lease.kind != "advance" || _lease.target != arg0.knowledge.target)
        {
            continue;
        }
        var _ally = _lease.execution;
        if (__ai_team_members(arg0, _ally) && _ally.commands.moving && _ally.npc.path_speed > 0 && !_ally.npc.reloading && _ally.npc.ammo_now > 0 && point_distance(arg0.npc.x, arg0.npc.y, _ally.npc.x, _ally.npc.y) <= arg0.profile.config.magazine.ally_radius_px)
        {
            return true;
        }
    }
    return false;
}

function ai_team_needs_cover(arg0, arg1)
{
    return is_struct(arg1) && is_struct(__ai_team_execution(arg1.npc)) && __ai_team_members(arg0, arg1) && arg1.knowledge.valid && arg0.knowledge.valid && arg1.knowledge.target == arg0.knowledge.target && (arg1.npc.reloading || (arg1.commands.moving && arg1.team.push_slot >= 0));
}

function ai_team_cover_recipient(arg0)
{
    var _list = arg0.team.approach_neighbors;
    var _recipient = undefined;
    for (var _i = 0; _i < array_length(_list); _i++)
    {
        var _other = __ai_team_flank_peer(arg0, _list[_i]);
        if (ai_team_needs_cover(arg0, _other))
        {
            _recipient = _other;
            break;
        }
    }
    if (!is_struct(_recipient))
    {
        return undefined;
    }
    for (var _i = 0; _i < array_length(_list); _i++)
    {
        var _other = __ai_team_flank_peer(arg0, _list[_i]);
        if (!is_struct(_other))
        {
            continue;
        }
        var _role = _other.combat.covering;
        if (is_struct(_role) && _role.ally == _recipient && _other.now < _role.until && __ai_commands_owned(_other, _role.token))
        {
            return undefined;
        }
    }
    return _recipient;
}
