var _old_alpha = draw_get_alpha();
var _old_color = draw_get_color();
var _cx = room_width / 2;
var _cy = room_height / 2;
draw_set_color(c_white);
for (var xx = 0; xx <= room_width; xx += marker_step)
{
    draw_set_alpha(((xx % marker_major) == 0) ? 0.3 : 0.1);
    draw_line(xx, 0, xx, room_height);
}
for (var yy = 0; yy <= room_height; yy += marker_step)
{
    draw_set_alpha(((yy % marker_major) == 0) ? 0.3 : 0.1);
    draw_line(0, yy, room_width, yy);
}
draw_set_color(c_yellow);
for (var i = 1; i <= ring_count; i++)
{
    var _r = i * ring_step;
    draw_set_alpha(0.25);
    draw_circle(_cx, _cy, _r, true);
    draw_set_alpha(0.8);
    draw_text(_cx + _r + 4, _cy + 4, string(_r));
}
draw_set_alpha(_old_alpha);
draw_set_color(_old_color);
