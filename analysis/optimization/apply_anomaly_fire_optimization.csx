using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string FireStep = "gml_Object_obj_anomaly_fire_Step_0";
UndertaleCode fireStep = Data.Code.ByName(FireStep);
if (fireStep is null)
    throw new Exception("Required fire anomaly code entry is missing: " + FireStep);

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

// Do not exit Step: off-screen NPC damage, audio and particles must still run.
// Bounding boxes conservatively prefilter the unchanged exact player test.
importGroup.QueueFindReplace(fireStep,
    "if (place_meeting(x, y, other.id))",
    "if (bbox_right >= other.bbox_left && bbox_left <= other.bbox_right && bbox_bottom >= other.bbox_top && bbox_top <= other.bbox_bottom && place_meeting(x, y, other.id))",
    true);
// Reuse the NPC collision result instead of repeating the query on every hit.
importGroup.QueueFindReplace(fireStep,
    "if (place_meeting(x, y, obj_npc_parent))",
    "var _fire_npc = instance_place(x, y, obj_npc_parent);\nif (_fire_npc != noone)",
    true);
importGroup.QueueFindReplace(fireStep,
    "var quale_id = instance_place(x, y, obj_npc_parent);",
    "var quale_id = _fire_npc;",
    true);

importGroup.Import();
ScriptMessage("Applied fire collision optimization: player bounds and one NPC query; all particle calls preserved.");
