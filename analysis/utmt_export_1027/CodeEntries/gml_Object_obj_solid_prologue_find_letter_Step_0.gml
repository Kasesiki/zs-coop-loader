if (instance_exists(obj_prologue))
{
    if (obj_prologue.state == UnknownEnum.Value_27)
    {
        instance_destroy();
    }
}

enum UnknownEnum
{
    Value_27 = 27
}
