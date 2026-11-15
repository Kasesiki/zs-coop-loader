function loot_in_quick_slot_slot(arg0)
{
    var _struct = 
    {
        free: false,
        quick_slot_number: 0
    };
    if (!is_struct(arg0))
    {
        return _struct;
    }
    if (is_undefined(struct_get_from_hash(arg0, variable_get_hash("placement"))))
    {
        return false;
    }
    else
    {
        return arg0.placement == "weapon slot 2";
    }
}
