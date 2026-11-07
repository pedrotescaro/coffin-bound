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

/// @description Filete ornamental compartilhado pelo menu e pelos painéis.
function cb_ui_rule(_x, _y, _width) {
    var _mid = _x + _width div 2;
    draw_set_color(make_color_rgb(139,172,15));
    draw_line(_x + 8, _y, _mid - 6, _y);
    draw_line(_mid + 6, _y, _x + _width - 8, _y);
    cb_dialogue_jewel(_mid, _y, 3, make_color_rgb(155,188,15));
    cb_dialogue_jewel(_x + 2, _y, 2, make_color_rgb(139,172,15));
    cb_dialogue_jewel(_x + _width - 2, _y, 2, make_color_rgb(139,172,15));
}

/// @description Arte do LibreSprite em escala 1; texto permanece editável no GML.
function cb_dialogue_draw() {
    var _ink = make_color_rgb(15,56,15);
    var _shade = make_color_rgb(48,98,48);
    var _edge = make_color_rgb(139,172,15);
    var _light = make_color_rgb(155,188,15);
    draw_set_alpha(1);
    draw_sprite_ext(spr_dialogue_frame, 0, 26, 132, 1, 1, 0, c_white, 1);
    draw_sprite_ext(spr_portrait_vampire, 0, 44, 147, 1, 1, 0, c_white, 1);

    var _name_width = clamp(string_length(dialogue_speaker) * 9 + 20, 98, 294);
    cb_dialogue_frame(146, 144, _name_width, 25, 2, _shade, _shade);
    draw_set_color(_edge);
    draw_line(148, 169, 146 + _name_width - 1, 169);
    dialogue_name.draw(151, 145);
    // 294px comportam a maior fala atual (270px); duas linhas de 20px.
    dialogue_body.draw(148, 173, dialogue_typist);

    var _ready = dialogue_typist.get_state() >= 1;
    draw_set_font(fnt_monogram);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(_light);
    draw_text(162, 232, _ready ? "CONTINUAR" : "REVELAR TEXTO");
    dialogue_continue.draw(358, 232);
    cb_dialogue_jewel(151, 242, 2, _ready ? _light : _edge);
    draw_set_color(_edge);
    draw_line(148, 242, 154, 242);
    if (_ready && floor(current_time / 400) mod 2 == 0) {
        cb_dialogue_jewel(443, 242, 2, _light);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(_light);
}
