/// @description Desenha feixes, halos e poeira do volume de luz sem alterar a física.
// ============================================================
// obj_light — EVENTO DRAW
// Renderização Volumétrica Translúcida de Luz da Masmorra
// ============================================================

var _curr_rad = light_radius + flicker;
var _c_bright = make_color_rgb(155,188,15); // Verde Brilhante #9bbc0f
var _c_light  = make_color_rgb(139,172,15); // Verde Médio #8bac0f

// Pulse de respiração da luz
var _pulse = dsin(pulse_timer * 70);

// ╔════════════════════════════════════════════════════════════╗
// ║  1. FEIXES VOLUMÉTRICOS DE LUZ DA JANELA (GOD-RAYS)       ║
// ╚════════════════════════════════════════════════════════════╝

// Feixe Angular 1 (Diagonal Esquerda)
draw_set_color(_c_bright);
draw_set_alpha(1);
draw_primitive_begin(pr_trianglelist);
draw_vertex(x, y - 10);
draw_vertex(x - _curr_rad * 0.8, y + _curr_rad * 0.9);
draw_vertex(x - _curr_rad * 0.2, y + _curr_rad * 0.9);
draw_primitive_end();

// Feixe Angular 2 (Vertical Central)
draw_set_alpha(1);
draw_primitive_begin(pr_trianglelist);
draw_vertex(x, y - 10);
draw_vertex(x - _curr_rad * 0.4, y + _curr_rad);
draw_vertex(x + _curr_rad * 0.4, y + _curr_rad);
draw_primitive_end();

// Feixe Angular 3 (Diagonal Direita)
draw_set_alpha(1);
draw_primitive_begin(pr_trianglelist);
draw_vertex(x, y - 10);
draw_vertex(x + _curr_rad * 0.2, y + _curr_rad * 0.9);
draw_vertex(x + _curr_rad * 0.8, y + _curr_rad * 0.9);
draw_primitive_end();


// ╔════════════════════════════════════════════════════════════╗
// ║  2. GRADIENTES RADIAIS SUAVES E TRANSLÚCIDOS              ║
// ╚════════════════════════════════════════════════════════════╝

// Halo Externo Suave (Alpha 5%)
draw_set_color(_c_light);
draw_set_alpha(1);
draw_circle(x, y, _curr_rad, false);

// Halo Intermediário (Alpha 10%)
draw_set_color(_c_bright);
draw_set_alpha(1);
draw_circle(x, y, _curr_rad * 0.65, false);

// Núcleo Central (Alpha 18% — Transparência Garantida)
draw_set_alpha(1);
draw_circle(x, y, _curr_rad * 0.35, false);

// Raios de Luz no Centro
draw_set_alpha(1);
draw_line_width(x - _curr_rad * 0.3, y, x + _curr_rad * 0.3, y, 1);
draw_line_width(x, y - _curr_rad * 0.3, x, y + _curr_rad * 0.3, 1);


// ╔════════════════════════════════════════════════════════════╗
// ║  3. POEIRA ATMOSFÉRICA FLUTUANTE EM PIXEL ART             ║
// ╚════════════════════════════════════════════════════════════╝
draw_set_color(_c_bright);
for (var i = 0; i < array_length(light_particles); i++) {
    var _p = light_particles[i];
    draw_set_alpha(1);
    draw_rectangle(round(_p.px), round(_p.py), round(_p.px) + _p.size - 1, round(_p.py) + _p.size - 1, false);
}

// Restaura Alpha Global para 1.0
draw_set_alpha(1);
draw_set_color(make_color_rgb(155,188,15));
