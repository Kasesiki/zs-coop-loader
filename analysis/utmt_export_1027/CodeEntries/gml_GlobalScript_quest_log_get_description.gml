function quest_log_get_description(arg0)
{
    var _quest_data = __quest_log_get_quest_data(arg0);
    if (_quest_data == undefined)
    {
        return "???";
    }
    if (_quest_data.daily)
    {
        return language_get_string_multiline(_quest_data.text);
    }
    return language_get_string(_quest_data.text);
}
