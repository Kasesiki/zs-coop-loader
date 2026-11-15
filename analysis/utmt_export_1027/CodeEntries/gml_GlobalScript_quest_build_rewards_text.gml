function quest_build_rewards_text(arg0, arg1)
{
    var _quest_name = npc_dialogue_get_quest_id(arg0, arg1);
    var _text = language_get_string("quest.reward.exp") + ": " + string(variable_struct_get(global.quest_database, _quest_name).experience);
    _text = _text + " / " + language_get_string("quest.reward.rep") + ": " + string(variable_struct_get(global.quest_database, _quest_name).reputation) + " / ";
    _text = _text + language_get_string("quest.reward.reward") + ": " + string(variable_struct_get(global.quest_database, _quest_name).money) + " " + language_get_string("trade.barter.roubles");
    return _text;
}
