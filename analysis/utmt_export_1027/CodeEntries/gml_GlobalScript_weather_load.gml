function weather_load()
{
    var _default_weather = weather_empty_struct();
    db_open("general");
    global.weather = SnapDeepCopy(db_read("weather", "data", _default_weather));
    if (!variable_struct_exists(global.weather, "kit_built"))
    {
        global.weather.kit_built = false;
    }
    db_close();
    var _npp_weather = undefined;
    for (var i = 0; i < array_length(global.weather.map); i++)
    {
        if (global.weather.map[i].map_id == "npp")
        {
            _npp_weather = global.weather.map[i];
            break;
        }
    }
    if (is_undefined(_npp_weather))
    {
        for (var i = 0; i < array_length(_default_weather.map); i++)
        {
            if (_default_weather.map[i].map_id == "npp")
            {
                _npp_weather = _default_weather.map[i];
                array_push(global.weather.map, _npp_weather);
                break;
            }
        }
    }
    _npp_weather.weather_type = array_create(24, "purple_rain_3");
    _npp_weather.snow_accumulation = 0;
}
