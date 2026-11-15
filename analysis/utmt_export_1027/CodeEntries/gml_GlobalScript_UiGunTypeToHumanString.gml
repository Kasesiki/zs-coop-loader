function UiGunTypeToHumanString(arg0)
{
    switch (arg0)
    {
        case "pistol":
            return language_get_string("weapon.type.pistol");
            break;
        case "smg":
            return language_get_string("weapon.type.smg");
            break;
        case "shotgun":
            return language_get_string("weapon.type.shotgun");
            break;
        case "rifle":
            return language_get_string("weapon.type.rifle");
            break;
        case "dmr":
            return language_get_string("weapon.type.dmr");
            break;
        case "sniper":
            return language_get_string("weapon.type.sniper");
            break;
        default:
            show_error("Didnt know what gun to display", false);
            break;
    }
}
