function ai_scene_assignments_create(arg0)
{
    var _kind = "none";
    switch (arg0.npc.npc_id)
    {
        case "scientist":
            _kind = "scientist_idle";
            break;
        case "scientist_2":
            _kind = "scientist_working";
            break;
        case "guardia_crimson_base":
            _kind = "crimson_gate";
            break;
        case "green_army_quest_swamp":
        case "green_army_quest_swamp_leader":
            _kind = "swamp_guard";
            break;
    }
    arg0.scene = 
    {
        kind: _kind,
        active: false,
        next_look: 0,
        next_text: 0,
        look_x: 0,
        look_y: 0
    };
}

function ai_scene_assignments_ready(arg0)
{
    var _e = arg0.user_data;
    return _e.scene.kind != "none" && _e.npc.state == "human_general" && !_e.knowledge.valid && !_e.npc.follow_path && !_e.npc.force_moving_towards_player && point_distance(_e.npc.x, _e.npc.y, _e.assignment.x, _e.assignment.y) <= 6;
}

function ai_scene_assignments_force_shoot(arg0)
{
    return arg0.npc.npc_id == "green_army_quest_swamp" && arg0.knowledge.valid && arg0.knowledge.visible && point_distance(arg0.npc.x, arg0.npc.y, arg0.knowledge.x, arg0.knowledge.y) < 150;
}

function ai_scene_assignments_enter(arg0, arg1)
{
    var _e = arg0.user_data;
    __ai_human_action_enter(arg0, arg1);
    _e.scene.active = true;
    _e.scene.next_look = _e.now;
    ai_commands_stop(_e, arg1.token);
    if (_e.scene.kind == "scientist_working")
    {
        _e.routines.active = true;
        _e.routines.token = arg1.token;
        _e.routines.kind = "scientist_working";
        __ai_routines_start_arms(_e, "scientist_working", arg1.token);
    }
}

function __ai_scene_quest_done()
{
    if (!variable_global_exists("quest_unique_done"))
    {
        return false;
    }
    var _done = global.quest_unique_done;
    var _index = UnknownEnum.Value_70;
    return is_array(_done) && _index >= 0 && _index < array_length(_done) && _done[_index];
}

function __ai_scene_gate_dialogue(arg0, arg1)
{
    if (!__ai_scene_quest_done() || !instance_exists(arg1))
    {
        return false;
    }
    if (variable_instance_exists(arg0.npc, "can_talk") && !arg0.npc.can_talk)
    {
        return false;
    }
    if (!__ai_routines_visible(arg0, arg1, 48))
    {
        return false;
    }
    var _bubble_asset = asset_get_index("obj_npc_draw_text");
    if (_bubble_asset >= 0)
    {
        for (var _i = 0; _i < instance_number(_bubble_asset); _i++)
        {
            var _bubble = instance_find(_bubble_asset, _i);
            if (variable_instance_exists(_bubble, "id_npc") && _bubble.id_npc == arg0.npc)
            {
                return false;
            }
        }
    }
    scr_draw_npc_text(arg0.npc, UnknownEnum.Value_164);
    arg0.npc.can_talk = false;
    return true;
}

function ai_scene_assignments_update(arg0, arg1)
{
    var _e = arg0.user_data;
    var _scene = _e.scene;
    if (!__ai_commands_active(_e, arg1.token) || !ai_scene_assignments_ready(arg0))
    {
        return UnknownEnum.Value_2;
    }
    ai_commands_stop(_e, arg1.token);
    if (_scene.kind == "scientist_working")
    {
        var _player = player_nearest_instance(_e.npc.x, _e.npc.y);
        if (_e.now >= _scene.next_text && __ai_routines_visible(_e, _player, 160))
        {
            _scene.next_text = _e.now + 8;
            __ai_routines_text(_e, UnknownEnum.Value_117);
        }
        return UnknownEnum.Value_0;
    }
    if (_scene.kind == "swamp_guard")
    {
        var _landmark_asset = asset_get_index("obj_faro");
        var _landmark = (_landmark_asset >= 0) ? instance_find(_landmark_asset, 0) : -4;
        if (instance_exists(_landmark))
        {
            ai_commands_aim(_e, arg1.token, _landmark.x, _landmark.y - 150);
            return UnknownEnum.Value_0;
        }
    }
    if (_scene.kind == "crimson_gate")
    {
        __ai_scene_gate_dialogue(_e, player_nearest_instance(_e.npc.x, _e.npc.y));
    }
    if (_e.now >= _scene.next_look)
    {
        _scene.next_look = _e.now + 1;
        var _direction = _e.npc.weapon_pointing_direction + ((ai_profile_random(_e.rng) - 0.5) * 30);
        _scene.look_x = _e.npc.x + lengthdir_x(32, _direction);
        _scene.look_y = _e.npc.y + lengthdir_y(32, _direction);
    }
    ai_commands_aim(_e, arg1.token, _scene.look_x, _scene.look_y);
    return UnknownEnum.Value_0;
}

function ai_scene_assignments_exit(arg0, arg1, arg2)
{
    var _e = arg0.user_data;
    if (_e.scene.kind == "scientist_working")
    {
        ai_routines_cancel(_e);
    }
    _e.scene.active = false;
    __ai_human_action_exit(arg0, arg1, arg2);
}

enum UnknownEnum
{
    Value_0,
    Value_2 = 2,
    Value_70 = 70,
    Value_117 = 117,
    Value_164 = 164
}
