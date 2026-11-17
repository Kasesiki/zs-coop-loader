using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

UndertaleCode runtime = Data.Code.ByName("gml_GlobalScript_ai_human_runtime");
if (runtime is null)
{
    throw new Exception("Required AI runtime code entry is missing: gml_GlobalScript_ai_human_runtime");
}

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

// ai_team_step is a per-NPC O(N) contact/reload/nearby scan. With many NPCs in
// view it becomes O(N^2) single-threaded VM work. Spread each NPC's team scan
// over 2 frames (or 3 when the crowd is large), phased by instance id.
// Movement and combat code are untouched; only the team coordination pass is
// time-sliced. The gate sits at the call site because the ai_team script uses a
// field name that UTMT's C# recompiler cannot round-trip on its own.
importGroup.QueueFindReplace(runtime,
    "        ai_team_step(_execution);",
    @"        var _coop_ai_count = instance_number(obj_npc_parent);
        var _coop_ai_stride = (_coop_ai_count >= 30) ? 3 : 2;
        if (_coop_ai_count < 4 || ((ai_world_get().frame + arg0.id) % _coop_ai_stride) == 0)
        {
            ai_team_step(_execution);
        }",
    true);

importGroup.Import();
ScriptMessage("Applied AI team-scan time slicing.");
