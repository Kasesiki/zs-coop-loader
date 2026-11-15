function ai_grenade_create(arg0)
{
    arg0.grenade = 
    {
        operation: undefined,
        retry_at: 0,
        reason: "initial",
        choice: undefined
    };
}

function __ai_grenade_point(arg0)
{
    var _k = arg0.knowledge;
    var _cover = ai_cover_current(arg0);
    if (!_k.visible && is_struct(_cover) && _cover.pocket && !ai_investigation_checked(arg0, _cover.x, _cover.y))
    {
        return 
        {
            x: _cover.x,
            y: _cover.y
        };
    }
    return 
    {
        x: _k.x,
        y: _k.y
    };
}

function __ai_grenade_group_free(arg0, arg1, arg2, arg3 = undefined)
{
    var _world = ai_world_get();
    if (!variable_struct_exists(_world, "grenade_throws"))
    {
        _world.grenade_throws = array_create(16, undefined);
    }
    var _free = false;
    var _npc = arg0.npc;
    for (var _i = 0; _i < 16; _i++)
    {
        var _r = _world.grenade_throws[_i];
        if (!is_struct(_r) || _r.until <= _world.frame)
        {
            _free = true;
        }
        else
        {
            if (_r.owner == _npc && _r.token == arg3)
            {
                return true;
            }
            if (_r.faction != _npc.faction || faction_get_rep_temp(_npc.faction, _r.faction) < 250)
            {
            }
            else
            {
                var _squad = __ai_team_id(_npc);
                if ((arg0.profile.config.profile == "hunter" || _r.hunter) && (is_undefined(_squad) || _squad != _r.squad))
                {
                }
                else if (!is_undefined(_squad) && !is_undefined(_r.squad) && _squad != _r.squad)
                {
                }
                else if (point_distance(_npc.x, _npc.y, _r.ox, _r.oy) <= arg0.profile.config.communication.radius_px && (_r.target == arg0.knowledge.target || point_distance(arg1, arg2, _r.x, _r.y) <= 96))
                {
                    return false;
                }
            }
        }
    }
    return _free;
}

function __ai_grenade_reserve(arg0, arg1, arg2, arg3)
{
    if (!__ai_grenade_group_free(arg0, arg2, arg3))
    {
        return false;
    }
    var _world = ai_world_get();
    for (var _i = 0; _i < 16; _i++)
    {
        var _r = _world.grenade_throws[_i];
        if (is_struct(_r) && _r.until > _world.frame)
        {
            continue;
        }
        _world.grenade_throws[_i] = 
        {
            owner: arg0.npc,
            token: arg1,
            target: arg0.knowledge.target,
            faction: arg0.npc.faction,
            squad: __ai_team_id(arg0.npc),
            hunter: arg0.profile.config.profile == "hunter",
            ox: arg0.npc.x,
            oy: arg0.npc.y,
            x: arg2,
            y: arg3,
            until: _world.frame + (max(3.1, arg0.profile.config.grenade.group_cooldown_seconds) * 60)
        };
        return true;
    }
    return false;
}

function ai_grenade_ready(arg0)
{
    var _npc = arg0.npc;
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.grenade;
    arg0.grenade.choice = undefined;
    if (!_c.enabled || !variable_instance_exists(_npc, "grenade_amount_max") || _npc.grenade_amount_thrown >= _npc.grenade_amount_max)
    {
        arg0.grenade.reason = "no_grenades";
        return false;
    }
    if (arg0.now < arg0.grenade.retry_at)
    {
        arg0.grenade.reason = "cooldown";
        return false;
    }
    if (!_k.valid || (arg0.now - _k.observed_at) > _c.memory_seconds || _npc.grenade_flash)
    {
        arg0.grenade.reason = "stale_contact";
        return false;
    }
    var _focus = ai_contact_focus(arg0);
    if (_focus != _k)
    {
        arg0.grenade.reason = __ai_hearing_source(_focus) ? "sound_only" : "tracking_only";
        return false;
    }
    var _point = __ai_grenade_point(arg0);
    if (!__ai_grenade_group_free(arg0, _point.x, _point.y))
    {
        arg0.grenade.reason = "ally_throw";
        return false;
    }
    if (!ai_grenade_destination_safe(arg0, _point.x, _point.y))
    {
        return false;
    }
    var _weights = [npc_get_prob_grenade_f1(_npc.npc_id), npc_get_prob_grenade_rgd(_npc.npc_id), npc_get_prob_grenade_flash(_npc.npc_id)];
    var _items = ["grenade_f1", "grenade_rgd5", "grenade_flash"];
    var _distance = point_distance(_npc.x, _npc.y, _point.x, _point.y);
    var _total = 0;
    for (var _i = 0; _i < 3; _i++)
    {
        var _item = _items[_i];
        var _radius = max(80, item_grenade_get_radius_min_damage(_item) + 12);
        if (_weights[_i] <= 0 || _distance < item_grenade_get_throw_min(_item) || _distance > item_grenade_get_throw_max(_item) || (_radius > 80 && !ai_grenade_destination_safe(arg0, _point.x, _point.y, _radius)))
        {
            _weights[_i] = 0;
        }
        _total += _weights[_i];
    }
    if (_total <= 0)
    {
        arg0.grenade.reason = "no_safe_item";
        return false;
    }
    _point.weights = _weights;
    _point.total = _total;
    arg0.grenade.choice = _point;
    arg0.grenade.reason = "ready";
    return true;
}

function ai_grenade_weight(arg0)
{
    if (!ai_grenade_ready(arg0))
    {
        return 0;
    }
    var _c = arg0.profile.config.grenade;
    var _weight = clamp(npc_get_prob_grenade_throw(arg0.npc.npc_id) / 100, 0, 1) * _c.base_weight_scale;
    var _cover = ai_cover_current(arg0);
    if (!arg0.knowledge.visible && is_struct(_cover))
    {
        if (_cover.kind == "isolated")
        {
            _weight *= _c.isolated_weight_multiplier;
        }
        else if (_cover.kind == "continuous")
        {
            _weight *= _c.cover_weight_multiplier;
        }
    }
    return _weight;
}

function __ai_grenade_throw_clear(arg0, arg1, arg2, arg3)
{
    var _list = ds_list_create();
    var _clear = true;
    var _count = collision_line_list(arg0, arg1, arg2, arg3, obj_solid, true, false, _list, false);
    if (_count > 32)
    {
        _clear = false;
    }
    for (var _i = 0; _clear && _i < _count; _i++)
    {
        var _solid = ds_list_find_value(_list, _i);
        var _height = undefined;
        if (_solid.object_index == obj_solid && variable_instance_exists(_solid, "my_height"))
        {
            _height = _solid.my_height;
        }
        else if (variable_instance_exists(_solid, "decor_id") && instance_exists(obj_controller) && variable_instance_exists(obj_controller, "decor_height"))
        {
            _height = obj_controller.decor_height[_solid.decor_id];
        }
        if (is_undefined(_height) || _height >= 18)
        {
            _clear = false;
        }
    }
    ds_list_destroy(_list);
    return _clear;
}

function ai_grenade_destination_safe(arg0, arg1, arg2, arg3 = 80)
{
    var _npc = arg0.npc;
    var _c = arg0.profile.config.grenade;
    var _distance = point_distance(_npc.x, _npc.y, arg1, arg2);
    if (_distance < max(arg3, _c.min_distance_px) || _distance > _c.max_distance_px)
    {
        arg0.grenade.reason = "range";
        return false;
    }
    if (collision_circle(arg1, arg2, 4, obj_solid, true, false) || !__ai_grenade_throw_clear(_npc.x, _npc.y, arg1, arg2))
    {
        arg0.grenade.reason = "blocked_throw";
        return false;
    }
    var _list = ds_list_create();
    collision_circle_list(arg1, arg2, arg3, obj_npc_parent, false, false, _list, false);
    collision_circle_list(arg1, arg2, arg3, obj_player_parent, false, false, _list, false);
    var _count = ds_list_size(_list);
    var _safe = _count <= 32;
    for (var _i = 0; _safe && _i < _count; _i++)
    {
        var _ally = ds_list_find_value(_list, _i);
        if (_ally != _npc && variable_instance_exists(_ally, "faction") && faction_get_rep_temp(_npc.faction, _ally.faction) >= 250)
        {
            _safe = false;
        }
    }
    ds_list_destroy(_list);
    if (!_safe)
    {
        arg0.grenade.reason = "ally_near_landing";
    }
    return _safe;
}

function ai_grenade_enter(arg0, arg1)
{
    __ai_human_action_enter(arg0, arg1);
    __ai_grenade_start(arg0.user_data, arg1);
}

function __ai_grenade_start(arg0, arg1, arg2 = true)
{
    var _npc = arg0.npc;
    if (!ai_grenade_ready(arg0))
    {
        return false;
    }
    var _point = arg0.grenade.choice;
    var _weights = _point.weights;
    var _items = ["grenade_f1", "grenade_rgd5", "grenade_flash"];
    var _choice = ai_profile_random(arg0.rng) * _point.total;
    var _item = _items[0];
    for (var _i = 0; _i < 3; _i++)
    {
        _choice -= _weights[_i];
        if (_choice < 0)
        {
            _item = _items[_i];
            break;
        }
    }
    if (!__ai_grenade_reserve(arg0, arg1.token, _point.x, _point.y))
    {
        return false;
    }
    arg0.grenade.retry_at = arg0.now + arg0.profile.config.grenade.retry_seconds;
    ai_commands_stop(arg0, arg1.token);
    var _arms = instance_create_depth(_npc.x, _npc.y, 0, obj_arms_grenade);
    _arms.linked_id = _npc;
    _arms.image_xscale = _npc.image_xscale;
    _arms.sprite_index = item_grenade_get_animation(_item);
    _arms.target_x = _point.x;
    _arms.target_y = _point.y;
    _arms.grenade_id = _item;
    _arms.faction = _npc.faction;
    _arms.ai_grenade_token = arg1.token;
    _arms.ai_grenade_execution = arg0;
    arg0.grenade.operation = 
    {
        arms: _arms,
        token: arg1.token,
        target: arg0.knowledge.target,
        committed: false,
        complete_action: arg2
    };
    _npc.draw_weapon = false;
    ai_compat_callout(_npc, "grenade_out");
    return true;
}

function ai_grenade_update(arg0, arg1)
{
    var _e = arg0.user_data;
    ai_commands_stop(_e, arg1.token);
    var _operation = _e.grenade.operation;
    if (!is_struct(_operation))
    {
        return UnknownEnum.Value_2;
    }
    if (_operation.committed)
    {
        return UnknownEnum.Value_1;
    }
    if (!instance_exists(_operation.arms) || (_e.now - arg1.started_at) >= 3)
    {
        return UnknownEnum.Value_2;
    }
    return UnknownEnum.Value_0;
}

function ai_grenade_valid(arg0)
{
    if (!variable_instance_exists(arg0, "ai_grenade_execution"))
    {
        return false;
    }
    var _e = arg0.ai_grenade_execution;
    if (!ai_human_migrated(_e.npc) || _e.npc.ai_execution != _e || _e.npc.state != "human_general" || _e.npc.grenade_flash || _e.npc.force_moving_towards_player || !__ai_commands_active(_e, arg0.ai_grenade_token))
    {
        return false;
    }
    var _op = _e.grenade.operation;
    return is_struct(_op) && !_op.committed && _e.knowledge.valid && _e.knowledge.target == _op.target && _op.arms == arg0 && _op.token == arg0.ai_grenade_token && ai_grenade_destination_safe(_e, arg0.target_x, arg0.target_y, max(80, item_grenade_get_radius_min_damage(arg0.grenade_id) + 12));
}

function ai_grenade_commit(arg0)
{
    if (!ai_grenade_valid(arg0))
    {
        return false;
    }
    var _e = arg0.ai_grenade_execution;
    _e.grenade.operation.committed = true;
    var _world = ai_world_get();
    for (var _i = 0; _i < 16; _i++)
    {
        var _r = _world.grenade_throws[_i];
        if (is_struct(_r) && _r.owner == _e.npc && _r.token == arg0.ai_grenade_token)
        {
            _r.until = _world.frame + (_e.profile.config.grenade.group_cooldown_seconds * 60);
        }
    }
    _e.npc.grenade_amount_thrown++;
    _e.npc.draw_weapon = true;
    if (_e.grenade.operation.complete_action)
    {
        ai_bt_complete(_e.tree_context, arg0.ai_grenade_token, UnknownEnum.Value_1, "grenade_committed");
    }
    return true;
}

function ai_grenade_animation_step(arg0)
{
    if (!variable_instance_exists(arg0, "ai_grenade_execution"))
    {
        return false;
    }
    if (!ai_grenade_valid(arg0))
    {
        instance_destroy(arg0);
        return true;
    }
    arg0.image_xscale = arg0.linked_id.image_xscale;
    arg0.depth = arg0.linked_id.depth - 2;
    return true;
}

function ai_grenade_cancel(arg0)
{
    if (!variable_struct_exists(arg0, "grenade"))
    {
        exit;
    }
    var _op = arg0.grenade.operation;
    if (is_struct(_op))
    {
        var _world = ai_world_get();
        if (!_op.committed && variable_struct_exists(_world, "grenade_throws"))
        {
            for (var _i = 0; _i < 16; _i++)
            {
                var _r = _world.grenade_throws[_i];
                if (is_struct(_r) && _r.owner == arg0.npc && _r.token == _op.token)
                {
                    _world.grenade_throws[_i] = undefined;
                }
            }
        }
        if (instance_exists(_op.arms))
        {
            instance_destroy(_op.arms);
        }
        if (instance_exists(arg0.npc))
        {
            arg0.npc.draw_weapon = true;
        }
    }
    arg0.grenade.operation = undefined;
}

function ai_grenade_exit(arg0, arg1, arg2)
{
    ai_grenade_cancel(arg0.user_data);
    __ai_human_action_exit(arg0, arg1, arg2);
}

function ai_grenade_isolated_opportunity(arg0)
{
    if (arg0.knowledge.visible || !arg0.profile.config.grenade.isolated_priority || npc_get_prob_grenade_throw(arg0.npc.npc_id) <= 0)
    {
        return false;
    }
    var _cover = ai_cover_current(arg0);
    return is_struct(_cover) && _cover.kind == "isolated" && ai_grenade_ready(arg0);
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2
}
