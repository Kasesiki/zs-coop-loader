using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string LogoStep = "gml_Object_obj_logo_screen_Step_0";
const string LogoDraw = "gml_Object_obj_logo_screen_Draw_64";
const string MainMenuStep = "gml_Object_obj_main_menu_Step_0";
const string MainMenuDraw = "gml_Object_obj_main_menu_Draw_64";
const string StaticPropsStep = "gml_Object_obj_vertex_props_Step_0";

UndertaleCode RequireCode(string name)
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
    {
        throw new Exception("Required scene code entry is missing: " + name);
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

CodeImportGroup importGroup = CreateImportGroup();
UndertaleCode logoStep = RequireCode(LogoStep);
UndertaleCode logoDraw = RequireCode(LogoDraw);
UndertaleCode mainMenuStep = RequireCode(MainMenuStep);
UndertaleCode mainMenuDraw = RequireCode(MainMenuDraw);
UndertaleCode staticPropsStep = RequireCode(StaticPropsStep);

// Avoid opening and decoding the boot video. The normal continue prompt remains.
importGroup.QueueFindReplace(logoStep,
    @"video = video_open(""ZS_boot.mp4"");
            var _video_duration = video_get_duration();
            alarm[0] = clamp(floor((_video_duration / 1000) * 60) - 60, 60, 370);
            video_enable_loop(false);",
    @"video = undefined;
            show_prompt = true;
            logo_fade_in = true;
            alarm[0] = 1;",
    true);

importGroup.QueueFindReplace(logoStep,
    "video_close();",
    @"if (video != undefined)
            {
                video_close();
            }",
    true);

importGroup.QueueFindReplace(logoDraw,
    @"var _video_state = video_draw();
if (_video_state[0] == 0 && surface_exists(_video_state[1]))
{
    draw_surface(_video_state[1], 0, 0);
}",
    @"if (video != undefined)
{
    var _video_state = video_draw();
    if (_video_state[0] == 0 && surface_exists(_video_state[1]))
    {
        draw_surface(_video_state[1], 0, 0);
    }
}",
    true);

// Input is processed before this call in the same event. Updating the menu tree
// every other frame preserves interaction while reducing idle UI work.
importGroup.QueueFindReplace(mainMenuStep,
    "__uiGlobal().__defaultOnion.Step();",
    @"if ((current_time div 16) mod 2 == 0)
{
    __uiGlobal().__defaultOnion.Step();
}",
    true);

string mainMenuDrawReplaceText = @"
display_set_gui_size(1920, 1080);
draw_clear(c_black);
__uiGlobal().__defaultOnion.Draw();
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_colour(c_lime);
draw_set_alpha(0.9);
draw_text(1900, 1065, ""Improvement"");
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
";

importGroup.QueueReplace(mainMenuDraw, mainMenuDrawReplaceText);

// Static props are already batched. Build the batch sooner after entering the hub.
importGroup.QueueFindReplace(staticPropsStep,
    "if (_wait < 8)",
    "if (_wait < 2)",
    true);

importGroup.Import();
ScriptMessage("Applied scene and startup optimization candidates.");
