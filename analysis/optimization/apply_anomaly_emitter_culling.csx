using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

UndertaleCode RequireCode(string name)
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
        throw new Exception("Required anomaly emitter code entry is missing: " + name);
    return code;
}

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

// Keep the full anomaly particle definition and all visible emissions. The
// parent emitter is skipped only when its whole emission rectangle misses the
// camera, so a large anomaly still emits when its area overlaps the view.
importGroup.QueueFindReplace(RequireCode("gml_Object_obj_anomaly_fire_parent_Step_0"),
    "var chance = obj_controller.place_radius[ano_id] * obj_controller.place_radius[ano_id];\nif (!settings_get(\"low spec\"))\n{\n    if (scr_chance(chance))",
    "var chance = obj_controller.place_radius[ano_id] * obj_controller.place_radius[ano_id];\nvar _camx = camera_get_view_x(view_camera[0]);\nvar _camy = camera_get_view_y(view_camera[0]);\nvar _camw = camera_get_view_width(view_camera[0]);\nvar _camh = camera_get_view_height(view_camera[0]);\nvar _d = (obj_controller.place_radius[ano_id] * 16) / 2;\nvar _visible = x + _d >= _camx && x - _d <= _camx + _camw && y + _d >= _camy && y - _d <= _camy + _camh;\nif (!settings_get(\"low spec\"))\n{\n    if (_visible && scr_chance(chance))",
    true);
importGroup.QueueFindReplace(RequireCode("gml_Object_obj_anomaly_gas_parent_Step_0"),
    "var chance = obj_controller.place_radius[ano_id];\nif (!settings_get(\"low spec\"))\n{\n    if (scr_chance(chance))",
    "var chance = obj_controller.place_radius[ano_id];\nvar _camx = camera_get_view_x(view_camera[0]);\nvar _camy = camera_get_view_y(view_camera[0]);\nvar _camw = camera_get_view_width(view_camera[0]);\nvar _camh = camera_get_view_height(view_camera[0]);\nvar _d = (obj_controller.place_radius[ano_id] * 16) / 2;\nvar _visible = x + _d >= _camx && x - _d <= _camx + _camw && y + _d >= _camy && y - _d <= _camy + _camh;\nif (!settings_get(\"low spec\"))\n{\n    if (_visible && scr_chance(chance))",
    true);

importGroup.Import();
ScriptMessage("Applied anomaly emitter culling: preserved particles whose emission area overlaps the camera.");
