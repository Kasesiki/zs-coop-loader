using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string CursorStep = "gml_Object_obj_cursor_Step_1";

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

// Drop the game to 10 FPS while the window does not have focus. The screen is
// not visible then, so fewer steps and presents only cost time, not quality.
// obj_cursor is persistent, is created at the logo screen and stays active in
// every room (including the pause menu), which makes it the cheapest per-frame
// hook available: one focus check on top of the check its own Step already does.
importGroup.QueuePrepend(CursorStep, @"
if (!instance_exists(obj_logo_screen))
{
    var _coop_target_fps = 5;
    if (!window_has_focus())
    {
        var _coop_fps = game_get_speed(gamespeed_fps);
        if (_coop_fps > _coop_target_fps)
        {
            // Remember the speed the player had chosen (for example the debug
            // menu's unlocked frame rate). Do not overwrite it if a room change
            // resets the speed while still unfocused.
            if (!variable_global_exists(""coop_bg_saved_fps"") || global.coop_bg_saved_fps <= 0)
            {
                global.coop_bg_saved_fps = _coop_fps;
            }
            game_set_speed(_coop_target_fps, gamespeed_fps);
        }
    }
    else if (variable_global_exists(""coop_bg_saved_fps"") && global.coop_bg_saved_fps > 0)
    {
        game_set_speed(global.coop_bg_saved_fps, gamespeed_fps);
        global.coop_bg_saved_fps = 0;
    }
}
");

importGroup.Import();
ScriptMessage("Applied background frame-rate throttle.");
