/// @description Prepara o Scribble e escolhe a fonte do menu com fallback seguro.
function menu_scribble_initialize()
{
    scribble_initialize();
    var _project_font = font_get_name(fnt_monogram);
    menu_scribble_font = scribble_font_exists(_project_font) ? _project_font : "scribble_fallback_font";
}

/// @description Desenha um texto do menu via Scribble com alinhamento e escala.
function menu_scribble_draw(_text, _id, _x, _y, _scale, _colour, _xscale = 1, _yscale = 1)
{
    scribble(_text, _id)
        .starting_format(menu_scribble_font, _colour)
        .align(fa_left, fa_top)
        .scale(_scale)
        .transform(_xscale, _yscale)
        .draw(_x, _y);
}
