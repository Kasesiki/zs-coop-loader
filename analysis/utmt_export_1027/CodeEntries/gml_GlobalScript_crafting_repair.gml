function crafting_repair(arg0)
{
    if (arg0 == undefined)
    {
        exit;
    }
    if (!crafting_meet_requirements(arg0, false, true))
    {
        exit;
    }
    var _durability_previous = loot_get_durability(arg0);
    var _repaired_item_id = loot_get_item(arg0);
    if (!global.general_debug)
    {
        crafting_remove_raw_materials(arg0);
    }
    loot_action_repair_from_crafting(arg0);
    var _durability_new = loot_get_durability(arg0);
    var _text = language_get_string("ui.repaired_items");
    _text = string_replace(_text, "[ITEM_NAME]", loot_get_name(arg0));
    _text = string_replace(_text, "[ITEM_DURABILITY]", loot_get_durability(arg0));
    scr_draw_text_with_box(_text);
    stat_increment("tot_items_repaired");
    steam_stat_increment("itemsrepaired");
    ui_crafting_populate("repair_gear");
    ui_crafting_requirements_populate(uiGetData().crafting_loot);
    if (_durability_new > _durability_previous)
    {
        mods_perform_event("item_repaired", [_repaired_item_id, _durability_previous, _durability_new, "crafting"]);
    }
}
