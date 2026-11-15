function difficulty_get_value_string(arg0)
{
    var _value = difficulty_get(arg0);
    if (difficulty_get_increment(arg0) >= 1)
    {
        return string(round(_value));
    }
    return string_format(_value, 1, 2);
}
