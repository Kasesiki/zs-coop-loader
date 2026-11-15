player_follow_local();
alpha += (alpha_amount * alpha_factor);
alpha = clamp(alpha, 0, 1);
if (alpha >= 0.7 && alpha <= 0.99)
{
    alarm[0] = 120;
}
if (alpha_factor == -1 && alpha <= 0.01)
{
    complete_quest("the_crystal");
    scr_draw_npc_text(player_get_local(), UnknownEnum.Value_113);
    instance_destroy();
}

enum UnknownEnum
{
    Value_113 = 113
}
