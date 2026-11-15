function zs2_exit_asset_pack(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
{
    return 
    {
        background: arg0,
        wishlist_normal: arg1,
        wishlist_normal_size: [0.5 * sprite_get_width(arg1), 0.5 * sprite_get_height(arg1)],
        wishlist_pressed: arg2,
        wishlist_pressed_size: [0.5 * sprite_get_width(arg2), 0.5 * sprite_get_height(arg2)],
        wishlist_center: arg5,
        exit_normal: arg3,
        exit_normal_size: [0.5 * sprite_get_width(arg3), 0.5 * sprite_get_height(arg3)],
        exit_pressed: arg4,
        exit_pressed_size: [0.5 * sprite_get_width(arg4), 0.5 * sprite_get_height(arg4)],
        exit_center: arg6
    };
}

function zs2_exit_language()
{
    var _language = "english";
    if (variable_global_exists("language_current") && is_string(global.language_current))
    {
        _language = string_lower(global.language_current);
    }
    switch (_language)
    {
        case "french":
        case "german":
        case "italian":
        case "pt_br":
        case "japanese":
        case "korean":
        case "polish":
        case "russian":
        case "chinese_simplified":
        case "spanish_es":
        case "spanish_latam":
        case "turkish":
            return _language;
        default:
            return "english";
    }
}

function zs2_exit_texture_group()
{
    return "tg_zs2_exit_" + zs2_exit_language();
}

function zs2_exit_egs_texture_group()
{
    return "tg_zs2_exit_egs_" + zs2_exit_language();
}

function __zs2_exit_texture_group_load_one(arg0)
{
    if (texturegroup_get_status(arg0) == 0)
    {
        if (texturegroup_load(arg0) < 0)
        {
            trace_error("Failed to load ZS2 exit texture group: ", arg0);
        }
    }
}

function zs2_exit_texture_group_load()
{
    __zs2_exit_texture_group_load_one(zs2_exit_texture_group());
    if (platform_target() != UnknownEnum.Value_1)
    {
        __zs2_exit_texture_group_load_one(zs2_exit_egs_texture_group());
    }
}

function zs2_exit_egs_background()
{
    switch (zs2_exit_language())
    {
        case "french":
            return spr_zs2_exit_egs_french;
        case "german":
            return spr_zs2_exit_egs_german;
        case "italian":
            return spr_zs2_exit_egs_italian;
        case "pt_br":
            return spr_zs2_exit_egs_pt_br;
        case "japanese":
            return spr_zs2_exit_egs_japanese;
        case "korean":
            return spr_zs2_exit_egs_korean;
        case "polish":
            return spr_zs2_exit_egs_polish;
        case "russian":
            return spr_zs2_exit_egs_russian;
        case "chinese_simplified":
            return spr_zs2_exit_egs_chinese_simplified;
        case "spanish_es":
            return spr_zs2_exit_egs_spanish_es;
        case "spanish_latam":
            return spr_zs2_exit_egs_spanish_latam;
        case "turkish":
            return spr_zs2_exit_egs_turkish;
        default:
            return spr_zs2_exit_egs_english;
    }
}

function zs2_exit_assets()
{
    var _pack = zs2_exit_assets_steam();
    if (platform_target() != UnknownEnum.Value_1)
    {
        _pack.background = zs2_exit_egs_background();
    }
    return _pack;
}

function zs2_exit_assets_steam()
{
    var _language = zs2_exit_language();
    switch (_language)
    {
        case "french":
            return zs2_exit_asset_pack(FRENCH_Background___NO_BUTTONS, FRENCH_wishlist_now____NOT_PRESSED, FRENCH_wishlist_now____PRESSED, FRENCH_EXIT___NOT_PRESSED, FRENCH_EXIT___PRESSED, [520.25, 876.75], [1790, 999]);
        case "german":
            return zs2_exit_asset_pack(GERMAN_Background___NO_BUTTONS, GERMAN_wishlist_now____NOT_PRESSED, GERMAN_wishlist_now____PRESSED, GERMAN_EXIT___NOT_PRESSED, GERMAN_EXIT___PRESSED, [520.25, 871.75], [1789, 997]);
        case "italian":
            return zs2_exit_asset_pack(ITALIAN_Background___NO_BUTTONS, ITALIAN_wishlist_now____NOT_PRESSED, ITALIAN_wishlist_now____PRESSED, ITALIAN_EXIT___NOT_PRESSED, ITALIAN_EXIT___PRESSED, [520.25, 871.75], [1789, 997]);
        case "pt_br":
            return zs2_exit_asset_pack(BRAZILIAN_PORTUGUESE_Background___NO_BUTTONS, BRAZILIAN_PORTUGUESE_wishlist_now____NOT_PRESSED, BRAZILIAN_PORTUGUESE_wishlist_now____PRESSED, BRAZILIAN_PORTUGUESE_exit____NOT__PRESSED, BRAZILIAN_PORTUGUESE_exit____PRESSED, [520.25, 871.75], [1789.75, 997]);
        case "japanese":
            return zs2_exit_asset_pack(JAPANESE_Background___NO_BUTTONS, JAPANESE_wishlist_now____NOT_PRESSED, JAPANESE_wishlist_now____PRESSED, JAPANESE_EXIT___NOT_PRESSED, JAPANESE_EXIT___PRESSED, [520.25, 876.75], [1786.5, 993.5]);
        case "korean":
            return zs2_exit_asset_pack(KOREAN_Background___NO_BUTTONS, KOREAN_wishlist_now____NOT_PRESSED, KOREAN_wishlist_now____PRESSED, KOREAN_EXIT___NOT_PRESSED, KOREAN_EXIT___PRESSED, [520.25, 876.75], [1788.75, 993.5]);
        case "polish":
            return zs2_exit_asset_pack(FRENCH_Background___NO_BUTTONS2991, POLISH_wishlist_now____NOT_PRESSED, POLISH_wishlist_now____PRESSED, POLISH_EXIT___NOT_PRESSED, POLISH_EXIT___PRESSED, [520.25, 851.75], [1788.5, 996.25]);
        case "russian":
            return zs2_exit_asset_pack(RUSSIAN_Background___NO_BUTTONS, RUSSIAN_WISHLIST_NOW___NOT_PRESSED, RUSSIAN_WISHLIST_NOW___PRESSED, RUSSIAN_EXIT___NOT_PRESSED, RUSSIAN_EXIT___PRESSED, [545.25, 894.5], [1790.25, 1000.75]);
        case "chinese_simplified":
            return zs2_exit_asset_pack(SIMPLIFIED_CHINESE_Background___NO_BUTTONS, SIMPLIFIED_CHINESE_wishlist_now____NOT_PRESSED, SIMPLIFIED_CHINESE_wishlist_now____PRESSED, SIMPLIFIED_CHINESE_EXIT___NOT_PRESSED, SIMPLIFIED_CHINESE_EXIT___PRESSED, [520.25, 876.75], [1787.25, 993.25]);
        case "spanish_es":
            return zs2_exit_asset_pack(SPANISH_Background___NO_BUTTONS, SPANISH_wishlist_now____NOT_PRESSED, SPANISH_wishlist_now____PRESSED, SPANISH_exit____NOT__PRESSED, SPANISH_exit____PRESSED, [520.25, 871.75], [1789.75, 997]);
        case "spanish_latam":
            return zs2_exit_asset_pack(SPANISH_LATAM_Background___NO_BUTTONS, SPANISH_LATAM_wishlist_now____NOT_PRESSED, SPANISH_LATAM_wishlist_now____PRESSED, SPANISH_LATAM_exit____NOT__PRESSED, SPANISH_LATAM_exit____PRESSED, [520.25, 871.75], [1789.75, 997]);
        case "turkish":
            return zs2_exit_asset_pack(TURKISH_Background___NO_BUTTONS, TURKISH_wishlist_now___NOT_PRESSED, TURKISH_wishlist_now___PRESSED, TURKISH_EXIT___NOT_PRESSED, TURKISH_EXIT___PRESSED, [520.25, 871.75], [1789.25, 1004.75]);
        default:
            return zs2_exit_asset_pack(Background___NO_BUTTONS, Wishlist_now___NOT_PRESSED, Wishlist_now___PRESSED, Exit___NOT_PRESSED, Exit___PRESSED, [520.25, 871.75], [1789.75, 997]);
    }
}

function zs2_exit_request()
{
    if (__uiGlobal().__defaultOnion.LayerExists("zs2 exit prompt"))
    {
        exit;
    }
    if (db_read_ext("shared settings", "ZERO Sievert 2 exit prompt", "shown", false))
    {
        if (review_prompt_should_show())
        {
            review_prompt_fire();
            exit;
        }
        db_quit_with_flush();
        exit;
    }
    db_open("shared settings");
    db_write("ZERO Sievert 2 exit prompt", "shown", true);
    db_close();
    zs2_exit_texture_group_load();
    __uiGlobal().__defaultOnion.LayerAddTop("ZS_vanilla/ui/modal_zs2_exit.ui", "zs2 exit prompt");
}

function zs2_exit_action(arg0)
{
    switch (arg0)
    {
        case "trailer":
            url_open("https://www.youtube.com/watch?v=Xry4iRHJKdc");
            break;
        case "wishlist":
            var _u = platform_store_url_zs2();
            if (_u != "")
            {
                url_open(_u);
            }
            db_quit_with_flush();
            break;
        case "never":
        case "later":
            db_quit_with_flush();
            break;
    }
}

enum UnknownEnum
{
    Value_1 = 1
}
