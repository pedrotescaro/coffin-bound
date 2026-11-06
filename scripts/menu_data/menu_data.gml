/// @description Dados da interface; preferências persistidas vivem em global.cb.
function menu_data_initialize() {
    current_page = MenuPage.MAIN;
    selected = 0;
    selectLerp = 0;
    cursorLevitate = 0;
    cursorTime = 0;
    leviRate = 1.5;
    lerpAmt = 0.25;
    spacing = 22;
    selectedCol = make_color_rgb(182, 204, 139);
    notSelectedCol = make_color_rgb(233, 237, 197);
    titleCol = notSelectedCol;
    gameTitle = "COFFIN BOUND";
    titleSize = 2;
    menu_notice = "";
    menu_notice_timer = 0;
    rebind_index = -1;
    rebind_deadline = 0;
    control_names = ["ESQUERDA", "DIREITA", "CIMA", "BAIXO", "PULAR", "DASH", "MORCEGO"];
    menu_main_refresh();
    menu_options_refresh_labels();
    menu_controls_refresh_labels();
}

function menu_main_refresh() {
    menu = global.cb.has_save
        ? ["CONTINUAR", "NOVO JOGO", "OPCOES", "CREDITOS", "SAIR"]
        : ["NOVO JOGO", "OPCOES", "CREDITOS", "SAIR"];
}

function menu_get_current_items() {
    switch (current_page) {
        case MenuPage.MAIN: return menu;
        case MenuPage.OPTIONS: return options_menu;
        case MenuPage.CONTROLS: return controls_menu;
        case MenuPage.CREDITS: return ["VOLTAR"];
    }
    return menu;
}

function menu_options_refresh_labels() {
    options_menu = [
        "VOLUME GERAL: " + string(round(global.cb.master * 100)) + "%",
        "MUSICA: " + string(round(global.cb.music * 100)) + "%",
        "EFEITOS: " + string(round(global.cb.sfx * 100)) + "%",
        (os_browser != browser_not_a_browser) ? "TELA CHEIA: BOTAO DO NAVEGADOR"
            : "TELA CHEIA: " + (global.cb.fullscreen ? "SIM" : "NAO"),
        "FILTRO GAMEBOY: " + (global.cb.filter ? "SIM" : "NAO"),
        "TECLAS", "VOLTAR"
    ];
}

function menu_controls_refresh_labels() {
    controls_menu = [];
    for (var _i = 0; _i < 7; _i++) {
        controls_menu[_i] = control_names[_i] + ": " + cb_key_name(global.cb.keys[_i]);
    }
    controls_menu[7] = "RESTAURAR PADRAO";
    controls_menu[8] = "VOLTAR";
}

function menu_show_notice(_message) {
    menu_notice = _message;
    menu_notice_timer = 180;
}
