var _ai_owned = variable_instance_exists(id, "ai_grenade_execution");
if (_ai_owned && !ai_grenade_valid(id))
{
    instance_destroy();
    exit;
}
if (instance_exists(linked_id))
{
    var _grenade = instance_create_depth(linked_id.x, linked_id.y, 0, obj_grenade_parent, 
    {
        grenade_id: grenade_id,
        throw_min: item_grenade_get_throw_min(grenade_id),
        throw_max: item_grenade_get_throw_max(grenade_id),
        fuse_time: item_grenade_get_fuse_time(grenade_id),
        throw_type: item_grenade_get_throw_type(grenade_id),
        damage_max: item_grenade_get_damage_max(grenade_id),
        damage_min: item_grenade_get_damage_min(grenade_id),
        detonation_type: item_grenade_get_detonation_type(grenade_id),
        detonation_duration: item_grenade_get_detonation_duration(grenade_id),
        radius_max_damage: item_grenade_get_radius_max_damage(grenade_id),
        radius_min_damage: item_grenade_get_radius_min_damage(grenade_id),
        throw_direction: point_direction(linked_id.x, linked_id.y, target_x, target_y),
        throw_speed: 3,
        detonation_point: point_distance(linked_id.x, linked_id.y, target_x, target_y),
        sprite_index: item_get_sprite_ingame(grenade_id)
    });
    _grenade.faction = faction;
    _grenade.ai_thrower = linked_id;
    _grenade.ai_thrower_team_id = variable_instance_exists(linked_id, "ai_team_id") ? linked_id.ai_team_id : undefined;
    _grenade.ai_thrower_is_hunter = ai_human_migrated(linked_id) && linked_id.ai_execution.profile.config.profile == "hunter";
    linked_id.draw_weapon = true;
    if (_ai_owned)
    {
        ai_grenade_commit(id);
    }
    else
    {
        linked_id.state_finito = true;
    }
}
instance_destroy();
