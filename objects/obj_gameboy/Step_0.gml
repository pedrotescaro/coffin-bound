/// @description Alterna o filtro retro opcional.
cb_audio_update();
if (keyboard_check_pressed(vk_f11)) cb_toggle_fullscreen();
if (layer_exists(camada_filtro) && keyboard_check_pressed(ord("G"))) {
    global.cb.filter = !global.cb.filter;
    cb_apply_filter();
    cb_save_settings();
}
