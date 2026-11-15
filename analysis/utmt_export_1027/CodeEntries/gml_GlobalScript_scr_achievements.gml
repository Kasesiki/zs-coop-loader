global.achievement_qa_tracking = {};

function steam_stat_increment(arg0)
{
    platform_stat_increment(arg0, 1);
}

function steam_set_achievement_flagged(arg0)
{
    if (platform_achievements_available())
    {
        platform_achievement_unlock(arg0);
    }
    else
    {
        if (!variable_struct_exists(global.achievement_qa_tracking, arg0))
        {
            variable_struct_set(global.achievement_qa_tracking, arg0, true);
            scr_draw_text_with_box("Achievement: " + arg0);
        }
        exit;
    }
}

function welcometozerosievert_achievement()
{
    var _name = "welcometozerosievert";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function blacksmith_achievement()
{
    var _name = "blacksmith";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function aliensexist_achievement()
{
    var _name = "aliensexist";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function heavypockets_achievement()
{
    if (global.player_money >= 1000000)
    {
        var _name = "heavypockets";
        if (!platform_achievement_is_unlocked(_name))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function rockbottom_achievement()
{
    if (global.player_money <= 10)
    {
        var _name = "rockbottom";
        if (!platform_achievement_is_unlocked(_name))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function lostinthewoods_achievement()
{
    var _name = "lostinthewoods";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function canispeaktothemanager_achievement()
{
    var _name = "canispeaktothemanager";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function campereliminated_achievement()
{
    var _name = "campereliminated";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function abigwin_achievement()
{
    var _name = "abigwin";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function milkrun_achievement()
{
    var _name = "milkrun";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (inventory_get_total_of_item("milk") >= 44)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function nothingbutjunk_achievement()
{
    var _name = "nothingbutjunk";
    if (!platform_achievement_is_unlocked(_name))
    {
        with (player_get_local())
        {
            if (shell_shot_count >= 1000)
            {
                steam_set_achievement_flagged(_name);
            }
        }
    }
}

function allthatforadropofblood_achievement()
{
    var _name = "allthatforadropofblood";
    if (!platform_achievement_is_unlocked(_name))
    {
        with (player_get_local())
        {
            if (hp <= 10)
            {
                steam_set_achievement_flagged(_name);
            }
        }
    }
}

function eyeforaneye_achievement()
{
    var _name = "eyeforaneye";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("igor_revenge"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function welcometozakovcity_achievement()
{
    var _name = "welcometozakovcity";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (uiGetData().map_selected == UnknownEnum.Value_8)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function downwiththesickness_achievement()
{
    var _name = "downwiththesickness";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("radiation_effect"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function maxedoutpistol_achievement()
{
    var _name = "maxedoutpistol";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (skills.get_value_dec("mastery_pistol") == 1)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function maxedoutsmg_achievement()
{
    var _name = "maxedoutsmg";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (skills.get_value_dec("mastery_smg") == 1)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function maxedoutshotgun_achievement()
{
    var _name = "maxedoutshotgun";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (skills.get_value_dec("mastery_shotgun") == 1)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function maxedoutrifle_achievement()
{
    var _name = "maxedoutrifle";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (skills.get_value_dec("mastery_rifle") == 1)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function maxedoutdmr_achievement()
{
    var _name = "maxedoutdmr";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (skills.get_value_dec("mastery_dmr") == 1)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function maxedoutsniper_achievement()
{
    var _name = "maxedoutsniper";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (skills.get_value_dec("mastery_sniper") == 1)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function ironman_achievement()
{
    var _name = "ironman";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (difficulty_get("hardcore_perma_death") == true)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function tutorial_achievement()
{
    var _name = "tutorialcompleted";
    var _a = platform_achievement_is_unlocked(_name);
    if (!platform_achievement_is_unlocked(_name))
    {
        if (instance_exists(obj_map_generator) && obj_map_generator.area == UnknownEnum.Value_10)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function bestfriends_achievement()
{
    var _name = "bestfriends";
    if (!platform_achievement_is_unlocked(_name))
    {
        var _faction_maxed = false;
        var _factions = ["Loners", "Green Army", "Crimson Corporation", "Scientists"];
        for (var i = 0; i < array_length(_factions); i++)
        {
            if (faction_get_rep("Player", _factions[i]) == 1000)
            {
                _faction_maxed = true;
                break;
            }
        }
        if (_faction_maxed)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function labassisntant_achievement()
{
    var _name = "labassisntant";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (faction_get_rep("Player", "Scientists") >= 450)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function lastorders_achievement()
{
    var _name = "lastorders";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("the_crystal") && quest_is_complete("underground_extraction") && quest_is_complete("stilysh_one_part_2") && quest_is_complete("machinery") && quest_is_complete("bowel_problems") && quest_is_complete("the_guide"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function unlocknpp_achievement()
{
    var _name = "unlocknpp";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function signalfound_achievement()
{
    var _name = "signalfound";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("battery_camera"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function corporateclimber_achievement()
{
    var _name = "corporateclimber";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("the_war_cc"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function noteasybeinggreen_achievement()
{
    var _name = "noteasybeinggreen";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("the_war_ga"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function intotheunknown_achievement()
{
    var _name = "intotheunknown";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("revelations"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function waycleared_achievement()
{
    var _name = "waycleared";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function madedevilcry_achievement()
{
    var _name = "madedevilcry";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function expandyourhorizons_achievement()
{
    var _name = "expandyourhorizons";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function mybloodyvalentine_achievement()
{
    var _name = "mybloodyvalentine";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function beataroundthebush_achievement()
{
    var _name = "beataroundthebush";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function hailtotherotking_achievement()
{
    var _name = "hailtotherotkingbaby";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function pirateradio_achievement()
{
    var _name = "pirateradio";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function crystalclear_achievement()
{
    var _name = "crystalclear";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function crystalclear_achievement2()
{
    var _name = "crystalclear";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("outer_deity"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function innerdeity_achievement()
{
    var _name = "innerdeity";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function innerdeity_achievement2()
{
    var _name = "innerdeity";
    if (!platform_achievement_is_unlocked(_name))
    {
        if (quest_is_complete("last_quest"))
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function shadowofzakov_achievement()
{
    var _name = "shadowofzakov";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function deaddrop_achievement()
{
    var _name = "deaddrop";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function onemanstrash_achievement()
{
    var _name = "onemanstrash";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function hoardersparadise_achievement()
{
    var _name = "hoardersparadise";
    if (!platform_achievement_is_unlocked(_name))
    {
        steam_set_achievement_flagged(_name);
    }
}

function fashionshow_achievement()
{
    var _name = "fashionshow";
    if (!platform_achievement_is_unlocked(_name))
    {
        var _required = {};
        _required.armor_rotking = false;
        _required.armor_killa = false;
        _required.armor_ghillie = false;
        _required.armor_horizon_boss = false;
        _required.armor_boss_city = false;
        _required.armor_arman = false;
        _required.armor_orel = false;
        _required.armor_lazar = false;
        _required.armor_watcher_devil = false;
        var _found = 0;
        var _total = 9;
        db_open(inventory_target_db());
        var _loot_array = db_read("Inventory", "items", []);
        db_close();
        var _i = 0;
        repeat (array_length(_loot_array))
        {
            var _item_id = _loot_array[_i].item;
            if (variable_struct_exists(_required, _item_id) && variable_struct_get(_required, _item_id) == false)
            {
                variable_struct_set(_required, _item_id, true);
                _found++;
                if (_found >= _total)
                {
                    break;
                }
            }
            _i++;
        }
        if (_found < _total && global.storage_slot_unlocked > 0)
        {
            var _c = 0;
            repeat (global.storage_slot_unlocked)
            {
                var _stash_array = db_read_ext("chest", "chest_" + string(_c), "items", []);
                var _j = 0;
                repeat (array_length(_stash_array))
                {
                    var _item_id = _stash_array[_j].item;
                    if (variable_struct_exists(_required, _item_id) && variable_struct_get(_required, _item_id) == false)
                    {
                        variable_struct_set(_required, _item_id, true);
                        _found++;
                        if (_found >= _total)
                        {
                            break;
                        }
                    }
                    _j++;
                }
                if (_found >= _total)
                {
                    break;
                }
                _c++;
            }
        }
        if (_found >= _total)
        {
            steam_set_achievement_flagged(_name);
        }
    }
}

function skininthegame_achievement()
{
    var _name = "skininthegame";
    if (!platform_achievement_is_unlocked(_name))
    {
        var _train_skin_struct = global.train_skin_struct;
        if (is_struct(_train_skin_struct))
        {
            if (_train_skin_struct.end_game == true || _train_skin_struct.end_game_good == true || _train_skin_struct.joined_ga == true || _train_skin_struct.joined_cc == true || _train_skin_struct.watcher == true || _train_skin_struct.scientist == true)
            {
                steam_set_achievement_flagged(_name);
            }
        }
    }
}

function railwaycollector_achievement()
{
    var _name = "railwaycollector";
    if (!platform_achievement_is_unlocked(_name))
    {
        var _train_skin_struct = global.train_skin_struct;
        if (is_struct(_train_skin_struct))
        {
            if (_train_skin_struct.end_game == true && _train_skin_struct.end_game_good == true && _train_skin_struct.joined_ga == true && _train_skin_struct.joined_cc == true && _train_skin_struct.watcher == true && _train_skin_struct.scientist == true)
            {
                steam_set_achievement_flagged(_name);
            }
        }
    }
}

function achievement_step()
{
    if (obj_controller.achievement_update_timer++ >= obj_controller.achievement_update_rate)
    {
        obj_controller.achievement_update_timer = 0;
        train_skin_sync();
        crystalclear_achievement2();
        innerdeity_achievement2();
        heavypockets_achievement();
        rockbottom_achievement();
        milkrun_achievement();
        eyeforaneye_achievement();
        lastorders_achievement();
        downwiththesickness_achievement();
        bestfriends_achievement();
        signalfound_achievement();
        corporateclimber_achievement();
        noteasybeinggreen_achievement();
        intotheunknown_achievement();
        labassisntant_achievement();
        fashionshow_achievement();
    }
}

enum UnknownEnum
{
    Value_8 = 8,
    Value_10 = 10
}
