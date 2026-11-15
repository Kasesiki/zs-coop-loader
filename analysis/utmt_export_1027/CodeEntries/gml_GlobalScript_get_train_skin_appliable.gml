function get_train_skin_appliable(arg0)
{
    if (global.general_debug)
    {
        return true;
    }
    var _struct = global.train_skin_struct;
    if (is_struct(_struct))
    {
        switch (arg0)
        {
            case "train_skin_ga":
                return _struct.joined_ga;
                break;
            case "train_skin_cc":
                return _struct.joined_cc;
                break;
            case "train_skin_scientist":
                return _struct.scientist;
                break;
            case "train_skin_watcher":
                return _struct.watcher;
                break;
            case "train_skin_end_game":
                return _struct.end_game;
                break;
            case "train_skin_end_game_good":
                return _struct.end_game_good;
                break;
            default:
                return true;
                break;
        }
        return true;
    }
    return false;
}
