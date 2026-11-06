/// @description Inicializa apresentação e filtro opcional.
cb_boot();
cb_render_init();
camada_filtro = layer_get_id("Efeito_Gameboy");
if (layer_exists(camada_filtro)) layer_set_visible(camada_filtro, global.cb_filter);
