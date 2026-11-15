function scr_horizon_armor_absorbed(arg0, arg1)
{
    var a = UnknownEnum.Value_70;
    var _o = obj_particles_controller;
    part_particles_create(_o.particles_system[a], arg0, arg1 - 6, _o.particles_type[a], 1);
}

enum UnknownEnum
{
    Value_70 = 70
}
