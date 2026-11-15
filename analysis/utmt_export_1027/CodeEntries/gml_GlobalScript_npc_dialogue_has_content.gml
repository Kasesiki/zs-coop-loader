function npc_dialogue_has_content(arg0)
{
    if (arg0 == undefined || !instance_exists(arg0))
    {
        return false;
    }
    if (npc_dialogue_get_question_count(arg0) > 0)
    {
        return true;
    }
    if (arg0.is_a_quest_giver[speaker_get_index(arg0.npc_speaker_id)])
    {
        return true;
    }
    var _count = npc_dialogue_get_prompt_count(arg0);
    for (var _i = 0; _i < _count; _i++)
    {
        var _type = npc_dialogue_get_prompt_type(arg0, _i);
        if (_type != "back" && _type != "question" && _type != "task")
        {
            return true;
        }
    }
    return false;
}
