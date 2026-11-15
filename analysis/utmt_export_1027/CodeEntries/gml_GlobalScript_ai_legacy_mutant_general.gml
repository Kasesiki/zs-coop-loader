function ai_legacy_mutant_general()
{
    var _player = player_get_local();
    var _lista_near_me = undefined;
    var _next_state = -1;
    if (state_finito == true)
    {
        human_tick = human_tick_max;
        path_timer = path_timer_reset;
    }
    NPCrecoil.IncreaseRadius(NPCrecoil.radius_decreasing_value);
    if (instance_exists(target))
    {
        NPCrecoil.NewCenter(target);
        NPCrecoil.MoveCrosshair();
        NPCrecoil.StuckCheck();
        var _dis = point_distance(last_seen_x, last_seen_y, target.x, target.y);
        if (reflexes_can_change == true)
        {
            var _dis_target = point_distance(x, y, target.x, target.y);
            var _dir_target = point_direction(x, y, target.x, target.y);
            var _dir_weapon = weapon_pointing_direction;
            if (_dis < reflex_min_distance_last_known)
            {
                if (reflexes_shot == true)
                {
                    riflessi_max = reflexes_minimum;
                    reflexes_shot = false;
                }
                if (!instance_line_of_sight(x, y, target))
                {
                    riflessi_max = reflexes_minimum;
                }
            }
            else
            {
                reflexes_can_change = false;
                reflexes_distance = lerp(reflexes_distance_min, reflexes_distance_max, _dis_target / 180);
                reflexes_distance = clamp(reflexes_distance, reflexes_distance_min, reflexes_distance_max);
                var _angle_diff = abs(angle_difference(_dir_target, _dir_weapon));
                reflexes_angle = lerp(reflexes_angle_min, reflexes_angle_max, _angle_diff / 180);
                reflexes_angle = clamp(reflexes_angle, reflexes_angle_min, reflexes_angle_max);
                riflessi_max = reflexes_minimum + reflexes_distance + reflexes_angle;
            }
        }
        riflessi = clamp(riflessi, 0, riflessi_max);
    }
    scr_bullet_near();
    human_tick++;
    if (human_tick >= human_tick_max)
    {
        human_tick_max = human_tick_max_ref + irandom_range(-1, 1);
        human_tick = 0;
        target = scr_find_target_for_human();
        scr_enemy_alert_others();
        var _list_action = ds_priority_create();
        var _new_just_shot = just_shot;
        var _no_target_or_ally = false;
        if (target == -4)
        {
            _no_target_or_ally = true;
        }
        if (target != -4)
        {
            if (instance_exists(target))
            {
                if (target_relation == UnknownEnum.Value_1)
                {
                    _no_target_or_ally = true;
                }
            }
        }
        var _my_faction = npc_get_faction(npc_id);
        if (_no_target_or_ally == true)
        {
            last_patrol_x = x;
            last_patrol_y = y;
            ds_priority_add(_list_action, UnknownEnum.Value_0, global.sub_ai_peso[UnknownEnum.Value_0]);
            if (scr_chance(1))
            {
                var pp = choose(UnknownEnum.Value_3, UnknownEnum.Value_4, UnknownEnum.Value_2);
                ds_priority_add(_list_action, pp, global.sub_ai_peso[pp]);
            }
            if (object_index == obj_scientist || object_index == obj_scientist_2)
            {
                var p = UnknownEnum.Value_1;
                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
            }
            if (object_index == obj_scientist_2)
            {
                var p = UnknownEnum.Value_5;
                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
            }
            if (object_index == obj_crimson_guardia_ingresso)
            {
                var p = UnknownEnum.Value_6;
                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
            }
            if (object_index == obj_crimson_guardia_ingresso || (variable_instance_exists(id, "leash_to_spawn") && leash_to_spawn))
            {
                if (point_distance(x, y, original_x, original_y) > 20)
                {
                    var p = UnknownEnum.Value_9;
                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                }
            }
            if (scr_chance(1))
            {
                if (faction == "Loners")
                {
                    if (!instance_exists(obj_arms_guitar))
                    {
                        if (instance_exists(obj_barrel_acciaio_fire))
                        {
                            var nearest = instance_nearest(x, y, obj_barrel_acciaio_fire);
                            if (point_distance(x, y, nearest.x, nearest.y) < 160)
                            {
                                move_point_x = nearest.x + irandom_range(-10, 10);
                                move_point_y = nearest.y;
                                var p = UnknownEnum.Value_7;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                    }
                }
            }
            var _my_id = id;
            var _alleato_morto_vicino = 0;
            var _ally_morto_x = 0;
            var _ally_morto_y = 0;
            var _id_chest_ally_dead = -4;
            if (alleato_morto_vicino != 2)
            {
                if (instance_exists(obj_chest_general))
                {
                    with (obj_chest_general)
                    {
                        if (chest_faction == _my_faction)
                        {
                            if (point_distance(x, y, _my_id.x, _my_id.y) < 260)
                            {
                                if (instance_line_of_sight(x, y, _my_id))
                                {
                                    _alleato_morto_vicino = 1;
                                    _ally_morto_x = x;
                                    _ally_morto_y = y;
                                    _id_chest_ally_dead = id;
                                }
                            }
                        }
                    }
                }
            }
            if (_alleato_morto_vicino == 1)
            {
                alleato_morto_vicino = 1;
                ally_morto_x = _ally_morto_x;
                ally_morto_y = _ally_morto_y;
                id_chest_ally_dead = _id_chest_ally_dead;
            }
            if (_alleato_morto_vicino == 1)
            {
                var p = UnknownEnum.Value_28;
                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
            }
            if (follow_path == true)
            {
                var p = UnknownEnum.Value_10;
                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
            }
        }
        var _grenade_close = false;
        var _grenade_close_same_faction = false;
        var _array_grenade_cover;
        if (instance_exists(obj_grenade_parent))
        {
            var __x = x;
            var __y = y;
            var _near = instance_nearest(x, y, obj_grenade_parent);
            if (grenade_close_id != _near)
            {
                grenade_can_cover = true;
                grenade_close_id = _near;
            }
            else
            {
                grenade_can_cover = false;
            }
            if (_near.faction == npc_get_faction(npc_id))
            {
                grenade_can_cover = true;
                _grenade_close_same_faction = true;
            }
            if (grenade_can_cover == true)
            {
                _array_grenade_cover = [0, 0];
                with (_near)
                {
                    if (point_distance(x, y, __x, __y) < radius_min_damage)
                    {
                        if (!collision_line(x, y, __x, __y, obj_solid, true, true))
                        {
                            _grenade_close = true;
                            _array_grenade_cover = scr_enemy_search_cover_grenade(_near);
                        }
                    }
                }
            }
        }
        var _grenade_flash = grenade_flash;
        var _array, _array_aim_moving, _array_cover, _array_change_cover, _grenade_id, _tx, _ty, _array_range_pos;
        if (target != -4)
        {
            _tx = target.x;
            _ty = target.y;
            var _line_of_sight = false;
            var _lo_vedo = false;
            target_visto = false;
            var _arma_dir_target = true;
            var _distanza_a_tiro = false;
            var _vedo_ultima_pos_vista_da_alleati = false;
            var _vedo_ultima_pos_vista_da_me = false;
            var _mouse_over_npc = false;
            var _counter_same_target = 0;
            var _counter_same_faction = 0;
            var _counter_first_time = 0;
            var _counter_array_action_ally, _counter_array_action_same_target;
            for (var i = 0; i < array_length(global.sub_ai_peso); i++)
            {
                _counter_array_action_ally[i] = 0;
                _counter_array_action_same_target[i] = 0;
            }
            var _counter_near_me = 0;
            _lista_near_me = ds_list_create();
            var _cover_pos_found = false;
            var _sono_vicino_al_target = false;
            var _distance_to_target_in_sight = 0;
            var _distance_to_target = 0;
            _grenade_id = "no_item";
            var _player_grenade_flashed_k = 1;
            var _distance_target = point_distance(x, y, _tx, _ty);
            var _player_inscreen = scr_target_player_and_inscreen();
            var _struct_range = npc_ai_effective_range(arma_now, _distance_target, 20, 5, 0);
            _array_range_pos = scr_enemy_search_range_position(_struct_range);
            precision_uneffective_range = 0;
            if (can_shoot_uneffective_range == true)
            {
                if (_distance_target <= _struct_range.ok_min)
                {
                    _struct_range.range_type = UnknownEnum.Value_0;
                    precision_uneffective_range = 45;
                }
                timer_shoot_uneffective_range += human_tick_max;
                if (timer_shoot_uneffective_range >= timer_shoot_uneffective_range_max)
                {
                    timer_shoot_uneffective_range = 0;
                }
            }
            var _eff_range_pos = [];
            var _same_faction_throw_grenade = false;
            var _same_faction_near_last_known = false;
            _distance_to_target = point_distance(x, y, target.x, target.y);
            if (instance_line_of_sight(x, y, target))
            {
                _line_of_sight = true;
                _distance_to_target_in_sight = point_distance(x, y, target.x, target.y);
                if (_distance_to_target_in_sight < 110)
                {
                    _sono_vicino_al_target = true;
                }
            }
            _lo_vedo = scr_enemy_target_inside_cone();
            if (!collision_line(x, y, last_seen_x, last_seen_y, obj_solid, true, true))
            {
                _vedo_ultima_pos_vista_da_alleati = true;
            }
            if (!collision_line(x, y, last_known_x, last_known_y, obj_solid, true, true))
            {
                _vedo_ultima_pos_vista_da_me = true;
            }
            with (obj_arms_grenade)
            {
                if (instance_exists(linked_id))
                {
                    var _npc_id = linked_id.npc_id;
                    var _faction = npc_get_faction(_npc_id);
                    if (_faction == _my_faction)
                    {
                        _same_faction_throw_grenade = true;
                    }
                }
            }
            if (_lo_vedo == true)
            {
                last_seen_x = _tx;
                last_seen_y = _ty;
                last_known_x = _tx;
                last_known_y = _ty;
                last_my_target_seen_x = x;
                last_my_target_seen_y = y;
                target_seen = true;
            }
            else
            {
                target_seen = false;
                reflexes_can_change = true;
            }
            var _dir = point_direction(x, y, _tx, _ty);
            var _angle_diff = angle_difference(weapon_pointing_direction, _dir);
            if (abs(_angle_diff) > angle_min_to_rotate)
            {
                _arma_dir_target = false;
                direction_to_aim = _dir;
                dir_to_aim_x = _tx;
                dir_to_aim_y = _ty;
            }
            var _devo_ricaricare = scr_calcola_chance_reload();
            if (instance_exists(obj_mouse) && point_distance(x, y, obj_mouse.x, obj_mouse.y) < 10)
            {
                _mouse_over_npc = true;
            }
            if (instance_exists(obj_hud_effect_flash))
            {
                _player_grenade_flashed_k = 3;
            }
            _my_faction = faction;
            var _my_target = target;
            var _my_id = id;
            var _my_x = x;
            var _my_y = y;
            with (obj_npc_parent)
            {
                if (id != _my_id)
                {
                    if (faction == _my_faction)
                    {
                        _counter_same_faction++;
                        if (human_state_now != -1)
                        {
                            _counter_array_action_ally[human_state_now] += 1;
                        }
                        if (point_distance(x, y, _my_x, _my_y) < 10)
                        {
                            _counter_near_me++;
                            ds_list_add(_lista_near_me, id);
                        }
                        if (target == _my_target)
                        {
                            _counter_same_target++;
                            if (human_state_now != -1)
                            {
                                _counter_array_action_same_target[human_state_now] += 1;
                            }
                        }
                    }
                }
            }
            if (human_state_now != UnknownEnum.Value_12 && human_state_now != UnknownEnum.Value_13)
            {
                _array_cover = scr_enemy_search_cover_position_2();
                if (_array_cover[0] != 0)
                {
                    var _path_cover = path_add();
                    path_clear_points(_path_cover);
                    if (mp_grid_path(npc_motion_grid(), _path_cover, x, y, _array_cover[0], _array_cover[1], true))
                    {
                        _cover_pos_found = true;
                    }
                    path_delete(_path_cover);
                }
            }
            if (instance_exists(target))
            {
                if (target_relation == UnknownEnum.Value_2)
                {
                    if (_lo_vedo == true)
                    {
                        alarm[5] = timer_searching_target_max;
                        target_visto_prima_volta = true;
                        target_visto = true;
                        if (_devo_ricaricare == false)
                        {
                            if ((_player_inscreen.inscreen || _player_inscreen.player == false) && (_struct_range.range_type == UnknownEnum.Value_0 || (_struct_range.range_type == UnknownEnum.Value_1 && _mouse_over_npc)))
                            {
                                var p = UnknownEnum.Value_11;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                last_known_x = target.x;
                                last_known_y = target.y;
                                if (_arma_dir_target == false)
                                {
                                    p = UnknownEnum.Value_21;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                            if (_array_range_pos[0] != 0)
                            {
                                if (_struct_range.range_type != UnknownEnum.Value_0 && !_mouse_over_npc)
                                {
                                    var p = UnknownEnum.Value_29;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                        }
                        if (_devo_ricaricare == true)
                        {
                            if (_cover_pos_found == true)
                            {
                                if (!_sono_vicino_al_target || have_to_reload == true)
                                {
                                    var p = UnknownEnum.Value_12;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                        }
                        if (_mouse_over_npc == true)
                        {
                            if (_cover_pos_found == true)
                            {
                                if (scr_chance(7))
                                {
                                    var p = UnknownEnum.Value_12;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                        }
                        if (scr_chance(1))
                        {
                            if (_cover_pos_found == true)
                            {
                                var p = UnknownEnum.Value_12;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                        if (_distance_target >= 100)
                        {
                            if (shooted_first_time == 1)
                            {
                                shooted_first_time = 2;
                                if (_cover_pos_found == true)
                                {
                                    var p = UnknownEnum.Value_13;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                        }
                    }
                    if (_lo_vedo == false)
                    {
                        if (_devo_ricaricare == true)
                        {
                            var p = UnknownEnum.Value_20;
                            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                        }
                        if (_devo_ricaricare == false)
                        {
                            if (_vedo_ultima_pos_vista_da_alleati == false)
                            {
                                _array = scr_enemy_search_shoot_position_2();
                                if (_array[0] != 0)
                                {
                                    var p = UnknownEnum.Value_15;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                                else if (target_visto_prima_volta == true)
                                {
                                    var p = UnknownEnum.Value_16;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                                else
                                {
                                }
                            }
                            if (_vedo_ultima_pos_vista_da_alleati == true)
                            {
                                if (target.faction != "Mutants")
                                {
                                    var _chance_tipo_weapon = 0;
                                    switch (tipo_arma_equipped)
                                    {
                                        case "pistol":
                                            _chance_tipo_weapon = 20;
                                            break;
                                        case "smg":
                                            _chance_tipo_weapon = 25;
                                            break;
                                        case "shotgun":
                                            _chance_tipo_weapon = 30;
                                            break;
                                        case "rifle":
                                            _chance_tipo_weapon = 15;
                                            break;
                                        case "dmr":
                                            _chance_tipo_weapon = 2;
                                            break;
                                        case "sniper":
                                            _chance_tipo_weapon = 0;
                                            break;
                                    }
                                    var _chance_counter_alleati_vicini = _counter_same_target;
                                    var _chance_totale = _chance_tipo_weapon * _chance_counter_alleati_vicini * _player_grenade_flashed_k;
                                    debug_chance_chase = _chance_totale;
                                    if (npc_id == "killa")
                                    {
                                        _chance_totale = 100;
                                    }
                                    if (npc_id == "horizon_contractor")
                                    {
                                        _chance_totale *= 3;
                                    }
                                    if (scr_chance(_chance_totale))
                                    {
                                        if (target_visto_prima_volta == true)
                                        {
                                            if (_counter_array_action_same_target[UnknownEnum.Value_16] < 2)
                                            {
                                                var p = UnknownEnum.Value_16;
                                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                            }
                                        }
                                    }
                                    else if (_counter_array_action_same_target[UnknownEnum.Value_24] < 2)
                                    {
                                        var p = UnknownEnum.Value_24;
                                        ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                    }
                                    if (instance_exists(obj_hud_effect_flash))
                                    {
                                        if (target == player_get_local())
                                        {
                                            var p = UnknownEnum.Value_16;
                                            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                        }
                                    }
                                }
                            }
                            if (_vedo_ultima_pos_vista_da_alleati == true)
                            {
                                if (point_distance(x, y, last_seen_x, last_seen_y) > 20)
                                {
                                    _array_aim_moving = scr_enemy_search_aim_moving(last_target_cover_x, last_target_cover_y);
                                    if (_array_aim_moving[0] != 0)
                                    {
                                        var p = UnknownEnum.Value_25;
                                        ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                    }
                                }
                            }
                            if (human_state_now == UnknownEnum.Value_16 || human_state_now == UnknownEnum.Value_23)
                            {
                                if (state_finito == true)
                                {
                                    var p = UnknownEnum.Value_19;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                            if (_vedo_ultima_pos_vista_da_alleati == true)
                            {
                                if (point_distance(x, y, last_seen_x, last_seen_y) < 10)
                                {
                                    var p = UnknownEnum.Value_19;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                            if (human_state_now == UnknownEnum.Value_18)
                            {
                                if (point_distance(_tx, _ty, last_seen_x, last_seen_y) > 48)
                                {
                                    if (point_distance(x, y, last_seen_x, last_seen_y) < 8)
                                    {
                                        var p = UnknownEnum.Value_19;
                                        ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                    }
                                }
                            }
                            if (chase_new_target_location == true)
                            {
                                var p = UnknownEnum.Value_18;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                            if (target_visto_prima_volta == false && chase_new_target_location == true)
                            {
                                var p = UnknownEnum.Value_18;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                            if (hear_target_shoot == true && _vedo_ultima_pos_vista_da_alleati == false)
                            {
                                hear_target_shoot = false;
                                if (scr_chance(85))
                                {
                                    var p = UnknownEnum.Value_23;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                            if (state_finito == true)
                            {
                                if (human_state_now == UnknownEnum.Value_28)
                                {
                                    var p = UnknownEnum.Value_19;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                        }
                    }
                    if (_line_of_sight == false)
                    {
                        alert_player = 0;
                        human_alert_barked = false;
                        riflessi = 0;
                        counter_target_cover++;
                        if (counter_target_cover >= counter_target_cover_max && counter_target_toggle == true)
                        {
                            last_target_cover_x = _tx;
                            last_target_cover_y = _ty;
                            counter_target_toggle = false;
                        }
                        if (human_state_now == UnknownEnum.Value_12)
                        {
                            if (scr_chance(12))
                            {
                                _array_change_cover = scr_enemy_change_cover_2();
                                if (_array_change_cover[0] != 0)
                                {
                                    var p = UnknownEnum.Value_14;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                        }
                    }
                    if (_line_of_sight == true)
                    {
                        counter_target_cover = 0;
                        counter_target_toggle = true;
                        if (_arma_dir_target == true && (_player_inscreen.inscreen || _player_inscreen.player == false) && (_struct_range.range_type == UnknownEnum.Value_0 || (_struct_range.range_type == UnknownEnum.Value_1 && _mouse_over_npc) || _distance_to_target_in_sight < 100))
                        {
                            var p = UnknownEnum.Value_11;
                            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            last_known_x = target.x;
                            last_known_y = target.y;
                        }
                        if (_array_range_pos[0] != 0)
                        {
                            if (_arma_dir_target == true && _struct_range.range_type != UnknownEnum.Value_0)
                            {
                                var p = UnknownEnum.Value_29;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                        if (_arma_dir_target == false && just_shot == 2 && _sono_vicino_al_target == false)
                        {
                            if (_cover_pos_found == true)
                            {
                                _new_just_shot = 0;
                                var p = UnknownEnum.Value_13;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                        if (_arma_dir_target == false && just_shot == 1)
                        {
                            _new_just_shot = 0;
                            var p = UnknownEnum.Value_21;
                            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                        }
                        if (_player_inscreen.player == true && _player_inscreen.inscreen == false)
                        {
                            var p = UnknownEnum.Value_21;
                            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                        }
                    }
                    if (must_take_cover == true)
                    {
                        must_take_cover = false;
                        if (human_state_before != UnknownEnum.Value_12 && human_state_now != UnknownEnum.Value_12)
                        {
                            if (_cover_pos_found == true)
                            {
                                var p = UnknownEnum.Value_12;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                    }
                    if (_counter_near_me >= 1)
                    {
                        var p = UnknownEnum.Value_26;
                        ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                    }
                    if (state_finito == true)
                    {
                        if (human_state_now == UnknownEnum.Value_13)
                        {
                            if (just_shot == 2)
                            {
                                _new_just_shot = 0;
                                var p = UnknownEnum.Value_27;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                    }
                    if (grenade_amount_thrown < grenade_amount_max)
                    {
                        if (_vedo_ultima_pos_vista_da_alleati == true && _line_of_sight == false && _same_faction_throw_grenade == false)
                        {
                            if (scr_chance(npc_get_prob_grenade_throw(npc_id)))
                            {
                                if (_distance_to_target < 160)
                                {
                                    var _array_grenade_id = [];
                                    repeat (npc_get_prob_grenade_f1(npc_id))
                                    {
                                        array_push(_array_grenade_id, "grenade_f1");
                                    }
                                    repeat (npc_get_prob_grenade_rgd(npc_id))
                                    {
                                        array_push(_array_grenade_id, "grenade_rgd5");
                                    }
                                    repeat (npc_get_prob_grenade_flash(npc_id))
                                    {
                                        array_push(_array_grenade_id, "grenade_flash");
                                    }
                                    if (array_length(_array_grenade_id) > 0)
                                    {
                                        _grenade_id = _array_grenade_id[irandom(array_length(_array_grenade_id) - 1)];
                                    }
                                    if (_grenade_id != "no_item")
                                    {
                                        var p = UnknownEnum.Value_32;
                                        ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                    }
                                }
                            }
                        }
                    }
                }
                if (target_relation == UnknownEnum.Value_0)
                {
                    if (_lo_vedo == true)
                    {
                        var p = UnknownEnum.Value_0;
                        ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                        if (_mouse_over_npc)
                        {
                            if (_arma_dir_target == false)
                            {
                                p = UnknownEnum.Value_21;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                            if (_arma_dir_target == true && item_exists(player_get_local().arma_now))
                            {
                                p = UnknownEnum.Value_37;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                        if (_distance_target <= neutral_distance_target)
                        {
                            if (counter_target_seen_neutral == 0)
                            {
                                if (_arma_dir_target == false)
                                {
                                    p = UnknownEnum.Value_21;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                                if (_arma_dir_target == true)
                                {
                                    p = UnknownEnum.Value_36;
                                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                                }
                            }
                        }
                    }
                    if (_lo_vedo == false)
                    {
                        var p = UnknownEnum.Value_0;
                        ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                    }
                }
                if (target_relation == UnknownEnum.Value_1)
                {
                }
                if (just_shot != 0)
                {
                    _new_just_shot = 0;
                    if (human_state_now != UnknownEnum.Value_11)
                    {
                        if (scr_chance(75))
                        {
                            if (_cover_pos_found == true && _distance_to_target_in_sight > 200)
                            {
                                var p = UnknownEnum.Value_13;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                        if (_lo_vedo == false && _line_of_sight == true)
                        {
                            if (_arma_dir_target == false)
                            {
                                var p = UnknownEnum.Value_21;
                                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                            }
                        }
                    }
                }
            }
            if (!instance_exists(target))
            {
                var p = UnknownEnum.Value_0;
                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
            }
        }
        if (_grenade_close == true && _grenade_close_same_faction == true)
        {
            if (_array_grenade_cover[0] != 0)
            {
                if (scr_chance(npc_get_prob_grenade_cover(npc_id)))
                {
                    var p = UnknownEnum.Value_30;
                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                }
            }
        }
        if (_grenade_flash == true)
        {
            var p = UnknownEnum.Value_31;
            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
        }
        if (global.is_emission_now == true)
        {
            if (!player_get_local_var("is_indoor", false))
            {
                if (global.state_emission_now > UnknownEnum.Value_16)
                {
                    var p = UnknownEnum.Value_33;
                    ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
                }
            }
        }
        if (have_to_reload == true)
        {
            var p = UnknownEnum.Value_20;
            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
        }
        if (human_state_now == -1)
        {
            human_state_now = UnknownEnum.Value_0;
            var p = UnknownEnum.Value_0;
            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
        }
        just_shot = _new_just_shot;
        if (npc_id == "green_army_quest_swamp" && target_relation == UnknownEnum.Value_2)
        {
            if (instance_exists(target) && distance_to_object(target) < 150)
            {
                ds_priority_destroy(_list_action);
                _list_action = ds_priority_create();
                var p = UnknownEnum.Value_11;
                ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
            }
        }
        if (force_moving_towards_player)
        {
            var p = UnknownEnum.Value_38;
            ds_priority_add(_list_action, p, global.sub_ai_peso[p]);
            force_moving_towards_player = false;
        }
        if (ds_priority_size(_list_action) > 0)
        {
            _next_state = ds_priority_find_max(_list_action);
            debug_next_state = _next_state;
            var _change_state = false;
            if (_next_state != human_state_now)
            {
                if (global.sub_ai_stop[human_state_now] == true || _next_state == UnknownEnum.Value_31)
                {
                    if (global.sub_ai_peso[human_state_now] < global.sub_ai_peso[_next_state])
                    {
                        _change_state = true;
                    }
                }
            }
            if (state_finito == true)
            {
                _change_state = true;
            }
            if (_change_state == true)
            {
                if (human_state_now != _next_state)
                {
                    human_state_before = human_state_now;
                }
                state_finito = true;
                human_state_now = _next_state;
                timer_last_state = current_time;
                draw_weapon = true;
            }
            if (state_finito == true)
            {
                state_finito = false;
                switch (_next_state)
                {
                    case UnknownEnum.Value_15:
                        path_end();
                        move_point_x = _array[0];
                        move_point_y = _array[1];
                        break;
                    case UnknownEnum.Value_25:
                        path_end();
                        move_point_x = _array_aim_moving[0];
                        move_point_y = _array_aim_moving[1];
                        break;
                    case UnknownEnum.Value_12:
                        move_point_x = _array_cover[0];
                        move_point_y = _array_cover[1];
                        if (scr_chance(50))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_1);
                        }
                        break;
                    case UnknownEnum.Value_14:
                        path_end();
                        move_point_x = _array_change_cover[0];
                        move_point_y = _array_change_cover[1];
                        break;
                    case UnknownEnum.Value_13:
                        move_point_x = _array_cover[0];
                        move_point_y = _array_cover[1];
                        if (scr_chance(80))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_10);
                        }
                        break;
                    case UnknownEnum.Value_30:
                        move_point_x = _array_grenade_cover[0];
                        move_point_y = _array_grenade_cover[1];
                        timer_cover_grenade = 0;
                        if (scr_chance(50))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_16);
                        }
                        break;
                    case UnknownEnum.Value_31:
                        path_end();
                        scr_draw_npc_text(id, UnknownEnum.Value_17);
                        break;
                    case UnknownEnum.Value_32:
                        grenade_amount_thrown++;
                        path_end();
                        scr_draw_npc_text(id, UnknownEnum.Value_18);
                        draw_weapon = false;
                        var _sprite = item_grenade_get_animation(_grenade_id);
                        var aa = instance_create_depth(x, y, 0, obj_arms_grenade);
                        aa.linked_id = id;
                        aa.image_xscale = image_xscale;
                        aa.sprite_index = _sprite;
                        aa.target_x = last_seen_x;
                        aa.target_y = last_seen_y;
                        aa.grenade_id = _grenade_id;
                        aa.faction = npc_get_faction(npc_id);
                        break;
                    case UnknownEnum.Value_16:
                        scr_enemy_choose_move_pos(last_seen_x, last_seen_y, 8);
                        if (scr_chance(50))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_8);
                        }
                        break;
                    case UnknownEnum.Value_17:
                        var _dir = point_direction(_tx, _ty, x, y);
                        var _dis = npc_get_alert_visual_distance(npc_id) / 2;
                        move_point_x = _tx + lengthdir_x(_dis, _dir);
                        move_point_y = _ty + lengthdir_y(_dis, _dir);
                        break;
                    case UnknownEnum.Value_26:
                        path_end();
                        if (ds_list_size(_lista_near_me) > 0)
                        {
                            var _id_near = ds_list_find_value(_lista_near_me, 0);
                            var _x_near = _id_near.x;
                            var _y_near = _id_near.y;
                            var _dir_near = point_direction(x, y, _x_near, _y_near);
                            hspd = -lengthdir_x(0.5, _dir_near);
                            vspd = -lengthdir_y(0.5, _dir_near);
                        }
                        break;
                    case UnknownEnum.Value_23:
                        scr_enemy_choose_move_pos(last_seen_x, last_seen_y, 8);
                        if (scr_chance(50))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_14);
                        }
                        break;
                    case UnknownEnum.Value_19:
                        path_end();
                        scr_enemy_choose_move_pos(last_seen_x + irandom_range(-7, 7), last_seen_y + irandom_range(-7, 7), 0);
                        if (scr_chance(75))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_9);
                        }
                        break;
                    case UnknownEnum.Value_27:
                        just_shot = 0;
                        if (scr_chance(75))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_13);
                        }
                        break;
                    case UnknownEnum.Value_18:
                        chase_new_target_location = false;
                        scr_enemy_choose_move_pos(last_seen_x, last_seen_y, 16);
                        if (scr_chance(50))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_11);
                        }
                        break;
                    case UnknownEnum.Value_20:
                        reloading = true;
                        alarm[0] = irandom(100) + 80;
                        path_end();
                        if (scr_chance(50))
                        {
                            scr_draw_npc_text(id, UnknownEnum.Value_6);
                        }
                        have_to_reload = false;
                        break;
                    case UnknownEnum.Value_0:
                        path_end();
                        visto_prima_volta = false;
                        break;
                    case UnknownEnum.Value_11:
                        path_end();
                        if (human_state_before == UnknownEnum.Value_19)
                        {
                            if (scr_chance(50))
                            {
                                scr_draw_npc_text(id, UnknownEnum.Value_12);
                            }
                        }
                        break;
                    case UnknownEnum.Value_21:
                        path_end();
                        if (human_state_before == UnknownEnum.Value_19)
                        {
                            if (scr_chance(75))
                            {
                                scr_draw_npc_text(id, UnknownEnum.Value_12);
                            }
                        }
                        break;
                    case UnknownEnum.Value_28:
                        scr_enemy_choose_move_pos(ally_morto_x, ally_morto_y, 8);
                        alleato_morto_vicino = 2;
                        scr_draw_npc_text(id, UnknownEnum.Value_15);
                        if (instance_exists(id_chest_ally_dead.id_of_the_killer))
                        {
                            target = id_chest_ally_dead.id_of_the_killer;
                        }
                        break;
                    case UnknownEnum.Value_33:
                        var _y = y;
                        var _pos_found = false;
                        move_point_x = x + 64;
                        move_point_y = y;
                        break;
                    case UnknownEnum.Value_29:
                        path_end();
                        move_point_x = _array_range_pos[0];
                        move_point_y = _array_range_pos[1];
                        break;
                    case UnknownEnum.Value_36:
                        path_end();
                        if (target == _player.id)
                        {
                            if (can_talk == true)
                            {
                                if (scr_chance(50))
                                {
                                    scr_npc_reset_talk(true, 180);
                                    scr_draw_npc_text(id, UnknownEnum.Value_3);
                                }
                            }
                        }
                        break;
                    case UnknownEnum.Value_37:
                        path_end();
                        if (target == _player.id)
                        {
                            if (can_talk == true)
                            {
                                if (scr_chance(101))
                                {
                                    scr_npc_reset_talk(true, 120);
                                    scr_draw_npc_text(id, UnknownEnum.Value_4);
                                }
                            }
                        }
                        break;
                    case UnknownEnum.Value_9:
                        scr_enemy_choose_move_pos(original_x, original_y, 0);
                        break;
                    case UnknownEnum.Value_10:
                        var _next_x = ds_list_find_value(lista_path_x, path_position_now + 1);
                        var _next_y = ds_list_find_value(lista_path_y, path_position_now + 1);
                        var _prev_x = ds_list_find_value(lista_path_x, path_position_now);
                        var _prev_y = ds_list_find_value(lista_path_y, path_position_now);
                        if (!is_undefined(_next_x) && !is_undefined(_next_y) && !is_undefined(_prev_x) && !is_undefined(_prev_y))
                        {
                            move_point_x = _next_x;
                            move_point_y = _next_y;
                            path_position_now++;
                        }
                        break;
                    case UnknownEnum.Value_3:
                        path_end();
                        scr_npc_create_animation(obj_arms_drink);
                        break;
                    case UnknownEnum.Value_4:
                        path_end();
                        scr_npc_create_animation(obj_arms_smoke);
                        break;
                    case UnknownEnum.Value_2:
                        path_end();
                        scr_npc_create_animation(obj_arms_eat);
                        break;
                    case UnknownEnum.Value_8:
                        path_end();
                        scr_npc_create_animation(obj_arms_guitar);
                        break;
                    case UnknownEnum.Value_5:
                        path_end();
                        scr_npc_create_animation(obj_arms_scientist_working);
                        break;
                    case UnknownEnum.Value_7:
                        path_end();
                        break;
                }
            }
        }
        ds_priority_destroy(_list_action);
    }
    switch (human_state_now)
    {
        case UnknownEnum.Value_0:
            path_end();
            scr_enemy_choose_idle_or_move();
            scr_collision();
            draw_weapon = true;
            if (is_in_hub())
            {
                target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
                if (x > xprevious)
                {
                    target_for_image_scale = x + 2;
                    weapon_pointing_direction = 300;
                }
                else if (x == xprevious)
                {
                }
                else if (x < xprevious)
                {
                    target_for_image_scale = x - 2;
                    weapon_pointing_direction = 240;
                }
            }
            else
            {
                scr_move_arma_random(2, weapon_pointing_angle, 1);
                if (object_index == obj_green_quest_swamp)
                {
                    if (instance_exists(obj_faro))
                    {
                        weapon_pointing_direction = point_direction(x, y, obj_faro.x, obj_faro.y - 150);
                    }
                }
                target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            }
            break;
        case UnknownEnum.Value_1:
            path_end();
            scr_collision();
            draw_weapon = true;
            scr_move_arma_random(2, weapon_pointing_angle, 1);
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            if (object_index == obj_scientist_2)
            {
                scr_npc_state_arms(obj_arms_scientist_working);
                if (scr_chance(0.5))
                {
                    scr_draw_npc_text(id, UnknownEnum.Value_117);
                }
            }
            break;
        case UnknownEnum.Value_11:
            var _termina_state = false;
            if (shoot_time == 0)
            {
                path_end();
                if (scr_chance(75))
                {
                    var _xx = irandom_range(-8, 8);
                    scr_enemy_choose_move_pos(x + _xx, y + _xx, 16);
                }
                else
                {
                    move_point_x = x;
                    move_point_y = y;
                }
            }
            if (instance_exists(target))
            {
                if (target_relation == UnknownEnum.Value_2)
                {
                    NPCrecoil.SetAimDirection();
                    weapon_pointing_direction = NPCrecoil.direction_aim;
                    scr_enemy_shoot();
                    shoot_time++;
                    if (shoot_time >= shoot_time_max)
                    {
                        shoot_time = 0;
                        if (scr_chance(30))
                        {
                            _termina_state = true;
                        }
                    }
                    if (target_visto == false)
                    {
                        _termina_state = true;
                    }
                }
                else
                {
                    _termina_state = true;
                }
            }
            else
            {
                _termina_state = true;
            }
            if (_termina_state == true)
            {
                can_shoot_uneffective_range = false;
                state_finito = true;
            }
            scr_enemy_path();
            break;
        case UnknownEnum.Value_20:
            if (reloading == false)
            {
                state_finito = true;
                if (image_xscale == 1)
                {
                    weapon_pointing_direction = 0;
                }
                else
                {
                    weapon_pointing_direction = 180;
                }
            }
            if (current_time > (timer_last_state + aim_still_timer))
            {
                reloading = false;
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_23:
            scr_enemy_path();
            if (point_distance(x, y, move_point_x, move_point_y) < 8)
            {
                state_finito = true;
            }
            scr_npc_exit_path_when_standing_still();
            break;
        case UnknownEnum.Value_16:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 8)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_17:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 8)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_26:
            scr_collision();
            var _my_faction = faction;
            var _my_target = target;
            var _my_id = id;
            var _my_x = x;
            var _my_y = y;
            var _exit_state = true;
            with (obj_npc_parent)
            {
                if (id != _my_id)
                {
                    if (faction == _my_faction)
                    {
                        if (point_distance(x, y, _my_x, _my_y) < 10)
                        {
                            _exit_state = false;
                        }
                    }
                }
            }
            if (_exit_state == true)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_18:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 8)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_12:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 4)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_13:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 4)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_14:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 4)
            {
                state_finito = true;
            }
            weapon_pointing_direction = point_direction(x, y, last_seen_x, last_seen_y);
            break;
        case UnknownEnum.Value_30:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            timer_cover_grenade++;
            if (point_distance(x, y, move_point_x, move_point_y) < 4 || timer_cover_grenade >= 120)
            {
                state_finito = true;
                timer_cover_grenade = 0;
            }
            break;
        case UnknownEnum.Value_31:
            path_end();
            grenade_flash_timer++;
            if (grenade_flash_timer >= grenade_flash_timer_max)
            {
                grenade_flash_timer = 0;
                grenade_flash = false;
                state_finito = true;
            }
            flash_weapon_dir_timer++;
            if (flash_weapon_dir_timer > flash_weapon_dir_timer_max)
            {
                flash_weapon_dir = irandom(360);
                flash_weapon_dir_timer = 0;
            }
            var _angle_diff = angle_difference(flash_weapon_dir, weapon_pointing_direction);
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            if (abs(_angle_diff) > angle_min_to_rotate)
            {
                if (_angle_diff > 0)
                {
                    weapon_pointing_direction += angle_increase_for_target;
                }
                if (_angle_diff < 0)
                {
                    weapon_pointing_direction -= angle_increase_for_target;
                }
            }
            shoot_time++;
            if (shoot_time >= 15)
            {
                riflessi_max = 15;
                scr_enemy_shoot();
                shoot_time = 0;
            }
            break;
        case UnknownEnum.Value_32:
            scr_npc_arms_animation(obj_arms_drink);
            break;
        case UnknownEnum.Value_15:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 8)
            {
                state_finito = true;
            }
            if (current_time >= (timer_last_state + timer_last_state_max))
            {
                state_finito = true;
            }
            weapon_pointing_direction = point_direction(x, y, last_seen_x, last_seen_y);
            break;
        case UnknownEnum.Value_25:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 8)
            {
                state_finito = true;
            }
            weapon_pointing_direction = point_direction(x, y, last_seen_x, last_seen_y);
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            break;
        case UnknownEnum.Value_24:
            path_end();
            weapon_pointing_direction = point_direction(x, y, last_seen_x, last_seen_y);
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            if (current_time >= (timer_last_state + aim_still_timer))
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_19:
            if (scr_chance(npc_get_prob_idle(npc_id)))
            {
                hspd = 0;
                vspd = 0;
            }
            if (scr_chance(npc_get_prob_move(npc_id) * 6))
            {
                var dir = irandom(360);
                hspd = lengthdir_x(npc_get_spd_not_alerted(npc_id), dir);
                vspd = lengthdir_y(npc_get_spd_not_alerted(npc_id), dir);
            }
            scr_collision();
            scr_move_arma_random(4, weapon_pointing_angle, 3);
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            break;
        case UnknownEnum.Value_27:
            path_end();
            scr_move_arma_random(4, weapon_pointing_angle, 3);
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            break;
        case UnknownEnum.Value_21:
            var _dir = point_direction(x, y, dir_to_aim_x, dir_to_aim_y);
            var _angle_diff = angle_difference(direction_to_aim, weapon_pointing_direction);
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            if (abs(_angle_diff) > (angle_min_to_rotate * 1.5))
            {
                if (_angle_diff > 0)
                {
                    weapon_pointing_direction += angle_increase_for_target;
                }
                if (_angle_diff < 0)
                {
                    weapon_pointing_direction -= angle_increase_for_target;
                }
            }
            else
            {
                weapon_pointing_direction = direction_to_aim;
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_29:
            riflessi++;
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            timer_recheck_eff_range++;
            if (point_distance(x, y, move_point_x, move_point_y) < 4)
            {
                state_finito = true;
                timer_recheck_eff_range = 0;
            }
            if (timer_recheck_eff_range >= timer_recheck_eff_range_max)
            {
                state_finito = true;
                timer_recheck_eff_range = 0;
                can_shoot_uneffective_range = true;
            }
            weapon_pointing_direction = point_direction(x, y, last_seen_x, last_seen_y);
            break;
        case UnknownEnum.Value_38:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 8)
            {
                state_finito = true;
            }
            if (target_seen == true)
            {
                state_finito = true;
            }
            if (instance_exists(target))
            {
                move_point_x = target.x;
                move_point_y = target.y;
            }
            break;
        case UnknownEnum.Value_9:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 4)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_28:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 4)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_33:
            scr_enemy_path();
            scr_npc_exit_path_when_standing_still();
            if (point_distance(x, y, move_point_x, move_point_y) < 4)
            {
                state_finito = true;
            }
            break;
        case UnknownEnum.Value_36:
            if (instance_exists(target))
            {
                var _x = target.x;
                var _y = target.y;
                var _dir = point_direction(x, y, _x, _y);
                weapon_pointing_direction = _dir;
                target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
                if (!instance_line_of_sight(x, y, target))
                {
                    state_finito = true;
                }
                if (point_distance(x, y, _x, _y) >= (neutral_distance_target * 1.5))
                {
                    state_finito = true;
                }
                timer_see_neutral++;
                if (timer_see_neutral >= timer_see_neutral_max)
                {
                    state_finito = true;
                    counter_target_seen_neutral = 1;
                    timer_see_neutral = 0;
                }
            }
            break;
        case UnknownEnum.Value_37:
            if (instance_exists(target))
            {
                var _x = target.x;
                var _y = target.y;
                var _dir = point_direction(x, y, _x, _y);
                weapon_pointing_direction = _dir;
                target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
                if (!instance_line_of_sight(x, y, target))
                {
                    state_finito = true;
                }
                if (instance_exists(obj_mouse) && point_distance(x, y, obj_mouse.x, obj_mouse.y) > 10)
                {
                    state_finito = true;
                }
            }
            break;
        case UnknownEnum.Value_10:
            scr_enemy_path();
            scr_move_arma_random(2, 1, 1);
            if (point_distance(x, y, move_point_x, move_point_y) < 2)
            {
                state_finito = true;
                for (var i = 0; i < array_length(global.list_n_id); i++)
                {
                    if (global.list_n_id[i] == id)
                    {
                        global.list_n_x[i] = x;
                        global.list_n_y[i] = y;
                    }
                }
            }
            break;
        case UnknownEnum.Value_3:
            scr_npc_arms_animation(obj_arms_drink);
            break;
        case UnknownEnum.Value_4:
            scr_npc_arms_animation(obj_arms_smoke);
            break;
        case UnknownEnum.Value_2:
            scr_npc_arms_animation(obj_arms_eat);
            break;
        case UnknownEnum.Value_5:
            scr_npc_arms_animation(obj_arms_scientist_working);
            break;
        case UnknownEnum.Value_8:
            scr_npc_arms_animation(obj_arms_guitar);
            break;
        case UnknownEnum.Value_7:
            scr_enemy_path();
            if (point_distance(x, y, move_point_x, move_point_y) < 8)
            {
                path_end();
                if (!instance_exists(obj_arms_guitar))
                {
                    scr_npc_create_animation(obj_arms_guitar);
                    human_state_now = UnknownEnum.Value_8;
                }
                else
                {
                    human_state_now = UnknownEnum.Value_0;
                }
            }
            break;
        case UnknownEnum.Value_6:
            path_end();
            scr_move_arma_random(2, weapon_pointing_angle, 1);
            var _active = scr_check_quest_in_corso(UnknownEnum.Value_69);
            if (global.quest_unique_done[UnknownEnum.Value_70] == true)
            {
                if (player_exists_local() && player_distance_local(x, y) < 48)
                {
                    if (can_talk == true)
                    {
                        scr_draw_npc_text(id, UnknownEnum.Value_164);
                        can_talk = false;
                    }
                }
            }
            target_for_image_scale = x + lengthdir_x(2, weapon_pointing_direction);
            break;
    }
    if (!is_undefined(_lista_near_me))
    {
        ds_list_destroy(_lista_near_me);
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
    Value_12,
    Value_13,
    Value_14,
    Value_15,
    Value_16,
    Value_17,
    Value_18,
    Value_19,
    Value_20,
    Value_21,
    Value_23 = 23,
    Value_24,
    Value_25,
    Value_26,
    Value_27,
    Value_28,
    Value_29,
    Value_30,
    Value_31,
    Value_32,
    Value_33,
    Value_36 = 36,
    Value_37,
    Value_38,
    Value_69 = 69,
    Value_70,
    Value_117 = 117,
    Value_164 = 164
}
