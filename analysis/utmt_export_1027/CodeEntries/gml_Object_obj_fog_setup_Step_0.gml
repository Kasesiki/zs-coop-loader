player_follow_local();
global.fow_early_reveal = difficulty_get("early_enemy_reveal");
global.fow_out_of_sight_steps = difficulty_get("enemy_out_of_sight_visibility") * 60;
global.fow_player_move_x = x - player_last_x;
global.fow_player_move_y = y - player_last_y;
player_last_x = x;
player_last_y = y;
if (player_exists_local())
{
    if (settings_get("FOG FOW"))
    {
        if (skill_hunter_obtained("doeeyed"))
        {
            global.angle_fow = 90 + struct_get_from_hash(struct_get_from_hash(global.skills_hunter_data, variable_get_hash("doeeyed")), variable_get_hash("view_fov_bonus"));
        }
        var _dir = point_direction(x, y, obj_cursor.aa_x, obj_cursor.aa_y) + 360;
        var _off = 650;
        var _angle_diff = global.angle_fow / 2;
        global.fow_direction = _dir;
        global.field_of_view_x1 = x + lengthdir_x(_off, _dir + _angle_diff);
        global.field_of_view_y1 = y + lengthdir_y(_off, _dir + _angle_diff);
        global.field_of_view_x2 = x + lengthdir_x(_off, _dir - _angle_diff);
        global.field_of_view_y2 = y + lengthdir_y(_off, _dir - _angle_diff);
    }
}
depth = 75;
