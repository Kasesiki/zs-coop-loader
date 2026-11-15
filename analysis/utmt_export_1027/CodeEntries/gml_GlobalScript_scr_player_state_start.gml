function scr_player_state_start()
{
    if (instance_exists(obj_map_generator))
    {
        var _map = obj_map_generator.area;
        var _spawn_with_train = obj_map_generator.area_player_train_spawn[_map];
        if (_map == UnknownEnum.Value_9)
        {
            _spawn_with_train = quest_is_complete("watcher_headquarters");
        }
        if (_spawn_with_train == true)
        {
            if (instance_exists(obj_train))
            {
                x = obj_train.x;
                y = obj_train.y;
            }
        }
        else if (instance_exists(obj_spawner_player_100))
        {
            x = obj_spawner_player_100.x;
            y = obj_spawner_player_100.y;
        }
    }
    visible = false;
}

enum UnknownEnum
{
    Value_9 = 9
}
