/// @description Alterna o filtro retro opcional.
if (layer_exists(camada_filtro) && keyboard_check_pressed(ord("G"))) {
    global.cb_filter = !global.cb_filter;
    layer_set_visible(camada_filtro, global.cb_filter);
}
