with (obj_player_parent)
{
    with (other)
    {
        if (place_meeting(x, y, other.id))
        {
            active = true;
            alarm[10] = 5;
            var _armor_id = player_get_local().armor_now;
            if (player_get_local() == other.id)
            {
                if (_armor_id != "armor_rotking")
                {
                    scr_anomaly_damage(damage);
                }
                else
                {
                    mods_player_heal(player_get_local(), 0.2);
                }
            }
            if (!audio_is_playing(snd_chemical_collision))
            {
                audio_play_sound(snd_chemical_collision, 10, false);
            }
        }
    }
    if (hp <= 0)
    {
    }
}
if (active == true)
{
    if (!place_meeting(x, y, obj_player_parent))
    {
        audio_stop_sound(snd_chemical_collision);
    }
}
var quale_id = instance_place(x, y, obj_npc_parent);
if (instance_exists(quale_id))
{
    if (quale_id.object_index != obj_rat_v2 && quale_id.object_index != obj_boss_rotking)
    {
        active = true;
        alarm[10] = 5;
        npc_damage(quale_id, 0.5, id);
    }
}
if (place_meeting(x, y, obj_bolt))
{
    active = true;
    alarm[10] = 30;
    if (instance_exists(obj_prologue))
    {
        if (obj_prologue.state == UnknownEnum.Value_31)
        {
            obj_prologue.timer_go = true;
            obj_prologue.timer_max = 30;
        }
    }
}
if (scr_chance(2))
{
    var a = UnknownEnum.Value_17;
    var c = obj_particles_controller;
    part_emitter_region(c.particles_system[a], c.partciles_emitter[a], x - 4, x + 4, y - 0, y + 0, 1, 1);
    part_emitter_burst(c.particles_system[a], c.partciles_emitter[a], c.particles_type[a], c.particle_amount[a]);
}
if (scr_chance(25))
{
    var a = UnknownEnum.Value_18;
    var c = obj_particles_controller;
    part_emitter_region(c.particles_system[a], c.partciles_emitter[a], x - 4, x + 4, y - 1, y + 1, 1, 1);
    part_emitter_burst(c.particles_system[a], c.partciles_emitter[a], c.particles_type[a], c.particle_amount[a]);
}
if (scr_chance(0.5))
{
    var a = UnknownEnum.Value_19;
    var c = obj_particles_controller;
    part_emitter_region(c.particles_system[a], c.partciles_emitter[a], x - 4, x + 4, y - 1, y + 1, 1, 1);
    part_emitter_burst(c.particles_system[a], c.partciles_emitter[a], c.particles_type[a], c.particle_amount[a]);
}
if (active == true)
{
    if (scr_chance(10))
    {
        var a = UnknownEnum.Value_19;
        var c = obj_particles_controller;
        part_emitter_region(c.particles_system[a], c.partciles_emitter[a], x - 4, x + 4, y - 1, y + 1, 1, 1);
        part_emitter_burst(c.particles_system[a], c.partciles_emitter[a], c.particles_type[a], c.particle_amount[a]);
    }
    if (scr_chance(20))
    {
        var a = UnknownEnum.Value_17;
        var c = obj_particles_controller;
        part_emitter_region(c.particles_system[a], c.partciles_emitter[a], x - 4, x + 4, y - 0, y + 0, 1, 1);
        part_emitter_burst(c.particles_system[a], c.partciles_emitter[a], c.particles_type[a], c.particle_amount[a]);
    }
}

enum UnknownEnum
{
    Value_17 = 17,
    Value_18,
    Value_19,
    Value_31 = 31
}
