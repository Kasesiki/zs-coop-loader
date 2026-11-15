function ai_human_migrated(arg0)
{
    return instance_exists(arg0) && variable_instance_exists(arg0, "ai_execution") && is_struct(arg0.ai_execution) && arg0.ai_execution.profile.config.tree == "human_basic";
}

function ai_bridge_create(arg0)
{
    arg0.bridge = 
    {
        events: [],
        last_bullet: noone,
        near_bullets: [],
        damage_until: 0,
        last_frame: ai_world_get().frame,
        hit: 
        {
            pending: false,
            active: false,
            surprised: false,
            cooldown_until: 0,
            ready_at: 0,
            expires: 0,
            threat: undefined
        }
    };
}

function ai_human_ingest(arg0, arg1, arg2, arg3, arg4, arg5 = 0)
{
    if (!ai_human_migrated(arg0))
    {
        return false;
    }
    var _e = arg0.ai_execution;
    if ((arg4 != "damage" && arg4 != "near_miss" && arg4 != "legacy_shot") || !__ai_profile_number(arg5) || arg5 < 0 || arg5 > 256)
    {
        return true;
    }
    if (arg0.hp <= 0 || !__ai_profile_number(arg2) || !__ai_profile_number(arg3))
    {
        return true;
    }
    if (!__ai_perception_hostile(arg0, arg1))
    {
        return true;
    }
    var _queue = _e.bridge.events;
    if (array_length(_queue) >= 8)
    {
        array_delete(_queue, 0, 1);
    }
    var _angle = ai_profile_random(_e.rng) * 360;
    var _radius = ai_profile_random(_e.rng) * max(0, arg5);
    array_push(_queue, 
    {
        target: arg1,
        x: arg2 + lengthdir_x(_radius, _angle),
        y: arg3 + lengthdir_y(_radius, _angle),
        source: arg4,
        uncertainty: arg5,
        frame: ai_world_get().frame,
        hit_angle: abs(angle_difference(point_direction(arg0.x, arg0.y, arg2, arg3), arg0.weapon_pointing_direction)),
        hit_distance: point_distance(arg0.x, arg0.y, arg2, arg3)
    });
    _e.bridge.events = _queue;
    return true;
}

function __ai_bridge_damage_switch(arg0, arg1)
{
    var _k = arg0.knowledge;
    var _c = arg0.profile.config.targeting;
    if (!_k.valid || !_k.visible || arg1.source != "damage" || arg1.target == _k.target || !_c.enabled || !_c.damage_switch || arg0.now < (arg0.perception.switch_at + _c.switch_cooldown_seconds))
    {
        return false;
    }
    var _npc = arg0.npc;
    return point_distance(_npc.x, _npc.y, arg1.x, arg1.y) < point_distance(_npc.x, _npc.y, _k.x, _k.y);
}

function ai_bridge_step(arg0)
{
    var _frame = ai_world_get().frame;
    var _queue = arg0.bridge.events;
    for (var _i = 0; _i < array_length(_queue); _i++)
    {
        var _event = _queue[_i];
        var _age = max(0, (_frame - _event.frame) / 60);
        if (_age > 3 || _age > arg0.now || !__ai_perception_hostile(arg0.npc, _event.target))
        {
            continue;
        }
        if (_event.source == "damage" || _event.source == "near_miss")
        {
            arg0.bridge.damage_until = arg0.now + 1;
            ai_perception_return_fire_mark(arg0, _event.target, _age);
        }
        if (_event.source == "damage")
        {
            __ai_human_hit_schedule(arg0, _event, _age);
        }
        if (_event.source == "near_miss")
        {
            __ai_human_near_miss(arg0, _event, _age);
        }
        var _damage_switch = __ai_bridge_damage_switch(arg0, _event);
        if (arg0.knowledge.valid && arg0.knowledge.visible && !_damage_switch)
        {
            continue;
        }
        var _accepted = ai_perception_observe(arg0, _event.target, _event.x, _event.y, _event.source, arg0.now - _age, _event.uncertainty);
        if (_accepted && _damage_switch)
        {
            arg0.perception.switch_at = arg0.now;
        }
    }
    arg0.bridge.events = [];
    var _bullet = instance_nearest(arg0.npc.x, arg0.npc.y, obj_bullet_parent);
    if (instance_exists(_bullet) && _bullet != arg0.bridge.last_bullet && point_distance(arg0.npc.x, arg0.npc.y, _bullet.x, _bullet.y) < arg0.profile.config.suppression.radius_px)
    {
        arg0.bridge.last_bullet = _bullet;
        var _seen = arg0.bridge.near_bullets;
        var _i = array_length(_seen) - 1;
        while (_i >= 0)
        {
            if ((_frame - _seen[_i].frame) > (60 * arg0.profile.config.suppression.window_seconds))
            {
                array_delete(_seen, _i, 1);
            }
            else if (_seen[_i].bullet == _bullet)
            {
                exit;
            }
            _i--;
        }
        if (array_length(_seen) >= 16)
        {
            array_delete(_seen, 0, 1);
        }
        array_push(_seen, 
        {
            bullet: _bullet,
            frame: _frame
        });
        arg0.bridge.near_bullets = _seen;
        ai_human_ingest(arg0.npc, _bullet.shooter_id, _bullet.start_x, _bullet.start_y, "near_miss", 48);
    }
}

function ai_human_suspend(arg0, arg1)
{
    if (!ai_human_migrated(arg0))
    {
        exit;
    }
    ai_routes_suspend(arg0.ai_execution);
    ai_human_cancel(arg0, arg1);
    var _e = arg0.ai_execution;
    _e.combat.cover = undefined;
    ai_perception_forget(_e, arg1);
    _e.bridge.events = [];
}

function ai_human_before_cull(arg0, arg1, arg2, arg3, arg4 = false)
{
    with (obj_npc_parent)
    {
        if (ai_human_migrated(id) && (arg4 || bbox_right < arg0 || bbox_left > arg2 || bbox_bottom < arg1 || bbox_top > arg3))
        {
            ai_human_suspend(id, "culled");
        }
    }
}
