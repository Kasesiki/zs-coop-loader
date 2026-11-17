// using System;
// using UndertaleModLib.Compiler;

// EnsureDataLoaded();

// UndertaleCode runtime = Data.Code.ByName("gml_GlobalScript_ai_human_runtime");
// if (runtime is null)
// {
//     throw new Exception("Required AI runtime code entry is missing: gml_GlobalScript_ai_human_runtime");
// }

// CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
// {
//     MainThreadAction = MainThreadAction
// };

// // ai_team_step is a per-NPC O(N) contact/reload/nearby scan. With many NPCs it
// // becomes O(N^2) single-threaded VM work. Spread each NPC's team scan over two
// // frames (or three when the crowd is large), phased by instance id.
// //
// // The gate sits at the call site because the ai_team script uses a field name
// // that UTMT's C# recompiler cannot round-trip on its own. Movement, perception,
// // combat and the behaviour tree are untouched; only the team coordination pass
// // is time-sliced. The NPC count is cached per simulation frame so the gate adds
// // one instance_number call per frame instead of one per NPC. `arg0` is already
// // the instance id; `arg0.id` compiles to a member access on a number and fails
// // at runtime with "DoAdd: Malformed variable".
// importGroup.QueueFindReplace(runtime,
//     "        ai_team_step(_execution);",
//     @"        var _coop_world = ai_world_get();
//         if (!variable_global_exists(""coop_ai_count_frame"") || global.coop_ai_count_frame != _coop_world.frame || global.coop_ai_count_room != room)
//         {
//             global.coop_ai_count = instance_number(obj_npc_parent);
//             global.coop_ai_count_frame = _coop_world.frame;
//             global.coop_ai_count_room = room;
//         }
//         var _coop_ai_stride = (global.coop_ai_count >= 30) ? 3 : 2;
//         if (global.coop_ai_count < 4 || ((_coop_world.frame + arg0) % _coop_ai_stride) == 0)
//         {
//             ai_team_step(_execution);
//         }",
//     true);

// importGroup.Import();
// ScriptMessage("Applied AI team-scan time slicing (2/3-frame stride, active from 4 NPCs).");
