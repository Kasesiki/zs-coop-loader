function ai_human_rollout_batch(arg0)
{
    static _batches = 
    {
        bandit_rookie: 1,
        bandit_intermediate: 1,
        bandit_skilled: 1,
        bandit_expert: 1,
        bandit_veteran: 1,
        bandit_master: 1,
        bandit_novice: 1,
        bandit_regular: 1,
        crimson_rookie: 2,
        crimson_intermediate: 2,
        crimson_skilled: 2,
        crimson_expert: 2,
        crimson_veteran: 2,
        crimson_master: 2,
        green_army_rookie: 2,
        green_army_intermediate: 2,
        green_army_skilled: 2,
        green_army_expert: 2,
        green_army_veteran: 2,
        green_army_master: 2,
        watcher_rookie: 2,
        watcher_intermediate: 2,
        watcher_skilled: 2,
        watcher_expert: 2,
        watcher_veteran: 2,
        watcher_master: 2,
        crimson_soldier: 2,
        green_army_soldier: 2,
        crimson_cyclops: 2,
        green_army_cyclops: 2,
        watcher_cyclops: 2,
        watcher_devil: 2,
        mercenary: 2,
        hunter_rookie: 3,
        hunter_intermediate: 3,
        hunter_skilled: 3,
        hunter_expert: 3,
        hunter_veteran: 3,
        hunter_master: 3,
        hunter_cyclops: 3,
        loner_enemy: 3,
        loner_enemy_2: 3
    };
    
    return (is_string(arg0) && variable_struct_exists(_batches, arg0)) ? variable_struct_get(_batches, arg0) : 0;
}

function ai_human_rollout_enabled(arg0, arg1 = 4)
{
    if (!__ai_profile_between(arg1, 0, 4, true))
    {
        return false;
    }
    if (arg1 == 4)
    {
        return is_string(arg0);
    }
    var _batch = ai_human_rollout_batch(arg0);
    return _batch > 0 && _batch <= arg1;
}

function ai_human_world_ready()
{
    var _map = instance_find(obj_map_generator, 0);
    return !instance_exists(_map) || !variable_instance_exists(_map, "state") || _map.state == UnknownEnum.Value_21;
}

enum UnknownEnum
{
    Value_21 = 21
}
