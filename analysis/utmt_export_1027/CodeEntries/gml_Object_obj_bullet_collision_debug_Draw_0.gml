language_set_font(UnknownEnum.Value_0);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
var _text = language_get_string("ui.shootingrange.hit_upper");
if (glance)
{
    _text = language_get_string("ui.shootingrange.glance");
}
draw_text(x + global.language_font_offset.x, (y + global.language_font_offset.y) - 16, _text);

enum UnknownEnum
{
    Value_0
}
