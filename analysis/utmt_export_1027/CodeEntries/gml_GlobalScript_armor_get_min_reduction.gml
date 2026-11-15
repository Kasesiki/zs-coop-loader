function armor_get_min_reduction(arg0, arg1)
{
    var _reduction_at_full_condition = max(0, 0.05 * (arg0 - 1));
    var _condition_factor = clamp(arg1 / 50, 0, 1);
    return _reduction_at_full_condition * _condition_factor;
}
