uiAddBoxType("UiVerticalScrollbar", class_ui_vertical_scrollbar);

function class_ui_vertical_scrollbar() : uiClassVerticalScrollbar() constructor
{
    static __UpdateHandleSizeFromContent = function()
    {
        if (__binding == undefined)
        {
            return false;
        }
        var _trackHeight = __localBottom - __localTop;
        var _visibleHeight = __binding.__localBottom - __binding.__localTop;
        var _scrollRange = max(0, __binding.scrollYMax - __binding.scrollYMin);
        var _newHeight = _trackHeight;
        if ((_visibleHeight + _scrollRange) > 0)
        {
            _newHeight = (_trackHeight * _visibleHeight) / (_visibleHeight + _scrollRange);
        }
        _newHeight = clamp(_newHeight, min(24, _trackHeight), _trackHeight);
        if (abs(_newHeight - handleHeight) < 0.5)
        {
            return false;
        }
        handleHeight = _newHeight;
        return true;
    };
    
    CallbackSet(UnknownEnum.Value_14, function()
    {
        handleWidth = 60;
        handleHeight = 24;
        __UpdateHandleSizeFromContent();
        uiCallInherited();
    });
    CallbackSet(UnknownEnum.Value_12, function()
    {
        var _oldValue = value;
        var _oldValueMin = valueMin;
        var _oldValueMax = valueMax;
        var _newValue = __CallbackExists(UnknownEnum.Value_24) ? __CallbackGet(UnknownEnum.Value_24).__Call(self) : undefined;
        var _handleResized = __UpdateHandleSizeFromContent();
        if (_newValue != undefined && (_newValue != _oldValue || valueMin != _oldValueMin || valueMax != _oldValueMax))
        {
            value = _newValue;
            __UpdateHandle(false);
        }
        else if (_handleResized)
        {
            __UpdateHandle(false);
        }
        var _color = merge_color(color, animBlend, animBlendAmount);
        var _alpha = alpha * animAlpha;
        var _scale = scale * animScale;
        var _handleLeft = __handleLeft + __drawLeft;
        var _handleTop = __handleTop + __drawTop;
        var _handleRight = __handleRight + __drawLeft;
        var _handleBottom = __handleBottom + __drawTop;
        var _handleX = 0.5 * (_handleLeft + _handleRight);
        var _handleY = 0.5 * (_handleTop + _handleBottom);
        if (uiPointerIsDirectional() && GetHover())
        {
            if (GetButton())
            {
                draw_sprite_stretched_ext(s_hud_slider_bar_9slice_thin, 0, __drawLeft - 10, __drawTop - 10, (20 + __drawRight) - __drawLeft, (20 + __drawBottom) - __drawTop, _color, _alpha);
            }
            else
            {
                draw_sprite_stretched_ext(s_hud_slider_bar_9slice_thin, 0, __drawLeft - 14, __drawTop - 14, (28 + __drawRight) - __drawLeft, (28 + __drawBottom) - __drawTop, _color, _alpha);
            }
        }
        draw_sprite_stretched_ext(s_hud_slider_bar_9slice_thick, 0, __drawLeft, __drawTop, __drawRight - __drawLeft, __drawBottom - __drawTop, _color, _alpha);
        var _barLeft = _handleX - 20;
        var _barRight = (_handleX + 20) - 1;
        var _barTop = _handleTop + 4;
        var _barBottom = _handleBottom - 4 - 1;
        var _barSolid = (GetHover() && !uiPointerIsDirectional()) || GetButton();
        var _oldDrawColor = draw_get_color();
        var _oldDrawAlpha = draw_get_alpha();
        draw_set_alpha(_alpha);
        draw_set_color(_color);
        draw_rectangle(_barLeft, _barTop, _barRight, _barBottom, false);
        if (!_barSolid)
        {
            draw_set_color(c_black);
            draw_rectangle(_barLeft + 4, _barTop + 4, _barRight - 4, _barBottom - 4, false);
        }
        draw_set_color(_oldDrawColor);
        draw_set_alpha(_oldDrawAlpha);
    });
}

enum UnknownEnum
{
    Value_12 = 12,
    Value_14 = 14,
    Value_24 = 24
}
