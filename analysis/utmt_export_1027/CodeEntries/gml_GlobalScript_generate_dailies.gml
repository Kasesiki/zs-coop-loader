function generate_dailies()
{
    global.daily_quest_generated = db_read_ext("general", "quest", "daily generated", false);
    if (global.daily_quest_generated == false)
    {
        var _i = 0;
        var _pool;
        _pool[_i] = 
        {
            type: "kill",
            unique: false,
            chance: 
            {
                Loners: 2,
                Scientists: 1,
                "Green Army": 3,
                "Crimson Corporation": 3
            },
            pool: [new class_daily_kill(global.quest_kill_array.bandit, "Bandits", 5, 1, -1, 3, 0, 3, 3), new class_daily_kill(["ghoul"], "", 5, 1, -1, 3, 0, 3, 3), new class_daily_kill(["wolf_brown"], "Wolf", 5, 1, -1, 2, 0, 2, 2), new class_daily_kill(["boar"], "", 2, 1, [UnknownEnum.Value_1, UnknownEnum.Value_2, UnknownEnum.Value_3], 3, 0, 2, 2), new class_daily_kill(["blink"], "", 3, 3, [UnknownEnum.Value_3, UnknownEnum.Value_4, UnknownEnum.Value_6], 3, 0, 2, 2), new class_daily_kill(["big"], "", 1, 3, [UnknownEnum.Value_4, UnknownEnum.Value_6], 0, 0, 1, 1), new class_daily_kill(global.quest_kill_array.hunter, "Hunters", 2, 1, -1, 2, 0, 4, 4), new class_daily_kill(["spider"], "", 4, 3, [UnknownEnum.Value_3, UnknownEnum.Value_4], 2, 0, 1, 1), new class_daily_kill(["bandit_boss"], "", 1, 1, [UnknownEnum.Value_1], 1, 0, 0, 0), new class_daily_kill(["arman"], "", 1, 3, [UnknownEnum.Value_2], 0, 0, 1, 1), new class_daily_kill(["killa"], "", 1, 4, [UnknownEnum.Value_6], 1, 0, 1, 1), new class_daily_kill(global.quest_kill_array.green_army, "Green Army soldier", 3, 1, -1, 0, 0, 0, 4), new class_daily_kill(global.quest_kill_array.crimson, "CC soldier", 3, 1, -1, 0, 0, 4, 0)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "collect",
            unique: false,
            chance: 
            {
                Loners: 1,
                Scientists: 4,
                "Green Army": 2,
                "Crimson Corporation": 2
            },
            pool: [new class_daily_collect("tushonka_meat", 2, 2, 0, 0, 0), new class_daily_collect("tushonka_fish", 2, 2, 0, 0, 0), new class_daily_collect("mre", 1, 2, 0, 1, 1), new class_daily_collect("bread", 4, 2, 0, 0, 0), new class_daily_collect("russian_chocolate", 1, 2, 0, 0, 0), new class_daily_collect("generic_chocolate", 2, 2, 0, 0, 0), new class_daily_collect("crackers", 4, 2, 0, 0, 0), new class_daily_collect("pasta", 1, 2, 0, 0, 0), new class_daily_collect("canned_beans", 1, 2, 0, 0, 0), new class_daily_collect("chips", 1, 2, 0, 0, 0), new class_daily_collect("salame", 2, 2, 0, 0, 0), new class_daily_collect("wurstel", 1, 2, 0, 0, 0), new class_daily_collect("butter", 2, 2, 0, 0, 0), new class_daily_collect("cheese", 2, 2, 0, 0, 0), new class_daily_collect("water_bottle", 2, 2, 0, 1, 1), new class_daily_collect("milk", 2, 2, 0, 0, 0), new class_daily_collect("vodka", 2, 2, 0, 2, 0), new class_daily_collect("fruit_juice", 1, 2, 0, 0, 0), new class_daily_collect("coke", 1, 2, 0, 0, 0), new class_daily_collect("energy_drink", 1, 2, 0, 1, 1), new class_daily_collect("red_cigarettes", 4, 2, 0, 2, 2), new class_daily_collect("blue_cigarettes", 2, 2, 0, 1, 1), new class_daily_collect("raw_meat", 6, 0, 2, 0, 0), new class_daily_collect("wolf_pelt", 4, 0, 1, 0, 0), new class_daily_collect("boar_pelt", 3, 0, 1, 0, 0), new class_daily_collect("rabbit_pelt", 5, 0, 1, 0, 0), new class_daily_collect("boar_fang", 3, 0, 1, 0, 0), new class_daily_collect("blink_artiglio", 4, 0, 1, 0, 0), new class_daily_collect("devourer_tooth", 1, 0, 1, 0, 0), new class_daily_collect("ghoul_tentacles", 5, 0, 1, 0, 0), new class_daily_collect("spider_eye", 2, 0, 1, 0, 0), new class_daily_collect("spider_web", 2, 0, 1, 0, 0), new class_daily_collect("drill", 1, 0, 0, 1, 1), new class_daily_collect("screwdriver", 2, 0, 0, 1, 1), new class_daily_collect("wrench", 2, 0, 0, 1, 1), new class_daily_collect("nail", 20, 0, 0, 1, 1), new class_daily_collect("pliers", 2, 0, 0, 1, 1), new class_daily_collect("hammer", 2, 0, 0, 1, 1), new class_daily_collect("rope", 1, 0, 0, 1, 1), new class_daily_collect("paint_white", 1, 0, 0, 1, 1), new class_daily_collect("dutch_tape", 2, 0, 0, 1, 1), new class_daily_collect("metal_pipe", 1, 0, 0, 1, 1), new class_daily_collect("spark_plug", 2, 0, 1, 1, 1), new class_daily_collect("car_battery", 1, 0, 1, 1, 1), new class_daily_collect("alchool", 1, 0, 1, 0, 0), new class_daily_collect("engine_oil", 1, 0, 0, 1, 1), new class_daily_collect("screw_nut", 15, 0, 0, 1, 1), new class_daily_collect("bolt_cutter", 1, 0, 0, 1, 1), new class_daily_collect("spray_bug", 1, 0, 1, 1, 1), new class_daily_collect("gas_tank", 1, 0, 1, 3, 3), new class_daily_collect("carbone", 4, 0, 0, 3, 3), new class_daily_collect("metro", 1, 0, 0, 1, 1), new class_daily_collect("hose", 1, 0, 0, 1, 1), new class_daily_collect("battery", 2, 0, 2, 2, 2), new class_daily_collect("bulb", 2, 0, 2, 2, 2), new class_daily_collect("electric_motor", 1, 0, 1, 1, 1), new class_daily_collect("hard_disk", 2, 0, 1, 1, 1), new class_daily_collect("wires", 2, 0, 1, 2, 2), new class_daily_collect("usb", 1, 0, 0, 1, 1), new class_daily_collect("gamestation", 1, 1, 0, 0, 0), new class_daily_collect("smartphone", 1, 2, 2, 2, 2), new class_daily_collect("relay", 2, 0, 1, 1, 1), new class_daily_collect("ram", 1, 0, 0, 2, 2), new class_daily_collect("cpu", 1, 0, 0, 2, 2), new class_daily_collect("multi_plug", 2, 0, 1, 2, 2), new class_daily_collect("power_bank", 1, 2, 0, 1, 1), new class_daily_collect("hair_dryer", 1, 1, 0, 0, 0), new class_daily_collect("fan", 2, 0, 0, 3, 3), new class_daily_collect("power_outlet", 2, 0, 2, 3, 3), new class_daily_collect("ssd", 1, 0, 0, 2, 2), new class_daily_collect("military_circuit", 1, 0, 2, 2, 2), new class_daily_collect("dvd_drive", 2, 2, 0, 0, 0), new class_daily_collect("knife", 2, 1, 0, 0, 0), new class_daily_collect("spoon", 2, 1, 0, 0, 0), new class_daily_collect("fork", 2, 1, 0, 0, 0), new class_daily_collect("matches", 5, 2, 0, 0, 0), new class_daily_collect("lighter", 2, 2, 0, 1, 1), new class_daily_collect("coffee", 1, 2, 0, 0, 0), new class_daily_collect("paper", 1, 1, 1, 1, 1), new class_daily_collect("soap", 1, 2, 2, 0, 0), new class_daily_collect("zippo", 1, 1, 0, 1, 1), new class_daily_collect("toilet_paper", 1, 1, 0, 1, 1), new class_daily_collect("shampoo", 1, 1, 0, 0, 0), new class_daily_collect("tea_bag", 1, 2, 0, 0, 0), new class_daily_collect("salt", 5, 2, 0, 0, 0), new class_daily_collect("pepper", 5, 2, 0, 0, 0), new class_daily_collect("pillow", 1, 1, 0, 1, 1), new class_daily_collect("pot_cooking", 1, 1, 0, 0, 0), new class_daily_collect("dumbell", 1, 1, 0, 1, 1), new class_daily_collect("wristwatch", 1, 1, 0, 0, 0), new class_daily_collect("wristwatch_gold", 1, 1, 0, 0, 0), new class_daily_collect("fragrance", 1, 1, 0, 0, 0), new class_daily_collect("zippo_gold", 1, 1, 0, 0, 0), new class_daily_collect("bracelet_silver", 1, 1, 0, 0, 0), new class_daily_collect("bracelet_gold", 1, 1, 0, 0, 0), new class_daily_collect("necklace_gold", 1, 1, 0, 0, 0), new class_daily_collect("injector_vuoto", 2, 0, 2, 0, 0), new class_daily_collect("scissors_surgery", 2, 0, 2, 1, 1), new class_daily_collect("medikit_1", 1, 0, 2, 1, 1), new class_daily_collect("medikit_2", 1, 0, 2, 0, 0), new class_daily_collect("medikit_3", 1, 0, 1, 0, 0), new class_daily_collect("medikit_long", 2, 0, 3, 1, 1), new class_daily_collect("bandage", 3, 0, 3, 1, 1), new class_daily_collect("pills_anti_rad", 3, 0, 2, 1, 1), new class_daily_collect("anti_bleed_gel", 1, 0, 2, 0, 0), new class_daily_collect("med_wound_1", 1, 0, 2, 0, 0), new class_daily_collect("med_wound_2", 1, 0, 1, 0, 0), new class_daily_collect("bandage_sterilizzata", 2, 0, 2, 0, 0), new class_daily_collect("injector1", 1, 0, 1, 1, 1), new class_daily_collect("injector2", 1, 0, 1, 1, 1), new class_daily_collect("injector3", 1, 0, 1, 1, 1), new class_daily_collect("injector7", 1, 0, 1, 1, 1), new class_daily_collect("injector4", 1, 0, 1, 1, 1), new class_daily_collect("injector5", 1, 0, 1, 1, 1), new class_daily_collect("injector6", 1, 0, 1, 1, 1), new class_daily_collect("cristallo_red", 2, 0, 6, 0, 2), new class_daily_collect("cristallo_blu", 2, 0, 4, 0, 2), new class_daily_collect("cristallo_verde", 2, 0, 6, 0, 2), new class_daily_collect("scrap_material", 20, 0, 0, 1, 1), new class_daily_collect("scrap_food", 10, 3, 0, 0, 0), new class_daily_collect("scrap_ammo", 70, 0, 0, 3, 3), new class_daily_collect("scrap_med", 10, 0, 4, 1, 1), new class_daily_collect("scrap_weapon", 20, 0, 0, 3, 3), new class_daily_collect("scrap_armor", 20, 0, 0, 3, 3)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "contract",
            unique: false,
            chance: 
            {
                Loners: 5,
                Scientists: 5,
                "Green Army": 5,
                "Crimson Corporation": 5
            },
            pool: [new class_daily_contract(obj_enemy_human_bandit_novice, "Bandit", -1, 1, 3, 0, 1, 0), new class_daily_contract(obj_enemy_human_bandit_regular, "Bandit", -1, 1, 3, 0, 1, 0), new class_daily_contract(obj_enemy_big, "Big", -1, 3, 1, 0, 1, 0), new class_daily_contract(obj_loner_enemy, "Hunter", -1, 1, 1, 0, 4, 1), new class_daily_contract(obj_loner_enemy2, "Hunter", -1, 1, 1, 0, 4, 1), new class_daily_contract(obj_enemy_infestation, "Infestation", -1, 1, 0, 3, 0, 2), new class_daily_contract(obj_green_army_soldier1, "Green Army soldier", -1, 1, 0, 0, 0, 5), new class_daily_contract(obj_crimson_soldier, "CC soldier", -1, 1, 0, 0, 5, 0)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "survive",
            unique: false,
            chance: 
            {
                Loners: 1,
                Scientists: 1,
                "Green Army": 1,
                "Crimson Corporation": 1
            },
            pool: [new class_daily_survive(UnknownEnum.Value_1, 2, 1, 1, 1, 0, 0), new class_daily_survive(UnknownEnum.Value_2, 2, 1, 1, 1, 1, 1), new class_daily_survive(UnknownEnum.Value_3, 1, 3, 1, 1, 1, 1), new class_daily_survive(UnknownEnum.Value_4, 1, 3, 0, 1, 1, 1), new class_daily_survive(UnknownEnum.Value_6, 1, 3, 0, 0, 1, 1)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "survive_exp",
            unique: false,
            chance: 
            {
                Loners: 1,
                Scientists: 1,
                "Green Army": 1,
                "Crimson Corporation": 1
            },
            pool: [new class_daily_survive_exp([UnknownEnum.Value_1, UnknownEnum.Value_2, UnknownEnum.Value_3, UnknownEnum.Value_4, UnknownEnum.Value_6], 2, 1, 125, 1, 1, 1, 1), new class_daily_survive_exp(-1, 2, 1, 125, 1, 1, 1, 1)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "survive_money",
            unique: false,
            chance: 
            {
                Loners: 1,
                Scientists: 1,
                "Green Army": 1,
                "Crimson Corporation": 1
            },
            pool: [new class_daily_survive_money([UnknownEnum.Value_1, UnknownEnum.Value_2, UnknownEnum.Value_3, UnknownEnum.Value_4, UnknownEnum.Value_6], 2, 1, 7500, 1, 1, 1, 1), new class_daily_survive_money(-1, 2, 1, 7500, 1, 1, 1, 1)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "retrieve_analyzer",
            unique: true,
            chance: 
            {
                Loners: 0,
                Scientists: 4,
                "Green Army": 0,
                "Crimson Corporation": 0
            },
            pool: [new class_daily_retrieve_analyzer(UnknownEnum.Value_11, "quest_retrive_analyzer_anomaly_fire_medium", obj_chest_retrive_analyzer_anomaly_fire_medium, 1, undefined, 0, 3, 0, 0), new class_daily_retrieve_analyzer(UnknownEnum.Value_12, "quest_retrive_analyzer_anomaly_fire_big", obj_chest_retrive_analyzer_anomaly_fire_big, 1, undefined, 0, 3, 0, 0), new class_daily_retrieve_analyzer(UnknownEnum.Value_15, "quest_retrive_analyzer_anomaly_gas_big", obj_chest_retrive_analyzer_anomaly_gas_big, 1, undefined, 0, 3, 0, 0), new class_daily_retrieve_analyzer(UnknownEnum.Value_14, "quest_retrive_analyzer_anomaly_gas_medium", obj_chest_retrive_analyzer_anomaly_gas_medium, 1, undefined, 0, 3, 0, 0)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "place_analyzer",
            unique: true,
            chance: 
            {
                Loners: 0,
                Scientists: 4,
                "Green Army": 0,
                "Crimson Corporation": 0
            },
            pool: [new class_daily_place_analyzer(UnknownEnum.Value_11, 1, undefined, obj_quest_place_analyzer_1, 0, 3, 0, 0), new class_daily_place_analyzer(UnknownEnum.Value_12, 1, undefined, obj_quest_place_analyzer_2, 0, 3, 0, 0), new class_daily_place_analyzer(UnknownEnum.Value_15, 1, undefined, obj_quest_place_analyzer_3, 0, 3, 0, 0), new class_daily_place_analyzer(UnknownEnum.Value_14, 1, undefined, obj_quest_place_analyzer_4, 0, 3, 0, 0)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "retrieve_equipment",
            unique: true,
            chance: 
            {
                Loners: 0,
                Scientists: 0,
                "Green Army": 5,
                "Crimson Corporation": 5
            },
            pool: [new class_daily_retrieve_equipment("Crimson Corporation", "quest_retrieve_equipment_1", obj_chest_retrive_equipment_1, 1, -1, 0, 0, 0, 3), new class_daily_retrieve_equipment("Green Army", "quest_retrieve_equipment_2", obj_chest_retrive_equipment_2, 1, -1, 0, 0, 3, 0)]
        };
        _i++;
        _pool[_i] = 
        {
            type: "collect_marker",
            unique: true,
            chance: 
            {
                Loners: 3,
                Scientists: 3,
                "Green Army": 3,
                "Crimson Corporation": 3
            },
            pool: [new class_daily_collect_marker(0, "quest_dcm_sawmill_1", 1, "unlock_makeshift_camp", obj_dcm_sawmill_1, obj_dcm_chest_quest_sawmill_1, obj_sawmill8, 2, 1, 1, 1, 1, "Special Tool Box: Located inside the Sawmill in the Forest."), new class_daily_collect_marker(1, "quest_dcm_sawmill_2", 1, "first_step_1", obj_dcm_sawmill_2, obj_dcm_chest_quest_sawmill_2, obj_dcm_chest_quest_sawmill_2, 8, 1, 1, 1, 1, "Special Tool Box: Located outside the Sawmill in the Forest."), new class_daily_collect_marker(2, "quest_dcm_forest_village_1", 1, "valuable_item", obj_dcm_forest_village_1, obj_dcm_chest_quest_forest_village_1, obj_dcm_chest_quest_forest_village_1, 8, 1, 1, 1, 1, "Rare Vodka: Located in Forest Village."), new class_daily_collect_marker(3, "quest_dcm_forest_village_2", 1, "fix_the_radio_tower", obj_dcm_forest_village_2, obj_dcm_chest_quest_forest_village_2, -4, 8, 1, 1, 1, 1, "Police Briefcase: Located inside the police station in the Forest."), new class_daily_collect_marker(4, "quest_dcm_radio_tower_1", 1, "fix_the_radio_tower", obj_dcm_radio_tower_1, obj_dcm_chest_quest_radio_tower_1, obj_dcm_chest_quest_radio_tower_1, 7, 1, 1, 1, 1, "Rare Circuit: Located near the Radio Tower in the Makeshift Camp."), new class_daily_collect_marker(5, "quest_dcm_motel_1", 1, "motel_2", obj_dcm_motel_1, obj_dcm_chest_quest_motel_1, obj_dcm_chest_quest_motel_1, 7, 1, 1, 1, 1, "Good Condition Car Battery: Located near the Motel in the Makeshift Camp."), new class_daily_collect_marker(6, "quest_dcm_motel_2", 1, "motel_2", obj_dcm_motel_2, obj_dcm_chest_quest_motel_2, -4, 7, 1, 1, 1, 1, "Motel Briefcase: Located inside the Motel in the Makeshift Camp, in the bottom-right room."), new class_daily_collect_marker(7, "quest_dcm_orel_outpost_1", 1, "kill_orel", obj_dcm_orel_outpost_1, obj_dcm_chest_quest_orel_outpost_1, obj_dcm_chest_quest_orel_outpost_1, 7, 1, 1, 1, 1, "Special Tool Box: Located near the Old Train Station in the Makeshift Camp."), new class_daily_collect_marker(8, "quest_dcm_lab_1", 1, "laboratory_document", obj_dcm_lab_1, obj_dcm_chest_quest_lab_1, -4, 7, 1, 1, 1, 1, "Laboratory Documents 1: Located inside the Makeshift Camp Laboratory, in the staff break room."), new class_daily_collect_marker(9, "quest_dcm_lab_2", 1, "laboratory_document", obj_dcm_lab_2, obj_dcm_chest_quest_lab_2, -4, 7, 1, 1, 1, 1, "Laboratory Documents 2: Located inside the Makeshift Camp Laboratory, in the main control room."), new class_daily_collect_marker(10, "quest_dcm_sewer_1", 1, "kill_orel", obj_dcm_sewer_1, obj_dcm_chest_quest_sewer_1, obj_dcm_chest_quest_sewer_1, 7, 1, 1, 1, 1, "Special Tool Box: Located near the entrance to the Sewer in the Swamp."), new class_daily_collect_marker(11, "quest_dcm_sewer_2", 1, "gate_sewer", obj_dcm_sewer_2, obj_dcm_chest_quest_sewer_2, -4, 7, 1, 1, 1, 1, "Rotor: Located inside the Sewer in the Swamp, where the bandits are."), new class_daily_collect_marker(12, "quest_dcm_sewer_3", 1, "chemical_document", obj_dcm_sewer_3, obj_dcm_chest_quest_sewer_3, -4, 7, 1, 1, 1, 1, "Briefcase: Located inside the Sewer in the Swamp, in the laboratory to the north."), new class_daily_collect_marker(13, "quest_dcm_mall_1", 1, "gate_sewer", obj_dcm_mall_1, obj_dcm_chest_quest_mall_1, -4, 7, 1, 1, 1, 1, "USB Data: Located inside the Mall, in one of the security rooms near the entrances."), new class_daily_collect_marker(14, "quest_dcm_mall_2", 1, "gate_sewer", obj_dcm_mall_2, obj_dcm_chest_quest_mall_2, -4, 7, 1, 1, 1, 1, "Rare Whisky: Located inside the Mall, in the Woody Pub."), new class_daily_collect_marker(15, "quest_dcm_mall_3", 1, "gate_sewer", obj_dcm_mall_3, obj_dcm_chest_quest_mall_3, -4, 7, 1, 1, 1, 1, "Shoes: Located inside the Mall, in either the Keri or Adibas shop."), new class_daily_collect_marker(16, "quest_dcm_mall_4", 1, "gate_sewer", obj_dcm_mall_4, obj_dcm_chest_quest_mall_4, -4, 7, 1, 1, 1, 1, "Special Tool Box: Located inside the Mall, in the Tools shop."), new class_daily_collect_marker(17, "quest_dcm_mall_5", 1, "gate_sewer", obj_dcm_mall_5, obj_dcm_chest_quest_mall_5, -4, 7, 1, 1, 1, 1, "Dumbbell: Located inside the Mall, in the Gym."), new class_daily_collect_marker(18, "quest_dcm_mall_6", 1, "gate_sewer", obj_dcm_mall_6, obj_dcm_chest_quest_mall_6, -4, 7, 1, 1, 1, 1, "Med Box: Located inside the Mall, in the Pharmacy."), new class_daily_collect_marker(19, "quest_dcm_mall_7", 1, "gate_sewer", obj_dcm_mall_7, obj_dcm_chest_quest_mall_7, -4, 7, 1, 1, 1, 1, "Rotor: Located inside the Mall, in the top control room."), new class_daily_collect_marker(20, "quest_dcm_mall_8", 1, "gate_sewer", obj_dcm_mall_8, obj_dcm_chest_quest_mall_8, -4, 7, 1, 1, 1, 1, "Toilet Paper: Located inside the Mall, in one of the public bathrooms."), new class_daily_collect_marker(21, "quest_dcm_mall_9", 1, "gate_sewer", obj_dcm_mall_9, obj_dcm_chest_quest_mall_9, -4, 7, 1, 1, 1, 1, "Gamestation: Located inside the Mall, in the Tech Store."), new class_daily_collect_marker(22, "quest_dcm_mall_10", 1, "gate_sewer", obj_dcm_mall_10, obj_dcm_chest_quest_mall_10, -4, 7, 1, 1, 1, 1, "Box of Ammo: Located inside the Mall, in the Gun Store."), new class_daily_collect_marker(23, "quest_dcm_mall_11", 1, "gate_sewer", obj_dcm_mall_11, obj_dcm_chest_quest_mall_11, -4, 7, 1, 1, 1, 1, "Sapphire Necklace: Located inside the Mall, in the Skaruvski shop."), new class_daily_collect_marker(24, "quest_dcm_mall_12", 1, "gate_sewer", obj_dcm_mall_12, obj_dcm_chest_quest_mall_12, obj_dcm_chest_quest_mall_12, 5, 1, 1, 1, 1, "Rotor: Located outside the Mall, to the north."), new class_daily_collect_marker(25, "quest_dcm_mall_13", 1, "gate_sewer", obj_dcm_mall_13, obj_dcm_chest_quest_mall_13, -4, 7, 1, 1, 1, 1, "USB Data: Located in the Mall underground, in the security room."), new class_daily_collect_marker(26, "quest_dcm_mall_14", 1, "gate_sewer", obj_dcm_mall_14, obj_dcm_chest_quest_mall_14, -4, 7, 1, 1, 1, 1, "Special Tool Box: Located in the Mall underground, in the conveyor belt room."), new class_daily_collect_marker(27, "quest_dcm_mall_15", 1, "underground_extraction", obj_dcm_mall_15, obj_dcm_chest_quest_mall_15, -4, 7, 1, 1, 1, 1, "CCTV Camera: Located at the Mall underground exit."), new class_daily_collect_marker(28, "quest_dcm_mall_16", 1, "gate_sewer", obj_dcm_mall_16, obj_dcm_chest_quest_mall_16, -4, 7, 1, 1, 1, 1, "CCTV Camera: Located in the Mall underground, in one of the escalator rooms."), new class_daily_collect_marker(29, "quest_dcm_ind_1", 1, "kill_orel", obj_dcm_ind_1, obj_dcm_chest_quest_ind_1, obj_dcm_chest_quest_ind_1, 7, 1, 1, 1, 1, "Concrete Bag: Located in the Industrial Area, near the Port."), new class_daily_collect_marker(30, "quest_dcm_ind_2", 1, "kill_orel", obj_dcm_ind_2, obj_dcm_chest_quest_ind_2, obj_dcm_chest_quest_ind_2, 7, 1, 1, 1, 1, "Rotor: Located in the Industrial Area, outside the Oil Factory."), new class_daily_collect_marker(31, "quest_dcm_ind_3", 1, "kill_orel", obj_dcm_ind_3, obj_dcm_chest_quest_ind_3, obj_dcm_chest_quest_ind_3, 7, 1, 1, 1, 1, "Special Tool Box: Located in the Industrial Area, near the Train Depot."), new class_daily_collect_marker(32, "quest_dcm_ind_4", 1, "gate_sewer", obj_dcm_ind_4, obj_dcm_chest_quest_ind_4, -4, 7, 1, 1, 1, 1, "USB Data: Located in the Industrial Area, inside the Oil Factory, in the staff office."), new class_daily_collect_marker(33, "quest_dcm_ind_5", 1, "gate_sewer", obj_dcm_ind_5, obj_dcm_chest_quest_ind_5, -4, 7, 1, 1, 1, 1, "Briefcase: Located in the Industrial Area, inside the Oil Factory, in the director's room."), new class_daily_collect_marker(34, "quest_dcm_ind_6", 1, "gate_sewer", obj_dcm_ind_6, obj_dcm_chest_quest_ind_6, -4, 7, 1, 1, 1, 1, "Electric Motor: Located in the Industrial Area, inside the Oil Factory, in the machinery room."), new class_daily_collect_marker(35, "quest_dcm_zakov_1", 1, "bridge_to_zakov", obj_dcm_zakov_1, obj_dcm_chest_quest_zakov_1, obj_dcm_chest_quest_zakov_1, 7, 1, 1, 1, 1, "Car Battery: Located in Zakov."), new class_daily_collect_marker(36, "quest_dcm_zakov_2", 1, "bridge_to_zakov", obj_dcm_zakov_2, obj_dcm_chest_quest_zakov_2, obj_dcm_chest_quest_zakov_2, 7, 1, 1, 1, 1, "Briefcase: Located in Zakov, in the city park."), new class_daily_collect_marker(37, "quest_dcm_zakov_3", 1, "bridge_to_zakov", obj_dcm_zakov_3, obj_dcm_chest_quest_zakov_3, obj_dcm_chest_quest_zakov_3, 7, 1, 1, 1, 1, "Briefcase: Located in Zakov, in the shopping area."), new class_daily_collect_marker(38, "quest_dcm_zakov_4", 1, "bridge_to_zakov", obj_dcm_zakov_4, obj_dcm_chest_quest_zakov_4, obj_dcm_chest_quest_zakov_4, 7, 1, 1, 1, 1, "Special Tool Box: Located in Zakov, near the Warehouse."), new class_daily_collect_marker(39, "quest_dcm_zakov_5", 1, "bridge_to_zakov", obj_dcm_zakov_5, obj_dcm_chest_quest_zakov_5, -4, 7, 1, 1, 1, 1, "USB Data: Located in Zakov, inside the Warehouse, in the office."), new class_daily_collect_marker(40, "quest_dcm_zakov_6", 1, "bridge_to_zakov", obj_dcm_zakov_6, obj_dcm_chest_quest_zakov_6, -4, 7, 1, 1, 1, 1, "Fire Station Documents: Located in Zakov, inside the Fire Station."), new class_daily_collect_marker(41, "quest_dcm_zakov_7", 1, "bridge_to_zakov", obj_dcm_zakov_7, obj_dcm_chest_quest_zakov_7, -4, 7, 1, 1, 1, 1, "Police Station Documents: Located in Zakov, inside the Police Station."), new class_daily_collect_marker(42, "quest_dcm_zakov_8", 1, "bridge_to_zakov", obj_dcm_zakov_8, obj_dcm_chest_quest_zakov_8, -4, 7, 1, 1, 1, 1, "Gas Tank: Located in Zakov, inside the gas station."), new class_daily_collect_marker(43, "quest_dcm_zakov_9", 1, "bridge_to_zakov", obj_dcm_zakov_9, obj_dcm_chest_quest_zakov_9, -4, 7, 1, 1, 1, 1, "Med Box: Located in Zakov, inside the pharmacy."), new class_daily_collect_marker(44, "quest_dcm_zakov_10", 1, "bridge_to_zakov", obj_dcm_zakov_10, obj_dcm_chest_quest_zakov_10, -4, 7, 1, 1, 1, 1, "Briefcase: Located in Zakov, inside the post office."), new class_daily_collect_marker(45, "quest_dcm_zakov_11", 1, "bridge_to_zakov", obj_dcm_zakov_11, obj_dcm_chest_quest_zakov_11, -4, 7, 1, 1, 1, 1, "Coffee: Located in Zakov, inside Roundbucks."), new class_daily_collect_marker(46, "quest_dcm_zakov_12", 1, "bridge_to_zakov", obj_dcm_zakov_12, obj_dcm_chest_quest_zakov_12, -4, 7, 1, 1, 1, 1, "Sapphire Necklace: Located in Zakov, inside either Tissiny or Thenel."), new class_daily_collect_marker(47, "quest_dcm_zakov_13", 1, "bridge_to_zakov", obj_dcm_zakov_13, obj_dcm_chest_quest_zakov_13, -4, 7, 1, 1, 1, 1, "Carton of Cigarettes: Located in Zakov, inside the Tabak shop."), new class_daily_collect_marker(48, "quest_dcm_zakov_14", 1, "bridge_to_zakov", obj_dcm_zakov_14, obj_dcm_chest_quest_zakov_14, -4, 7, 1, 1, 1, 1, "Dumbbell: Located in Zakov, inside the FitX gym."), new class_daily_collect_marker(49, "quest_dcm_zakov_15", 1, "bridge_to_zakov", obj_dcm_zakov_15, obj_dcm_chest_quest_zakov_15, -4, 7, 1, 1, 1, 1, "Shoes: Located in Zakov, inside the Zaka shop."), new class_daily_collect_marker(50, "quest_dcm_zakov_16", 1, "bridge_to_zakov", obj_dcm_zakov_16, obj_dcm_chest_quest_zakov_16, -4, 7, 1, 1, 1, 1, "Shoes: Located in Zakov, inside the Limbertand shop."), new class_daily_collect_marker(51, "quest_dcm_zakov_17", 1, "bridge_to_zakov", obj_dcm_zakov_17, obj_dcm_chest_quest_zakov_17, -4, 7, 1, 1, 1, 1, "Wine: Located in Zakov, inside Da Pino."), new class_daily_collect_marker(52, "quest_dcm_zakov_18", 1, "the_school", obj_dcm_zakov_18, obj_dcm_chest_quest_zakov_18, -4, 7, 1, 1, 1, 1, "Book: Located in Zakov, inside the school, in one of the classrooms."), new class_daily_collect_marker(53, "quest_dcm_zakov_19", 1, "bridge_to_zakov", obj_dcm_zakov_19, obj_dcm_chest_quest_zakov_19, -4, 7, 1, 1, 1, 1, "Pasta: Located in Zakov, inside the market, near the shelves."), new class_daily_collect_marker(54, "quest_dcm_zakov_20", 1, "bridge_to_zakov", obj_dcm_zakov_20, obj_dcm_chest_quest_zakov_20, -4, 7, 1, 1, 1, 1, "CCTV Camera: Located in Zakov, in the financial offices, in the lounge area."), new class_daily_collect_marker(55, "quest_dcm_zakov_21", 1, "bridge_to_zakov", obj_dcm_zakov_21, obj_dcm_chest_quest_zakov_21, -4, 7, 1, 1, 1, 1, "USB Data: Located in Zakov, in the financial offices, in the blue office."), new class_daily_collect_marker(56, "quest_dcm_zakov_22", 1, "bridge_to_zakov", obj_dcm_zakov_22, obj_dcm_chest_quest_zakov_22, -4, 7, 1, 1, 1, 1, "Briefcase: Located in Zakov, in the financial offices, in the largest office."), new class_daily_collect_marker(57, "quest_dcm_zakov_24", 1, "machinery", obj_dcm_zakov_24, obj_dcm_chest_quest_zakov_24, -4, 7, 1, 1, 1, 1, "Briefcase: Located in Zakov, inside the Watcher Headquarters, in the main control room.")]
        };
        var _quest_reward_pool = 
        {
            tier_1: [new class_quest_reward_daily("scrap_1", 2), new class_quest_reward_daily("ammo_1", 2), new class_quest_reward_daily("medication_1", 2), new class_quest_reward_daily("supplies_1", 2), new class_quest_reward_daily("building_1", 2), new class_quest_reward_daily("attachment_1", 2), new class_quest_reward_daily("medication_2", 1), new class_quest_reward_daily("ammo_2", 1), new class_quest_reward_daily("building_2", 1), new class_quest_reward_daily("building_3", 2), new class_quest_reward_daily("repair_1", 1)],
            tier_2: [new class_quest_reward_daily("scrap_2", 2), new class_quest_reward_daily("ammo_2", 2), new class_quest_reward_daily("medication_2", 2), new class_quest_reward_daily("supplies_1", 1), new class_quest_reward_daily("building_1", 2), new class_quest_reward_daily("attachment_1", 2), new class_quest_reward_daily("medication_3", 1), new class_quest_reward_daily("ammo_3", 1), new class_quest_reward_daily("building_2", 2), new class_quest_reward_daily("building_3", 2), new class_quest_reward_daily("supplies_2", 2), new class_quest_reward_daily("scrap_3", 2), new class_quest_reward_daily("weapon_1", 1), new class_quest_reward_daily("attachment_2", 1), new class_quest_reward_daily("attachment_3", 1), new class_quest_reward_daily("repair_1", 2), new class_quest_reward_daily("repair_2", 2)],
            tier_3: [new class_quest_reward_daily("scrap_3", 2), new class_quest_reward_daily("ammo_2", 1), new class_quest_reward_daily("medication_2", 1), new class_quest_reward_daily("medication_3", 2), new class_quest_reward_daily("ammo_3", 2), new class_quest_reward_daily("building_3", 2), new class_quest_reward_daily("supplies_2", 2), new class_quest_reward_daily("scrap_3", 2), new class_quest_reward_daily("attachment_2", 1), new class_quest_reward_daily("attachment_3", 1), new class_quest_reward_daily("attachment_ga_1", 1), new class_quest_reward_daily("attachment_cc_1", 1), new class_quest_reward_daily("repair_1", 2), new class_quest_reward_daily("repair_2", 2), new class_quest_reward_daily("repair_4", 1)]
        };
        var _create_new = array_create(8, true);
        for (var i = 0; i < 8; i++)
        {
            for (var j = 0; j < 30; j++)
            {
                if (global.quest_state[j].id == ("daily_quest_" + string(i)))
                {
                    _create_new[i] = false;
                }
            }
        }
        for (var i = 0; i < 8; i++)
        {
            if (_create_new[i] == false)
            {
                var _array_objective = variable_struct_get(global.quest_database, "daily_quest_" + string(i)).objective;
                for (var j = 0; j < array_length(_array_objective); j++)
                {
                    for (var k = 0; k < array_length(_pool); k++)
                    {
                        if (_pool[k].unique == true)
                        {
                            var _array_pool = _pool[k].pool;
                            for (var o = 0; o < array_length(_array_pool); o++)
                            {
                                var _pool_struct = _array_pool[o];
                                var _quest_objective_struct = _array_objective[j];
                                var _quest_type = _array_objective[j].type;
                                var _pool_type = _pool[k].type;
                                if (_quest_type == _pool_type)
                                {
                                    switch (_quest_type)
                                    {
                                        case "retrieve_analyzer":
                                            if (_quest_objective_struct.item == _pool_struct.item)
                                            {
                                                _pool_struct.choosen = true;
                                            }
                                            break;
                                        case "retrieve_equipment":
                                            if (_quest_objective_struct.item == _pool_struct.item_id)
                                            {
                                                _pool_struct.choosen = true;
                                            }
                                            break;
                                        case "collect_marker":
                                            if (_quest_objective_struct.entry_id == _pool_struct.entry_id)
                                            {
                                                _pool_struct.choosen = true;
                                            }
                                            break;
                                        case "place_analyzer":
                                            if (_quest_objective_struct.object == _pool_struct.object_id)
                                            {
                                                _pool_struct.choosen = true;
                                            }
                                            break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        for (var i = 0; i < 8; i++)
        {
            if (_create_new[i] == true)
            {
                var _id = "daily_quest_" + string(i);
                var _name = "Daily Quest " + string(i);
                var _faction;
                switch (i)
                {
                    case 0:
                        _name = "Loners work 1";
                        _faction = "Loners";
                        break;
                    case 1:
                        _name = "Loners work 2";
                        _faction = "Loners";
                        break;
                    case 2:
                        _name = "Soldier work 1";
                        _faction = "Green Army";
                        break;
                    case 3:
                        _name = "Soldier work 2";
                        _faction = "Green Army";
                        break;
                    case 4:
                        _name = "Crimson work 1";
                        _faction = "Crimson Corporation";
                        break;
                    case 5:
                        _name = "Crimson work 2";
                        _faction = "Crimson Corporation";
                        break;
                    case 6:
                        _name = "Scientist work 1";
                        _faction = "Scientists";
                        break;
                    case 7:
                        _name = "Scientist work 2";
                        _faction = "Scientists";
                        break;
                    default:
                        trace_error("Unhandled case ", i);
                        break;
                }
                var _text;
                switch (i)
                {
                    case 0:
                        _text = "A lone raider needs a job doing.";
                        break;
                    case 1:
                        _text = "A lone raider needs a job doing.";
                        break;
                    case 2:
                        _text = "One of the Green Army grunts has a task.";
                        break;
                    case 3:
                        _text = "One of the Green Army grunts has a task.";
                        break;
                    case 4:
                        _text = "The Crimson Corporation got in touch.";
                        break;
                    case 5:
                        _text = "The Crimson Corporation got in touch.";
                        break;
                    case 6:
                        _text = "The scientists are doing another experiment.";
                        break;
                    case 7:
                        _text = "The scientists are doing another experiment.";
                        break;
                    default:
                        trace_error("Unhandled case ", i);
                        break;
                }
                var _struct = 
                {
                    id: _id,
                    name: _name,
                    experience: 0,
                    reputation: 0,
                    money: 0,
                    faction: _faction,
                    daily: true,
                    initial_item: [],
                    rep_min: 0,
                    quest_next: [new class_next_quest(_id, "daily_quest_giver")],
                    removable: true,
                    text: _text,
                    objective: [],
                    reward: []
                };
                var _quest_reward_money = 0;
                var _quest_reward_exp = 0;
                var _quest_reward_rep = 0;
                var _quest_initial_item = [];
                var _n_objectives = 1;
                var _n_chance = random(100);
                if (_n_chance < 40)
                {
                    _n_objectives = 2;
                }
                if (_n_chance < 18)
                {
                    _n_objectives = 3;
                }
                if (_n_chance < 9)
                {
                    _n_objectives = 4;
                }
                if (_n_chance < 3)
                {
                    _n_objectives = 5;
                }
                _n_objectives = 4;
                var _user_lvl = global.xp_level_now + 1;
                for (var j = 0; j < _n_objectives; j++)
                {
                    var _n_quest_type = array_length(_pool);
                    var _array_chance = [];
                    for (var k = 0; k < _n_quest_type; k++)
                    {
                        var _struct_chance = _pool[k].chance;
                        var _chance_type = variable_struct_get(_struct_chance, _faction);
                        repeat (_chance_type)
                        {
                            array_push(_array_chance, k);
                        }
                    }
                    var _already_generated = true;
                    var _sub_pool_entry, _array_sub_pool, _quest_type_selected;
                    while (_already_generated == true)
                    {
                        var _array_length = array_length(_array_chance);
                        var _pool_index = _array_chance[irandom(_array_length - 1)];
                        _quest_type_selected = _pool[_pool_index].type;
                        if (_quest_type_selected == "collect_marker")
                        {
                            var a = 0;
                        }
                        _array_sub_pool = _pool[_pool_index].pool;
                        var _array_chance2 = [];
                        for (var k = 0; k < array_length(_array_sub_pool); k++)
                        {
                            var _can_add = true;
                            if (_user_lvl < _array_sub_pool[k].lvl_min)
                            {
                                _can_add = false;
                            }
                            if (_quest_type_selected == "collect_marker" && !quest_is_complete(_array_sub_pool[k].quest_needed))
                            {
                                _can_add = false;
                            }
                            if (_can_add)
                            {
                                var _pool_index_chance_faction;
                                switch (_faction)
                                {
                                    case "Loners":
                                        _pool_index_chance_faction = _array_sub_pool[k].chance_loner;
                                        break;
                                    case "Scientists":
                                        _pool_index_chance_faction = _array_sub_pool[k].chance_scientst;
                                        break;
                                    case "Green Army":
                                        _pool_index_chance_faction = _array_sub_pool[k].chance_ga;
                                        break;
                                    case "Crimson Corporation":
                                        _pool_index_chance_faction = _array_sub_pool[k].chance_cc;
                                        break;
                                }
                                repeat (_pool_index_chance_faction)
                                {
                                    array_push(_array_chance2, k);
                                }
                            }
                        }
                        if (array_length(_array_chance2) > 0)
                        {
                            _sub_pool_entry = _array_chance2[irandom(array_length(_array_chance2) - 1)];
                            if (_array_sub_pool[_sub_pool_entry].choosen == false)
                            {
                                _array_sub_pool[_sub_pool_entry].choosen = true;
                                _already_generated = false;
                            }
                        }
                    }
                    var _struct_sub_pool = _array_sub_pool[_sub_pool_entry];
                    var _diff_default = irandom(3);
                    var _struct_objective;
                    switch (_quest_type_selected)
                    {
                        case "kill":
                            var _diff_multiplier = 1 + _diff_default;
                            var _amount_to_kill = round(_struct_sub_pool.amount * _diff_multiplier);
                            if (_struct_sub_pool.amount == 1)
                            {
                                _amount_to_kill = 1;
                            }
                            var _choosed_quest_map = -1;
                            _struct_objective = new quest_create_kill(_amount_to_kill, _struct_sub_pool.name, _choosed_quest_map, _struct_sub_pool.object);
                            _quest_reward_money += round(400 * _diff_multiplier);
                            _quest_reward_exp += round(10 * _diff_multiplier);
                            break;
                        case "collect":
                            var _item_to_collect = _struct_sub_pool.item;
                            var _diff_multiplier = 1 + (_diff_default / 2);
                            var _amount_to_collect = 1;
                            _struct_objective = new quest_create_collect(_item_to_collect, _amount_to_collect);
                            _quest_reward_money += round(item_get_value(_item_to_collect) * _amount_to_collect * difficulty_get("trade_sell_mult") * 0.75);
                            _quest_reward_exp += round(10 * _diff_multiplier);
                            break;
                        case "collect_marker":
                            _struct_objective = new quest_create_collect_marker(_struct_sub_pool.entry_id, _struct_sub_pool.item, 1, _struct_sub_pool.quest_needed, _struct_sub_pool.temp_prop, _struct_sub_pool.chest_object, _struct_sub_pool.marker_object, _struct_sub_pool.marker_radius, "");
                            _struct.text += "\n" + _struct_sub_pool.quest_description;
                            _quest_reward_money += round(1000 * (_user_lvl / 2) * random_range(0.75, 1.25));
                            _quest_reward_money = clamp(_quest_reward_money, 3000, 15000);
                            _quest_reward_exp += round(10 * random_range(1, 2));
                            break;
                        case "contract":
                            var _kill_obj_instance = _struct_sub_pool.object;
                            var _diff_multiplier = 1 + ((_diff_default * 2) / 10);
                            var _choosed_quest_map;
                            if (_struct_sub_pool.map == -1)
                            {
                                if (_user_lvl < 3)
                                {
                                    _choosed_quest_map = choose(UnknownEnum.Value_1, UnknownEnum.Value_2);
                                }
                                else
                                {
                                    _choosed_quest_map = choose(UnknownEnum.Value_1, UnknownEnum.Value_2, UnknownEnum.Value_3, UnknownEnum.Value_4, UnknownEnum.Value_6);
                                }
                            }
                            else
                            {
                                _choosed_quest_map = _struct_sub_pool.map;
                            }
                            _struct_objective = new quest_create_contract(_struct_sub_pool.object, _choosed_quest_map, _struct_sub_pool.name);
                            _quest_reward_money += round(400 * _diff_multiplier);
                            _quest_reward_exp += round(10 * _diff_multiplier);
                            break;
                        case "survive":
                            var _diff_multiplier = 1 + (_diff_default / 4);
                            var _choosed_quest_map = _struct_sub_pool.map;
                            var _amount_to_survive = round(_struct_sub_pool.amount * _diff_multiplier);
                            _struct_objective = new quest_create_survive_map(_choosed_quest_map, _amount_to_survive);
                            _quest_reward_money += round(250 * _diff_multiplier);
                            _quest_reward_exp += round(10 * _diff_multiplier);
                            break;
                        case "survive_exp":
                            var _diff_multiplier = (1 + (_diff_default / 3)) * random_range(0.8, 1.2);
                            var _choosed_quest_map;
                            if (_struct_sub_pool.map != -1)
                            {
                                _choosed_quest_map = daily_return_map();
                            }
                            else
                            {
                                _choosed_quest_map = -1;
                            }
                            var _exp_min = round(_struct_sub_pool.amount_var * _diff_multiplier) + irandom_range(-25, 25);
                            _struct_objective = new quest_create_survive_min_exp(_choosed_quest_map, _struct_sub_pool.amount, _exp_min);
                            _quest_reward_money += round(250 * _diff_multiplier);
                            _quest_reward_exp += round(12 * _diff_multiplier);
                            break;
                        case "survive_money":
                            var _diff_multiplier = (1 + (_diff_default / 3)) * random_range(0.8, 1.2);
                            var _choosed_quest_map;
                            if (_struct_sub_pool.map != -1)
                            {
                                _choosed_quest_map = daily_return_map();
                            }
                            else
                            {
                                _choosed_quest_map = -1;
                            }
                            var _roubles_min = round(_struct_sub_pool.amount_var * _diff_multiplier * random_range(0.9, 1.1));
                            _struct_objective = new quest_create_survive_min_money(_choosed_quest_map, _struct_sub_pool.amount, _roubles_min);
                            _quest_reward_money += round(250 * _diff_multiplier);
                            _quest_reward_exp += round(12 * _diff_multiplier);
                            break;
                        case "retrieve_analyzer":
                            var _diff_multiplier = 1 + _diff_default;
                            var _choosed_quest_map;
                            if (_struct_sub_pool.map == -1)
                            {
                                _choosed_quest_map = daily_return_map();
                            }
                            else
                            {
                                _choosed_quest_map = irandom(array_length(_struct_sub_pool.map) - 1);
                            }
                            var _chest_obj = -1;
                            var _item_id = _struct_sub_pool.item;
                            _chest_obj = _struct_sub_pool.chest_obj;
                            var _ano_id = _struct_sub_pool.ano_id;
                            _struct_objective = new quest_create_retrieve_analyzer(_item_id, _choosed_quest_map, _chest_obj, _ano_id, 10);
                            _quest_reward_money += round(1000 * _diff_multiplier);
                            _quest_reward_exp += round(12 * _diff_multiplier);
                            break;
                        case "place_analyzer":
                            var _diff_multiplier = 1 + _diff_default;
                            var _choosed_quest_map;
                            if (_struct_sub_pool.map == -1)
                            {
                                _choosed_quest_map = daily_return_map();
                            }
                            else
                            {
                                _choosed_quest_map = irandom(array_length(_struct_sub_pool.map) - 1);
                            }
                            var _ano_id = _struct_sub_pool.ano_id;
                            var _dis = (place_radius[_ano_id] * 16) / 2;
                            var _object_id = _struct_sub_pool.object_id;
                            _struct_objective = new quest_create_place_analyzer(_ano_id, _object_id, "scientific_analyzer", _dis, "Place", _choosed_quest_map, UnknownEnum.Value_73, UnknownEnum.Value_74, _object_id, 9);
                            var _struct_item = new class_quest_initial_item("scientific_analyzer", 1);
                            array_push(_quest_initial_item, _struct_item);
                            _quest_reward_money += round(1000 * _diff_multiplier);
                            _quest_reward_exp += round(12 * _diff_multiplier);
                            break;
                        case "retrieve_equipment":
                            var _diff_multiplier = 1 + _diff_default;
                            var _choosed_quest_map;
                            if (_struct_sub_pool.map == -1)
                            {
                                _choosed_quest_map = daily_return_map();
                            }
                            else
                            {
                                _choosed_quest_map = irandom(array_length(_struct_sub_pool.map) - 1);
                            }
                            var _chest_obj = _struct_sub_pool.chest_obj;
                            var _item_id = _struct_sub_pool.item_id;
                            var _faction_quest = _struct_sub_pool.faction;
                            _struct_objective = new quest_create_retrieve_equipment(_faction_quest, _item_id, _choosed_quest_map, _chest_obj, 10);
                            _quest_reward_money += round(1500 * _diff_multiplier);
                            _quest_reward_exp += round(12 * _diff_multiplier);
                            break;
                    }
                    _quest_reward_rep += (variable_struct_get(global.struct_faction, _faction).rep_daily + (_diff_default * 2));
                    array_push(_struct.objective, _struct_objective);
                }
                _quest_reward_rep += variable_struct_get(global.struct_faction, _faction).rep_daily;
                _struct.experience = _quest_reward_exp;
                _struct.money = _quest_reward_money;
                _struct.reputation = _quest_reward_rep;
                _struct.initial_item = _quest_initial_item;
                var _tier;
                switch (_n_objectives)
                {
                    case 1:
                        _tier = "tier_1";
                        break;
                    case 2:
                        _tier = "tier_1";
                        if (scr_chance(50))
                        {
                            _tier = "tier_2";
                        }
                        break;
                    case 3:
                        _tier = "tier_2";
                        if (scr_chance(30))
                        {
                            _tier = "tier_3";
                        }
                        break;
                    case 4:
                        _tier = "tier_2";
                        if (scr_chance(75))
                        {
                            _tier = "tier_3";
                        }
                        break;
                    case 5:
                        _tier = "tier_3";
                }
                var _array_tier = variable_struct_get(_quest_reward_pool, _tier);
                var _array_reward = [];
                for (var m = 0; m < array_length(_array_tier); m++)
                {
                    var _amount = _array_tier[m].chance;
                    repeat (_amount)
                    {
                        array_push(_array_reward, _array_tier[m].name);
                    }
                }
                var _reward_name = _array_reward[irandom(array_length(_array_reward) - 1)];
                _struct.reward = variable_struct_get(global.quest_reward_database, _reward_name).item;
                variable_struct_set(global.quest_database, _id, _struct);
                global.save_daily_quest[i] = _struct;
            }
        }
        quest_save();
        global.daily_quest_generated = true;
        db_open("general");
        db_write("quest", "daily generated", true);
        db_close();
    }
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_2,
    Value_3,
    Value_4,
    Value_6 = 6,
    Value_11 = 11,
    Value_12,
    Value_14 = 14,
    Value_15,
    Value_73 = 73,
    Value_74
}
