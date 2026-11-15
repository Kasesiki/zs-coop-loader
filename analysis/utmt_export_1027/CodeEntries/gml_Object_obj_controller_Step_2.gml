screenshot_handle();
surface_cache_prune();
achievement_step();
if (global.roaming_enabled && player_exists_local() && is_in_raid() && instance_exists(obj_map_generator))
{
    if (obj_map_generator.state == UnknownEnum.Value_21)
    {
        var _roaming_player = player_get_local();
        ai_roaming_step(_roaming_player.x, _roaming_player.y);
    }
}
if ((keyboard_check_pressed(vk_escape) || obj_gamepad.input_value[UnknownEnum.Value_13]) && !__uiGlobal().__defaultOnion.HasInputReceiver())
{
    uiGetData().reward_item = undefined;
    if (__uiGlobal().__defaultOnion.HasInputReceiver())
    {
        ui_inventory_close_all();
    }
    game_pause();
}
if (!instance_exists(obj_main_menu) && variable_global_exists("pending_post_prologue_difficulty") && global.pending_post_prologue_difficulty && is_in_hub() && can_pause && !instance_exists(obj_exit_screen))
{
    global.pending_post_prologue_difficulty = false;
    uiGetData().difficulty_post_prologue = true;
    game_pause();
}
for (var i = 0; i < array_length(function_queue_end_step); i++)
{
    function_queue_end_step[i]();
}
function_queue_end_step = [];
global.UI_Item_Drag_Skip_Placement_Assignment = false;
if (__uiGlobal().__defaultOnion.HasInputReceiver())
{
    ui_pda_close();
}
if (can_pause == false)
{
    can_pause = true;
}

enum UnknownEnum
{
    Value_13 = 13,
    Value_21 = 21
}
