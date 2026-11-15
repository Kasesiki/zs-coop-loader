if (quest_is_complete("revelations"))
{
    scr_draw_npc_text(id, UnknownEnum.Value_236);
}
else
{
    scr_draw_npc_text(id, UnknownEnum.Value_251);
}

enum UnknownEnum
{
    Value_236 = 236,
    Value_251 = 251
}
