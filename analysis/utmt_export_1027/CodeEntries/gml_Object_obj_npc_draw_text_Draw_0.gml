language_set_font(UnknownEnum.Value_0);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
if (counter < string_length(t))
{
    counter += text_speed;
}
if (counter >= (string_length(t) - 2) && counter < (string_length(t) - 1))
{
    alarm[0] = text_timer;
}
var sub_t = string_copy(t, 1, ceil(counter));
var c2 = 0;
var c1 = 16777215;
if (bark_alpha >= 1)
{
    scr_draw_text_outlined(x + global.language_font_offset.x, y + global.language_font_offset.y + draw_offset_y, sub_t, c1, c2, 1, 1);
}
else
{
    var _text_x = x + (global.language_font_offset.x * 2);
    var _text_y = y + (global.language_font_offset.y * 2) + draw_offset_y;
    for (var _outline_x = -1; _outline_x <= 1; _outline_x++)
    {
        for (var _outline_y = -1; _outline_y <= 1; _outline_y++)
        {
            if (_outline_x == 0 && _outline_y == 0)
            {
                continue;
            }
            draw_text_transformed_color(_text_x + _outline_x, _text_y + _outline_y, sub_t, 1, 1, 0, c2, c2, c2, c2, bark_alpha * 0.5);
        }
    }
    draw_text_transformed_color(_text_x, _text_y, sub_t, 1, 1, 0, c1, c1, c1, c1, bark_alpha);
}

enum UnknownEnum
{
    Value_0
}
