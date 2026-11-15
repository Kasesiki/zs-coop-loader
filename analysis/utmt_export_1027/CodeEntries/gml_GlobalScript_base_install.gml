function base_install(arg0, arg1, arg2 = true)
{
    if (!is_in_hub())
    {
        scr_draw_text_with_box("You can only install modules in the bunker");
        return false;
    }
    var _slot = base_find_slot(arg0);
    if (_slot != undefined)
    {
        if (arg2)
        {
            scr_draw_text_with_box("Already installed!");
        }
        return false;
    }
    global.sl_free[arg1] = 2;
    global.sl_base_id[arg1] = arg0;
    obj_base_parent.alarm[0] = 1;
    scr_save_skill_and_base();
    mods_perform_event("base_module_built", [base_component_to_name(arg0), arg1, global.base_lvl[arg0]]);
    return true;
}
