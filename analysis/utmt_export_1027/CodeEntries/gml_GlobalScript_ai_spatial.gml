function ai_spatial_create(arg0)
{
    arg0.spatial = 
    {
        probe: path_add(),
        request: undefined,
        claim_key: undefined,
        candidates: 0,
        paths: 0,
        deferrals: 0,
        last_reason: "initial"
    };
    return arg0.spatial;
}

function ai_spatial_destroy(arg0)
{
    if (!variable_struct_exists(arg0, "spatial") || is_undefined(arg0.spatial))
    {
        exit;
    }
    ai_spatial_release(arg0);
    if (path_exists(arg0.spatial.probe))
    {
        path_delete(arg0.spatial.probe);
    }
    arg0.spatial = undefined;
}

function __ai_spatial_result(arg0, arg1)
{
    return 
    {
        status: arg0,
        x: 0,
        y: 0,
        cover_x: 0,
        cover_y: 0,
        threat_x: 0,
        threat_y: 0,
        reason: arg1
    };
}

function __ai_spatial_clear_line(arg0, arg1, arg2, arg3)
{
    return !collision_line(arg0, arg1, arg2, arg3, obj_solid, true, true);
}

function __ai_spatial_corridor(arg0, arg1, arg2, arg3)
{
    var _angle = point_direction(arg0, arg1, arg2, arg3) + 90;
    var _dx = lengthdir_x(4, _angle);
    var _dy = lengthdir_y(4, _angle);
    for (var _side = -1; _side <= 1; _side++)
    {
        var _ax = arg0 + (_side * _dx);
        var _ay = arg1 + (_side * _dy);
        var _bx = arg2 + (_side * _dx);
        var _by = arg3 + (_side * _dy);
        if (collision_line(_ax, _ay, _bx, _by, obj_solid, true, true) || collision_line(_ax, _ay, _bx, _by, obj_solid_can_see, true, true))
        {
            return false;
        }
    }
    return true;
}

function __ai_spatial_key(arg0, arg1)
{
    return string(floor(arg0 / 16)) + ":" + string(floor(arg1 / 16));
}

function __ai_spatial_claim_free(arg0, arg1, arg2, arg3 = 16)
{
    var _world = ai_world_get();
    var _cx = floor(arg1 / 16);
    var _cy = floor(arg2 / 16);
    for (var _dx = -2; _dx <= 2; _dx++)
    {
        for (var _dy = -2; _dy <= 2; _dy++)
        {
            var _key = string(_cx + _dx) + ":" + string(_cy + _dy);
            var _claim = variable_struct_get(_world.claims, _key);
            if (is_undefined(_claim))
            {
                continue;
            }
            if (_world.frame > _claim.expires || !instance_exists(_claim.owner) || _claim.owner.hp <= 0)
            {
                variable_struct_remove(_world.claims, _key);
            }
            else
            {
                var _gap = variable_struct_exists(_claim, "separation") ? _claim.separation : 16;
                if (_claim.owner != arg0.npc && ((_dx == 0 && _dy == 0) || point_distance(arg1, arg2, _claim.x, _claim.y) < max(arg3, _gap)))
                {
                    return false;
                }
            }
        }
    }
    return true;
}

function __ai_spatial_free(arg0, arg1, arg2, arg3 = 16)
{
    if (!ai_world_position_valid(arg0, arg1, arg2) || !__ai_spatial_claim_free(arg0, arg1, arg2, arg3))
    {
        return false;
    }
    return !__ai_spatial_occupied(arg0, arg1, arg2);
}

function __ai_spatial_occupied(arg0, arg1, arg2)
{
    var _occupied = false;
    with (arg0.npc)
    {
        _occupied = collision_circle(arg1, arg2, 8, obj_npc_parent, false, true) || collision_circle(arg1, arg2, 8, obj_player_parent, false, true);
    }
    return _occupied;
}

function ai_spatial_approach_remember(arg0, arg1, arg2 = false)
{
    var _c = arg0.profile.config.approach;
    if (!_c.enabled || !arg1.valid || !arg0.knowledge.valid)
    {
        return undefined;
    }
    var _a = arg0.combat.approach;
    if (arg2 || !is_struct(_a) || _a.target != arg0.knowledge.target || arg0.now >= _a.expires || point_distance(_a.x, _a.y, arg1.x, arg1.y) >= _c.anchor_reset_px)
    {
        _a = 
        {
            target: arg0.knowledge.target,
            x: arg1.x,
            y: arg1.y,
            bearing: point_direction(arg1.x, arg1.y, arg0.npc.x, arg0.npc.y),
            expires: arg0.now + _c.memory_seconds
        };
        arg0.combat.approach = _a;
    }
    return _a;
}

function __ai_spatial_approach_score(arg0, arg1)
{
    var _a = arg0.approach;
    var _c = _a.config;
    var _bearing = point_direction(arg0.threat_x, arg0.threat_y, arg1[0], arg1[1]);
    var _score = (abs(angle_difference(_bearing, _a.bearing)) / 90) * _c.side_weight;
    for (var _i = 0; _i < array_length(_a.neighbors); _i++)
    {
        var _n = _a.neighbors[_i];
        var _gap = point_distance(arg1[0], arg1[1], _n.x, _n.y);
        if (_n.goal)
        {
            _gap = min(_gap, point_distance(arg1[0], arg1[1], _n.gx, _n.gy));
        }
        var _dx = arg1[0] - arg0.origin_x;
        var _dy = arg1[1] - arg0.origin_y;
        for (var _j = 0; _j < (_n.goal ? 2 : 1); _j++)
        {
            var _nx = (_j == 0) ? _n.x : _n.gx;
            var _ny = (_j == 0) ? _n.y : _n.gy;
            var _t = clamp((((_nx - arg0.origin_x) * _dx) + ((_ny - arg0.origin_y) * _dy)) / max(0.001, (_dx * _dx) + (_dy * _dy)), 0, 1);
            _gap = min(_gap, point_distance(arg0.origin_x + (_dx * _t), arg0.origin_y + (_dy * _t), _nx, _ny));
        }
        var _crowd = max(0, 1 - (_gap / _c.spacing_px));
        _score += (_crowd * _c.crowd_weight);
    }
    _score += ((point_distance(arg0.origin_x, arg0.origin_y, arg1[0], arg1[1]) / 128) * 0.1);
    if (arg0.kind == "advance")
    {
        _score += ((point_distance(arg1[0], arg1[1], arg0.threat_x, arg0.threat_y) / 128) * 0.4);
    }
    return _score;
}

function __ai_spatial_request(arg0, arg1, arg2, arg3)
{
    var _range = 160;
    if (variable_struct_exists(arg0.combat, "weapon_range"))
    {
        _range = arg0.combat.weapon_range;
    }
    var _config = undefined;
    if (arg1 == "angle")
    {
        _config = arg0.profile.config.engagement;
    }
    if (arg1 == "strafe")
    {
        _config = arg0.profile.config.strafe;
    }
    if (arg1 == "space_in" || arg1 == "space_out")
    {
        _config = arg0.profile.config.spacing;
    }
    if (arg1 == "interception")
    {
        _config = arg0.profile.config.interception;
    }
    if (arg1 == "investigate")
    {
        _config = arg0.profile.config.investigation;
    }
    if (arg1 == "search")
    {
        _config = arg0.profile.config.search;
    }
    if (arg1 == "advance")
    {
        _config = arg0.profile.config.pursuit;
    }
    if (arg1 == "relocation")
    {
        _config = arg0.profile.config.relocation;
    }
    if (arg1 == "defensive_reposition")
    {
        _config = arg0.profile.config.defensive_reposition;
    }
    if (arg1 == "flee")
    {
        _config = arg0.profile.config.abandonment;
    }
    if (arg1 == "shoot_retreat")
    {
        _config = arg0.profile.config.shoot_retreat;
    }
    if (arg1 == "scatter" || arg1 == "flank" || arg1 == "peek_reposition" || arg1 == "reload_push" || arg1 == "heal_push" || arg1 == "flash_push")
    {
        _config = variable_struct_get(arg0.profile.config, arg1);
    }
    var _scatter_ally = (arg1 == "scatter") ? ai_team_nearby_ally(arg0) : undefined;
    var _ally_x = is_undefined(_scatter_ally) ? arg0.npc.x : _scatter_ally.npc.x;
    var _ally_y = is_undefined(_scatter_ally) ? arg0.npc.y : _scatter_ally.npc.y;
    var _search_direction = variable_struct_exists(arg3, "escape_direction") ? arg3.escape_direction : 0;
    var _approach = undefined;
    if (arg1 == "advance" || arg1 == "investigate")
    {
        var _memory = ai_spatial_approach_remember(arg0, arg3);
        if (is_struct(_memory))
        {
            _approach = 
            {
                bearing: _memory.bearing,
                config: arg0.profile.config.approach,
                neighbors: []
            };
        }
    }
    return 
    {
        open_pockets: variable_struct_exists(arg3, "open_pockets") && arg3.open_pockets,
        search_direction: _search_direction,
        search_offset: (arg1 == "search") ? ai_profile_random(arg0.rng) : 0,
        approach: _approach,
        ranked: [],
        ranked_ready: false,
        ranked_cursor: 0,
        options: [],
        transfer: undefined,
        keep_bearing: variable_struct_exists(arg3, "keep_bearing") ? arg3.keep_bearing : undefined,
        allow_close: variable_struct_exists(arg3, "allow_close") && arg3.allow_close,
        angle_offset: (arg1 == "angle") ? (ai_profile_random(arg0.rng) * 360) : 0,
        gain_px: variable_struct_exists(arg3, "gain_px") ? arg3.gain_px : 0,
        protected: variable_struct_exists(arg3, "protected") && arg3.protected,
        hit_cover_distance: arg0.profile.config.hit_reaction.directional_enabled ? arg0.profile.config.hit_reaction.cover_distance_px : 96,
        scatter_repeat: arg1 == "scatter" && arg0.combat.scatter.repeating,
        ally_x: _ally_x,
        ally_y: _ally_y,
        kind: arg1,
        token: arg2,
        revision: arg3.revision,
        config: _config,
        side: ((arg1 == "relocation" || arg1 == "angle" || arg1 == "advance" || arg1 == "strafe" || arg1 == "flank" || arg1 == "peek_reposition") && ai_profile_random(arg0.rng) < 0.5) ? -1 : 1,
        aggression: arg0.profile.personality.traits.aggression,
        watch_x: arg3.x,
        watch_y: arg3.y,
        fixed_threat: arg3 != arg0.knowledge,
        threat_x: arg3.x,
        threat_y: arg3.y,
        origin_x: arg0.npc.x,
        origin_y: arg0.npc.y,
        weapon: arg0.npc.arma_now,
        assignment_x: arg0.assignment.x,
        assignment_y: arg0.assignment.y,
        assignment_radius: arg0.assignment.radius,
        range: _range,
        started: arg0.now,
        cursor: 0,
        candidate: undefined,
        result: undefined
    };
}

function __ai_spatial_same(arg0, arg1, arg2, arg3, arg4)
{
    return arg1.kind == arg2 && arg1.token == arg3 && arg1.revision == arg4.revision && arg1.fixed_threat == (arg4 != arg0.knowledge) && arg1.weapon == arg0.npc.arma_now && arg1.assignment_x == arg0.assignment.x && arg1.assignment_y == arg0.assignment.y && arg1.assignment_radius == arg0.assignment.radius && ((variable_struct_exists(arg1, "moving_correction") && arg1.moving_correction) || point_distance(arg1.origin_x, arg1.origin_y, arg0.npc.x, arg0.npc.y) <= 8);
}

function __ai_spatial_candidate(arg0, arg1)
{
    var _facing = point_direction(arg0.origin_x, arg0.origin_y, arg0.threat_x, arg0.threat_y);
    if (arg0.kind == "flee" || arg0.kind == "shoot_retreat")
    {
        var _i = arg1 % 28;
        var _offsets = [0, 30, -30, 60, -60, 85, -85];
        _radius = lerp(arg0.config.distance_px, arg0.config.min_move_px, (_i div 7) / 3);
        if (arg0.kind == "shoot_retreat")
        {
            _radius = min(_radius, max(arg0.config.min_move_px, arg0.config.preferred_distance_px - point_distance(arg0.origin_x, arg0.origin_y, arg0.threat_x, arg0.threat_y)));
        }
        var _direction = _facing + 180 + _offsets[_i % 7];
        return [arg0.origin_x + lengthdir_x(_radius, _direction), arg0.origin_y + lengthdir_y(_radius, _direction)];
    }
    if (arg0.kind == "relocation")
    {
        var _angles = [90, -90, 70, -70, 110, -110, 135, -135];
        _radius = lerp(arg0.config.min_move_px, arg0.config.distance_px, (arg1 div 8) / 2);
        var _direction = _facing + (_angles[arg1 % 8] * arg0.side);
        return [arg0.origin_x + lengthdir_x(_radius, _direction), arg0.origin_y + lengthdir_y(_radius, _direction)];
    }
    if (arg0.kind == "defensive_reposition")
    {
        var _angles = [180, 150, -150, 120, -120, 90, -90, 180];
        _radius = lerp(arg0.config.min_move_px, arg0.config.max_move_px, (arg1 div 8) / 2);
        return [arg0.origin_x + lengthdir_x(_radius, _facing + _angles[arg1 % 8]), arg0.origin_y + lengthdir_y(_radius, _facing + _angles[arg1 % 8])];
    }
    if (arg0.kind == "investigate")
    {
        return ai_investigation_candidate(arg0, arg1);
    }
    if (arg0.kind == "search")
    {
        var _c = arg0.config;
        _angle = arg0.search_direction + ((frac(arg0.search_offset + ((arg1 % 6) / 6)) - 0.5) * _c.cone_degrees);
        _radius = lerp(_c.radius_min_px, _c.radius_max_px, (arg1 div 6) / 2);
        return [arg0.threat_x + lengthdir_x(_radius, _angle), arg0.threat_y + lengthdir_y(_radius, _angle)];
    }
    if (arg0.kind == "scatter")
    {
        var _offset = [90, -90, 110, -110, 130, -130];
        var _projection = ((arg0.ally_x - arg0.origin_x) * lengthdir_x(1, _facing + 90)) + ((arg0.ally_y - arg0.origin_y) * lengthdir_y(1, _facing + 90));
        var _side = (abs(_projection) > 1) ? -sign(_projection) : arg0.side;
        var _direction = _facing + ((arg0.scatter_repeat ? (((arg1 % 2) == 0) ? 90 : -90) : _offset[arg1 % 6]) * _side);
        _radius = arg0.scatter_repeat ? (arg0.config.distance_px * (0.5 + (0.25 * (arg1 div 2)))) : (arg0.config.opening_distance_px * (1 - (0.2 * (arg1 div 6))));
        return [arg0.origin_x + lengthdir_x(_radius, _direction), arg0.origin_y + lengthdir_y(_radius, _direction)];
    }
    if (arg0.kind == "advance")
    {
        var _c = arg0.config;
        var _distance = point_distance(arg0.origin_x, arg0.origin_y, arg0.threat_x, arg0.threat_y);
        var _stop = _c.stop_distance_px * lerp(1.5, 0.75, arg0.aggression);
        var _forward = min(_c.advance_distance_px * lerp(0.75, 1.25, arg0.aggression), max(0, _distance - _stop));
        if (is_struct(arg0.approach) && arg1 < 15)
        {
            _offsets = [0, 1, -1, 2, -2];
            _radius = max(_stop, _distance - (_forward * (1 - (0.25 * (arg1 div 5)))));
            var _step = min(35, radtodeg(arctan(arg0.approach.config.spacing_px / max(24, _radius))));
            var _direction = arg0.approach.bearing + (_offsets[arg1 % 5] * _step * arg0.side);
            return [arg0.threat_x + lengthdir_x(_radius, _direction), arg0.threat_y + lengthdir_y(_radius, _direction)];
        }
        if (is_struct(arg0.approach))
        {
            var _fallback = [0, 1, 4];
            arg1 = _fallback[arg1 - 15];
        }
        _forward *= (1 - (0.25 * (arg1 div 6)));
        var _offsets = [1, -1, 2, -2, 0, 3];
        var _side = _offsets[arg1 % 6] * arg0.side * _c.spread_px;
        return [arg0.origin_x + lengthdir_x(_forward, _facing) + lengthdir_x(_side, _facing + 90), arg0.origin_y + lengthdir_y(_forward, _facing) + lengthdir_y(_side, _facing + 90)];
    }
    if (arg0.kind == "flank" || arg0.kind == "peek_reposition" || arg0.kind == "reload_push" || arg0.kind == "heal_push" || arg0.kind == "flash_push")
    {
        var _offset = (arg0.kind == "reload_push" || arg0.kind == "heal_push" || arg0.kind == "flash_push") ? [0, 20, -20, 40, -40, 60] : [70, -70, 90, -90, 110, -110];
        var _direction = _facing + (_offset[arg1 % 6] * arg0.side);
        _radius = arg0.config.distance_px * (0.5 + (0.25 * (arg1 div 6)));
        if (arg0.kind == "flash_push")
        {
            _radius = min(_radius, max(4, point_distance(arg0.origin_x, arg0.origin_y, arg0.threat_x, arg0.threat_y) - arg0.config.min_target_distance_px));
        }
        return [arg0.origin_x + lengthdir_x(_radius, _direction), arg0.origin_y + lengthdir_y(_radius, _direction)];
    }
    if (arg0.kind == "angle")
    {
        _radius = arg0.config.angle_distance_px * (0.25 + (0.15 * (arg1 div 16)));
        var _direction = arg0.angle_offset + ((arg1 % 16) * 22.5);
        return [arg0.origin_x + lengthdir_x(_radius, _direction), arg0.origin_y + lengthdir_y(_radius, _direction)];
    }
    if (arg0.kind == "strafe")
    {
        var _offset = [90, -90, 75, -75, 105, -105];
        var _direction = _facing + (_offset[arg1 % 6] * arg0.side);
        return [arg0.origin_x + lengthdir_x(arg0.config.distance_px, _direction), arg0.origin_y + lengthdir_y(arg0.config.distance_px, _direction)];
    }
    if (arg0.kind == "space_in" || arg0.kind == "space_out")
    {
        var _offset = [0, 30, -30, 60, -60, 90, -90, 180];
        var _direction = _facing + ((arg0.kind == "space_out") ? 180 : 0) + _offset[arg1 % 8];
        var _distance = point_distance(arg0.origin_x, arg0.origin_y, arg0.threat_x, arg0.threat_y);
        var _needed = (arg0.kind == "space_in") ? (_distance - (arg0.range * arg0.config.far_ratio)) : ((arg0.range * arg0.config.near_ratio) - _distance);
        _radius = lerp(clamp(_needed, arg0.config.min_move_px, arg0.config.max_move_px), arg0.config.min_move_px, (arg1 div 8) / 2);
        return [arg0.origin_x + lengthdir_x(_radius, _direction), arg0.origin_y + lengthdir_y(_radius, _direction)];
    }
    if (arg0.kind == "interception")
    {
        if (arg1 == 0)
        {
            return [arg0.origin_x, arg0.origin_y];
        }
        arg1--;
        _radius = (arg0.config.move_px * (1 + (arg1 div 8))) / 3;
        var _direction = _facing + ((arg1 % 8) * 45);
        return [arg0.origin_x + lengthdir_x(_radius, _direction), arg0.origin_y + lengthdir_y(_radius, _direction)];
    }
    if (arg0.kind == "cover" && arg1 == 0)
    {
        return [arg0.origin_x, arg0.origin_y];
    }
    if (arg0.kind == "cover")
    {
        arg1--;
    }
    if (arg0.kind == "cover_move")
    {
        arg1 += 16;
    }
    var _radius = (1 + (arg1 div 8)) * ((arg0.kind == "peek") ? 8 : 16);
    if (arg0.kind == "hit_cover")
    {
        _radius = ((1 + (arg1 div 8)) * arg0.hit_cover_distance) / 6;
    }
    var _angle = point_direction(arg0.origin_x, arg0.origin_y, arg0.threat_x, arg0.threat_y);
    if (arg0.kind == "cover" || arg0.kind == "cover_move" || arg0.kind == "hit_cover" || arg0.kind == "reload_cover" || arg0.kind == "retreat")
    {
        _angle += 180;
    }
    _angle += ((arg1 % 8) * 45);
    return [arg0.origin_x + lengthdir_x(_radius, _angle), arg0.origin_y + lengthdir_y(_radius, _angle)];
}

function __ai_spatial_candidate_valid(arg0, arg1, arg2, arg3)
{
    if (!__ai_spatial_free(arg0, arg2, arg3, (arg1.kind == "scatter") ? 32 : ((arg1.kind == "advance") ? arg1.config.separation_px : 16)))
    {
        return false;
    }
    if (!is_undefined(arg1.keep_bearing) && abs(angle_difference(arg1.keep_bearing, point_direction(arg1.threat_x, arg1.threat_y, arg2, arg3))) > 90)
    {
        return false;
    }
    if ((arg1.kind == "relocation" || arg1.kind == "angle" || arg1.kind == "flank" || arg1.kind == "peek_reposition") && __ai_human_memory_avoid(arg0, arg2, arg3))
    {
        return false;
    }
    if (arg1.kind == "investigate")
    {
        return ai_investigation_candidate_valid(arg0, arg1, arg2, arg3);
    }
    if (arg1.kind == "search")
    {
        return point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3) >= 24 && !ai_investigation_checked(arg0, arg2, arg3);
    }
    var _clear = __ai_spatial_clear_line(arg2, arg3, arg1.threat_x, arg1.threat_y);
    if (arg1.kind == "cover")
    {
        return !_clear;
    }
    if (arg1.kind == "cover_move")
    {
        return !_clear && point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3) >= 32;
    }
    if (arg1.kind == "hit_cover")
    {
        return !_clear;
    }
    var _distance = point_distance(arg2, arg3, arg1.threat_x, arg1.threat_y);
    var _old_distance = point_distance(arg1.origin_x, arg1.origin_y, arg1.threat_x, arg1.threat_y);
    if (arg1.kind == "flee" || arg1.kind == "shoot_retreat")
    {
        return _distance >= (_old_distance + arg1.config.distance_gain_px) && (arg1.cursor > 28 || !_clear);
    }
    if (arg1.kind == "relocation")
    {
        var _c = arg1.config;
        if (_clear || point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3) < (_c.min_move_px - 0.01) || _distance < min(32, arg1.range * 0.2) || (arg0.combat.pursuit_allowed == false && _distance < (_old_distance - 8)))
        {
            return false;
        }
        var _facing = point_direction(arg2, arg3, arg1.threat_x, arg1.threat_y);
        if (__ai_spatial_clear_line(arg2, arg3, arg2 + lengthdir_x(min(_distance, _c.cover_probe_px), _facing), arg3 + lengthdir_y(min(_distance, _c.cover_probe_px), _facing)))
        {
            return false;
        }
        for (var _side = -1; _side <= 1; _side += 2)
        {
            var _px = arg2 + lengthdir_x(_c.cover_probe_px, _facing + (90 * _side));
            var _py = arg3 + lengthdir_y(_c.cover_probe_px, _facing + (90 * _side));
            if (ai_world_position_valid(arg0, _px, _py) && __ai_spatial_corridor(arg2, arg3, _px, _py) && __ai_spatial_clear_line(_px, _py, arg1.threat_x, arg1.threat_y))
            {
                return true;
            }
        }
        return false;
    }
    if (arg1.kind == "defensive_reposition")
    {
        if (_clear || _distance < (_old_distance + arg1.gain_px) || point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3) < (arg1.config.min_move_px - 0.01))
        {
            return false;
        }
        return arg1.protected || __ai_human_defense_protected(arg0, arg2, arg3, 
        {
            x: arg1.threat_x,
            y: arg1.threat_y
        });
    }
    if (arg1.kind == "angle")
    {
        return _clear && (arg1.allow_close || _distance >= (_old_distance - 8)) && _distance >= min(48, arg1.range * 0.3) && point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3) >= 16;
    }
    if (arg1.kind == "advance")
    {
        return _distance <= (_old_distance - 8);
    }
    if (arg1.kind == "scatter")
    {
        var _old_gap = point_distance(arg1.origin_x, arg1.origin_y, arg1.ally_x, arg1.ally_y);
        return _distance >= (_old_distance - 1) && point_distance(arg2, arg3, arg1.ally_x, arg1.ally_y) >= max(32, _old_gap + 16);
    }
    if (arg1.kind == "flank" || arg1.kind == "peek_reposition" || arg1.kind == "reload_push" || arg1.kind == "heal_push" || arg1.kind == "flash_push")
    {
        var _travel = point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3);
        if (arg1.kind == "flash_push")
        {
            return _travel >= 4 && _distance <= (_old_distance - 4) && _distance >= (arg1.config.min_target_distance_px - 2);
        }
        if (_travel < max(24, arg1.config.distance_px * 0.5))
        {
            return false;
        }
        if (arg1.kind == "reload_push" || arg1.kind == "heal_push" || arg1.kind == "flash_push")
        {
            return _distance <= (_old_distance - 24) && _distance >= (arg1.config.min_target_distance_px * 0.5);
        }
        if (arg1.kind == "flank")
        {
            return _clear && _distance >= (arg1.config.min_target_distance_px * 0.5);
        }
        if (arg0.combat.pursuit_allowed == false && _distance < (_old_distance - 8))
        {
            return false;
        }
        if (_clear)
        {
            return _distance >= min(32, arg1.range * 0.2);
        }
        var _facing = point_direction(arg2, arg3, arg1.threat_x, arg1.threat_y);
        for (var _side = -1; _side <= 1; _side += 2)
        {
            var _px = arg2 + lengthdir_x(24, _facing + (_side * 90));
            var _py = arg3 + lengthdir_y(24, _facing + (_side * 90));
            if (ai_world_position_valid(arg0, _px, _py) && __ai_spatial_corridor(arg2, arg3, _px, _py) && __ai_spatial_clear_line(_px, _py, arg1.threat_x, arg1.threat_y))
            {
                return true;
            }
        }
        return false;
    }
    if (arg1.kind == "reload_cover" || arg1.kind == "retreat")
    {
        var _travel = point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3);
        return _travel >= 32 && _travel <= 96 && _distance >= (_old_distance + 24) && (arg1.kind == "retreat" || !_clear);
    }
    if (arg1.kind == "interception")
    {
        if (!__ai_spatial_corridor(arg1.origin_x, arg1.origin_y, arg2, arg3))
        {
            return false;
        }
        if (_clear && _distance <= (arg1.range * arg1.config.range_ratio))
        {
            arg1.watch_x = arg1.threat_x;
            arg1.watch_y = arg1.threat_y;
            return true;
        }
        var _facing = point_direction(arg2, arg3, arg1.threat_x, arg1.threat_y);
        for (var _side = -1; _side <= 1; _side += 2)
        {
            var _wx = arg1.threat_x + lengthdir_x(arg1.config.watch_offset_px, _facing + (90 * _side));
            var _wy = arg1.threat_y + lengthdir_y(arg1.config.watch_offset_px, _facing + (90 * _side));
            if (point_distance(arg2, arg3, _wx, _wy) <= (arg1.range * arg1.config.range_ratio) && __ai_spatial_clear_line(arg2, arg3, _wx, _wy))
            {
                arg1.watch_x = _wx;
                arg1.watch_y = _wy;
                return true;
            }
        }
        return false;
    }
    if (!_clear)
    {
        return false;
    }
    if (arg1.kind == "strafe")
    {
        return __ai_spatial_corridor(arg1.origin_x, arg1.origin_y, arg2, arg3);
    }
    if (arg1.kind == "space_in" || arg1.kind == "space_out")
    {
        var _c = arg1.config;
        var _gain = (arg1.kind == "space_in") ? (_old_distance - _distance) : (_distance - _old_distance);
        return _gain >= _c.min_gain_px && (arg1.kind == "space_out" || _distance >= (arg1.range * _c.near_ratio)) && (arg1.kind == "space_in" || _distance <= (arg1.range * _c.far_ratio)) && __ai_spatial_corridor(arg1.origin_x, arg1.origin_y, arg2, arg3);
    }
    if (arg1.kind == "push")
    {
        return _distance <= (_old_distance - 12) && _distance >= min(32, arg1.range * 0.2);
    }
    if (arg1.kind == "reposition")
    {
        return _distance >= min(32, arg1.range * 0.2) && _distance <= arg1.range && point_distance(arg1.origin_x, arg1.origin_y, arg2, arg3) >= 12;
    }
    return __ai_spatial_corridor(arg1.origin_x, arg1.origin_y, arg2, arg3);
}

function __ai_spatial_found(arg0, arg1, arg2)
{
    var _result = __ai_spatial_result("FOUND", "reachable");
    _result.x = arg2[0];
    _result.y = arg2[1];
    _result.cover_x = (arg1.kind == "peek") ? arg1.origin_x : arg2[0];
    _result.cover_y = (arg1.kind == "peek") ? arg1.origin_y : arg2[1];
    _result.threat_x = arg1.threat_x;
    _result.threat_y = arg1.threat_y;
    _result.watch_x = arg1.watch_x;
    _result.watch_y = arg1.watch_y;
    _result.owner = arg0.npc;
    _result.target = arg0.knowledge.target;
    _result.separation = (arg1.kind == "scatter") ? 32 : ((arg1.kind == "advance") ? arg1.config.separation_px : 16);
    _result.fixed_threat = arg1.fixed_threat;
    _result.kind = arg1.kind;
    _result.token = arg1.token;
    _result.revision = arg1.revision;
    _result.weapon = arg1.weapon;
    _result.assignment_x = arg1.assignment_x;
    _result.assignment_y = arg1.assignment_y;
    _result.assignment_radius = arg1.assignment_radius;
    _result.route_length = path_get_length(arg0.spatial.probe);
    _result.expires = arg0.now + arg0.profile.config.queries.retry_seconds;
    return _result;
}

function __ai_spatial_deferred(arg0, arg1, arg2)
{
    arg0.spatial.deferrals++;
    if ((arg0.now - arg1.started) >= (arg0.profile.config.queries.max_defer_seconds - 0.000000001))
    {
        if (__ai_spatial_finish_available(arg0, arg1))
        {
            return arg1.result;
        }
        arg1.result = __ai_spatial_result("NO_RESULT", "query_deadline");
        return arg1.result;
    }
    return __ai_spatial_result("DEFERRED", arg2);
}

function __ai_spatial_choose_option(arg0, arg1)
{
    var _best = 1000000000;
    for (var _i = 0; _i < array_length(arg1.options); _i++)
    {
        _best = min(_best, arg1.options[_i].score);
    }
    var _choices = [];
    for (var _i = 0; _i < array_length(arg1.options); _i++)
    {
        if (arg1.options[_i].score <= (_best + 24))
        {
            array_push(_choices, arg1.options[_i].result);
        }
    }
    return _choices[min(array_length(_choices) - 1, floor(ai_profile_random(arg0.rng) * array_length(_choices)))];
}

function __ai_spatial_finish_available(arg0, arg1)
{
    if (is_struct(arg1.transfer))
    {
        arg1.result = arg1.transfer.best;
    }
    else if (array_length(arg1.options) > 0)
    {
        arg1.result = __ai_spatial_choose_option(arg0, arg1);
    }
    else
    {
        return false;
    }
    arg1.result.expires = arg0.now + arg0.profile.config.queries.retry_seconds;
    arg0.spatial.last_reason = "found";
    return true;
}

function __ai_spatial_path_cost(arg0, arg1)
{
    var _length = path_get_length(arg1);
    var _cost = _length;
    for (var _i = 1; _i <= 4; _i++)
    {
        var _x = path_get_x(arg1, _i / 4);
        var _y = path_get_y(arg1, _i / 4);
        if (__ai_spatial_clear_line(_x, _y, arg0.threat_x, arg0.threat_y))
        {
            _cost += (_length * 0.2);
        }
        if (variable_struct_exists(arg0, "neighbors"))
        {
            for (var _n = 0; _n < array_length(arg0.neighbors); _n++)
            {
                var _a = arg0.neighbors[_n];
                _cost += (max(0, 32 - point_distance(_x, _y, _a.x, _a.y)) * 0.25);
            }
        }
    }
    return _cost;
}

function __ai_spatial_angle_path_safe(arg0, arg1)
{
    if (arg0.kind != "angle")
    {
        return true;
    }
    var _minimum = arg0.allow_close ? min(48, arg0.range * 0.3) : max(0, point_distance(arg0.origin_x, arg0.origin_y, arg0.threat_x, arg0.threat_y) - 8);
    for (var _i = 1; _i < path_get_number(arg1); _i++)
    {
        var _ax = path_get_point_x(arg1, _i - 1);
        var _ay = path_get_point_y(arg1, _i - 1);
        var _dx = path_get_point_x(arg1, _i) - _ax;
        var _dy = path_get_point_y(arg1, _i) - _ay;
        var _t = clamp((((arg0.threat_x - _ax) * _dx) + ((arg0.threat_y - _ay) * _dy)) / max(0.001, (_dx * _dx) + (_dy * _dy)), 0, 1);
        if (point_distance(_ax + (_dx * _t), _ay + (_dy * _t), arg0.threat_x, arg0.threat_y) < (_minimum - 0.01))
        {
            return false;
        }
    }
    return true;
}

function __ai_spatial_transfer_begin(arg0, arg1, arg2)
{
    arg1.transfer = 
    {
        best: arg2,
        direct_length: arg2.route_length,
        best_cost: arg2.travel_cost,
        side: 0,
        leg: 0,
        length: 0,
        cost: 0,
        checked: false,
        x: 0,
        y: 0
    };
}

function __ai_spatial_transfer_query(arg0, arg1)
{
    var _t = arg1.transfer;
    var _s = arg0.spatial;
    var _goal = _t.best;
    while (_t.side < 2 && _t.direct_length >= 48 && (arg0.now - arg1.started) < (arg0.profile.config.queries.max_defer_seconds - 0.05))
    {
        if (!_t.checked)
        {
            if (!ai_world_take_candidate(arg0))
            {
                return __ai_spatial_deferred(arg0, arg1, "candidate_budget");
            }
            _s.candidates++;
            var _angle = point_direction(arg1.origin_x, arg1.origin_y, _goal.x, _goal.y) + ((_t.side == 0) ? 90 : -90);
            var _offset = clamp(point_distance(arg1.origin_x, arg1.origin_y, _goal.x, _goal.y) * 0.5, 24, 64);
            _t.x = ((arg1.origin_x + _goal.x) * 0.5) + lengthdir_x(_offset, _angle);
            _t.y = ((arg1.origin_y + _goal.y) * 0.5) + lengthdir_y(_offset, _angle);
            if (!__ai_spatial_free(arg0, _t.x, _t.y))
            {
                _t.side++;
                continue;
            }
            _t.checked = true;
        }
        var _first = _t.leg == 0;
        var _path = ai_world_path(arg0, _s.probe, _first ? arg1.origin_x : _t.x, _first ? arg1.origin_y : _t.y, _first ? _t.x : _goal.x, _first ? _t.y : _goal.y);
        if (_path == "deferred")
        {
            return __ai_spatial_deferred(arg0, arg1, "path_budget");
        }
        _s.paths++;
        var _valid = _path == "found" && __ai_spatial_angle_path_safe(arg1, _s.probe);
        if (_valid)
        {
            _t.length += path_get_length(_s.probe);
            _t.cost += __ai_spatial_path_cost(arg1, _s.probe);
            _valid = _t.length <= ((_t.direct_length * 1.6) + 16);
        }
        if (_valid && _first)
        {
            _t.leg = 1;
            continue;
        }
        if (_valid && _t.cost < (_t.best_cost * 0.95))
        {
            _t.best = variable_clone(_goal);
            _t.best.route_length = _t.length;
            _t.best.via_x = _t.x;
            _t.best.via_y = _t.y;
            _t.best.via_done = false;
            _t.best_cost = _t.cost;
        }
        _t.side++;
        _t.leg = 0;
        _t.length = 0;
        _t.cost = 0;
        _t.checked = false;
    }
    __ai_spatial_finish_available(arg0, arg1);
    return arg1.result;
}

function ai_spatial_query(arg0, arg1, arg2, arg3 = undefined)
{
    if (is_undefined(arg3))
    {
        arg3 = ai_contact_focus(arg0);
    }
    if (!__ai_commands_active(arg0, arg2) || !arg3.valid)
    {
        return __ai_spatial_result("NO_RESULT", "invalid_owner_or_memory");
    }
    if (arg1 != "shoot_retreat" && arg1 != "flee" && arg1 != "relocation" && arg1 != "defensive_reposition" && arg1 != "angle" && arg1 != "investigate" && arg1 != "search" && arg1 != "scatter" && arg1 != "advance" && arg1 != "cover" && arg1 != "cover_move" && arg1 != "hit_cover" && arg1 != "peek" && arg1 != "push" && arg1 != "reposition" && arg1 != "reload_cover" && arg1 != "retreat" && arg1 != "strafe" && arg1 != "space_in" && arg1 != "space_out" && arg1 != "interception" && arg1 != "flank" && arg1 != "peek_reposition" && arg1 != "reload_push" && arg1 != "heal_push" && arg1 != "flash_push")
    {
        return __ai_spatial_result("NO_RESULT", "invalid_kind");
    }
    var _s = arg0.spatial;
    var _request = _s.request;
    if (is_undefined(_request) || !__ai_spatial_same(arg0, _request, arg1, arg2, arg3))
    {
        _request = __ai_spatial_request(arg0, arg1, arg2, arg3);
        _s.request = _request;
    }
    if (!is_undefined(_request.result))
    {
        return _request.result;
    }
    if ((arg0.now - _request.started) >= (arg0.profile.config.queries.max_defer_seconds - 0.000000001))
    {
        if (__ai_spatial_finish_available(arg0, _request))
        {
            return _request.result;
        }
        _request.result = __ai_spatial_result("NO_RESULT", "query_deadline");
        return _request.result;
    }
    if (is_struct(_request.transfer))
    {
        return __ai_spatial_transfer_query(arg0, _request);
    }
    var _pool = arg1 == "angle" || arg1 == "cover" || arg1 == "cover_move";
    if ((_pool || arg1 == "advance" || arg1 == "investigate") && !variable_struct_exists(_request, "neighbors"))
    {
        _request.neighbors = variable_struct_exists(arg0, "team") ? ai_team_approach_neighbors(arg0) : [];
    }
    if (arg1 == "peek" && __ai_spatial_clear_line(_request.origin_x, _request.origin_y, _request.threat_x, _request.threat_y))
    {
        _request.result = __ai_spatial_result("NO_RESULT", "origin_not_cover");
        return _request.result;
    }
    var _limit = (arg1 == "peek") ? (floor(arg0.profile.config.peek.distance_px / 8) * 8) : ((arg1 == "hit_cover" || arg1 == "reload_cover" || arg1 == "retreat") ? 48 : 97);
    if (arg1 == "flee" || arg1 == "shoot_retreat")
    {
        _limit = 56;
    }
    if (arg1 == "investigate")
    {
        _limit = 144;
    }
    if (arg1 == "strafe")
    {
        _limit = 6;
    }
    if (arg1 == "defensive_reposition" || arg1 == "relocation")
    {
        _limit = 24;
    }
    if (arg1 == "space_in" || arg1 == "space_out")
    {
        _limit = 24;
    }
    if (arg1 == "interception")
    {
        _limit = 25;
    }
    if (arg1 == "search" || arg1 == "scatter" || arg1 == "advance" || arg1 == "flank" || arg1 == "peek_reposition" || arg1 == "reload_push" || arg1 == "heal_push" || arg1 == "flash_push")
    {
        _limit = 18;
    }
    if (arg1 == "angle" || arg1 == "cover_move")
    {
        _limit = 96;
    }
    if (arg1 == "scatter" && _request.scatter_repeat)
    {
        _limit = 6;
    }
    var _ranked = is_struct(_request.approach);
    if (_ranked && !_request.ranked_ready)
    {
        while (_request.cursor < _limit)
        {
            if (!ai_world_take_candidate(arg0))
            {
                return __ai_spatial_deferred(arg0, _request, "candidate_budget");
            }
            _s.candidates++;
            var _candidate = __ai_spatial_candidate(_request, _request.cursor++);
            if (!__ai_spatial_candidate_valid(arg0, _request, _candidate[0], _candidate[1]))
            {
                continue;
            }
            array_push(_request.ranked, 
            {
                point: _candidate,
                score: 0,
                watch_x: _request.watch_x,
                watch_y: _request.watch_y,
                order: _request.cursor
            });
        }
        _request.approach.neighbors = ai_team_approach_neighbors(arg0);
        for (var _i = 0; _i < array_length(_request.ranked); _i++)
        {
            _request.ranked[_i].score = __ai_spatial_approach_score(_request, _request.ranked[_i].point);
        }
        array_sort(_request.ranked, function(arg0, arg1)
        {
            return (arg0.score == arg1.score) ? (arg0.order - arg1.order) : sign(arg0.score - arg1.score);
        });
        _request.ranked_ready = true;
    }
    while ((!_ranked && _request.cursor < _limit) || (_ranked && _request.ranked_cursor < array_length(_request.ranked)) || !is_undefined(_request.candidate))
    {
        if (is_undefined(_request.candidate))
        {
            if (_ranked)
            {
                var _entry = _request.ranked[_request.ranked_cursor++];
                _request.watch_x = _entry.watch_x;
                _request.watch_y = _entry.watch_y;
                _request.candidate = _entry.point;
            }
            else
            {
                if (!ai_world_take_candidate(arg0))
                {
                    return __ai_spatial_deferred(arg0, _request, "candidate_budget");
                }
                _s.candidates++;
                var _candidate = __ai_spatial_candidate(_request, _request.cursor++);
                if (!__ai_spatial_candidate_valid(arg0, _request, _candidate[0], _candidate[1]))
                {
                    continue;
                }
                _request.candidate = _candidate;
            }
        }
        var _point = _request.candidate;
        if (_ranked && !__ai_spatial_free(arg0, _point[0], _point[1], (arg1 == "advance") ? _request.config.separation_px : 16))
        {
            _request.candidate = undefined;
            continue;
        }
        var _path = ai_world_path(arg0, _s.probe, arg0.npc.x, arg0.npc.y, _point[0], _point[1]);
        if (_path == "deferred")
        {
            return __ai_spatial_deferred(arg0, _request, "path_budget");
        }
        _s.paths++;
        _request.candidate = undefined;
        if (_path != "found")
        {
            continue;
        }
        if (arg1 == "flee" || arg1 == "shoot_retreat")
        {
            if (path_get_length(_s.probe) > (_request.config.distance_px * 2))
            {
                continue;
            }
            var _minimum = max(0, point_distance(_request.origin_x, _request.origin_y, _request.threat_x, _request.threat_y) - ((arg1 == "shoot_retreat") ? 8 : 16));
            var _safe = true;
            var _px = _request.origin_x;
            var _py = _request.origin_y;
            for (var _j = 0; _j < path_get_number(_s.probe); _j++)
            {
                var _qx = path_get_point_x(_s.probe, _j);
                var _qy = path_get_point_y(_s.probe, _j);
                var _dx = _qx - _px;
                var _dy = _qy - _py;
                var _along = clamp((((_request.threat_x - _px) * _dx) + ((_request.threat_y - _py) * _dy)) / max(0.0001, (_dx * _dx) + (_dy * _dy)), 0, 1);
                if (point_distance(_px + (_dx * _along), _py + (_dy * _along), _request.threat_x, _request.threat_y) < _minimum)
                {
                    _safe = false;
                    break;
                }
                _px = _qx;
                _py = _qy;
            }
            if (!_safe)
            {
                continue;
            }
        }
        if (arg1 == "investigate" && path_get_length(_s.probe) > (max(_request.config.trigger_distance_px, point_distance(_request.origin_x, _request.origin_y, _request.threat_x, _request.threat_y)) + (_request.config.pocket_radius_px * 2)))
        {
            continue;
        }
        if (arg1 == "peek" && path_get_length(_s.probe) > arg0.profile.config.peek.max_path_px)
        {
            continue;
        }
        if (arg1 == "hit_cover" && path_get_length(_s.probe) > max(128, _request.hit_cover_distance * 2))
        {
            continue;
        }
        if ((arg1 == "reload_cover" || arg1 == "retreat") && path_get_length(_s.probe) > 128)
        {
            continue;
        }
        if (arg1 == "angle" && (path_get_length(_s.probe) > (_request.config.angle_distance_px * 2.5) || !__ai_spatial_angle_path_safe(_request, _s.probe)))
        {
            continue;
        }
        if ((arg1 == "cover" || arg1 == "cover_move") && path_get_length(_s.probe) > 256)
        {
            continue;
        }
        if (arg1 == "strafe" && path_get_length(_s.probe) > (_request.config.distance_px * 1.25))
        {
            continue;
        }
        if ((arg1 == "space_in" || arg1 == "space_out") && path_get_length(_s.probe) > (_request.config.max_move_px * 1.25))
        {
            continue;
        }
        if (arg1 == "interception" && path_get_length(_s.probe) > (_request.config.move_px * 1.5))
        {
            continue;
        }
        if (arg1 == "search" && path_get_length(_s.probe) > (point_distance(_request.origin_x, _request.origin_y, _request.threat_x, _request.threat_y) + (_request.config.radius_max_px * 2)))
        {
            continue;
        }
        if (arg1 == "advance" && path_get_length(_s.probe) > ((_request.config.advance_distance_px * 2) + (_request.config.spread_px * 2)))
        {
            continue;
        }
        if ((arg1 == "relocation" || arg1 == "scatter" || arg1 == "flank" || arg1 == "peek_reposition" || arg1 == "reload_push" || arg1 == "heal_push" || arg1 == "flash_push") && path_get_length(_s.probe) > (_request.config.distance_px * 1.5))
        {
            continue;
        }
        if (arg1 == "defensive_reposition")
        {
            if (path_get_length(_s.probe) > (_request.config.max_move_px * 1.5))
            {
                continue;
            }
            var _safe = true;
            if (_request.protected)
            {
                for (var _sample = 1; _sample <= 4; _sample++)
                {
                    if (__ai_spatial_clear_line(path_get_x(_s.probe, _sample / 4), path_get_y(_s.probe, _sample / 4), _request.threat_x, _request.threat_y))
                    {
                        _safe = false;
                        break;
                    }
                }
            }
            if (!_safe)
            {
                continue;
            }
        }
        var _found = __ai_spatial_found(arg0, _request, _point);
        if (_pool && _found.route_length > 4)
        {
            _found.travel_cost = __ai_spatial_path_cost(_request, _s.probe);
            var _score = _found.route_length * 0.25;
            if (arg1 == "angle")
            {
                _score -= (min(90, abs(angle_difference(point_direction(_request.threat_x, _request.threat_y, _request.origin_x, _request.origin_y), point_direction(_request.threat_x, _request.threat_y, _found.x, _found.y)))) * 0.25);
            }
            array_push(_request.options, 
            {
                result: _found,
                score: _score
            });
            if (array_length(_request.options) < 5)
            {
                continue;
            }
            __ai_spatial_transfer_begin(arg0, _request, __ai_spatial_choose_option(arg0, _request));
            return __ai_spatial_transfer_query(arg0, _request);
        }
        if (arg1 == "advance" || arg1 == "investigate")
        {
            _found.travel_cost = __ai_spatial_path_cost(_request, _s.probe);
            __ai_spatial_transfer_begin(arg0, _request, _found);
            return __ai_spatial_transfer_query(arg0, _request);
        }
        _request.result = _found;
        _s.last_reason = "found";
        return _request.result;
    }
    if (array_length(_request.options) > 0)
    {
        __ai_spatial_transfer_begin(arg0, _request, __ai_spatial_choose_option(arg0, _request));
        return __ai_spatial_transfer_query(arg0, _request);
    }
    _request.result = __ai_spatial_result("NO_RESULT", "candidates_exhausted");
    _s.last_reason = _request.result.reason;
    return _request.result;
}

function ai_spatial_claim(arg0, arg1, arg2)
{
    if (arg1.status != "FOUND" || arg1.token != arg2 || !__ai_commands_active(arg0, arg2) || arg0.now > arg1.expires || !ai_spatial_validate(arg0, arg1))
    {
        return false;
    }
    var _x = (arg1.kind == "peek") ? arg1.cover_x : arg1.x;
    var _y = (arg1.kind == "peek") ? arg1.cover_y : arg1.y;
    var _separation = variable_struct_exists(arg1, "separation") ? arg1.separation : 16;
    if (!__ai_spatial_free(arg0, _x, _y, _separation))
    {
        return false;
    }
    ai_spatial_release(arg0);
    var _world = ai_world_get();
    var _key = __ai_spatial_key(_x, _y);
    variable_struct_set(_world.claims, _key, 
    {
        owner: arg0.npc,
        token: arg2,
        x: _x,
        y: _y,
        separation: _separation,
        expires: _world.frame + 60
    });
    arg0.spatial.claim_key = _key;
    return true;
}

function ai_spatial_release(arg0)
{
    if (!variable_struct_exists(arg0, "spatial") || is_undefined(arg0.spatial))
    {
        exit;
    }
    var _key = arg0.spatial.claim_key;
    if (!is_undefined(_key))
    {
        var _claims = ai_world_get().claims;
        var _claim = variable_struct_get(_claims, _key);
        if (!is_undefined(_claim) && _claim.owner == arg0.npc)
        {
            variable_struct_remove(_claims, _key);
        }
    }
    arg0.spatial.claim_key = undefined;
    arg0.spatial.request = undefined;
}

function ai_spatial_validate(arg0, arg1, arg2 = false)
{
    return ai_spatial_status(arg0, arg1, arg2) == "valid";
}

function ai_spatial_tracking_correct(arg0, arg1, arg2, arg3, arg4, arg5 = 0)
{
    var _d = arg1.data;
    if (!is_struct(_d.result) || arg0.knowledge.visible || arg0.now >= _d.until || point_distance(arg0.npc.x, arg0.npc.y, _d.result.x, _d.result.y) <= 8)
    {
        return false;
    }
    var _focus = ai_contact_focus(arg0);
    var _clue = arg0.perception.tracking.clue;
    if (!variable_struct_exists(_d, "tracking_correction") || is_undefined(_d.tracking_correction))
    {
        if (variable_struct_exists(_d, "tracking_attempt") || !is_struct(_clue) || _focus != _clue || _clue.corrected || (variable_struct_exists(_d.threat, "tracking_serial") && _d.threat.tracking_serial == _clue.revision) || point_distance(_d.threat.x, _d.threat.y, _clue.x, _clue.y) < max(24, _clue.uncertainty * 2))
        {
            return false;
        }
        _d.tracking_attempt = true;
        _clue.corrected = true;
        var _threat = ai_movement_snapshot(arg0);
        _threat.keep_bearing = point_direction(_threat.x, _threat.y, _d.result.x, _d.result.y);
        _threat.open_pockets = variable_struct_exists(_d.threat, "open_pockets") && _d.threat.open_pockets;
        _threat.allow_close = variable_struct_exists(_d.threat, "allow_close") && _d.threat.allow_close;
        _d.tracking_correction = 
        {
            threat: _threat,
            request: undefined,
            result: undefined,
            until: arg0.now + arg0.profile.config.queries.max_defer_seconds,
            clue: _clue,
            goal: _d.result
        };
    }
    var _c = _d.tracking_correction;
    if (is_undefined(_c))
    {
        return false;
    }
    if (_focus != _c.clue || _d.result != _c.goal || arg0.now > (_c.until + 0.000001))
    {
        _d.tracking_correction = undefined;
        return false;
    }
    if (is_undefined(_c.result))
    {
        var _saved = arg0.spatial.request;
        arg0.spatial.request = _c.request;
        var _query = ai_spatial_query(arg0, arg2, arg1.token, _c.threat);
        _c.request = arg0.spatial.request;
        if (is_struct(_c.request))
        {
            _c.request.moving_correction = true;
        }
        arg0.spatial.request = _saved;
        if (_query.status == "DEFERRED")
        {
            return false;
        }
        _c.result = _query;
    }
    var _result = _c.result;
    if (_result.status == "FOUND")
    {
        var _via = variable_struct_exists(_result, "via_x") && !_result.via_done;
        var _path = ai_world_path(arg0, arg0.spatial.probe, arg0.npc.x, arg0.npc.y, _via ? _result.via_x : _result.x, _via ? _result.via_y : _result.y);
        if (_path == "deferred")
        {
            return false;
        }
        arg0.spatial.paths++;
        if (_path != "found" || !__ai_spatial_angle_path_safe(_c.request, arg0.spatial.probe))
        {
            _d.tracking_correction = undefined;
            return false;
        }
    }
    _d.tracking_correction = undefined;
    if (_result.status != "FOUND" || !ai_spatial_claim(arg0, _result, arg1.token))
    {
        return false;
    }
    ai_commands_stop(arg0, arg1.token);
    _d.result = _result;
    _d.threat = _c.threat;
    _d.busy_since = -1;
    _d.until = arg0.now + ai_commands_travel_seconds(arg0, _result, arg3, arg4) + arg5;
    if (arg0.perception.search_until > 0)
    {
        _d.until = min(_d.until, arg0.perception.search_until);
    }
    arg0.combat.decision_reason = "tracking_correction";
    return true;
}

function ai_spatial_status(arg0, arg1, arg2 = false)
{
    var _fixed = variable_struct_exists(arg1, "fixed_threat") && arg1.fixed_threat;
    if (arg1.status != "FOUND" || arg1.owner != arg0.npc || !__ai_commands_active(arg0, arg1.token) || (!arg2 && !_fixed && !arg0.knowledge.valid) || arg1.weapon != arg0.npc.arma_now || arg1.assignment_x != arg0.assignment.x || arg1.assignment_y != arg0.assignment.y || arg1.assignment_radius != arg0.assignment.radius)
    {
        return "invalid";
    }
    if (!arg2 && variable_struct_exists(arg1, "target") && arg0.knowledge.valid && arg1.target != arg0.knowledge.target)
    {
        return "invalid";
    }
    if (!arg2 && !_fixed && arg1.revision != arg0.knowledge.revision)
    {
        return "invalid";
    }
    var _x = arg2 ? arg1.cover_x : arg1.x;
    var _y = arg2 ? arg1.cover_y : arg1.y;
    if (!ai_world_position_valid(arg0, _x, _y))
    {
        return "invalid";
    }
    if (arg2 || arg1.kind == "relocation" || arg1.kind == "defensive_reposition" || arg1.kind == "cover" || arg1.kind == "cover_move" || arg1.kind == "hit_cover" || arg1.kind == "reload_cover")
    {
        var _live = arg0.knowledge.valid && arg0.knowledge.visible;
        var _tx = _live ? arg0.knowledge.x : arg1.threat_x;
        var _ty = _live ? arg0.knowledge.y : arg1.threat_y;
        if (__ai_spatial_clear_line(_x, _y, _tx, _ty))
        {
            return "invalid";
        }
    }
    if (arg2 && !__ai_spatial_corridor(arg0.npc.x, arg0.npc.y, _x, _y))
    {
        return "invalid";
    }
    var _key = arg0.spatial.claim_key;
    if (!is_undefined(_key))
    {
        var _world = ai_world_get();
        var _claim = variable_struct_get(_world.claims, _key);
        if (is_undefined(_claim) || _claim.owner != arg0.npc || _claim.token != arg1.token)
        {
            return "invalid";
        }
        _claim.expires = _world.frame + 60;
    }
    if (!__ai_spatial_claim_free(arg0, _x, _y, variable_struct_exists(arg1, "separation") ? arg1.separation : 16) || __ai_spatial_occupied(arg0, _x, _y))
    {
        return "busy";
    }
    return "valid";
}

function ai_spatial_progress(arg0, arg1, arg2, arg3 = false)
{
    var _status = ai_spatial_status(arg0, arg2, arg3);
    var _d = arg1.data;
    if (_status != "busy")
    {
        _d.busy_since = -1;
        return _status;
    }
    ai_commands_stop(arg0, arg1.token);
    if (!variable_struct_exists(_d, "busy_since") || _d.busy_since < 0)
    {
        _d.busy_since = arg0.now;
    }
    return ((arg0.now - _d.busy_since) < 0.35) ? "waiting" : "busy";
}

function ai_spatial_route_create(arg0, arg1, arg2, arg3)
{
    var _c = arg0.profile.config.relocation;
    var _r = __ai_spatial_request(arg0, "relocation_route", arg1, arg2);
    _r.config = _c;
    _r.side = (ai_profile_random(arg0.rng) < 0.5) ? -1 : 1;
    _r.angle_route = false;
    _r.angle_allow_close = false;
    return 
    {
        request: _r,
        speed: arg3,
        cursor: 0,
        points: [],
        results: [],
        leg: 0,
        checked: false,
        length: 0,
        status: "DEFERRED",
        max_seconds: _c.route_max_seconds,
        seconds: lerp(_c.route_min_seconds, _c.route_max_seconds, ai_profile_random(arg0.rng))
    };
}

function __ai_spatial_route_angle(arg0, arg1)
{
    var _o = arg0.profile.config.flank_opportunity;
    var _r = arg1.request;
    if (_r.angle_route || !_o.enabled || !_o.angle_route_enabled)
    {
        return false;
    }
    _r.angle_route = true;
    _r.angle_allow_close = arg0.combat.pursuit_allowed == true && __ai_human_magazine_ready(arg0) && ai_team_begin_push(arg0, _r.token);
    arg1.cursor = 0;
    arg1.points = [];
    arg1.results = [];
    arg1.leg = 0;
    arg1.length = 0;
    arg1.checked = false;
    arg1.max_seconds = _o.angle_max_seconds;
    return true;
}

function __ai_spatial_route_safe(arg0, arg1, arg2)
{
    var _c = arg2.config;
    var _old = point_distance(arg2.origin_x, arg2.origin_y, arg2.threat_x, arg2.threat_y);
    var _minimum = max(_c.route_close_px, _old * 0.65);
    if (arg2.angle_route)
    {
        _minimum = max(arg0.profile.config.flank_opportunity.angle_close_px, arg2.angle_allow_close ? 0 : (_old - 8));
    }
    if (arg0.combat.pursuit_allowed == false)
    {
        _minimum = max(_minimum, _old - 8);
    }
    for (var _i = 1; _i < path_get_number(arg1); _i++)
    {
        var _ax = path_get_point_x(arg1, _i - 1);
        var _ay = path_get_point_y(arg1, _i - 1);
        var _dx = path_get_point_x(arg1, _i) - _ax;
        var _dy = path_get_point_y(arg1, _i) - _ay;
        var _t = clamp((((arg2.threat_x - _ax) * _dx) + ((arg2.threat_y - _ay) * _dy)) / max(0.001, (_dx * _dx) + (_dy * _dy)), 0, 1);
        if (point_distance(_ax + (_dx * _t), _ay + (_dy * _t), arg2.threat_x, arg2.threat_y) < (_minimum - 0.01))
        {
            return false;
        }
    }
    return true;
}

function ai_spatial_route_query(arg0, arg1)
{
    var _r = arg1.request;
    var _c = _r.config;
    if (arg1.status != "DEFERRED")
    {
        return arg1.status;
    }
    if (!__ai_commands_active(arg0, _r.token) || (arg0.now - _r.started) >= arg0.profile.config.queries.max_defer_seconds || arg1.speed <= 0)
    {
        arg1.status = "NO_RESULT";
        return arg1.status;
    }
    if (!_r.angle_route && !arg0.knowledge.visible && point_distance(_r.origin_x, _r.origin_y, _r.threat_x, _r.threat_y) <= _c.route_close_px)
    {
        __ai_spatial_route_angle(arg0, arg1);
    }
    while (arg1.cursor < 12)
    {
        if (array_length(arg1.points) == 0)
        {
            if ((arg0.now - _r.started) >= (arg0.profile.config.queries.max_defer_seconds * 0.5))
            {
                __ai_spatial_route_angle(arg0, arg1);
            }
            var _distance = point_distance(_r.origin_x, _r.origin_y, _r.threat_x, _r.threat_y);
            var _budget = arg1.speed * 60 * lerp(arg1.seconds, _c.route_min_seconds, (arg1.cursor div 2) / 5);
            var _angle = clamp(radtodeg(_budget / max(64, _distance)), _c.route_min_angle, _c.route_max_angle);
            _angle = lerp(_angle, _c.route_min_angle, (arg1.cursor div 2) / 5);
            var _count = min(_c.route_max_waypoints, (_angle >= 100) ? 3 : 2);
            var _radius = max(_distance + 16, _budget / (2 * _count * dsin(_angle / (2 * _count))));
            var _side = _r.side * (((arg1.cursor % 2) == 0) ? 1 : -1);
            var _start = point_direction(_r.threat_x, _r.threat_y, _r.origin_x, _r.origin_y);
            arg1.points = [];
            arg1.results = [];
            arg1.leg = 0;
            arg1.length = 0;
            arg1.checked = false;
            if (_r.angle_route)
            {
                var _o = arg0.profile.config.flank_opportunity;
                var _variant = arg1.cursor div 2;
                var _travel = _o.angle_distance_px * ((_variant < 3) ? 1 : 0.75);
                _angle = @@array_get@@([90, 135, 180], _variant % 3);
                _radius = max(_o.angle_close_px + 8, _distance * ((_variant < 3) ? 1 : 0.8));
                array_push(arg1.points, [_r.origin_x + lengthdir_x(_travel, _start + (_side * 90)), _r.origin_y + lengthdir_y(_travel, _start + (_side * 90))]);
                array_push(arg1.points, [_r.threat_x + lengthdir_x(_radius, _start + (_side * _angle)), _r.threat_y + lengthdir_y(_radius, _start + (_side * _angle))]);
            }
            else
            {
                if (_radius > (_distance + 128))
                {
                    arg1.cursor++;
                    continue;
                }
                for (var _i = 1; _i <= _count; _i++)
                {
                    var _direction = _start + ((_side * _angle * _i) / _count);
                    array_push(arg1.points, [_r.threat_x + lengthdir_x(_radius, _direction), _r.threat_y + lengthdir_y(_radius, _direction)]);
                }
            }
        }
        var _point = arg1.points[arg1.leg];
        var _last = arg1.leg == (array_length(arg1.points) - 1);
        if (!arg1.checked)
        {
            if (!ai_world_take_candidate(arg0))
            {
                return "DEFERRED";
            }
            arg0.spatial.candidates++;
            var _valid = __ai_spatial_free(arg0, _point[0], _point[1]) && !__ai_human_memory_avoid(arg0, _point[0], _point[1]);
            if (_last)
            {
                _valid = _valid && point_distance(_r.origin_x, _r.origin_y, _point[0], _point[1]) >= (_r.angle_route ? arg0.profile.config.flank_opportunity.angle_min_move_px : _c.route_min_move_px) && __ai_spatial_clear_line(_point[0], _point[1], _r.threat_x, _r.threat_y);
            }
            if (!_valid)
            {
                arg1.points = [];
                arg1.cursor++;
                continue;
            }
            arg1.checked = true;
        }
        var _from = (arg1.leg == 0) ? [_r.origin_x, _r.origin_y] : arg1.points[arg1.leg - 1];
        var _path = ai_world_path(arg0, arg0.spatial.probe, _from[0], _from[1], _point[0], _point[1]);
        if (_path == "deferred")
        {
            return "DEFERRED";
        }
        arg0.spatial.paths++;
        var _length = (_path == "found") ? path_get_length(arg0.spatial.probe) : 0;
        if (_path != "found" || !__ai_spatial_route_safe(arg0, arg0.spatial.probe, _r) || (arg1.length + _length) > (arg1.speed * 60 * arg1.max_seconds))
        {
            arg1.points = [];
            arg1.cursor++;
            continue;
        }
        arg1.length += _length;
        array_push(arg1.results, __ai_spatial_found(arg0, _r, _point));
        arg1.leg++;
        arg1.checked = false;
        if (_last)
        {
            if (!_r.angle_route && arg1.length < (arg1.speed * 60 * _c.route_min_seconds))
            {
                arg1.points = [];
                arg1.cursor++;
                continue;
            }
            arg1.status = "FOUND";
            arg0.spatial.last_reason = _r.angle_route ? "angle_route_found" : "route_found";
            return arg1.status;
        }
    }
    if (__ai_spatial_route_angle(arg0, arg1))
    {
        return ai_spatial_route_query(arg0, arg1);
    }
    arg1.status = "NO_RESULT";
    arg0.spatial.last_reason = "no_useful_route";
    return arg1.status;
}
