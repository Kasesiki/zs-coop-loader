using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();
CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

// Preserve the previous chemical/electric patch. Fire uses its own script.
foreach (string name in new[] {
    "gml_Object_obj_anomaly_electric_Step_0",
    "gml_Object_obj_anomaly_gas_Step_0"
})
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
        throw new Exception("Required anomaly code is missing: " + name);
    importGroup.QueueFindReplace(code,
        "if (place_meeting(x, y, other.id))",
        "if (point_distance(x, y, other.x, other.y) <= 64 && place_meeting(x, y, other.id))",
        true);
}
importGroup.Import();
ScriptMessage("Preserved chemical/electric player collision prefilter.");
