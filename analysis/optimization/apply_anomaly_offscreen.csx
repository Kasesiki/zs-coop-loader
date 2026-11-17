using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

UndertaleCode RequireCode(string name)
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
    {
        throw new Exception("Required anomaly code entry is missing: " + name);
    }
    return code;
}

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

UndertaleCode fireStep = RequireCode("gml_Object_obj_anomaly_fire_Step_0");
UndertaleCode gasStep = RequireCode("gml_Object_obj_anomaly_gas_Step_0");
UndertaleCode electricStep = RequireCode("gml_Object_obj_anomaly_electric_Step_0");
UndertaleCode electricGenerator = RequireCode("gml_Object_obj_anomaly_electric_generator_Step_0");
UndertaleCode anomalyEnemyFire = RequireCode("gml_Object_obj_enemy_anomaly_fire_Step_0");
UndertaleCode anomalyEnemyElectric = RequireCode("gml_Object_obj_enemy_anomaly_electric_Step_0");

// All anomaly children and the electric generator run their Step even when they
// are nowhere near the camera. A big fire area creates 65 children; gas creates
// 30. Each child does player/NPC/bolt collision checks and can emit particles
// every frame, so a map with several anomalies pays for all of them at once.
//
// Stop the Step only when the instance is clearly outside the camera plus a
// margin. The margin scales with the camera width so it stays correct at other
// view sizes. Inside the margin the original collision, damage and activation
// logic runs unchanged, including damage to NPCs that are just off-screen.
//
// Camera values are cached per 16 ms bucket in globals: before this, every one
// of the 95+ anomaly children called four camera_get_view_* builtins each
// frame. The cache is one frame stale at most and the culling margin absorbs it.
const string CameraCache = @"
    var _coop_now = current_time div 16;
    if (!variable_global_exists(""coop_camera_frame"") || global.coop_camera_frame != _coop_now || global.coop_camera_room != room)
    {
        global.coop_camera_frame = _coop_now;
        global.coop_camera_room = room;
        global.coop_camera_x = camera_get_view_x(view_camera[0]);
        global.coop_camera_y = camera_get_view_y(view_camera[0]);
        global.coop_camera_w = camera_get_view_width(view_camera[0]);
        global.coop_camera_h = camera_get_view_height(view_camera[0]);
    }
    var _coop_camx = global.coop_camera_x;
    var _coop_camy = global.coop_camera_y;
    var _coop_camw = global.coop_camera_w;
    var _coop_camh = global.coop_camera_h;
";

string CameraGuard(string minimum, string factor)
{
    return @"
var _coop_draw_particles = true;
if (view_camera[0] != -1)
{
" + CameraCache + @"
    var _coop_margin = max(" + minimum + @", _coop_camw * " + factor + @");
    if (x < _coop_camx - _coop_margin || x > _coop_camx + _coop_camw + _coop_margin || y < _coop_camy - _coop_margin || y > _coop_camy + _coop_camh + _coop_margin)
    {
        exit;
    }
    _coop_draw_particles = x >= _coop_camx - 64 && x <= _coop_camx + _coop_camw + 64 && y >= _coop_camy - 64 && y <= _coop_camy + _coop_camh + 64;
}
";
}

string ParticleVisibility()
{
    return @"
var _coop_draw_particles = true;
if (view_camera[0] != -1)
{
" + CameraCache + @"
    _coop_draw_particles = x >= _coop_camx - 64 && x <= _coop_camx + _coop_camw + 64 && y >= _coop_camy - 64 && y <= _coop_camy + _coop_camh + 64;
}
";
}

foreach (UndertaleCode code in new[] { fireStep, gasStep, electricStep })
{
    importGroup.QueuePrepend(code, CameraGuard("96", "0.25"));
}

// Particles are only visible inside the view. Instances between the view edge
// and the culling margin still run collision/damage logic, but skip the
// particle bursts that would be born off-screen.
importGroup.QueueFindReplace(fireStep,
    "if (active)\n{\n    var a = UnknownEnum.Value_13;",
    "if (_coop_draw_particles && active)\n{\n    var a = UnknownEnum.Value_13;",
    true);
importGroup.QueueFindReplace(fireStep,
    "if (scr_chance(0.2))\n{\n    var a = UnknownEnum.Value_14;",
    "if (scr_chance(0.2) && _coop_draw_particles)\n{\n    var a = UnknownEnum.Value_14;",
    true);

foreach (string chance in new[] { "2", "25", "0.5" })
{
    importGroup.QueueFindReplace(gasStep,
        "if (scr_chance(" + chance + "))\n{\n    var a = UnknownEnum.Value_",
        "if (scr_chance(" + chance + ") && _coop_draw_particles)\n{\n    var a = UnknownEnum.Value_",
        true);
}

// The active-gas extra bursts are nested inside an active check, so match the
// condition itself instead of the indentation-sensitive block.
importGroup.QueueFindReplace(gasStep,
    "if (scr_chance(10))",
    "if (scr_chance(10) && _coop_draw_particles)",
    true);
importGroup.QueueFindReplace(gasStep,
    "if (scr_chance(20))",
    "if (scr_chance(20) && _coop_draw_particles)",
    true);

importGroup.QueueFindReplace(electricStep,
    "if (scr_chance(100))\n{\n    var a = UnknownEnum.Value_20;",
    "if (scr_chance(100) && _coop_draw_particles)\n{\n    var a = UnknownEnum.Value_20;",
    true);

// The electric generator emits a 10-particle burst every frame and can create
// up to 96-pixel spark paths. Its Step does not manage the looped emitter
// sound, so skipping it off-screen only skips particles, lights and damage
// checks that cannot be seen or reached from the view.
importGroup.QueuePrepend(electricGenerator, CameraGuard("160", "0.33"));
importGroup.QueueFindReplace(electricGenerator,
    "if (scr_chance(100))\n{\n    if (instance_exists(obj_particles_controller))",
    "if (scr_chance(100) && _coop_draw_particles)\n{\n    if (instance_exists(obj_particles_controller))",
    true);

// Anomaly wraiths emit their body particles every Step while their AI keeps
// running. The AI must not be culled, but the particle bursts are invisible
// outside the view, so only those are gated.
importGroup.QueuePrepend(anomalyEnemyFire, ParticleVisibility());
importGroup.QueuePrepend(anomalyEnemyElectric, ParticleVisibility());
importGroup.QueueFindReplace(anomalyEnemyFire,
    "part_emitter_burst(ob.particles_system[a], ob.partciles_emitter[a], ob.particles_type[a], ob.particle_amount[a]);",
    "if (_coop_draw_particles) { part_emitter_burst(ob.particles_system[a], ob.partciles_emitter[a], ob.particles_type[a], ob.particle_amount[a]); }",
    true);
importGroup.QueueFindReplace(anomalyEnemyElectric,
    "if (instance_exists(obj_particles_controller))",
    "if (_coop_draw_particles && instance_exists(obj_particles_controller))",
    true);

importGroup.Import();
ScriptMessage("Applied anomaly off-screen culling with cached camera and particle visibility gating.");
