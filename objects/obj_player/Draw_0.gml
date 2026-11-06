/// @description Desenha o sprite do player com squash/stretch e iluminação exclusivamente visuais.
// ============================================================
// obj_player — EVENTO DRAW
// Desenha o player com interpolação de Squish & Stretch por código,
// iluminação visual, e animações fluidas sem travamentos.
// ============================================================

// Efeito de piscar ao sofrer dano da luz
var _blend = c_white;
var _alpha = image_alpha;

if (flash_hit > 0 && floor(current_time / 40) % 2 == 0) {
    _blend = make_color_rgb(255, 120, 120); // Tom avermelhado de queimadura
}

// Desenha o sprite com xscale/yscale dinamicos de squish & stretch e angulo
draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    image_xscale * xscale_draw,
    yscale_draw,
    angle_draw,
    _blend,
    _alpha
);
