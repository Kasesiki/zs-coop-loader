global.__difficulty_data = {};
global.__difficulty_preset_data = {};
global.__difficulty_array = [];
global.__difficulty_sandbox = true;
global.__difficulty_sandbox_values = {};
__difficulty_define_range("trade_sell_mult", 0.4, 0, 1, "difficulty.modifier.sell_multiplier", "Factor by which the value of an item is multiplied when selling it.\nExample: an item with a value of 100 Rubles will be bought for 100 and sold for 100 x Sell Multiplier");
__difficulty_define_range("loot_item_amount", 1.5, 0, 5, "difficulty.modifier.items_amount");
__difficulty_define_range("loot_amount_single_item", 1, 0, 5, "difficulty.modifier.amount_of_single_item");
__difficulty_define_range("loot_weapon_dur_min", 60, 0, 100, "difficulty.modifier.minimun_weapon_durability");
__difficulty_define_range("loot_weapon_dur_max", 60, 0, 100, "difficulty.modifier.maximun_weapon_durability");
__difficulty_define_toggle("loot_npc_drop_armor", true, "difficulty.modifier.npcs_drop_armor", "Unused. NPCs will always drop armor");
__difficulty_define_range("loot_npc_drop_ammo", 2, 0, 10, "difficulty.modifier.npc_ammo_amount");
__difficulty_define_toggle("npc_loot_bodies", true, "difficulty.menu.npc_loot_bodies", "difficulty.menu.tooltip.npc_loot_bodies");
__difficulty_define_toggle("npc_claim_bodies", true, "difficulty.menu.npc_claim_bodies", "difficulty.menu.tooltip.npc_defend_bodies");
__difficulty_define_range("npc_loot_amount", 1, 0, 2, "difficulty.menu.npc_loot_amount", "difficulty.menu.tooltip.npc_loot_amount");
__difficulty_define_toggle("npc_loot_weapons", true, "difficulty.menu.npc_loot_weapons", "difficulty.menu.tooltip.npc_loot_weapons");
__difficulty_define_toggle("npc_loot_armor", true, "difficulty.menu.npc_loot_armor", "difficulty.menu.tooltip.npc_loot_armor");
__difficulty_define_toggle("npc_loot_backpacks", true, "difficulty.menu.npc_loot_backpacks", "difficulty.menu.tooltip.npc_loot_backpacks");
__difficulty_define_toggle("npc_loot_attachments", true, "difficulty.menu.npc_loot_attachments", "difficulty.menu.tooltip.npc_loot_attachments");
__difficulty_define_toggle("npc_loot_ammo", true, "difficulty.menu.npc_loot_ammo", "difficulty.menu.tooltip.npc_loot_ammo");
__difficulty_define_toggle("npc_loot_medical", true, "difficulty.menu.npc_loot_medical", "difficulty.menu.tooltip.npc_loot_medical");
__difficulty_define_toggle("npc_loot_valuables", true, "difficulty.menu.npc_loot_valuables", "difficulty.menu.tooltip.npc_loot_valuables");
__difficulty_define_range("npc_spare_equipment", 1, 0, 3, "difficulty.menu.npc_spare_equipment", "difficulty.menu.tooltip.npc_spare_equipment", 1);
__difficulty_define_range("npc_hunter_extra_loot", 5, 0, 10, "difficulty.menu.npc_hunter_extra_loot", "difficulty.menu.tooltip.npc_hunter_extra_loot", 1);
__difficulty_define_toggle("npc_loot_unseen_fights", true, "difficulty.menu.npc_loot_unseen_fights", "difficulty.menu.tooltip.npc_loot_unseen_fights");
__difficulty_define_range("loot_backpack_tier1", 75, 0, 100, "difficulty.menu.backpack_tier_1");
__difficulty_define_range("loot_backpack_tier2", 50, 0, 100, "difficulty.menu.backpack_tier_2");
__difficulty_define_range("loot_backpack_tier3", 25, 0, 100, "difficulty.menu.backpack_tier_3");
__difficulty_define_range("trade_sell_mult", 0.4, 0, 1, "difficulty.modifier.sell_multiplier", "Factor by which the value of an item is multiplied when selling it.\nExample: an item with a value of 100 Rubles will be bought for 100 and sold for 100 x Sell Multiplier");
__difficulty_define_range("trade_item_amount", 3, 0, 5, "difficulty.modifier.items_amount", "Multiplier whereby all items sold by merchants are multiplied");
__difficulty_define_range("trade_trader_money", 3, 0, 5, "difficulty.modifier.traders_money", "Multiplication factor of the number of money a trader has.");
__difficulty_define_range("trade_price_weapon", 1, 0, 2, "difficulty.modifier.price_weapon", "");
__difficulty_define_range("trade_price_armor", 1, 0, 2, "difficulty.modifier.price_armor", "");
__difficulty_define_range("trade_price_backpack", 1, 0, 2, "difficulty.modifier.price_backpack", "");
__difficulty_define_range("trade_price_ammo", 1, 0, 2, "difficulty.modifier.price_ammo", "");
__difficulty_define_range("trade_price_medication", 1, 0, 2, "difficulty.modifier.price_medication", "");
__difficulty_define_range("armor_class_03_chance", 75, 0, 100, "difficulty.menu.class_0_3_drop_chance");
__difficulty_define_range("armor_class_03_dur_min", 50, 0, 100, "Class 0-3 dur min");
__difficulty_define_range("armor_class_03_dur_max", 90, 0, 100, "Class 0-3 dur max");
__difficulty_define_range("armor_class_4_chance", 60, 0, 100, "difficulty.menu.class_4_drop_chance");
__difficulty_define_range("armor_class_4_dur_min", 35, 0, 100, "Class 4 dur min");
__difficulty_define_range("armor_class_4_dur_max", 75, 0, 100, "Class 4 dur max");
__difficulty_define_range("armor_class_5_chance", 25, 0, 100, "difficulty.menu.class_5_drop_chance");
__difficulty_define_range("armor_class_5_dur_min", 25, 0, 100, "Class 5 dur min");
__difficulty_define_range("armor_class_5_dur_max", 50, 0, 100, "Class 5 dur max");
__difficulty_define_range("armor_class_6_chance", 15, 0, 100, "difficulty.menu.class_6_drop_chance");
__difficulty_define_range("armor_class_6_dur_min", 10, 0, 100, "Class 6 dur min");
__difficulty_define_range("armor_class_6_dur_max", 35, 0, 100, "Class 6 dur max");
__difficulty_define_range("loot_item_amount", 1.5, 0, 5, "difficulty.modifier.items_amount", "Multiplication factor of the number of items contained in each container.");
__difficulty_define_range("loot_amount_single_item", 1, 0, 5, "difficulty.modifier.amount_of_single_item", "Multiplication factor of the number of each individual item in a container.");
__difficulty_define_range("loot_weapon_dur_min", 60, 0, 100, "difficulty.modifier.minimun_weapon_durability", "");
__difficulty_define_range("loot_weapon_dur_max", 60, 0, 100, "difficulty.modifier.maximun_weapon_durability", "");
__difficulty_define_toggle("loot_npc_drop_armor", true, "difficulty.modifier.npcs_drop_armor", "All NPCs will drop their armor. The durability of the armor depends on how many hits they took.");
__difficulty_define_range("loot_npc_drop_ammo", 2, 0, 10, "difficulty.modifier.npc_ammo_amount", "");
__difficulty_define_range("pro_player_health", 110, 40, 120, "difficulty.modifier.character_health", "");
__difficulty_define_range("pro_min_carry_weight", 15, 5, 30, "difficulty.modifier.minimum_transportable_weight", "");
__difficulty_define_range("pro_hunger_thirst_rate", 0.5, 0, 2, "difficulty.modifier.hunger_thirst_decay_rate", "");
__difficulty_define_range("pro_reputation_multiplier", 2, 0, 4, "difficulty.modifier.reputation_multiplier", "Factor that will be multiplied to the reputation obtained at the end of each Hunt.");
__difficulty_define_range("pro_exp_multiplier", 2, 0, 4, "difficulty.modifier.skill_experience_multiplier", "");
__difficulty_define_range("pro_quest_rep", 2, 0, 4, "difficulty.modifier.reputation_from_quests", "");
__difficulty_define_range("pro_quest_money", 1, 0, 4, "difficulty.modifier.roubles_from_quests", "");
__difficulty_define_range("pro_quest_item", 1, 0, 4, "difficulty.modifier.items_from_quests", "");
__difficulty_define_range("pro_service_price", 0.3, 0, 2, "difficulty.modifier.service_price", "Factor that will be multiplied to the price of each service provided by NPCs in the bunker");
__difficulty_define_range("enemy_human_hp", 0.8, 0, 2, "difficulty.modifier.human_health", "");
__difficulty_define_range("enemy_human_damage", 0.6, 0, 2, "difficulty.modifier.human_damage_dealt", "Note: this value is applied only to the damage received by the player.");
__difficulty_define_range("enemy_mutant_hp", 1, 0, 2, "difficulty.modifier.mutant_health", "");
__difficulty_define_range("enemy_mutant_damage", 0.6, 0, 2, "difficulty.modifier.mutant_damage_dealt", "Note: this value is applied only to the damage received by the player.");
__difficulty_define_range("enemy_human_aim_spread", 1, 0.5, 3, "difficulty.modifier.enemy_human_aim_spread", "Multiplier on human enemy aim error. 1.0 = vanilla, higher = less accurate.");
__difficulty_define_toggle("smart_ai", true, "difficulty.menu.difficult_ai", "difficulty.menu.tooltip.difficult_ai");
__difficulty_define_range("early_enemy_reveal", 0, 0, 2, "difficulty.menu.early_enemy_reveal", "difficulty.menu.tooltip.early_enemy_reveal", 0.25);
__difficulty_define_range("enemy_out_of_sight_visibility", 0.15, 0, 1, "difficulty.menu.enemy_out_of_sight_visibility", "difficulty.menu.tooltip.enemy_out_of_sight_visibility", 0.05);
__difficulty_define_toggle("npc_join_fights", true, "difficulty.menu.hunters_join_fights", "difficulty.menu.tooltip.hunters_join_fights");
__difficulty_define_range("npc_join_fights_range", 750, 0, 7000, "difficulty.menu.hunter_hearing_range", "difficulty.menu.tooltip.hunter_hearing_range", 50);
__difficulty_define_range("npc_join_fights_groups", 2, 1, 5, "difficulty.menu.hunter_groups_joining_fights", "difficulty.menu.tooltip.hunter_groups_joining_fights", 1);
__difficulty_define_toggle("hardcore_lose_equipment", false, "difficulty.modifier.lose_equipment", "Upon death, you lose all the equipment you have worn.");
__difficulty_define_toggle("hardcore_lose_ammo", false, "difficulty.modifier.lose_ammo", "Upon death, you lose all the ammunition in your inventory.");
__difficulty_define_toggle("hardcore_lose_medication", false, "difficulty.modifier.lose_medication", "Upon death, you lose all the medication in your inventory.");
__difficulty_define_toggle("hardcore_lose_consumable", false, "difficulty.modifier.lose_consumable", "Upon death, you lose all the consumable items in your inventory.");
__difficulty_define_toggle("hardcore_lose_keys", false, "difficulty.modifier.lose_keys", "Upon death, you lose all the keys in your inventory.");
__difficulty_define_toggle("hardcore_lose_other", false, "difficulty.modifier.lose_other_item", "Upon death, you lose all items that are not part of the categories above.");
__difficulty_define_toggle("hardcore_perma_death", false, "difficulty.modifier.perma_death", "Upon death, the save files related to the slot used will be deleted.\nNote: All crashes are not recognized as death, nevertheless the use of this setting is not recommended until the game is bug-free.");
__difficulty_define_toggle("weapon_jam_enabled", true, "difficulty.modifier.weapon_jam_enabled", "When enabled, weapons in poor condition can jam when fired.");
__difficulty_define_toggle("weapon_durability_degrade_mult", false, "difficulty.modifier.weapon_durability_degrade_mult", "When ON, weapons wear at 25% of the normal rate, so they seldom reach the jam threshold.");
__difficulty_define_range("pro_player_health", 110, 40, 120, "difficulty.modifier.character_health", "");
__difficulty_define_range("pro_min_carry_weight", 15, 5, 30, "difficulty.modifier.minimum_transportable_weight", "");
__difficulty_define_range("pro_hunger_thirst_rate", 0.5, 0, 2, "difficulty.modifier.hunger_thirst_decay_rate", "");
__difficulty_define_range("pro_reputation_multiplier", 2, 0, 4, "difficulty.modifier.reputation_multiplier", "Factor that will be multiplied to the reputation obtained at the end of each Hunt.");
__difficulty_define_range("pro_exp_multiplier", 2, 0, 4, "difficulty.modifier.skill_experience_multiplier", "");
__difficulty_define_range("pro_quest_rep", 2, 0, 4, "difficulty.modifier.reputation_from_quests", "");
__difficulty_define_range("pro_quest_money", 1, 0, 4, "difficulty.modifier.roubles_from_quests", "");
__difficulty_define_range("pro_quest_item", 1, 0, 4, "difficulty.modifier.items_from_quests", "");
__difficulty_define_range("pro_service_price", 0.3, 0, 2, "difficulty.modifier.service_price", "Factor that will be multiplied to the price of each service provided by NPCs in the bunker");
__difficulty_init_rookie();
__difficulty_init_standard();
__difficulty_init_survivor();
__difficulty_init_hunter();

function __difficulty_define_range(arg0, arg1, arg2, arg3, arg4 = arg0, arg5 = "", arg6 = 0.00001)
{
    array_push(global.__difficulty_array, arg0);
    variable_struct_set(global.__difficulty_data, arg0, 
    {
        __type: "range",
        __name: arg0,
        __default: arg1,
        __min: arg2,
        __max: arg3,
        __friendlyName: arg4,
        __description: arg5,
        __increment: arg6
    });
}

function __difficulty_define_toggle(arg0, arg1, arg2 = arg0, arg3 = "")
{
    array_push(global.__difficulty_array, arg0);
    variable_struct_set(global.__difficulty_data, arg0, 
    {
        __type: "toggle",
        __name: arg0,
        __default: arg1,
        __min: false,
        __max: true,
        __friendlyName: arg2,
        __description: arg3
    });
}
