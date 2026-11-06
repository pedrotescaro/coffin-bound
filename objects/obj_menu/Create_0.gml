/// @description Inicializa preferências e consome o pedido de créditos ao concluir.
cb_boot();
cb_gui_apply();
menu_data_initialize();
menu_scribble_initialize();
if (variable_global_exists("cb_open_credits") && global.cb_open_credits) {
    global.cb_open_credits = false;
    current_page = MenuPage.CREDITS;
    selected = 0;
    selectLerp = 0;
}
