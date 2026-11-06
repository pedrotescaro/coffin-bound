/// @description Renderiza título, opções e cursor no espaço GUI do menu.
function menu_draw()
{
    cb_gui_apply();

    var _title_pulse = 1;
    menu_scribble_draw(gameTitle, "menu_title", 48, 32, titleSize, titleCol, _title_pulse, _title_pulse);

    var _items = menu_get_current_items();
    var _menu_x = 36;
    var _menu_y = 120;

    for (var i = 0; i < array_length(_items); i++)
    {
        var _is_selected = (selected == i);
        var _colour = _is_selected ? selectedCol : notSelectedCol;
        var _scale = 1;
        menu_scribble_draw(_items[i], "menu_item_" + string(current_page) + "_" + string(i), _menu_x, _menu_y + (i * spacing), 1, _colour, _scale, _scale);
    }

    var _cursor_width = sprite_exists(s_cursor) ? sprite_get_width(s_cursor) : 16;
    var _cursor_x = _menu_x - _cursor_width - 6 + cursorLevitate;
    var _cursor_y = _menu_y + (selectLerp * spacing) + 4;

    if (sprite_exists(s_cursor))
    {
        draw_sprite(s_cursor, -1, round(_cursor_x), round(_cursor_y));
    }
    else
    {
        menu_scribble_draw(">", "menu_cursor_fallback", _cursor_x, _cursor_y - 4, 1, selectedCol);
    }
}
