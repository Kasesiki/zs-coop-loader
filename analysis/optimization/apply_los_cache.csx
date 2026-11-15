using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string TargetName = "gml_GlobalScript_instance_line_of_sight";

UndertaleCode RequireCode(string name)
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
    {
        throw new Exception("Missing target code entry: " + name);
    }
    return code;
}

CodeImportGroup CreateImportGroup()
{
    return new CodeImportGroup(Data, null, Data.ToolInfo.DecompilerSettings)
    {
        MainThreadAction = MainThreadAction
    };
}

string replacement = @"
function instance_line_of_sight(arg0, arg1, arg2)
{
    if (!instance_exists(arg2))
    {
        return false;
    }

    static _last_room = -1;
    static _last_ox = 0;
    static _last_oy = 0;
    static _last_target = -4;
    static _last_tx = 0;
    static _last_ty = 0;
    static _last_frame = -1000000;
    static _last_result = false;

    var _frame = current_time div 16;
    if (_last_room == room && _last_target == arg2 && _last_ox == arg0 && _last_oy == arg1 && _last_tx == arg2.x && _last_ty == arg2.y && (_frame - _last_frame) <= 2)
    {
        return _last_result;
    }

    _last_room = room;
    _last_ox = arg0;
    _last_oy = arg1;
    _last_target = arg2;
    _last_tx = arg2.x;
    _last_ty = arg2.y;
    _last_frame = _frame;
    _last_result = !collision_line(arg0, arg1, arg2.x, arg2.y, obj_solid, true, true);
    return _last_result;
}
";

CodeImportGroup importGroup = CreateImportGroup();
importGroup.QueueReplace(RequireCode(TargetName), replacement);
importGroup.Import();
ScriptMessage("Replaced " + TargetName + " with the experimental two-frame cache.");
