function surface_ensure(arg0, arg1, arg2)
{
    if (arg1 == -1)
    {
        arg1 = surface_get_width(application_surface);
    }
    if (arg2 == -1)
    {
        arg2 = surface_get_height(application_surface);
    }
    if (!surface_exists(arg0))
    {
        arg0 = surface_create(arg1, arg2);
    }
    return arg0;
}
