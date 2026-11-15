function end_game_create_white_hud()
{
    if (!player_exists_local())
    {
        exit;
    }
    var _player = player_get_local();
    player_set_local_state(scr_player_state_dummy);
    var _fade = instance_create_depth(_player.x, _player.y, -10000, obj_hud_white_fade);
    _fade.fade_color = 0;
    _fade.timer_full_white = 30;
    _fade.end_game_credits_on_full_fade = true;
}

function end_game_create_credits()
{
    uiGetData().end_game_credits_active = true;
    uiGetData().end_game_credits_finished = false;
    uiGetData().end_game_credits_finish_requested = false;
    if (player_exists_local())
    {
        player_set_local_state(scr_player_state_dummy);
    }
    if (__uiGlobal().__defaultOnion.LayerExists("end game credits"))
    {
        __uiGlobal().__defaultOnion.LayerDelete("end game credits");
    }
    __uiGlobal().__defaultOnion.LayerAddTop("ZS_vanilla/ui/end_game_credits.ui", "end game credits");
}

function end_game_finish_credits()
{
    if (!uiGetData().end_game_credits_active)
    {
        return uiGetData().end_game_credits_active == false;
    }
    uiGetData().end_game_credits_finished = true;
    end_game_create_black_transition_cover(20);
    if (__uiGlobal().__defaultOnion.LayerExists("end game credits"))
    {
        __uiGlobal().__defaultOnion.LayerDelete("end game credits");
    }
    end_game_create_exit_screen(true);
}

function end_game_create_exit_screen(arg0 = false)
{
    if (!player_exists_local())
    {
        exit;
    }
    var _player = player_get_local();
    player_set_local_state(scr_player_state_start);
    if (!instance_exists(obj_exit_screen))
    {
        var eend = instance_create_depth(_player.x, _player.y, -9999, obj_exit_screen);
        eend.survived = true;
        eend.factor_survived = 1;
        if (arg0)
        {
            eend.a = 1;
        }
        global.ui_close_flag = true;
        tutorial_achievement();
    }
    if (instance_exists(obj_camera))
    {
        with (obj_camera)
        {
            follow = UnknownEnum.Value_1;
            camera_set_view_size(view_camera[0], 480, 270);
        }
    }
    if (instance_exists(_player.torch_holder))
    {
        with (_player.torch_holder)
        {
            instance_destroy();
        }
        _player.torch_holder = -4;
    }
    if (instance_exists(obj_controller))
    {
        obj_controller.alarm[4] = 99999;
    }
    if (instance_exists(obj_map_generator))
    {
        if (obj_map_generator.area != UnknownEnum.Value_10)
        {
            global.az_done[UnknownEnum.Value_3] = true;
        }
    }
    with (obj_extraction_point)
    {
        if (variable_instance_exists(id, "end_game_wait_for_credits"))
        {
            if (end_game_wait_for_credits)
            {
                instance_destroy();
            }
        }
    }
}

function end_game_create_black_transition_cover(arg0 = 20)
{
    if (!player_exists_local())
    {
        return -4;
    }
    var _player = player_get_local();
    var _fade = instance_create_depth(_player.x, _player.y, -10000, obj_hud_white_fade);
    _fade.fade_color = 0;
    _fade.alpha = 1;
    _fade.alpha_factor = 1;
    _fade.alpha_amount = 0.06;
    _fade.timer_full_white = arg0;
    return _fade;
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_3 = 3,
    Value_10 = 10
}
