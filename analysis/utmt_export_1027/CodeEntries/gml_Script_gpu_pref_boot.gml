var _i = 0;
repeat (parameter_count())
{
    if (parameter_string(_i) == "-no_gpu_pref")
    {
        return false;
    }
    _i += 1;
}
return gpu_pref_apply() == 1;
