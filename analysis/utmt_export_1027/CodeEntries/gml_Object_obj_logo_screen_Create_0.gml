trace("ZERO Sievert   ", concat(1, ".", 4, ".", 13), " (QA=", "true", ")   ", date_datetime_string(46335.378367028956));
trace("Init: Starting!");
trace("Init: gpu_pref_query() = ", gpu_pref_query());
if (1 && gpu_pref_boot())
{
    trace("Init: relaunching on the dedicated GPU...");
    game_end();
    exit;
}
platform_init();
global.platform_room_live = true;
__platform_ensure_pump();
phase = 0;
phase_delay = 0;
video = undefined;
show_prompt = false;
prompt_alpha = 0;
prompt_seen = false;
fade_out = false;
logo_fade_in = false;
logo_fade_in_dec = 0;
final_phase = 16;
loading_works = true;
draw_loading_work_tips = false;
global.coming_from_main_menu = true;
if (!variable_global_exists("last_run_succeeded"))
{
    global.last_run_succeeded = false;
}
bar_width = 600;
bar_height = 60;
bar_x = (display_get_gui_width() / 2) - (bar_width / 2);
bar_y = display_get_gui_height() - 180;
bar_colour_bg = 16777215;
bar_colour_text = 0;
