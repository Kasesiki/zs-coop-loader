if (is_struct(global.platform_backend) && variable_struct_exists(global.platform_backend, "on_async"))
{
    global.platform_backend.on_async(async_load);
}
