/// @description Sprite inteiro com espelhamento; a máscara não depende do desenho.
var _blend = c_white;
if (flash_hit > 0 && floor(current_time / 40) mod 2 == 0) {
    _blend = make_color_rgb(139,172,15);
}
if (state != PlayerState.DEATH) {
    draw_sprite_ext(sprite_index, image_index, round(x), round(y),
        facing_dir, 1, 0, _blend, image_alpha);
}
