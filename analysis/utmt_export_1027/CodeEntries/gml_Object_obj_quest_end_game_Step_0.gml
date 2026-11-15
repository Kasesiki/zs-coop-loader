if (instance_exists(obj_particles_controller))
{
    var ob = obj_particles_controller;
    timer_effect_1++;
    if (timer_effect_1 >= timer_effect_1_max)
    {
        timer_effect_1 = 0;
        var a = UnknownEnum.Value_65;
        part_emitter_region(ob.particles_system[a], ob.partciles_emitter[a], x, x, y, y, 0, 0);
        part_emitter_burst(ob.particles_system[a], ob.partciles_emitter[a], ob.particles_type[a], 2);
    }
    timer_effect_2++;
    if (timer_effect_2 >= timer_effect_2_max)
    {
        timer_effect_2 = 0;
        var a = UnknownEnum.Value_66;
        var _r = 2;
        part_emitter_region(ob.particles_system[a], ob.partciles_emitter[a], x - _r, x + _r, y - _r, y + _r, 0, 0);
        part_emitter_burst(ob.particles_system[a], ob.partciles_emitter[a], ob.particles_type[a], 1);
    }
    timer_effect_3++;
    if (timer_effect_3 >= timer_effect_2_max)
    {
        timer_effect_3 = 0;
        var a = UnknownEnum.Value_67;
        var _r = 2;
        part_emitter_region(ob.particles_system[a], ob.partciles_emitter[a], x - _r, x + _r, y - _r, y + _r, 0, 0);
        part_emitter_burst(ob.particles_system[a], ob.partciles_emitter[a], ob.particles_type[a], 1);
    }
}
if (instance_exists(obj_npc_draw_text))
{
    if (obj_npc_draw_text.text_id == UnknownEnum.Value_247 || obj_npc_draw_text.text_id == UnknownEnum.Value_254)
    {
        alarm[1] = 30;
    }
}
if (instance_exists(obj_npc_draw_text))
{
    if (obj_npc_draw_text.text_id == UnknownEnum.Value_262 || obj_npc_draw_text.text_id == UnknownEnum.Value_284)
    {
        alarm[2] = 30;
    }
}

enum UnknownEnum
{
    Value_65 = 65,
    Value_66,
    Value_67,
    Value_247 = 247,
    Value_254 = 254,
    Value_262 = 262,
    Value_284 = 284
}
