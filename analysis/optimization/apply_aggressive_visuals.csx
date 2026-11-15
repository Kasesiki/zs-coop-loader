using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string BulletDraw = "gml_Object_obj_bullet_regular_Draw_0";

UndertaleCode RequireCode(string name)
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
    {
        throw new Exception("Required visual code entry is missing: " + name);
    }
    return code;
}

CodeImportGroup CreateImportGroup()
{
    return new CodeImportGroup(Data, null, Data.ToolInfo.DecompilerSettings)
    {
        AutoCreateAssets = true,
        MainThreadAction = MainThreadAction
    };
}

UndertaleCode bulletDraw = RequireCode(BulletDraw);
CodeImportGroup importGroup = CreateImportGroup();

// Preserve all particle systems. Bullet simulation still runs; only the
// off-screen ordinary bullet draw is skipped.
importGroup.QueueReplace(bulletDraw, @"
if (!sphere_is_visible(x, y, 0, 8))
{
    exit;
}
event_inherited();
draw_sprite_ext(sprite_index, 0, x, y, timer, 1, direction, draw_colour, 1);
");

importGroup.Import();
ScriptMessage("Applied visual optimization: preserved particles, culled off-screen bullet draw.");
