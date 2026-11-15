function scr_gamepad_rumble_stepEvent()
{
    if (last_gamepad_pressed != -4 && !!obj_gamepad.last_input_keyboard)
    {
        if (platform_target() == UnknownEnum.Value_1 || !__rumble_zeroed)
        {
            var _count_connected = array_length(connected_devices);
            for (var i = 0; i < _count_connected; i++)
            {
                var _gamepad_id = connected_devices[i];
                gamepad_set_vibration(_gamepad_id, 0, 0);
            }
            __rumble_zeroed = true;
            __rumble_zero_sends += _count_connected;
        }
    }
    else
    {
        __rumble_zeroed = false;
    }
    if ((current_time - __rumble_zero_log_last_ms) >= 1000)
    {
        if (__rumble_zero_sends > 0)
        {
            __platform_log("rumble zero-sends/s=" + string(__rumble_zero_sends) + " (off-gamepad path)");
        }
        __rumble_zero_sends = 0;
        __rumble_zero_log_last_ms = current_time;
    }
    if (last_gamepad_pressed != previous_gamepad_pressed)
    {
        gamepad_set_vibration(previous_gamepad_pressed, 0, 0);
        if (__rumble_feeding)
        {
            __rumble_feeding = false;
            __platform_log("rumble stop (pad-switch " + string(previous_gamepad_pressed) + "->" + string(last_gamepad_pressed) + ")");
        }
    }
    previous_gamepad_pressed = last_gamepad_pressed;
    if (current_curve != -4)
    {
        var _this_rumble = rumble_styles[current_curve];
        var _curve = animcurve_get_channel(curve_rumble, _this_rumble.curve);
        var _value = animcurve_channel_evaluate(_curve, current_frame / total_frames);
        if (platform_target() != UnknownEnum.Value_1 && _value < 0.05)
        {
            _value = 0;
        }
        gamepad_set_vibration(last_gamepad_pressed, _value, _value);
        if (_value > 0)
        {
            __rumble_feeding = true;
            if ((current_time - __rumble_log_last_ms) >= 1000)
            {
                __rumble_log_last_ms = current_time;
                __platform_log("rumble send value=" + string(_value) + " curve=" + _this_rumble.curve + " pad=" + string(last_gamepad_pressed));
            }
        }
        current_frame--;
        if (current_frame < 0)
        {
            current_curve = -4;
            current_frame = 0;
            total_frames = 0;
            gamepad_set_vibration(last_gamepad_pressed, 0, 0);
            if (__rumble_feeding)
            {
                __rumble_feeding = false;
                __platform_log("rumble stop (curve-end) curve=" + _this_rumble.curve);
            }
        }
    }
}

enum UnknownEnum
{
    Value_1 = 1
}
