function npc_dialogue_get_quest_description(arg0, arg1)
{
    var _id = npc_dialogue_get_quest_id(arg0, arg1);
    if (_id == undefined)
    {
        return "???";
    }
    var _quest_data = variable_struct_get(global.quest_database, _id);
    if (_quest_data.daily)
    {
        return language_get_string_multiline(_quest_data.text);
    }
    return language_get_string(_quest_data.text);
}
