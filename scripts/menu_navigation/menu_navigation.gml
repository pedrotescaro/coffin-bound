/// @description Atualiza o cursor e move a seleção dentro da página atual.
function menu_navigation_update()
{
    cursorLevitate = dsin(cursorTime) * 3;
    cursorTime += leviRate;

    if (menu_input_vertical != 0)
    {
        var _items = menu_get_current_items();
        selected = clamp(selected + sign(menu_input_vertical), 0, array_length(_items) - 1);
    }

    selectLerp = lerp(selectLerp, selected, lerpAmt);
}

/// @description Troca de página mantendo a posição visual do cursor consistente.
function menu_navigation_open_page(_page, _selection)
{
    current_page = _page;
    selected = _selection;
    selectLerp = _selection;
}
