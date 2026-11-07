/// @description Interface em 480x270, ampliada pelo compositor com escala inteira.
function menu_draw() {
    cb_gui_apply();
    var _background = make_color_rgb(15,56,15);
    var _card = make_color_rgb(15,56,15);
    var _border = make_color_rgb(48,98,48);
    draw_set_alpha(1);
    draw_set_color(_background);
    draw_rectangle(24, 12, 456, 232, false);
    draw_set_alpha(1);
    draw_set_color(_border);
    draw_rectangle(24, 12, 456, 232, true);

    var _heading = gameTitle;
    var _heading_x = 132;
    switch (current_page) {
        case MenuPage.OPTIONS: _heading = "OPCOES"; _heading_x = 186; break;
        case MenuPage.CONTROLS: _heading = "TECLAS"; _heading_x = 186; break;
        case MenuPage.CREDITS: _heading = "CREDITOS"; _heading_x = 168; break;
    }
    menu_scribble_draw(_heading, "menu_heading", _heading_x, 24, 2, titleCol);
    if (current_page == MenuPage.CREDITS) {
        menu_scribble_draw("CRIACAO: PEDRO TESCARO", "credits_author", 48, 82, 1, titleCol);
        menu_scribble_draw("MONOGRAM: DATAGOBLIN (CC0)", "credits_font", 48, 108, 1, notSelectedCol);
        menu_scribble_draw("INPUT/SCRIBBLE: JULIAN ADAMS (MIT)", "credits_libs", 48, 134, 1, notSelectedCol);
        menu_scribble_draw("MUSICA E EFEITOS ORIGINAIS (CC0)", "credits_audio", 48, 160, 1, notSelectedCol);
        menu_scribble_draw("OBRIGADO POR JOGAR!", "credits_thanks", 48, 186, 1, selectedCol);
        menu_scribble_draw("> VOLTAR", "credits_back", 48, 210, 1, selectedCol);
    } else {
        var _items = menu_get_current_items();
        var _menu_y = (current_page == MenuPage.MAIN) ? 112 : 70;
        var _spacing = (current_page == MenuPage.CONTROLS) ? 18 : 22;
        if (current_page == MenuPage.CONTROLS) _menu_y = 64;
        if (current_page == MenuPage.MAIN) {
            menu_scribble_draw("ENCONTRE SEU LUGAR NA NOITE.", "menu_subtitle", 96, 70, 1, selectedCol);
        }
        for (var _i = 0; _i < array_length(_items); _i++) {
            var _row_y = _menu_y + _i * _spacing;
            if (_i == selected) {
                draw_set_color(_card);
                draw_rectangle(58, _row_y, 434, _row_y + _spacing - 1, false);
            }
            var _colour = (_i == selected) ? selectedCol : notSelectedCol;
            menu_scribble_draw(_items[_i], "menu_item_" + string(current_page) + "_" + string(_i), 72, _row_y, 1, _colour);
        }
        var _cursor_y = round(_menu_y + selectLerp * _spacing + 5);
        if (sprite_exists(s_cursor)) draw_sprite(s_cursor, -1, round(38 + cursorLevitate), _cursor_y);
        else menu_scribble_draw(">", "menu_cursor", 42, _cursor_y - 5, 1, selectedCol);
    }

    var _footer = "SETAS: NAVEGAR   ENTER: CONFIRMAR";
    if (current_page == MenuPage.OPTIONS) _footer = "ESQ/DIR: AJUSTAR   ESC: VOLTAR";
    if (current_page == MenuPage.CONTROLS) _footer = "SETAS FIXAS | A/B/X NO CONTROLE";
    if (current_page == MenuPage.CREDITS) _footer = "ENTER / ESC: VOLTAR";
    if (rebind_index >= 0) _footer = "PRESSIONE UMA TECLA. ESC CANCELA.";
    if (menu_notice_timer > 0) _footer = menu_notice;
    menu_scribble_draw(_footer, "menu_footer", 42, 240, 1, titleCol);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(155,188,15));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
