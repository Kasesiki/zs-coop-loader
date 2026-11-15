function ai_bt_action(arg0, arg1, arg2, arg3)
{
    return 
    {
        kind: UnknownEnum.Value_0,
        name: arg0,
        enter: arg1,
        update: arg2,
        exit: arg3
    };
}

function ai_bt_condition(arg0, arg1)
{
    return 
    {
        kind: UnknownEnum.Value_1,
        name: arg0,
        check: arg1
    };
}

function ai_bt_sequence(arg0, arg1)
{
    return 
    {
        kind: UnknownEnum.Value_2,
        name: arg0,
        children: arg1
    };
}

function ai_bt_selector(arg0, arg1)
{
    return 
    {
        kind: UnknownEnum.Value_3,
        name: arg0,
        children: arg1
    };
}

function ai_bt_branch(arg0, arg1)
{
    return 
    {
        check: arg0,
        child: arg1
    };
}

function ai_bt_priority(arg0, arg1)
{
    return 
    {
        kind: UnknownEnum.Value_4,
        name: arg0,
        branches: arg1
    };
}

function ai_bt_guard(arg0, arg1, arg2)
{
    return 
    {
        kind: UnknownEnum.Value_5,
        name: arg0,
        check: arg1,
        child: arg2
    };
}

function ai_bt_timeout(arg0, arg1, arg2)
{
    return 
    {
        kind: UnknownEnum.Value_6,
        name: arg0,
        seconds: arg1,
        child: arg2
    };
}

function ai_bt_cooldown(arg0, arg1, arg2)
{
    return 
    {
        kind: UnknownEnum.Value_7,
        name: arg0,
        seconds: arg1,
        child: arg2
    };
}

function __ai_bt_error(arg0)
{
    throw "Behavior tree: " + arg0;
}

function __ai_bt_field(arg0, arg1)
{
    if (!variable_struct_exists(arg0, arg1))
    {
        __ai_bt_error("missing definition field '" + arg1 + "'.");
    }
    return variable_struct_get(arg0, arg1);
}

function __ai_bt_callback(arg0, arg1)
{
    if (arg1 && is_undefined(arg0))
    {
        return arg0;
    }
    if (!is_callable(arg0))
    {
        __ai_bt_error("callback must be callable.");
    }
    return arg0;
}

function __ai_bt_integer(arg0)
{
    return is_numeric(arg0) && !is_nan(arg0) && !is_infinity(arg0) && sign(frac(arg0)) == 0;
}

function __ai_bt_due(arg0, arg1)
{
    return sign((arg0 - arg1) + 0.000000001) >= 0;
}

function __ai_bt_duration(arg0)
{
    if (!is_numeric(arg0) || is_nan(arg0) || is_infinity(arg0) || sign(arg0) < 0)
    {
        __ai_bt_error("duration must be a finite nonnegative number of seconds.");
    }
    return arg0;
}

function __ai_bt_compile(arg0, arg1)
{
    if (!is_struct(arg0))
    {
        __ai_bt_error("node definition must be a struct.");
    }
    for (var _i = 0; _i < array_length(arg1.ancestors); _i++)
    {
        if (arg1.ancestors[_i] == arg0)
        {
            __ai_bt_error("cyclic definition.");
        }
    }
    var _kind = __ai_bt_field(arg0, "kind");
    var _name = __ai_bt_field(arg0, "name");
    if (!is_string(_name))
    {
        __ai_bt_error("node name must be a string.");
    }
    if (!__ai_bt_integer(_kind))
    {
        __ai_bt_error("node kind must be an AiBtKind value.");
    }
    var _node = 
    {
        kind: _kind,
        name: _name,
        children: []
    };
    var _index = array_length(arg1.nodes);
    array_push(arg1.nodes, _node);
    array_push(arg1.ancestors, arg0);
    switch (_kind)
    {
        case UnknownEnum.Value_0:
            _node.enter = __ai_bt_callback(__ai_bt_field(arg0, "enter"), true);
            _node.update = __ai_bt_callback(__ai_bt_field(arg0, "update"), false);
            _node.exit = __ai_bt_callback(__ai_bt_field(arg0, "exit"), true);
            break;
        case UnknownEnum.Value_1:
            _node.check = __ai_bt_callback(__ai_bt_field(arg0, "check"), false);
            break;
        case UnknownEnum.Value_2:
        case UnknownEnum.Value_3:
            var _children = __ai_bt_field(arg0, "children");
            if (!is_array(_children))
            {
                __ai_bt_error("children must be an array.");
            }
            for (var _i = 0; _i < array_length(_children); _i++)
            {
                array_push(_node.children, __ai_bt_compile(_children[_i], arg1));
            }
            break;
        case UnknownEnum.Value_4:
            var _branches = __ai_bt_field(arg0, "branches");
            if (!is_array(_branches) || array_length(_branches) == 0)
            {
                __ai_bt_error("priority requires at least one branch.");
            }
            _node.checks = [];
            for (var _i = 0; _i < array_length(_branches); _i++)
            {
                var _branch = _branches[_i];
                if (!is_struct(_branch))
                {
                    __ai_bt_error("branch must be a struct.");
                }
                array_push(_node.checks, __ai_bt_callback(__ai_bt_field(_branch, "check"), false));
                array_push(_node.children, __ai_bt_compile(__ai_bt_field(_branch, "child"), arg1));
            }
            break;
        case UnknownEnum.Value_5:
            _node.check = __ai_bt_callback(__ai_bt_field(arg0, "check"), false);
            array_push(_node.children, __ai_bt_compile(__ai_bt_field(arg0, "child"), arg1));
            break;
        case UnknownEnum.Value_6:
        case UnknownEnum.Value_7:
            _node.seconds = __ai_bt_duration(__ai_bt_field(arg0, "seconds"));
            array_push(_node.children, __ai_bt_compile(__ai_bt_field(arg0, "child"), arg1));
            break;
        default:
            __ai_bt_error("unknown node kind on '" + _name + "'.");
    }
    array_pop(arg1.ancestors);
    return _index;
}

function ai_bt_tree(arg0)
{
    var _build = 
    {
        nodes: [],
        ancestors: []
    };
    __ai_bt_compile(arg0, _build);
    return 
    {
        nodes: _build.nodes
    };
}

function ai_bt_context(arg0, arg1)
{
    var _slots = array_create(array_length(arg0.nodes));
    for (var _i = 0; _i < array_length(_slots); _i++)
    {
        _slots[_i] = 
        {
            active: false,
            cursor: 0,
            child_index: -1,
            child_entered: false,
            started_at: 0,
            cooldown_until: 0,
            token: 0,
            data: undefined,
            pending_status: undefined,
            pending_reason: undefined
        };
    }
    return 
    {
        tree: arg0,
        user_data: arg1,
        now: 0,
        last_result: UnknownEnum.Value_2,
        last_reason: undefined,
        _slots: _slots,
        _last_step: undefined,
        _next_token: 0,
        _active_action: -1,
        _busy: false
    };
}

function __ai_bt_finish(arg0, arg1, arg2, arg3)
{
    var _node = arg0.tree.nodes[arg1];
    var _state = arg0._slots[arg1];
    _state.active = false;
    _state.cursor = 0;
    _state.child_index = -1;
    _state.child_entered = false;
    _state.pending_status = undefined;
    _state.pending_reason = undefined;
    arg0.last_reason = arg3;
    if (_node.kind == UnknownEnum.Value_0)
    {
        arg0._active_action = -1;
        if (!is_undefined(_node.exit))
        {
            _node.exit(arg0, _state, arg3);
        }
    }
    return arg2;
}

function __ai_bt_cancel(arg0, arg1, arg2)
{
    var _state = arg0._slots[arg1];
    if (!_state.active)
    {
        exit;
    }
    var _node = arg0.tree.nodes[arg1];
    if (_state.child_index >= 0)
    {
        __ai_bt_cancel(arg0, _state.child_index, arg2);
    }
    if (_node.kind == UnknownEnum.Value_7 && _state.child_entered)
    {
        _state.cooldown_until = arg0.now + _node.seconds;
    }
    __ai_bt_finish(arg0, arg1, UnknownEnum.Value_2, arg2);
}

function __ai_bt_terminal(arg0)
{
    return __ai_bt_integer(arg0) && (arg0 == UnknownEnum.Value_1 || arg0 == UnknownEnum.Value_2);
}

function __ai_bt_visit(arg0, arg1, arg2)
{
    var _node = arg0.tree.nodes[arg1];
    var _state = arg0._slots[arg1];
    var _entering = !_state.active;
    if (_entering)
    {
        _state.active = true;
        _state.started_at = arg0.now;
        _state.cursor = 0;
        _state.child_index = -1;
        _state.child_entered = false;
    }
    var _result;
    switch (_node.kind)
    {
        case UnknownEnum.Value_0:
            if (_entering)
            {
                _state.data = {};
                _state.token = ++arg0._next_token;
                arg0._active_action = arg1;
                if (!is_undefined(_node.enter))
                {
                    _node.enter(arg0, _state);
                }
            }
            if (!is_undefined(_state.pending_status))
            {
                return __ai_bt_finish(arg0, arg1, _state.pending_status, _state.pending_reason);
            }
            _result = _node.update(arg0, _state);
            if (!__ai_bt_integer(_result) || _result < UnknownEnum.Value_0 || _result > UnknownEnum.Value_2)
            {
                __ai_bt_error("action '" + _node.name + "' returned an invalid status.");
            }
            if (_result == UnknownEnum.Value_0)
            {
                return _result;
            }
            return __ai_bt_finish(arg0, arg1, _result, (_result == UnknownEnum.Value_1) ? "success" : "failure");
        case UnknownEnum.Value_1:
            _result = _node.check(arg0) ? UnknownEnum.Value_1 : UnknownEnum.Value_2;
            return __ai_bt_finish(arg0, arg1, _result, (_result == UnknownEnum.Value_1) ? "success" : "failure");
        case UnknownEnum.Value_2:
        case UnknownEnum.Value_3:
            var _advance_on = (_node.kind == UnknownEnum.Value_2) ? UnknownEnum.Value_1 : UnknownEnum.Value_2;
            while (_state.cursor < array_length(_node.children))
            {
                _state.child_index = _node.children[_state.cursor];
                _result = __ai_bt_visit(arg0, _state.child_index, arg2);
                if (_result == UnknownEnum.Value_0)
                {
                    return _result;
                }
                if (_result != _advance_on)
                {
                    return __ai_bt_finish(arg0, arg1, _result, arg0.last_reason);
                }
                _state.cursor++;
            }
            return __ai_bt_finish(arg0, arg1, _advance_on, (_advance_on == UnknownEnum.Value_1) ? "success" : "failure");
        case UnknownEnum.Value_4:
            if (_entering || arg2)
            {
                var _selected = -1;
                for (var _i = 0; _i < array_length(_node.children); _i++)
                {
                    var _check = _node.checks[_i];
                    if (_check(arg0))
                    {
                        _selected = _node.children[_i];
                        break;
                    }
                }
                if (_state.child_index != _selected)
                {
                    if (_state.child_index >= 0)
                    {
                        __ai_bt_cancel(arg0, _state.child_index, (_selected >= 0) ? "preempted" : "guard_failed");
                    }
                    _state.child_index = _selected;
                }
            }
            if (_state.child_index < 0)
            {
                return __ai_bt_finish(arg0, arg1, UnknownEnum.Value_2, "guard_failed");
            }
            _result = __ai_bt_visit(arg0, _state.child_index, arg2);
            break;
        case UnknownEnum.Value_5:
            if ((_entering || arg2) && !_node.check(arg0))
            {
                if (_state.child_index >= 0)
                {
                    __ai_bt_cancel(arg0, _state.child_index, "guard_failed");
                }
                return __ai_bt_finish(arg0, arg1, UnknownEnum.Value_2, "guard_failed");
            }
            _state.child_index = _node.children[0];
            _result = __ai_bt_visit(arg0, _state.child_index, arg2);
            break;
        case UnknownEnum.Value_6:
            if (__ai_bt_due(arg0.now, _state.started_at + _node.seconds))
            {
                if (_state.child_index >= 0)
                {
                    __ai_bt_cancel(arg0, _state.child_index, "timeout");
                }
                return __ai_bt_finish(arg0, arg1, UnknownEnum.Value_2, "timeout");
            }
            _state.child_index = _node.children[0];
            _result = __ai_bt_visit(arg0, _state.child_index, arg2);
            break;
        case UnknownEnum.Value_7:
            if (_entering && !__ai_bt_due(arg0.now, _state.cooldown_until))
            {
                return __ai_bt_finish(arg0, arg1, UnknownEnum.Value_2, "cooldown");
            }
            _state.child_index = _node.children[0];
            _state.child_entered = true;
            _result = __ai_bt_visit(arg0, _state.child_index, arg2);
            if (_result != UnknownEnum.Value_0)
            {
                _state.cooldown_until = arg0.now + _node.seconds;
            }
            break;
    }
    if (_result == UnknownEnum.Value_0)
    {
        return _result;
    }
    return __ai_bt_finish(arg0, arg1, _result, arg0.last_reason);
}

function ai_bt_tick(arg0, arg1, arg2)
{
    if (arg0._busy)
    {
        __ai_bt_error("tick/abort cannot be called from a runtime callback.");
    }
    if (!__ai_bt_integer(arg1))
    {
        __ai_bt_error("Step ID must be a finite integer.");
    }
    if (!is_undefined(arg0._last_step))
    {
        if (arg1 < arg0._last_step)
        {
            __ai_bt_error("Step IDs must increase.");
        }
        if (arg1 == arg0._last_step)
        {
            return arg0.last_result;
        }
    }
    arg0._last_step = arg1;
    arg0.now += 0.016666666666666666;
    arg0._busy = true;
    try
    {
        arg0.last_result = __ai_bt_visit(arg0, 0, arg2);
        return arg0.last_result;
    }
    finally
    {
        arg0._busy = false;
    }
}

function ai_bt_abort(arg0, arg1 = "cancelled")
{
    if (arg0._busy)
    {
        __ai_bt_error("tick/abort cannot be called from a runtime callback.");
    }
    if (!is_string(arg1))
    {
        __ai_bt_error("abort reason must be a string.");
    }
    arg0._busy = true;
    try
    {
        __ai_bt_cancel(arg0, 0, arg1);
        arg0.last_result = UnknownEnum.Value_2;
        arg0.last_reason = arg1;
    }
    finally
    {
        arg0._busy = false;
    }
}

function ai_bt_complete(arg0, arg1, arg2, arg3 = undefined)
{
    if (!is_undefined(arg3) && !is_string(arg3))
    {
        __ai_bt_error("completion reason must be a string.");
    }
    if (!__ai_bt_integer(arg1) || !__ai_bt_terminal(arg2) || arg0._active_action < 0)
    {
        return false;
    }
    var _state = arg0._slots[arg0._active_action];
    if (!_state.active || _state.token != arg1 || !is_undefined(_state.pending_status))
    {
        return false;
    }
    _state.pending_status = arg2;
    _state.pending_reason = is_undefined(arg3) ? ((arg2 == UnknownEnum.Value_1) ? "success" : "failure") : arg3;
    return true;
}

function ai_bt_inspect(arg0)
{
    var _path = [];
    var _index = 0;
    while (_index >= 0 && arg0._slots[_index].active)
    {
        array_push(_path, arg0.tree.nodes[_index].name);
        _index = arg0._slots[_index].child_index;
    }
    var _active = arg0._active_action;
    return 
    {
        active_action: (_active < 0) ? undefined : arg0.tree.nodes[_active].name,
        active_token: (_active < 0) ? undefined : arg0._slots[_active].token,
        active_path: _path,
        now: arg0.now,
        last_result: arg0.last_result,
        last_reason: arg0.last_reason
    };
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_4,
    Value_5,
    Value_6,
    Value_7
}
