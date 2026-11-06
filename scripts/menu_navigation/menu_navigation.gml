function menu_navigation_update() {
    cursorLevitate = round(dsin(cursorTime) * 2);
    cursorTime += leviRate;
    menu_notice_timer = max(0, menu_notice_timer - 1);
    if (menu_input_vertical != 0 && current_page != MenuPage.CREDITS) {
        var _previous = selected;
        selected = clamp(selected + sign(menu_input_vertical), 0, array_length(menu_get_current_items()) - 1);
        if (selected != _previous) cb_play_sfx(snd_cb_ui);
    }
    selectLerp = lerp(selectLerp, selected, lerpAmt);
}

function menu_navigation_open_page(_page, _selection) {
    current_page = _page;
    selected = _selection;
    selectLerp = _selection;
    rebind_index = -1;
    menu_notice_timer = 0;
    cb_play_sfx(snd_cb_ui);
}
