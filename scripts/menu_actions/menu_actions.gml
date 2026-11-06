function menu_actions_update() {
    if (menu_input_back && current_page != MenuPage.MAIN) {
        if (current_page == MenuPage.CONTROLS) menu_navigation_open_page(MenuPage.OPTIONS, 5);
        else if (current_page == MenuPage.CREDITS) menu_navigation_open_page(MenuPage.MAIN, global.cb.has_save ? 3 : 2);
        else menu_navigation_open_page(MenuPage.MAIN, global.cb.has_save ? 2 : 1);
        return;
    }
    if (current_page == MenuPage.OPTIONS) {
        menu_actions_options();
        return;
    }
    if (!menu_input_accept) return;
    cb_play_sfx(snd_cb_ui);
    switch (current_page) {
        case MenuPage.MAIN: menu_actions_main(); break;
        case MenuPage.CONTROLS: menu_actions_controls(); break;
        case MenuPage.CREDITS:
            menu_navigation_open_page(MenuPage.MAIN, global.cb.has_save ? 3 : 2);
            break;
    }
}

function menu_actions_main() {
    var _choice = selected;
    if (global.cb.has_save) {
        if (_choice == 0) { cb_start_game(false); return; }
        _choice--;
    }
    switch (_choice) {
        case 0: cb_start_game(true); break;
        case 1: menu_navigation_open_page(MenuPage.OPTIONS, 0); break;
        case 2: menu_navigation_open_page(MenuPage.CREDITS, 0); break;
        case 3:
            if (os_browser != browser_not_a_browser) menu_show_notice("Feche esta aba para sair.");
            else game_end();
            break;
    }
}

function menu_actions_options() {
    if (!menu_input_accept && menu_input_horizontal == 0) return;
    if (selected <= 2) {
        var _values = [global.cb.master, global.cb.music, global.cb.sfx];
        var _value = _values[selected];
        if (menu_input_horizontal != 0) _value = clamp(_value + sign(menu_input_horizontal) * 0.1, 0, 1);
        else _value = (_value >= 0.99) ? 0 : min(1, _value + 0.1);
        switch (selected) {
            case 0: global.cb.master = _value; break;
            case 1: global.cb.music = _value; break;
            case 2: global.cb.sfx = _value; break;
        }
        cb_apply_audio();
        cb_save_settings();
        cb_play_sfx(snd_cb_ui);
    } else if (selected == 3) {
        if (!menu_input_accept) return;
        if (os_browser != browser_not_a_browser) {
            menu_show_notice("Use o botao de tela cheia do itch.io.");
            return;
        }
        cb_toggle_fullscreen();
        cb_save_settings();
        cb_play_sfx(snd_cb_ui);
    } else if (selected == 4) {
        if (!menu_input_accept) return;
        global.cb.filter = !global.cb.filter;
        cb_apply_filter();
        cb_save_settings();
        cb_play_sfx(snd_cb_ui);
    } else if (menu_input_accept) {
        if (selected == 5) menu_navigation_open_page(MenuPage.CONTROLS, 0);
        else menu_navigation_open_page(MenuPage.MAIN, global.cb.has_save ? 2 : 1);
    }
    menu_options_refresh_labels();
}

function menu_actions_controls() {
    if (selected < 7) {
        rebind_index = selected;
        rebind_deadline = current_time + 5000;
        menu_show_notice("Pressione uma tecla; Esc cancela.");
    } else if (selected == 7) {
        global.cb.keys = [ord("A"), ord("D"), ord("W"), ord("S"), vk_space, ord("C"), ord("F")];
        cb_bindings_apply();
        cb_save_settings();
        menu_controls_refresh_labels();
        menu_show_notice("Teclas padrao restauradas.");
    } else {
        menu_navigation_open_page(MenuPage.OPTIONS, 5);
    }
}

/// @description Captura um novo pressionamento; comandos de interface são reservados.
function menu_rebind_update() {
    if (menu_input_back || current_time >= rebind_deadline) {
        rebind_index = -1;
        menu_show_notice("Remapeamento cancelado.");
        return;
    }
    var _key = keyboard_lastkey;
    if (_key <= 0 || !keyboard_check_pressed(_key)) return;
    if (!cb_key_valid(_key)) {
        menu_show_notice("Tecla reservada. Use letra, numero ou Shift.");
        return;
    }
    for (var _i = 0; _i < 7; _i++) {
        if (_i != rebind_index && global.cb.keys[_i] == _key) {
            menu_show_notice("Tecla ja usada por outra acao.");
            return;
        }
    }
    global.cb.keys[rebind_index] = _key;
    cb_bindings_apply();
    cb_save_settings();
    rebind_index = -1;
    menu_controls_refresh_labels();
    menu_show_notice("Tecla salva.");
    cb_play_sfx(snd_cb_ui);
}
