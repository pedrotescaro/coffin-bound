/// @description Inicializa os dados e valores visuais usados pelo menu.
function menu_data_initialize()
{
    menu = ["JOGAR", "CONFIGURACOES", "SAIR"];
    options_menu = ["", "", "VOLTAR"];

    current_page = MenuPage.MAIN;
    selected = 0;
    selectLerp = 0;

    is_filter_on = true;
    is_fullscreen = window_get_fullscreen();
    menu_options_refresh_labels();

    cursorLevitate = 0;
    cursorTime = 0;
    leviRate = 1.5;
    lerpAmt = 0.25;
    spacing = 18;

    selectedCol = make_color_rgb(182, 204, 139);
    notSelectedCol = make_color_rgb(11, 13, 23);
    titleCol = c_white;
    gameTitle = "COFFIN BOUND";
    titleSize = 2;
}

/// @description Retorna os itens correspondentes à página aberta.
function menu_get_current_items()
{
    return (current_page == MenuPage.MAIN) ? menu : options_menu;
}

/// @description Atualiza os textos das opções que refletem preferências atuais.
function menu_options_refresh_labels()
{
    options_menu[0] = "FILTRO GAMEBOY: " + (is_filter_on ? "LIGADO" : "DESLIGADO");
    options_menu[1] = "TELA CHEIA: " + (is_fullscreen ? "LIGADO" : "DESLIGADO");
}
