global.database_alias = undefined;
global.database_current = undefined;
global.database_data_root = undefined;
global.database_array = [];
global.database_struct = {};
global.database_cloud_conflict = 0;
global.database_was_previously_using_cloud_saves = undefined;
if (!extension_exists("Steamworks"))
{
    trace_error("Steamworks extension missing");
}
if (platform_target() == UnknownEnum.Value_0 && 1)
{
    trace_error("No store platform detected (Steam not running)");
}
__db_trace("Cloud available: ", platform_cloud_available());
var _q = platform_cloud_quota();
if (_q != undefined)
{
    __db_trace("cloud quota total = ", _q.total);
    __db_trace("cloud quota free = ", _q.free);
}
else
{
    __db_trace("quota: n/a");
}
global.database_savedata_root = platform_user_id() + "/";
trace("DB: Set savedata root as ", global.database_savedata_root);
directory_create(global.database_savedata_root);
directory_create(global.database_savedata_root + "backup");

enum UnknownEnum
{
    Value_0
}
