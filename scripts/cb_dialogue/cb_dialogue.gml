/// @description Painel com cantos recortados e traços de um pixel.
function cb_dialogue_frame(_x, _y, _width, _height, _cut, _fill, _edge) {
    var _right = _x + _width - 1;
    var _bottom = _y + _height - 1;
    draw_set_color(_fill);
    draw_rectangle(_x, _y + _cut, _right, _bottom - _cut, false);
    for (var _row = 0; _row < _cut; _row++) {
        draw_line(_x + _cut - _row, _y + _row, _right - _cut + _row, _y + _row);
        draw_line(_x + _cut - _row, _bottom - _row, _right - _cut + _row, _bottom - _row);
    }
    draw_set_color(_edge);
    draw_line(_x + _cut, _y, _right - _cut, _y);
    draw_line(_right - _cut, _y, _right, _y + _cut);
    draw_line(_right, _y + _cut, _right, _bottom - _cut);
    draw_line(_right, _bottom - _cut, _right - _cut, _bottom);
    draw_line(_right - _cut, _bottom, _x + _cut, _bottom);
    draw_line(_x + _cut, _bottom, _x, _bottom - _cut);
    draw_line(_x, _bottom - _cut, _x, _y + _cut);
    draw_line(_x, _y + _cut, _x + _cut, _y);
}

/// @description Pequena joia em clusters de pixels, sem textura ou antialiasing.
function cb_dialogue_jewel(_x, _y, _radius, _colour) {
    draw_set_color(_colour);
    for (var _row = -_radius; _row <= _radius; _row++) {
        var _span = _radius - abs(_row);
        draw_line(_x - _span, _y + _row, _x + _span, _y + _row);
    }
}

/// @description Diálogo gótico em 480x270; retrato e fonte em escala 1.
function cb_dialogue_draw() {
    var _ink = make_color_rgb(11, 13, 23);
    var _plate = make_color_rgb(28, 25, 45);
    var _shadow = make_color_rgb(48, 38, 63);
    var _line = make_color_rgb(75, 54, 87);
    var _edge = make_color_rgb(109, 77, 104);
    var _bone = make_color_rgb(233, 237, 197);
    var _muted = make_color_rgb(152, 115, 138);
    var _ruby = make_color_rgb(191, 89, 99);
    var _gold = make_color_rgb(180, 136, 91);
    var _glint = make_color_rgb(241, 201, 128);

    draw_set_alpha(0.55);
    cb_dialogue_frame(18, 143, 448, 118, 6, _ink, _ink);
    draw_set_alpha(1);
    cb_dialogue_frame(16, 140, 448, 118, 6, _ink, _edge);
    cb_dialogue_frame(18, 142, 444, 114, 5, _plate, _shadow);

    // Filetes e joias acompanham o recorte da moldura.
    draw_set_color(_gold);
    draw_line(29, 144, 451, 144);
    draw_line(29, 253, 451, 253);
    cb_dialogue_jewel(24, 148, 2, _ruby);
    cb_dialogue_jewel(455, 148, 2, _ruby);
    cb_dialogue_jewel(24, 249, 2, _ruby);
    cb_dialogue_jewel(455, 249, 2, _ruby);
    draw_set_color(_glint);
    draw_point(24, 147);
    draw_point(455, 147);

    // Fundo arquitetônico permanece visível nas áreas transparentes do retrato.
    cb_dialogue_frame(22, 150, 92, 100, 3, _ink, _gold);
    draw_set_color(_shadow);
    draw_line(30, 242, 30, 173);
    draw_line(30, 173, 68, 155);
    draw_line(68, 155, 105, 173);
    draw_line(105, 173, 105, 242);
    draw_set_color(_line);
    draw_line(34, 242, 34, 177);
    draw_line(34, 177, 68, 161);
    draw_line(68, 161, 101, 177);
    draw_line(101, 177, 101, 242);
    draw_sprite(spr_portrait_vampire, 0, 24, 152);

    draw_set_color(_line);
    draw_line(122, 158, 122, 241);
    cb_dialogue_jewel(122, 153, 2, _gold);
    cb_dialogue_jewel(122, 246, 2, _gold);

    var _name_width = clamp(string_length(dialogue_speaker) * 9 + 20, 98, 306);
    cb_dialogue_frame(128, 148, _name_width, 25, 3, _shadow, _line);
    dialogue_name.draw(134, 151);

    draw_set_color(_line);
    draw_line(134, 176, 443, 176);
    draw_set_color(_ruby);
    draw_line(134, 176, 157, 176);
    // As quatro falas existentes têm duas linhas de até 270px; a área mede 306x44.
    dialogue_body.draw(134, 181, dialogue_typist);

    draw_set_color(_line);
    draw_line(134, 230, 443, 230);
    var _ready = dialogue_typist.get_state() >= 1;
    draw_set_font(fnt_monogram);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(_muted);
    draw_text(134, 235, _ready ? "CONTINUAR" : "REVELAR TEXTO");
    dialogue_continue.draw(344, 235);
    var _arrow_x = 440 + ((_ready && floor(current_time / 400) mod 2 == 0) ? 1 : 0);
    cb_dialogue_jewel(_arrow_x, 244, 2, _ready ? _glint : _muted);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
