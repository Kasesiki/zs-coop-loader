global.languages_last_compiled = "unknown";

function gamedata_build_languages()
{
    language_apply_epic_initial_locale();
    global.language_current = string_lower(settings_get("language"));
    if (global.languages_last_compiled == global.language_current && variable_struct_names_count(global.language_data_current) > 0)
    {
        exit;
    }
    if (!variable_struct_exists(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current))
    {
        global.language_current = "english";
    }
    var _file = struct_get_from_hash(variable_struct_get(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current), variable_get_hash("csv"));
    if (file_exists(_file))
    {
        global.language_data_current = {};
        __language_load_csv_into(_file, global.language_data_current);
        language_load_alias();
        language_load_english_master();
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
            global.language_fonts[i] = font_add(struct_get_from_hash(variable_struct_get(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current), variable_get_hash("font")), _font_sizes[i], false, false, 32, 255);
        }
        global.language_font_offset_array = struct_get_from_hash(variable_struct_get(struct_get_from_hash(global.language_data, variable_get_hash("languages")), global.language_current), variable_get_hash("font_offset"));
    }
    else
    {
        show_error("Missing font: " + _file, true);
    }
    global.languages_last_compiled = global.language_current;
}
