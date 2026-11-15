function get_train_skin_sprite(arg0)
{
    if (!is_string(arg0) || !variable_struct_exists(global.train_skin_struct_data, arg0))
    {
        arg0 = "train_skin_default";
    }
    var _sprite = variable_struct_get(global.train_skin_struct_data, arg0).sprite;
    return _sprite;
}
