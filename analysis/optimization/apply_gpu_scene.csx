using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string GrassDraw = "gml_Object_obj_vertex_grass_Draw_0";

UndertaleCode RequireCode(string name)
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
    {
        throw new Exception("Required GPU scene code entry is missing: " + name);
    }
    return code;
}

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

// Keep the batched grass geometry and textures, but remove per-vertex wind
// deformation and its time-dependent shader work. The grass remains visible.
importGroup.QueueFindReplace(RequireCode(GrassDraw),
    "if (settings_get(\"dynamic grass\"))",
    "if (false)",
    true);

importGroup.Import();
ScriptMessage("Applied GPU scene optimization: static grass shading.");
