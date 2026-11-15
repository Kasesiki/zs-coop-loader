function prologue_try_tutorial_jam()
{
    if (obj_prologue.tutorial_jam_fired)
    {
        exit;
    }
    if (!(instance_exists(obj_map_generator) && obj_map_generator.area == UnknownEnum.Value_10))
    {
        exit;
    }
    if (!(obj_prologue.state == UnknownEnum.Value_14 || obj_prologue.state == UnknownEnum.Value_15))
    {
        exit;
    }
    if (player_loadout_get_fire_mode(self, weapon_slot_now) == "bolt_action")
    {
        exit;
    }
    var _b = instance_nearest(x, y, obj_bandit_preset_rookie);
    if (!instance_exists(_b))
    {
        exit;
    }
    if (point_distance(x, y, _b.x, _b.y) >= 220)
    {
        exit;
    }
    player_loadout_set_jammed(weapon_slot_now, true);
    obj_prologue.tutorial_jam_fired = true;
}

enum UnknownEnum
{
    Value_10 = 10,
    Value_14 = 14,
    Value_15
}
