function get_train_skin_type()
{
    db_open("general");
    var _skin_train = db_read("train_skin", "skin", "train_skin_default");
    db_close();
    if (!is_string(_skin_train) || !variable_struct_exists(global.train_skin_struct_data, _skin_train))
    {
        _skin_train = "train_skin_default";
    }
    return _skin_train;
}
