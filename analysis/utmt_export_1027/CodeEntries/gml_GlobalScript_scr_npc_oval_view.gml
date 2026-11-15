function scr_npc_oval_view(arg0, arg1)
{
    var _min = npc_get_alert_visual_distance_h();
    var _distance_max = arg0;
    if (arg1 >= 0 && arg1 < 90)
    {
        arg0 = lerp(_min, _distance_max, 1 - (arg1 / 90));
    }
    if (arg1 >= 90 && arg1 < 180)
    {
        arg0 = lerp(_min, _distance_max, (arg1 - 90) / 90);
    }
    if (arg1 >= 180 && arg1 < 270)
    {
        arg0 = lerp(_min, _distance_max, 1 - ((arg1 - 180) / 90));
    }
    if (arg1 >= 270 && arg1 < 360)
    {
        arg0 = lerp(_min, _distance_max, (arg1 - 270) / 90);
    }
    return arg0;
}
