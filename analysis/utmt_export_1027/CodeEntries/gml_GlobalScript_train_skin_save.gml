function train_skin_save()
{
    var _train_skin_struct_to_save = variable_clone(global.train_skin_struct);
    db_open("shared settings");
    db_write("Train skin", "skin", _train_skin_struct_to_save);
    db_close();
}
