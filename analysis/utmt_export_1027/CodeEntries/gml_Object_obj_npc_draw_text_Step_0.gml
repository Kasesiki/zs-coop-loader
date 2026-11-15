if (instance_exists(id_npc) && bark_heard_through_walls)
{
    var _speaker_in_view = true;
    if (instance_exists(player_get_local()))
    {
        _speaker_in_view = !collision_line(id_npc.x, id_npc.y, obj_player.x, obj_player.y, obj_solid, false, false);
    }
    if (_speaker_in_view)
    {
        x = id_npc.x;
        y = id_npc.y;
        visible = true;
        bark_alpha = 1;
    }
    else
    {
        visible = point_distance(x, y, obj_player.x, obj_player.y) <= bark_hearing_radius_px;
        bark_alpha = bark_unseen_alpha;
    }
}
else if (instance_exists(id_npc))
{
    x = id_npc.x;
    y = id_npc.y;
    if (global.t_npc_needs_sight[text_id])
    {
        if (instance_exists(player_get_local()))
        {
            if (!collision_line(x, y, obj_player.x, obj_player.y, obj_solid, false, false))
            {
                visible = true;
            }
            else
            {
                visible = false;
            }
        }
    }
}
else
{
    instance_destroy();
}
if (bark_kind != "")
{
    bark_age_steps += 1;
    if (bark_age_steps > ((string_length(t) / text_speed) + text_timer + 10))
    {
        instance_destroy();
    }
}
