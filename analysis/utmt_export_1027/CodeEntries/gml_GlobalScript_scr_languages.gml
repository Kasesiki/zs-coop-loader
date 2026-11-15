global.language_current = "english";
global.language_data_current = {};
global.language_tracking = {};
global.language_missing_traced = {};
global.language_alias = {};
global.language_alias_loaded = false;
global.language_data_english = {};
global.language_data_english_loaded = false;
global.language_font_offset = 
{
    x: 0,
    y: 0
};
global.language_font_offset_array = [
{
    x: 0,
    y: 0
}];
global.language_font_scale = [8, 12, 16, 24, 32, 64];
global.language_fonts = array_create(array_length(global.language_font_scale), undefined);
global.language_fonts_references = 
{
    font_credits_32px: font_credits_32px,
    font_credits_64px: font_credits_64px,
    font_credits_big: font_credits_big,
    font_credits_small: font_credits_small,
    font_main_menu: font_main_menu,
    font_minuscolo_16px: font_minuscolo_16px,
    font_munro_12px: font_munro_12px,
    font_munro_24: font_munro_24,
    font_munro_32px: font_munro_32px,
    font_munro_64px: font_munro_64px,
    font_munro_8px: font_munro_8px,
    font_name_speaker: font_name_speaker,
    font_quest: font_quest,
    font_quest_32px: font_quest_32px
};

function language_set_new_language(arg0)
{
    var _language_previous = global.language_current;
    global.language_current = arg0;
    settings_set("language", arg0);
    settings_set_write_to_disk(true);
    var _file = struct_get_from_hash(variable_struct_get(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current), variable_get_hash("csv"));
    if (file_exists(_file))
    {
        global.language_data_current = {};
        __language_load_csv_into(_file, global.language_data_current);
        language_load_alias();
        language_load_english_master();
    }
    else
    {
        show_error("Missing translation: " + _file, false);
        global.language_current = _language_previous;
    }
    font_add_enable_aa(false);
    _file = struct_get_from_hash(variable_struct_get(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current), variable_get_hash("font"));
    var _font_sizes = struct_get_from_hash(variable_struct_get(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current), variable_get_hash("font_sizes"));
    if (file_exists(_file))
    {
        for (var i = 0; i < array_length(global.language_font_scale); i++)
        {
            if (!is_undefined(global.language_fonts[i]) && font_exists(global.language_fonts[i]))
            {
                font_delete(global.language_fonts[i]);
            }
            global.language_fonts[i] = font_add(struct_get_from_hash(variable_struct_get(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current), variable_get_hash("font")), _font_sizes[i], false, false, 32, 9467);
        }
        global.language_font_offset_array = struct_get_from_hash(variable_struct_get(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current), variable_get_hash("font_offset"));
    }
    else
    {
        show_error("Missing font: " + _file, false);
    }
}

function draw_set_font_language(arg0)
{
    draw_set_font(arg0);
    for (var i = 0; i < array_length(global.language_font_offset_array); i++)
    {
        if (arg0 == global.language_fonts[i])
        {
            global.language_font_offset = global.language_font_offset_array[i];
            exit;
        }
    }
}

function language_resolve_font(arg0)
{
    var _font_value = arg0;
    if (is_string(_font_value))
    {
        _font_value = variable_struct_get(global.language_fonts_references, _font_value);
        if (is_undefined(_font_value))
        {
            show_error("Missing font! " + arg0, false);
        }
    }
    switch (_font_value)
    {
        case font_quest:
        case font_munro_8px:
        case font_credits_small:
            return global.language_fonts[UnknownEnum.Value_0];
            break;
        case font_munro_12px:
        case font_main_menu:
            return global.language_fonts[UnknownEnum.Value_2];
            break;
        case font_minuscolo_16px:
        case font_name_speaker:
        case font_credits_big:
            return global.language_fonts[UnknownEnum.Value_1];
            break;
        case font_munro_24:
        case font_death_screen:
            return global.language_fonts[UnknownEnum.Value_3];
            break;
        case font_credits_32px:
        case font_munro_32px:
        case font_quest_32px:
            return global.language_fonts[UnknownEnum.Value_4];
            break;
        case font_credits_64px:
        case font_munro_64px:
            return global.language_fonts[UnknownEnum.Value_5];
            break;
    }
}

function __language_key_number(arg0)
{
    if (!is_string(arg0))
    {
        arg0 = string(arg0);
    }
    if (string_length(arg0) < 5)
    {
        return undefined;
    }
    var _us = string_pos("_", arg0);
    if (_us == 0)
    {
        if (string_length(arg0) != 5)
        {
            return undefined;
        }
    }
    else if (_us != 6)
    {
        return undefined;
    }
    for (var i = 1; i <= 5; i++)
    {
        var _c = ord(string_char_at(arg0, i));
        if (_c < 48 || _c > 57)
        {
            return undefined;
        }
    }
    return string_copy(arg0, 1, 5);
}

function __language_csv_col(arg0, arg1)
{
    var _w = ds_grid_width(arg0);
    for (var _x = 0; _x < _w; _x++)
    {
        if (ds_grid_get(arg0, _x, 0) == arg1)
        {
            return _x;
        }
    }
    return undefined;
}

function __language_load_csv_into(arg0, arg1)
{
    var _grid = load_csv(arg0);
    if (ds_grid_width(_grid) > 0 && ds_grid_height(_grid) > 0)
    {
        var _h0 = ds_grid_get(_grid, 0, 0);
        if (is_string(_h0) && string_char_at(_h0, 1) == "﻿")
        {
            ds_grid_set(_grid, 0, 0, string_delete(_h0, 1, 1));
        }
    }
    var _ci_num = __language_csv_col(_grid, "Number");
    var _ci_desc = __language_csv_col(_grid, "Descriptor");
    var _ci_text = __language_csv_col(_grid, "Text");
    if (is_undefined(_ci_num) || is_undefined(_ci_desc) || is_undefined(_ci_text))
    {
        ds_grid_destroy(_grid);
        show_error("Language CSV missing Number/Descriptor/Text header: " + arg0, true);
        exit;
    }
    var _rows = ds_grid_height(_grid);
    for (var _y = 0; _y < _rows; _y++)
    {
        if (!is_undefined(__language_key_number(ds_grid_get(_grid, _ci_num, _y))))
        {
            variable_struct_set(arg1, ds_grid_get(_grid, _ci_desc, _y), string_replace_all(ds_grid_get(_grid, _ci_text, _y), "\\n", "\n"));
        }
    }
    ds_grid_destroy(_grid);
}

function __language_is_fused(arg0)
{
    if (!is_string(arg0))
    {
        return false;
    }
    if (string_length(arg0) <= 6)
    {
        return false;
    }
    if (string_char_at(arg0, 6) != "_")
    {
        return false;
    }
    for (var i = 1; i <= 5; i++)
    {
        var _c = ord(string_char_at(arg0, i));
        if (_c < 48 || _c > 57)
        {
            return false;
        }
    }
    return true;
}

function __language_value(arg0)
{
    var _v = variable_struct_get(global.language_data_current, arg0);
    if (is_undefined(_v))
    {
        return undefined;
    }
    if (_v == "")
    {
        var _e = variable_struct_get(global.language_data_english, arg0);
        if (!is_undefined(_e) && _e != "")
        {
            return _e;
        }
    }
    return _v;
}

function language_load_alias()
{
    if (global.language_alias_loaded)
    {
        exit;
    }
    var _file = "ZS_vanilla/gamedata/alias_map.csv";
    if (!file_exists(_file))
    {
        show_error("Missing alias map: " + _file, false);
        exit;
    }
    var _grid = load_csv(_file);
    var _rows = ds_grid_height(_grid);
    for (var _y = 0; _y < _rows; _y++)
    {
        if (!is_undefined(variable_struct_get(global.language_data_current, ds_grid_get(_grid, 1, _y))))
        {
            variable_struct_set(global.language_alias, string_replace_all(ds_grid_get(_grid, 0, _y), "\\n", "\n"), ds_grid_get(_grid, 1, _y));
        }
    }
    ds_grid_destroy(_grid);
    global.language_alias_loaded = true;
}

function language_load_english_master()
{
    if (global.language_data_english_loaded)
    {
        exit;
    }
    var _en = struct_get_from_hash(struct_get_from_hash(global.language_data, variable_get_hash("languages")), variable_get_hash("english"));
    if (is_undefined(_en))
    {
        exit;
    }
    var _file = struct_get_from_hash(_en, variable_get_hash("csv"));
    if (!file_exists(_file))
    {
        show_error("Missing english master: " + _file, false);
        exit;
    }
    __language_load_csv_into(_file, global.language_data_english);
    global.language_data_english_loaded = true;
}

function language_get_string(arg0 = "")
{
    if (string_replace_all(arg0, " ", "") == "")
    {
        return arg0;
    }
    if (__language_is_fused(arg0))
    {
        var _rf = __language_value(string_copy(arg0, 7, string_length(arg0) - 6));
        return is_undefined(_rf) ? arg0 : _rf;
    }
    var _rb = __language_value(arg0);
    if (!is_undefined(_rb))
    {
        return _rb;
    }
    var _d = variable_struct_get(global.language_alias, arg0);
    if (is_undefined(_d))
    {
        _d = variable_struct_get(global.language_alias, string_make_first_uppercase(arg0));
        if (is_undefined(_d))
        {
            _d = variable_struct_get(global.language_alias, string_make_first_lowercase(arg0));
        }
    }
    if (!is_undefined(_d))
    {
        var _rv = __language_value(_d);
        if (!is_undefined(_rv))
        {
            return _rv;
        }
    }
    var _em = variable_struct_get(global.language_data_english, arg0);
    if (!is_undefined(_em) && _em != "")
    {
        if (!variable_struct_exists(global.language_missing_traced, arg0))
        {
            variable_struct_set(global.language_missing_traced, arg0, true);
            trace("Loc: descriptor \"", arg0, "\" absent from language_data_current for language \"", global.language_current, "\"; rendering English master text");
        }
        return _em;
    }
    if (true && !variable_struct_exists(global.language_tracking, arg0))
    {
        variable_struct_set(global.language_tracking, arg0, true);
        return arg0;
    }
    return arg0;
}

function language_get_string_iterative(arg0 = "")
{
    if (string_replace_all(arg0, " ", "") == "")
    {
        return arg0;
    }
    var _string = arg0;
    var _words = [];
    var _translation = language_get_string(arg0);
    if (_translation != arg0)
    {
        return _translation;
    }
    _string = string_replace_all(_string, "  ", " ");
    var _length = string_length(_string);
    for (var i = 1; i < _length; i++)
    {
        if (string_char_at(_string, i) == " ")
        {
            array_push(_words, language_get_string(string_copy(_string, 1, i - 1)));
            _string = string_delete(_string, 1, i);
            _length = string_length(_string);
            i = 1;
        }
    }
    array_push(_words, language_get_string(_string));
    _string = "";
    for (var i = 0; i < array_length(_words); i++)
    {
        _string = _string + _words[i] + " ";
    }
    if (array_length(_words) > 0)
    {
        _string = string_delete(_string, string_length(_string), 1);
    }
    return _string;
}

function language_get_string_multiline(arg0 = "")
{
    if (string_replace_all(arg0, " ", "") == "")
    {
        return arg0;
    }
    var _translation = language_get_string(arg0);
    if (_translation != arg0)
    {
        return _translation;
    }
    var _result = "";
    var _line = "";
    var _length = string_length(arg0);
    for (var i = 1; i <= _length; i++)
    {
        var _char = string_char_at(arg0, i);
        if (_char == "\n")
        {
            _result += (language_get_string(_line) + "\n");
            _line = "";
        }
        else
        {
            _line += _char;
        }
    }
    _result += language_get_string(_line);
    return _result;
}

function language_get_font(arg0 = 1)
{
    return global.language_fonts[arg0];
}

function language_set_font(arg0 = 1)
{
    return draw_set_font_language(global.language_fonts[arg0]);
}

function language_string_width(arg0 = "", arg1 = 1)
{
    var _font = draw_get_font();
    draw_set_font_language(language_get_font(arg1));
    var _width = string_width(arg0);
    draw_set_font_language(_font);
    return _width;
}

function language_string_height(arg0 = "", arg1 = 1)
{
    var _font = draw_get_font();
    draw_set_font_language(language_get_font(arg1));
    var _width = string_height(arg0);
    draw_set_font_language(_font);
    return _width;
}

function __epic_locale_to_language_code(arg0)
{
    var _t = string_replace_all(string_lower(arg0), "_", "-");
    switch (_t)
    {
        case "en-us":
        case "en-gb":
        case "en":
            return "english";
        case "de":
            return "german";
        case "fr":
            return "french";
        case "it":
            return "italian";
        case "ko":
            return "korean";
        case "es-es":
        case "es":
            return "spanish_es";
        case "es-mx":
            return "spanish_latam";
        case "zh-hans":
        case "zh":
            return "chinese_simplified";
        case "ru":
            return "russian";
        case "ja":
            return "japanese";
        case "pl":
            return "polish";
        case "tr":
            return "turkish";
        case "pt-br":
        case "pt":
            return "pt_br";
        default:
            return "";
    }
}

function language_apply_epic_initial_locale()
{
    if (platform_target() != UnknownEnum.Value_2)
    {
        exit;
    }
    if (!variable_global_exists("platform_epic_args"))
    {
        exit;
    }
    var _tag = global.platform_epic_args.epiclocale;
    if (_tag == "")
    {
        exit;
    }
    if (db_read_ext("shared settings", "settings", "language", undefined) != undefined)
    {
        exit;
    }
    var _code = __epic_locale_to_language_code(_tag);
    if (_code == "")
    {
        exit;
    }
    settings_set("language", _code);
    __platform_log("[platform] epic: initial language from -epiclocale=" + _tag + " -> " + _code);
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_4,
    Value_5
}
