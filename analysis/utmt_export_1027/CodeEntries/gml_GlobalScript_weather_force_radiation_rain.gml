function weather_force_radiation_rain()
{
    if (is_in_hub())
    {
        exit;
    }
    var _weather_previous = weather_get_weather_now();
    var _map_enum = obj_map_generator.area;
    var _map_macro = from_map_enum_to_map_macro(_map_enum);
    for (var i = 0; i < array_length(global.weather.map); i++)
    {
        if (global.weather.map[i].map_id == _map_macro && _map_macro != "npp")
        {
            global.weather.map[i].weather_type[0] = "rad_rain_3";
            global.weather.map[i].weather_type[1] = "rad_rain_3";
            global.weather.map[i].weather_type[2] = "rad_rain_2";
            global.weather.map[i].weather_type[3] = "rad_rain_1";
        }
    }
    var _weather_new = weather_get_weather_now();
    if (_weather_new != _weather_previous)
    {
        mods_perform_event("weather_changed", [_weather_previous, _weather_new]);
    }
    weather_transition(500, false);
}
