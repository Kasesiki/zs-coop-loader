function scr_player_quest_trigger_end_game()
{
    if (instance_exists(obj_quest_end_game))
    {
        var _x = obj_quest_end_game.x;
        var _y = obj_quest_end_game.y;
        if (point_distance(x, y, _x, _y) < 96 && global.end_game_done_test == false)
        {
            scr_player_quest_start_end_game_cutscene(60);
        }
    }
}

function scr_player_quest_prepare_end_game_cutscene()
{
    if (!player_exists_local())
    {
        return false;
    }
    if (!instance_exists(obj_quest_end_game))
    {
        return false;
    }
    with (player_get_local())
    {
        action = true;
        player_set_local_state(scr_player_state_dummy);
        hspd = 0;
        vspd = 0;
        arms_holder = undefined;
        weapon_holder.is_visible = false;
        if (instance_exists(torch_holder))
        {
            with (torch_holder)
            {
                instance_destroy();
            }
        }
        torch_holder = -4;
        global.night_vision = false;
        mods_player_heal(id, hp_max - hp);
        bleed = 0;
        radiation_accumulata = 0;
        weapon_pointing_direction = point_direction(x, y, obj_quest_end_game.x, obj_quest_end_game.y);
    }
    if (instance_exists(obj_camera))
    {
        obj_camera.follow = UnknownEnum.Value_6;
        obj_camera.x = obj_quest_end_game.x;
        obj_camera.y = obj_quest_end_game.y + 48;
    }
    return true;
}

function scr_player_quest_start_end_game_cutscene(arg0 = 60)
{
    if (!scr_player_quest_prepare_end_game_cutscene())
    {
        return false;
    }
    obj_quest_end_game.alarm[0] = arg0;
    global.end_game_done_test = true;
    return true;
}

function end_game_start_boss_transition(arg0, arg1)
{
    if (!variable_global_exists("end_game_boss_transition_active"))
    {
        global.end_game_boss_transition_active = false;
    }
    if (global.end_game_boss_transition_active)
    {
        return false;
    }
    if (variable_global_exists("end_game_done_test"))
    {
        if (global.end_game_done_test)
        {
            return false;
        }
    }
    if (!player_exists_local())
    {
        return false;
    }
    global.end_game_boss_transition_active = true;
    global.end_game_boss_transition_target_x = arg0;
    global.end_game_boss_transition_target_y = arg1;
    global.end_game_boss_transition_player_y_offset = 48;
    instance_activate_object(obj_quest_end_game_spawner);
    array_push(obj_controller.function_queue_end_step, method(undefined, function()
    {
        if (!global.end_game_boss_transition_active)
        {
            exit;
        }
        if (instance_exists(obj_quest_end_game_spawner))
        {
            global.end_game_boss_transition_target_x = obj_quest_end_game_spawner.x;
            global.end_game_boss_transition_target_y = obj_quest_end_game_spawner.y;
        }
    }));
    var _fade = instance_create_depth(x, y, 0, obj_hud_white_fade);
    _fade.fade_color = 0;
    _fade.alpha_amount = 0.035;
    _fade.timer_full_white = 30;
    _fade.end_game_boss_transition = true;
    return true;
}

function end_game_boss_transition_spawn()
{
    var _x = global.end_game_boss_transition_target_x;
    var _y = global.end_game_boss_transition_target_y;
    var _anomaly = -4;
    if (instance_exists(obj_quest_end_game))
    {
        _anomaly = obj_quest_end_game;
        _anomaly.x = _x;
        _anomaly.y = _y;
    }
    else
    {
        _anomaly = instance_create_depth(_x, _y, 0, obj_quest_end_game);
    }
    x = _anomaly.x;
    y = _anomaly.y;
    if (player_exists_local())
    {
        with (player_get_local())
        {
            x = _anomaly.x;
            y = _anomaly.y + global.end_game_boss_transition_player_y_offset;
            hspd = 0;
            vspd = 0;
        }
    }
    scr_player_quest_prepare_end_game_cutscene();
    global.end_game_done_test = true;
}

function end_game_boss_transition_start_dialogue()
{
    if (!scr_player_quest_start_end_game_cutscene(1))
    {
        global.end_game_done_test = false;
        if (player_exists_local())
        {
            with (player_get_local())
            {
                player_set_local_state(scr_player_state_move);
                weapon_holder.is_visible = true;
            }
        }
        if (instance_exists(obj_camera))
        {
            obj_camera.follow = UnknownEnum.Value_1;
        }
    }
    global.end_game_boss_transition_active = false;
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_6 = 6
}
