var _orbit_amount = 8;
var _orbit_radius_x = 28;
var _orbit_radius_y = 7;
var _orbit_center_y = y + 20;
var _orbit_speed = 12;
var _orbit_angle = current_time / _orbit_speed;
var _orbit_scale_back = 0.95;
var _orbit_scale_front = 1.08;
var _orbit_alpha_back = 0.85;
var _orbit_alpha_front = 1;
var _draw_front = false;
for (var _draw_pass = 0; _draw_pass < 2; _draw_pass++)
{
    if (_draw_pass == 1)
    {
        event_inherited();
        _draw_front = true;
    }
    for (var i = 0; i < _orbit_amount; i++)
    {
        var _phase = _orbit_angle + ((360 / _orbit_amount) * i);
        var _orbit_y = dsin(_phase) * _orbit_radius_y;
        var _is_front = _orbit_y >= 0;
        if (_is_front == _draw_front)
        {
            var _orbit_x = dcos(_phase) * _orbit_radius_x;
            var _depth_amount = (_orbit_y + _orbit_radius_y) / (_orbit_radius_y * 2);
            var _scale = _orbit_scale_back + (_depth_amount * (_orbit_scale_front - _orbit_scale_back));
            var _alpha = image_alpha * (_orbit_alpha_back + (_depth_amount * (_orbit_alpha_front - _orbit_alpha_back)));
            var _bob = dsin((_phase * 2) + _orbit_angle) * 0.75;
            draw_sprite_ext(s_cristallo_viola_small_npp, 0, x + _orbit_x, _orbit_center_y + _orbit_y + _bob, _scale, _scale, 0, c_white, _alpha);
        }
    }
}
