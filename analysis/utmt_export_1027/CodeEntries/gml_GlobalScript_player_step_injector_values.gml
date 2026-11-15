function player_step_injector_values()
{
    global.injector_factor[UnknownEnum.Value_0] = 0;
    global.injector_factor[UnknownEnum.Value_1] = 0;
    global.injector_factor[UnknownEnum.Value_2] = 0;
    global.injector_factor[UnknownEnum.Value_3] = 0;
    global.injector_factor[UnknownEnum.Value_4] = 0;
    global.injector_factor[UnknownEnum.Value_5] = 0;
    global.injector_factor[UnknownEnum.Value_6] = 0;
    global.injector_factor[UnknownEnum.Value_7] = 0;
    global.injector_factor[UnknownEnum.Value_8] = 0;
    global.injector_factor[UnknownEnum.Value_9] = 0;
    global.injector_factor[UnknownEnum.Value_10] = 0;
    global.injector_factor[UnknownEnum.Value_11] = 0;
    global.injector_factor[UnknownEnum.Value_12] = 0;
    var i = array_length(global.injector_active) - 1;
    while (i >= 0)
    {
        var _inj_id = global.injector_active[i].id;
        global.injector_active[i].timer--;
        if (global.injector_active[i].timer <= 0)
        {
            array_delete(global.injector_active, i, 1);
            with (player_get_local())
            {
                hp_max -= item_inj_get_max_hp(_inj_id);
                bleed_immune -= item_inj_get_bleed_immune(_inj_id);
                stamina_max -= item_inj_get_stamina_max(_inj_id);
                radiation_defence -= item_inj_get_rad_def(_inj_id);
            }
        }
        else
        {
            global.injector_factor[UnknownEnum.Value_0] += item_inj_get_max_hp(_inj_id);
            global.injector_factor[UnknownEnum.Value_1] += item_inj_get_hp_regen(_inj_id);
            global.injector_factor[UnknownEnum.Value_2] += item_inj_get_bleed_rec(_inj_id);
            global.injector_factor[UnknownEnum.Value_3] += item_inj_get_bleed_immune(_inj_id);
            global.injector_factor[UnknownEnum.Value_4] += item_inj_get_stamina_max(_inj_id);
            global.injector_factor[UnknownEnum.Value_5] += item_inj_get_stamina_regen(_inj_id);
            global.injector_factor[UnknownEnum.Value_6] += item_inj_get_max_weight(_inj_id);
            global.injector_factor[UnknownEnum.Value_7] += item_inj_get_rad_regen(_inj_id);
            global.injector_factor[UnknownEnum.Value_8] += item_inj_get_rad_def(_inj_id);
            global.injector_factor[UnknownEnum.Value_9] += item_inj_get_hunger(_inj_id);
            global.injector_factor[UnknownEnum.Value_10] += item_inj_get_hunger_regen(_inj_id);
            global.injector_factor[UnknownEnum.Value_11] += item_inj_get_thirst(_inj_id);
            global.injector_factor[UnknownEnum.Value_12] += item_inj_get_thirst_regen(_inj_id);
        }
        i--;
    }
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_4,
    Value_5,
    Value_6,
    Value_7,
    Value_8,
    Value_9,
    Value_10,
    Value_11,
    Value_12
}
