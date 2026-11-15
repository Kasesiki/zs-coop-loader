var _timer_previous = timer_exit;
if (!uscito && player_exists_local())
{
    if (draw_smoke == true && instance_exists(obj_particles_controller))
    {
        var a = UnknownEnum.Value_37;
        part_particles_create(obj_particles_controller.particles_system[a], x + 8, y + 8, obj_particles_controller.particles_type[a], 1);
    }
    if (player_distance_local(x + 8, y + 8) < minimum_dis_exit && !player_local_state_is(scr_player_state_inventory))
    {
        timer_exit++;
        if (timer_exit >= timer_exit_max)
        {
            uscito = true;
            if (instance_exists(obj_map_generator) && obj_map_generator.area != UnknownEnum.Value_10)
            {
                global.last_run_succeeded = true;
                mods_perform_event("raid_extracted", [player_get_local(), obj_map_generator.area]);
            }
            player_set_local_state(scr_player_state_start);
            if (!instance_exists(obj_exit_screen))
            {
                var eend = instance_create_depth(x, y, -9999, obj_exit_screen);
                eend.survived = true;
                eend.factor_survived = 1;
                global.ui_close_flag = true;
                tutorial_achievement();
            }
            with (obj_camera)
            {
                follow = UnknownEnum.Value_1;
                camera_set_view_size(view_camera[0], 480, 270);
            }
            with (player_get_local().torch_holder)
            {
                instance_destroy();
            }
            obj_controller.alarm[4] = 99999;
            if (instance_exists(obj_map_generator) && obj_map_generator.area != UnknownEnum.Value_10)
            {
                global.az_done[UnknownEnum.Value_3] = true;
            }
            instance_destroy();
        }
    }
    else
    {
        timer_exit = 0;
    }
}
depth = -9999;
if (!uscito)
{
    var _area = instance_exists(obj_map_generator) ? obj_map_generator.area : -1;
    if (_timer_previous <= 0 && timer_exit > 0)
    {
        mods_perform_event("extraction_started", [player_get_local(), id, _area], id);
    }
    else if (_timer_previous > 0 && timer_exit <= 0)
    {
        mods_perform_event("extraction_cancelled", [player_get_local(), id, _area], id);
    }
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_3 = 3,
    Value_10 = 10,
    Value_37 = 37
}
