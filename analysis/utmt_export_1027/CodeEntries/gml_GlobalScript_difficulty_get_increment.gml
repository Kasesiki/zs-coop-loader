function difficulty_get_increment(arg0)
{
    var _difficulty_def = variable_struct_get(global.__difficulty_data, arg0);
    if (!is_struct(_difficulty_def))
    {
        trace_error("Difficulty \"", arg0, "\" not recognised");
    }
    return struct_get_from_hash(_difficulty_def, variable_get_hash("__increment")) ?? 0.00001;
}
