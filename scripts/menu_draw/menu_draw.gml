/// @description Floresta e ruínas, com painéis opacos de quatro cores para leitura.
function menu_draw() {
    cb_gui_apply();
    var _ink = make_color_rgb(15,56,15);
    var _shade = make_color_rgb(48,98,48);
    var _edge = make_color_rgb(139,172,15);
    var _light = make_color_rgb(155,188,15);
    var _main = current_page == MenuPage.MAIN;
    draw_set_alpha(1);
    draw_sprite_ext(spr_menu_forest, 0, 0, 0, 1, 1, 0, c_white, 1);
    draw_sprite_ext(spr_ui_border, 0, 0, 0, 1, 1, 0, c_white, 1);

    if (_main) {
        cb_dialogue_frame(86, 16, 308, 55, 4, _ink, _shade);
        draw_sprite_ext(spr_title_coffin, 0, 106, 27, 1, 1, 0, c_white, 1);
        cb_ui_rule(100, 64, 280);
        cb_dialogue_frame(106, 74, 268, 23, 3, _ink, _shade);
        menu_scribble_draw("ENCONTRE SEU LUGAR NA NOITE.", "menu_subtitle", 123, 75, 1, _light);
        cb_dialogue_frame(278, 105, 174, 125, 4, _ink, _edge);
        cb_dialogue_frame(280, 107, 170, 121, 3, _ink, _shade);
    } else {
        cb_dialogue_frame(24, 16, 432, 218, 5, _ink, _edge);
        cb_dialogue_frame(27, 19, 426, 212, 4, _ink, _shade);
        var _heading = "OPCOES", _heading_x = 186;
        switch (current_page) {
            case MenuPage.CONTROLS: _heading = "TECLAS"; break;
            case MenuPage.CREDITS: _heading = "CREDITOS"; _heading_x = 168; break;
        }
        menu_scribble_draw(_heading, "menu_heading", _heading_x, 23, 2, _light);
        cb_ui_rule(58, 59, 364);
    }

    if (current_page == MenuPage.CREDITS) {
        menu_scribble_draw("CRIACAO: PEDRO TESCARO", "credits_author", 48, 82, 1, _light);
        menu_scribble_draw("MONOGRAM: DATAGOBLIN (CC0)", "credits_font", 48, 108, 1, _edge);
        menu_scribble_draw("INPUT/SCRIBBLE: JULIAN ADAMS (MIT)", "credits_libs", 48, 134, 1, _edge);
        menu_scribble_draw("MUSICA E EFEITOS ORIGINAIS (CC0)", "credits_audio", 48, 160, 1, _edge);
        menu_scribble_draw("OBRIGADO POR JOGAR!", "credits_thanks", 48, 186, 1, _light);
        menu_scribble_draw("> VOLTAR", "credits_back", 48, 210, 1, _light);
    } else {
        var _items = menu_get_current_items();
        var _menu_y = _main ? 109 : 70;
        var _spacing = _main ? 23 : 22;
        var _text_x = _main ? 306 : 72;
        if (current_page == MenuPage.CONTROLS) { _menu_y = 64; _spacing = 18; }
        for (var _i = 0; _i < array_length(_items); _i++) {
            var _row_y = _menu_y + _i * _spacing;
            if (_i == selected) {
                draw_set_color(_shade);
                draw_rectangle(_main ? 299 : 65, _row_y + 2,
                    _main ? 441 : 434, _row_y + _spacing - 1, false);
            }
            menu_scribble_draw(_items[_i], "menu_item_" + string(current_page) + "_" + string(_i),
                _text_x, _row_y, 1, (_i == selected) ? _light : _edge);
        }
        var _cursor_y = round(_menu_y + selectLerp * _spacing + 11);
        cb_dialogue_jewel(_main ? 290 : 54, _cursor_y, 3, _light);
    }

    var _footer = "SETAS: NAVEGAR   ENTER: CONFIRMAR";
    if (current_page == MenuPage.OPTIONS) _footer = "ESQ/DIR: AJUSTAR   ESC: VOLTAR";
    if (current_page == MenuPage.CONTROLS) _footer = "SETAS FIXAS | A/B/X NO CONTROLE";
    if (current_page == MenuPage.CREDITS) _footer = "ENTER / ESC: VOLTAR";
    if (rebind_index >= 0) _footer = "PRESSIONE UMA TECLA. ESC CANCELA.";
    if (menu_notice_timer > 0) _footer = menu_notice;
    cb_dialogue_frame(26, 239, 428, 24, 3, _ink, _shade);
    menu_scribble_draw(_footer, "menu_footer", 42, 240, 1, _light);
    draw_set_alpha(1);
    draw_set_color(_light);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
