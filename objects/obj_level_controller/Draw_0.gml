/// @description Partículas limitadas por quantidade e tempo de vida; coordenadas de mundo.
for (var _i = 0; _i < array_length(fx_particles); _i++) {
    var _p = fx_particles[_i];
    draw_set_color(_p.colour);
    draw_set_alpha(_p.life / _p.max_life);
    draw_point(round(_p.px), round(_p.py));
}
draw_set_alpha(1);
draw_set_color(c_white);
