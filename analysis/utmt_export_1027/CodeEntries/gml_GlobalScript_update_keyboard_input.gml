function update_keyboard_input()
{
    var _i = 0;
    var _steam_overlay = platform_overlay_active();
    repeat (array_length(global.kb_id))
    {
        var _constant = global.kb_now[_i];
        if (_steam_overlay)
        {
            global.kb_hold[_i] = false;
            global.kb_pressed[_i] = false;
            keyboard_clear(_constant);
        }
        else
        {
            global.kb_hold[_i] = keyboard_check(_constant) || mouse_check_button(_constant) || obj_gamepad.action[_i].value;
            global.kb_pressed[_i] = keyboard_check_pressed(_constant) || mouse_check_button_pressed(_constant) || obj_gamepad.action[_i].pressed;
        }
        _i++;
    }
}
