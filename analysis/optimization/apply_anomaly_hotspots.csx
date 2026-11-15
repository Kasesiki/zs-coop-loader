using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string ShaderDraw = "gml_Object_obj_shader_controller_Draw_77";

UndertaleCode shaderDraw = Data.Code.ByName(ShaderDraw);
if (shaderDraw is null)
{
    throw new Exception("Required radiation shader draw event is missing: " + ShaderDraw);
}

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

// Keep all anomaly particle calls unchanged. The optimization targets only the
// full-screen radiation pass, which is independent of particle simulation.
importGroup.QueueFindReplace(shaderDraw,
    "if (amount > 0 && !global.night_vision && !player_local_state_is(scr_player_state_start, scr_player_state_free_camera))",
    "if (amount > 0.08 && !global.night_vision && !player_local_state_is(scr_player_state_start, scr_player_state_free_camera))",
    true);

importGroup.Import();
ScriptMessage("Applied anomaly optimization: preserved particles, gated low-intensity radiation pass.");
