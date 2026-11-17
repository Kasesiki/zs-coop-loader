using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

UndertaleCode RequireCode(string name)
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
    {
        throw new Exception("Required fire anomaly code entry is missing: " + name);
    }
    return code;
}

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

UndertaleCode particles = RequireCode("gml_Object_obj_particles_controller_Create_0");
UndertaleCode fireStep = RequireCode("gml_Object_obj_anomaly_fire_Step_0");
UndertaleCode lightInit = RequireCode("gml_Object_obj_light_Alarm_0");

// The large red layer over a fire anomaly is particle type 15: a cloud shape
// with life 90-180 and size 5-7, emitted once per frame by the fire parent.
// The individual alpha is tiny, but the overlapping fill is expensive. Keep
// the same particle type and color, only shorten its life and reduce its size.
importGroup.QueueFindReplace(particles,
    @"part_type_life(particles_type[a], 90, 180);
part_type_orientation(particles_type[a], 0, 360, 0, 2, 0);
part_type_size(particles_type[a], 5, 7, 0, 0);",
    @"part_type_life(particles_type[a], 60, 110);
part_type_orientation(particles_type[a], 0, 360, 0, 2, 0);
part_type_size(particles_type[a], 3, 5, 0, 0);",
    true);

// Type 14 is the long-lived ember/fireball trail. Shorten its life, and reduce
// the amount only for this type; the short active-flame type 13 keeps its
// original 5-particle burst.
importGroup.QueueFindReplace(particles,
    @"a = UnknownEnum.Value_14;
particles_system[a] = part_system_create();
part_system_depth(particles_system[a], -15910);
partciles_emitter[a] = part_emitter_create(particles_system[a]);
particles_type[a] = part_type_create();
part_type_shape(particles_type[a], 10);
part_type_life(particles_type[a], 90, 120);",
    @"a = UnknownEnum.Value_14;
particles_system[a] = part_system_create();
part_system_depth(particles_system[a], -15910);
partciles_emitter[a] = part_emitter_create(particles_system[a]);
particles_type[a] = part_type_create();
part_type_shape(particles_type[a], 10);
part_type_life(particles_type[a], 60, 90);",
    true);
importGroup.QueueFindReplace(fireStep,
    @"if (scr_chance(0.2))
{
    var a = UnknownEnum.Value_14;
    var c = obj_particles_controller;
    part_particles_create(c.particles_system[a], x, y, c.particles_type[a], c.particle_fire_amount);
}",
    @"if (scr_chance(0.2))
{
    var a = UnknownEnum.Value_14;
    var c = obj_particles_controller;
    part_particles_create(c.particles_system[a], x, y, c.particles_type[a], min(c.particle_fire_amount, 2));
}",
    true);

// Anomaly wraiths each carry a 256x256 additive fire light; several of them
// overlap into a large red glow. Reduce the glow radius/alpha and the 60-frame
// death light, without removing the light entirely.
importGroup.QueueFindReplace(lightInit,
    @"    case ""wraith_fire"":
        light_sprite = s_glow_256x256;
        scale_start = 0.5;
        alpha_togliere = 0.4;
        alpha_mettere = 0.9;",
    @"    case ""wraith_fire"":
        light_sprite = s_glow_256x256;
        scale_start = 0.35;
        alpha_togliere = 0.3;
        alpha_mettere = 0.65;",
    true);
importGroup.QueueFindReplace(lightInit,
    @"    case ""wraith_fire_dead"":
        light_sprite = s_glow_256x256;
        scale_start = 1;
        alpha_togliere = 0.4;
        alpha_mettere = 0.7;",
    @"    case ""wraith_fire_dead"":
        light_sprite = s_glow_256x256;
        scale_start = 0.7;
        alpha_togliere = 0.3;
        alpha_mettere = 0.5;",
    true);

importGroup.Import();
ScriptMessage("Applied fire anomaly visual load reduction.");
