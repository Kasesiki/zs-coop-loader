function scr_gamepad_get_glyph_index()
{
    var _t = platform_input_controller_type();
    obj_gamepad.steam_gamepad_ids = _t.handles;
    global.is_steamdeck = _t.is_steam_deck;
    return _t.family;
}

function gamepad_log_and_map_devices(arg0)
{
    for (var _slot = 0; _slot <= 11; _slot++)
    {
        if (!gamepad_is_connected(_slot))
        {
            continue;
        }
        var _desc = string(gamepad_get_description(_slot));
        var _map = gamepad_get_mapping(_slot);
        var _has_map = !(is_undefined(_map) || string(_map) == "" || string_pos("no mapping", string_lower(string(_map))) > 0);
        __platform_log("gamepad slot=" + string(_slot) + " desc=" + _desc + " mapping=" + (_has_map ? string(string_length(string(_map))) : "none") + " (" + arg0 + ")");
        if (!_has_map && platform_target() != UnknownEnum.Value_1)
        {
            var _guid = string_lower(string(gamepad_get_guid(_slot)));
            var _is_dualsense = (string_pos("4c05", _guid) > 0 && string_pos("e60c", _guid) > 0) || string_pos("dualsense", string_lower(_desc)) > 0;
            if (_is_dualsense)
            {
                var _bindings = "a:b1,b:b2,x:b0,y:b3,back:b8,guide:b12,start:b9,leftstick:b10,rightstick:b11,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a5,lefttrigger:a3,righttrigger:a4";
                var _line = gamepad_get_guid(_slot) + ",DualSense," + _bindings + ",platform:Windows,";
                gamepad_set_mapping(_slot, _line);
                __platform_log("gamepad slot=" + string(_slot) + " applied SDL DualSense mapping (was 'none')");
            }
        }
    }
}

enum UnknownEnum
{
    Value_1 = 1
}
