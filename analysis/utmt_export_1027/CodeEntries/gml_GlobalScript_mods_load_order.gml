function mods_load_order_read(arg0 = "mods_order.json")
{
    if (!file_exists(arg0))
    {
        return [];
    }
    try
    {
        var _buffer = buffer_load(arg0);
        var _json_text = buffer_read(_buffer, buffer_text);
        buffer_delete(_buffer);
        var _saved_names = json_parse(_json_text);
        if (!is_array(_saved_names))
        {
            return [];
        }
        var _clean_names = [];
        for (var _index = 0; _index < array_length(_saved_names); _index++)
        {
            if (is_string(_saved_names[_index]))
            {
                array_push(_clean_names, _saved_names[_index]);
            }
        }
        return _clean_names;
    }
    catch (_error)
    {
        show_debug_message("Mods: could not read \"" + arg0 + "\", using the default order. " + string(_error));
        return [];
    }
}

function mods_load_order_save(arg0, arg1 = "mods_order.json")
{
    var _buffer = buffer_create(1, buffer_grow, 1);
    buffer_write(_buffer, buffer_text, json_stringify(arg0));
    buffer_save(_buffer, arg1);
    buffer_delete(_buffer);
}

function mods_load_order_sorted(arg0, arg1)
{
    var _sorted_names = [];
    for (var _index = 0; _index < array_length(arg1); _index++)
    {
        var _saved_name = arg1[_index];
        if (array_contains(arg0, _saved_name) && !array_contains(_sorted_names, _saved_name))
        {
            array_push(_sorted_names, _saved_name);
        }
    }
    for (var _index = 0; _index < array_length(arg0); _index++)
    {
        if (!array_contains(_sorted_names, arg0[_index]))
        {
            array_push(_sorted_names, arg0[_index]);
        }
    }
    return _sorted_names;
}

function mods_load_order_dispatch_list(arg0, arg1)
{
    var _dispatch_names = [];
    for (var _index = 0; _index < array_length(arg0); _index++)
    {
        if (!array_contains(_dispatch_names, arg0[_index]))
        {
            array_push(_dispatch_names, arg0[_index]);
        }
    }
    for (var _index = 0; _index < array_length(arg1); _index++)
    {
        if (!array_contains(_dispatch_names, arg1[_index]))
        {
            array_push(_dispatch_names, arg1[_index]);
        }
    }
    return _dispatch_names;
}

function mods_load_order_apply(arg0 = "mods_order.json")
{
    global.Mods_Order = mods_load_order_sorted(global.Mods_Order, mods_load_order_read(arg0));
    global.Mods_Data_Array = mods_load_order_dispatch_list(global.Mods_Order, global.Mods_Data_Array);
}

function mods_load_order_position(arg0)
{
    return array_get_index(global.Mods_Order, arg0);
}

function mods_load_order_move(arg0, arg1, arg2 = "mods_order.json")
{
    var _old_position = mods_load_order_position(arg0);
    if (_old_position < 0)
    {
        return false;
    }
    arg1 = clamp(arg1, 0, array_length(global.Mods_Order) - 1);
    if (arg1 == _old_position)
    {
        return false;
    }
    array_delete(global.Mods_Order, _old_position, 1);
    array_insert(global.Mods_Order, arg1, arg0);
    mods_load_order_save(global.Mods_Order, arg2);
    return true;
}
