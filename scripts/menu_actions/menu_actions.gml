/// @description Executa confirmar e voltar de acordo com a página do menu.
function menu_actions_update()
{
    if (menu_input_back && current_page == MenuPage.OPTIONS)
    {
        menu_navigation_open_page(MenuPage.MAIN, 1);
        return;
    }

    if (!menu_input_accept) return;

    if (current_page == MenuPage.MAIN)
    {
        menu_actions_main();
    }
    else
    {
        menu_actions_options();
    }
}

/// @description Executa a opção atualmente selecionada no menu principal.
function menu_actions_main()
{
    switch (selected)
    {
        case 0:
            room_goto(rm_level1);
        break;

        case 1:
            menu_navigation_open_page(MenuPage.OPTIONS, 0);
        break;

        case 2:
            game_end();
        break;
    }
}

/// @description Executa a opção atualmente selecionada na página de configurações.
function menu_actions_options()
{
    switch (selected)
    {
        case 0:
            is_filter_on = !is_filter_on;
            var _layer = layer_get_id("Efeito_Gameboy");
            if (layer_exists(_layer)) layer_set_visible(_layer, is_filter_on);
            menu_options_refresh_labels();
        break;

        case 1:
            is_fullscreen = !is_fullscreen;
            window_set_fullscreen(is_fullscreen);
            menu_options_refresh_labels();
        break;

        case 2:
            menu_navigation_open_page(MenuPage.MAIN, 1);
        break;
    }
}
