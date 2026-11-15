global.__settings_data = {};
global.__settings_write_to_disk = true;
global.cursor_needs_resync = false;
__settings_define_range("master volume", "local settings", "settings", 1, 0, 1, function(arg0)
{
    audio_master_gain(arg0);
});
__settings_define_range("radiation volume", "local settings", "settings", 0.8, 0, 1, function(arg0)
{
    audio_group_set_gain(Radiation, arg0, 1);
});
__settings_define_range("heart volume", "local settings", "settings", 0.6, 0, 1, function(arg0)
{
    audio_group_set_gain(audiogroup_heart, arg0, 1);
});
__settings_define_range("main volume", "local settings", "settings", 0.7, 0, 1, function(arg0)
{
    audio_group_set_gain(audiogroup_main_menu, arg0, 1);
});
__settings_define_range("ui rad button volume", "local settings", "settings", 0.6, 0, 1, function(arg0)
{
    audio_group_set_gain(audiogroup_ui_rad_button, arg0, 1);
});
__settings_define_range("ui PDA open sound", "local settings", "settings", 0.6, 0, 1, function(arg0)
{
    audio_group_set_gain(audiogroup_pda_open, arg0, 1);
});
__settings_define_range("ui PDA sound", "local settings", "settings", 0.6, 0, 1, function(arg0)
{
    audio_group_set_gain(audiogroup_pda, arg0, 1);
});
__settings_define_range("grenade ear effect", "local settings", "settings", 0.8, 0, 1, function(arg0)
{
    audio_group_set_gain(audiogroup_grenade_ear_effect, arg0, 1);
});
__settings_define_toggle("npc_alert_bark", "shared settings", "settings", true);
__settings_define_range("resolution scaling", "local settings", "settings", 1, 0.1, 1);
__settings_define_range("amount grass", "local settings", "settings", 0.6, 0, 1);
__settings_define_toggle("dynamic grass", "local settings", "settings", true);
__settings_define_toggle("fog rain", "local settings", "settings", true);
__settings_define_toggle("low spec", "local settings", "settings", false);
__settings_define_toggle("fullscreen", "local settings", "settings", true, function(arg0)
{
    if (arg0)
    {
        window_enable_borderless_fullscreen(settings_get("borderless"));
    }
    else
    {
        window_enable_borderless_fullscreen(false);
    }
    window_set_fullscreen(arg0);
    global.cursor_needs_resync = true;
});
__settings_define_toggle("borderless", "local settings", "settings", true, function(arg0)
{
    window_enable_borderless_fullscreen(arg0);
    if (settings_get("fullscreen"))
    {
        window_set_fullscreen(false);
        window_set_fullscreen(true);
    }
    global.cursor_needs_resync = true;
});
__settings_define_toggle("vsync", "local settings", "settings", false, function(arg0)
{
    display_reset(0, arg0);
});
__settings_define_toggle("fog of war", "shared settings", "settings", true);
__settings_define_range("fog of war alpha", "shared settings", "settings", 0.25, 0, 1);
__settings_define_toggle("FOG FOW", "shared settings", "settings", true);
__settings_define_toggle("black flashbang", "shared settings", "settings", false);
__settings_define_toggle("colour overlay", "shared settings", "settings", true);
__settings_define_toggle("enable_dinput_devices", "shared settings", "settings", false);
__settings_define_toggle("enable_gamepad_devices", "shared settings", "settings", true);
__settings_define_toggle("enable_gamepad_rumble", "shared settings", "settings", true);
__settings_define_range("gamepad_aim_assist", "shared settings", "settings", 3, 0, 6);
__settings_define_range("resolution", "local settings", "resolution", UnknownEnum.Value_1, UnknownEnum.Value_0, UnknownEnum.Value_3, function(arg0)
{
    switch (arg0)
    {
        case UnknownEnum.Value_0:
            window_set_size(1280, 720);
            break;
        case UnknownEnum.Value_1:
            window_set_size(1920, 1080);
            break;
        case UnknownEnum.Value_2:
            window_set_size(2560, 1440);
            break;
        case UnknownEnum.Value_3:
            window_set_size(3840, 2160);
            break;
        default:
            trace("Warning! Resolution \"", arg0, "\" not recognised");
            break;
    }
    global.cursor_needs_resync = true;
});
__settings_define_toggle("collect_data", "shared settings", "Game analytics", false);
__settings_define_toggle("toggle_sprint", "shared settings", "settings", false);
__settings_define_toggle("bunker_animation", "shared settings", "settings", true);
__settings_define_toggle("display_ftue", "shared settings", "settings", true);
__settings_define_toggle("display_npc_marker", "shared settings", "settings", true);
__settings_define_range("item_overlay", "shared settings", "settings", 0.5, 0, 1);
__settings_define_toggle("lost_focus_pause", "shared settings", "settings", true);
__settings_define_range("decrease_minimum_range", "shared settings", "settings", 0, 0, 60);
__settings_define_range("increase_maximum_range", "shared settings", "settings", 0, 0, 20);
__settings_define_toggle("show_quickbar", "shared settings", "settings", true);
__settings_define_toggle("heal_prompt", "shared settings", "settings", false);
__settings_define_toggle("close_inv", "shared settings", "settings", false);
__settings_define_toggle("close_pda", "shared settings", "settings", false);
__settings_define_toggle("show_ammo_icon", "shared settings", "show_ammo_icon", true);
__settings_define_toggle("show_durability", "shared settings", "settings", true);
__settings_define_toggle("harm_warnings", "shared settings", "settings", true);
__settings_define_toggle("auto_switch_ammo", "shared settings", "settings", true);
__settings_define_string("language", "shared settings", "settings", "english", "english", function()
{
});
__settings_define_toggle("community_event", "shared settings", "settings", true);
__settings_define_description("master volume", "");
__settings_define_description("radiation volume", "Use this setting to adjust the volume of the geiger counter");
__settings_define_description("heart volume", "Use this setting to adjust the volume of the heartbeat when health points are low");
__settings_define_description("main volume", "");
__settings_define_description("ui rad button volume", "Adjust the volume of the radiation buttons sound");
__settings_define_description("ui PDA open sound", "");
__settings_define_description("grenade ear effect", "Adjust the volume of the tinnitus ringing after explosions");
__settings_define_description("npc_alert_bark", "settings.sound.human_attack_voice_desc");
__settings_define_description("resolution scaling", "This setting affects the resolution scale of the game. This does not affect the user interface.");
__settings_define_description("amount grass", "This setting will take effect only from the next map generation.");
__settings_define_description("dynamic grass", "");
__settings_define_description("fog rain", "");
__settings_define_description("low spec", "Low Spec Mode reduces the number of visual effects and particle effects");
__settings_define_description("fullscreen", "");
__settings_define_description("borderless", "");
__settings_define_description("vsync", "Toggle vertical synchronization");
__settings_define_description("fog of war", "");
__settings_define_description("fog of war alpha", "");
__settings_define_description("FOG FOW", "");
__settings_define_description("black flashbang", "Flashbangs HUD effect is black instead of white");
__settings_define_description("colour overlay", "Toggle full screen overlay effects. (used for weather)");
__settings_define_description("resolution", "");
__settings_define_description("collect_data", "The data collected is used to help the developer balance the game based on community statistics");
__settings_define_description("community_event", "Take part in community events!");
__settings_define_description("toggle_sprint", "When ON, tap to toggle sprinting on and off; when OFF, hold the key to sprint.");
__settings_define_description("bunker_animation", "Immediate use of food and drink in the bunker without the animation");
__settings_define_description("display_ftue", "Display helper dialogue prompts to help new players");
__settings_define_description("display_npc_marker", "Display markers to help locating NPC in the bunker");
__settings_define_description("item_overlay", "Time required for the overlay showing the statistics of an object to appear");
__settings_define_description("lost_focus_pause", "");
__settings_define_description("decrease_minimum_range", "Decrease the minimum range for all weapon by this percentage");
__settings_define_description("increase_maximum_range", "Increase the maximum range for all weapon by this percentage");
__settings_define_description("show_quickbar", "Always show the quickbar");
__settings_define_description("show_durability", "settings.show_durability_warnings_desc");
__settings_define_description("harm_warnings", "Play a sound and on-screen warning when you are bleeding, hungry, thirsty, exhausted, irradiated or critically hurt.");
__settings_define_description("heal_prompt", "Prompt yes/no before healing");
__settings_define_description("close_inv", "Automatically close the inventory when hit");
__settings_define_description("close_pda", "Automatically close the PDA when hit");
__settings_define_description("auto_switch_ammo", "When the current ammo is unavailable, reload with the most plentiful compatible ammo if its inventory amount is greater than the current ammo in the weapon and inventory.");
__settings_define_description("enable_dinput_devices", "Enable Direct Input devices");
__settings_define_description("enable_gamepad_devices", "Enable gamepad devices");
__settings_define_description("enable_gamepad_rumble", "Enable the haptic vibrations when using gamepads");
__settings_define_description("language", "language");

function __settings_define_range(arg0, arg1, arg2, arg3, arg4, arg5, arg6 = undefined)
{
    variable_struct_set(global.__settings_data, arg0, 
    {
        __type: "range",
        __name: arg0,
        __db_alias: arg1,
        __db_section: arg2,
        __default: arg3,
        __min: arg4,
        __max: arg5,
        __callback: arg6,
        __description: ""
    });
}

function __settings_define_string(arg0, arg1, arg2, arg3, arg4 = "English", arg5 = undefined)
{
    variable_struct_set(global.__settings_data, arg0, 
    {
        __type: "string",
        __name: arg0,
        __db_alias: arg1,
        __db_section: arg2,
        __default: arg3,
        __str: arg4,
        __callback: arg5,
        __description: ""
    });
}

function __settings_define_toggle(arg0, arg1, arg2, arg3, arg4 = undefined)
{
    variable_struct_set(global.__settings_data, arg0, 
    {
        __type: "toggle",
        __name: arg0,
        __db_alias: arg1,
        __db_section: arg2,
        __default: arg3,
        __min: false,
        __max: true,
        __callback: arg4,
        __description: ""
    });
}

function __settings_define_description(arg0, arg1)
{
    variable_struct_get(global.__settings_data, arg0).__description = arg1;
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3
}
