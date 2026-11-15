function npc_dialogue_repair()
{
    if (!player_exists_local())
    {
        exit;
    }
    var _player = player_get_local();
    if (!item_fits_category(_player.armor_now, "armor"))
    {
        scr_draw_text_with_box("No armor in the slot");
        exit;
    }
    var _price = npc_dialogue_get_repair_price();
    if (global.player_money < _price)
    {
        scr_draw_text_with_box("Not enough Roubles");
        exit;
    }
    if (item_armor_get_class(_player.armor_now) > 4)
    {
        scr_draw_text_with_box("Armor class is too high");
        exit;
    }
    var _durability_previous = player_loadout_get_durability(_player, "armor slot");
    var _repaired_item_id = _player.armor_now;
    trader_transfer_money(undefined, 0, _price);
    player_loadout_set_durability("armor slot", 100);
    var _durability_new = player_loadout_get_durability(_player, "armor slot");
    if (is_in_hub())
    {
        db_force_save_soft("pre_raid");
    }
    audio_play_sound(snd_ui_click_text_npc, 9, false);
    scr_draw_text_with_box("Armor repaired");
    if (_durability_new > _durability_previous)
    {
        mods_perform_event("item_repaired", [_repaired_item_id, _durability_previous, _durability_new, "trader"]);
    }
}
