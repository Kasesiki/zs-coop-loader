using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string VideoClass = "gml_GlobalScript_uiClassVideo";

UndertaleCode videoClass = Data.Code.ByName(VideoClass);
if (videoClass is null)
{
    throw new Exception("Required menu background code entry is missing: " + VideoClass);
}

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

// Remember whether the video was already closed by the static path, so the
// fallback does not call video_close() every frame.
importGroup.QueueFindReplace(videoClass,
    @"    backup_image = spr_videoreplacement_mainmenu;
    CallbackSetOnClose(function()",
    @"    backup_image = spr_videoreplacement_mainmenu;
    coop_static_background_active = false;
    CallbackSetOnClose(function()",
    true);

// The game already ships a full-size static key art (spr_videoreplacement_mainmenu)
// and uses it on Steam Deck. Draw that instead of decoding the menu video when the
// user asked for a static background. The condition is filled in by the Rust
// loader from its configuration, so the same csx serves every mode.
importGroup.QueueFindReplace(videoClass,
    @"    CallbackSetDraw(function()
    {
        queue_buffer_timer = max(queue_buffer_timer - 1, 0);",
    @"    CallbackSetDraw(function()
    {
        if ((@@COOP_STATIC_PAUSE@@ && room != r_menu) || (@@COOP_STATIC_MENU@@ && room == r_menu))
        {
            if (!coop_static_background_active)
            {
                queue_video = false;
                video_close();
                coop_static_background_active = true;
            }
            var _coop_bg_color = merge_color(color, animBlend, animBlendAmount);
            var _coop_bg_alpha = alpha * animAlpha;
            draw_sprite_stretched_ext(backup_image, 0, __drawLeft, __drawTop, __localRight - __localLeft, __localBottom - __localTop, _coop_bg_color, _coop_bg_alpha);
            return;
        }
        coop_static_background_active = false;
        queue_buffer_timer = max(queue_buffer_timer - 1, 0);",
    true);

importGroup.Import();
ScriptMessage("Applied static menu background.");
