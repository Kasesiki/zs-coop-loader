if (is_in_raid())
{
    if (quest_is_active("chemical_document") || quest_is_complete("chemical_document"))
    {
        instance_create_depth(x, y, 0, obj_boss_rotking);
    }
}
