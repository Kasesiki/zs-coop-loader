function train_skin_apply(arg0)
{
    if (!is_string(arg0) || !variable_struct_exists(global.train_skin_struct_data, arg0))
    {
        arg0 = "train_skin_default";
    }
    db_open("general");
    db_write("train_skin", "skin", arg0);
    db_close();
    with (obj_train_hub)
    {
        var _skin_sprite = get_train_skin_sprite(arg0);
        sprite_index = _skin_sprite;
    }
}
