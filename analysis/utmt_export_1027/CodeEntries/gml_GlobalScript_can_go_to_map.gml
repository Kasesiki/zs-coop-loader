function can_go_to_map()
{
    if (inventory_category_exists("container"))
    {
        scr_draw_text_with_box("You cant leave with a container in the inventory.");
        return false;
    }
    return true;
}
