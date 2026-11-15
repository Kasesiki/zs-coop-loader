if (instance_exists(obj_prologue))
{
    if (place_meeting(x, y, obj_player_parent))
    {
        if (obj_prologue.state < UnknownEnum.Value_34)
        {
            obj_prologue.state = UnknownEnum.Value_34;
        }
    }
}

enum UnknownEnum
{
    Value_34 = 34
}
