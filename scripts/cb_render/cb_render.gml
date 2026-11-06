/// @description Resolução lógica única e apresentação com escala inteira.
function cb_render_init() {
    if (!variable_global_exists("cb_render_started")) {
        global.cb_render_started = true;
        if (!variable_global_exists("cb_filter")) global.cb_filter = false;
        if (os_type == os_windows) {
            if (!window_get_fullscreen()) window_set_size(960, 540);
            window_set_min_width(480);
            window_set_min_height(270);
            window_center();
        }
    }
    application_surface_draw_enable(false);
    gpu_set_texfilter(false);
    view_wport[0] = 480;
    view_hport[0] = 270;
    cb_gui_apply();
}

/// @description Recalcula barras e escala ao alternar fullscreen ou redimensionar.
function cb_render_layout() {
    var _width = max(1, window_get_width());
    var _height = max(1, window_get_height());
    global.cb_render_scale = max(1, floor(min(_width / 480, _height / 270)));
    global.cb_render_x = floor((_width - 480 * global.cb_render_scale) / 2);
    global.cb_render_y = floor((_height - 270 * global.cb_render_scale) / 2);
}

/// @description A GUI usa o mesmo retângulo inteiro da imagem do jogo.
function cb_gui_apply() {
    cb_render_layout();
    display_set_gui_maximise(global.cb_render_scale, global.cb_render_scale,
        global.cb_render_x, global.cb_render_y);
}

/// @description A surface de aplicação pertence ao runner; não criar/free manualmente.
function cb_render_prepare() {
    gpu_set_texfilter(false);
    if (surface_exists(application_surface)) {
        if (surface_get_width(application_surface) != 480
            || surface_get_height(application_surface) != 270) {
            surface_resize(application_surface, 480, 270);
        }
    }
}

/// @description Post Draw: apresenta a surface sobre barras pretas sem reamostrar pixels.
function cb_render_present() {
    cb_render_layout();
    draw_clear_alpha(c_black, 1);
    if (!surface_exists(application_surface)) return;
    gpu_set_texfilter(false);
    gpu_set_blendenable(false);
    draw_surface_stretched(application_surface, global.cb_render_x, global.cb_render_y,
        480 * global.cb_render_scale, 270 * global.cb_render_scale);
    gpu_set_blendenable(true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
