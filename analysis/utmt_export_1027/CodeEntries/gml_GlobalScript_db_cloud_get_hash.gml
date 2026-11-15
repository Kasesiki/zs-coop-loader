function db_cloud_get_hash(arg0)
{
    __db_trace("Checking hash for \"", arg0, "\" in Steam Cloud");
    if (!db_cloud_enabled())
    {
        __db_trace("Cloud not enabled");
        return undefined;
    }
    var _exists = platform_cloud_exists(arg0);
    if (!_exists.exists)
    {
        __db_trace("File does not exist, returning <undefined>");
        return undefined;
    }
    var _read = platform_cloud_read(arg0);
    if (!_read.done)
    {
        __db_trace("hash unavailable: request not immediate");
        return undefined;
    }
    var _hash = md5_string_utf8(_read.text);
    return _hash;
}
