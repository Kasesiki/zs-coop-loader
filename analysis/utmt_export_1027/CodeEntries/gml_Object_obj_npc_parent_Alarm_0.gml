if (ai_commands_reload_complete(id))
{
    exit;
}
reloading = false;
shooting = false;
ammo_now = item_weapon_get_modded_magazine_size(arma_now, mod_container);
