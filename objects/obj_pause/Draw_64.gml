/// @description Desenha o overlay e as opções de pausa somente quando o jogo está pausado.
// ============================================================
// obj_pause — EVENTO DRAW GUI
// Renderização do Mini Menu de Pausa In-Game com a Fonte fnt_monogram
// ============================================================

if (!global.is_paused) exit;

// 1. Trava a resolução da camada GUI em 480x270 (Pixel-Perfect)
display_set_gui_size(480, 270);
var _gui_w = 480;
var _gui_h = 270;

// Configuração da fonte monogramada da room do menu
if (font_exists(fnt_monogram)) {
    draw_set_font(fnt_monogram);
} else {
    draw_set_font(-1);
}

// 2. Fundo Translúcido Escurecido sobre o jogo
draw_set_color(make_color_rgb(15, 56, 15)); // #0f380f (COLOR_GB_DARKEST)
draw_set_alpha(0.75);
draw_rectangle(0, 0, _gui_w, _gui_h, false);
draw_set_alpha(1.0);

// 3. Moldura de Lápide Centralizada (170x106px)
var _box_w = 170;
var _box_h = 106;
var _box_x = (_gui_w - _box_w) / 2;
var _box_y = (_gui_h - _box_h) / 2;

// Fundo da Caixa de Pausa (Verde Médio GameBoy)
draw_set_color(make_color_rgb(48, 98, 48)); // #306230 (COLOR_GB_DARK)
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);

// Moldura Dupla Pixel Art
draw_set_color(make_color_rgb(155, 188, 15)); // #9bbc0f (COLOR_GB_BRIGHT)
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);
draw_set_color(make_color_rgb(15, 56, 15));
draw_rectangle(_box_x + 1, _box_y + 1, _box_x + _box_w - 1, _box_y + _box_h - 1, true);

// 4. Título do Mini Menu
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(titleCol);
draw_text_transformed(_box_x + (_box_w / 2), _box_y + 12, "PAUSA", 1.4, 1.4, 0);

// 5. Lista de Opções (JOGAR, RECOMECAR, MENU)
var _menu_x = _box_x + 44;
var _menu_y = _box_y + 42;
var _spacing = 18;

draw_set_halign(fa_left);

for (var i = 0; i < array_length(pause_menu); i++) {
    if (selected == i) {
        draw_set_color(selectedCol);
    } else {
        draw_set_color(notSelectedCol);
    }
    draw_text(_menu_x, _menu_y + (i * _spacing), pause_menu[i]);
}

// 6. Desenha o Cursor (s_cursor) Flutuante sem Colisão com o Texto
var _curs_w = sprite_exists(s_cursor) ? sprite_get_width(s_cursor) : 16;
var _curs_x = _menu_x - _curs_w - 6 + cursorLevitate; // Offset seguro à esquerda
var _curs_y = _menu_y + (selectLerp * _spacing) + 4;

if (sprite_exists(s_cursor)) {
    draw_sprite(s_cursor, -1, _curs_x, _curs_y);
} else {
    draw_set_color(selectedCol);
    draw_text(_curs_x, _curs_y - 4, ">");
}
