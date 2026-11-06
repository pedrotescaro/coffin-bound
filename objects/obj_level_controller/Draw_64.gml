/// @description Caixa de dialogo inspirada em Celeste, renderizada pelo Scribble.
if (!variable_global_exists("dialogue_active") || !global.dialogue_active) exit;

cb_gui_apply();
draw_set_alpha(0.96);
draw_set_color(COLOR_LEVEL_DARKEST);
draw_rectangle(20, 174, 460, 254, false);
draw_set_alpha(1);
draw_set_color(COLOR_LEVEL_BRIGHT);
draw_rectangle(20, 174, 460, 254, true);
draw_rectangle(22, 176, 458, 252, true);

draw_set_color(COLOR_LEVEL_DARK);
draw_rectangle(30, 186, 68, 242, false);
draw_set_color(COLOR_LEVEL_BRIGHT);
draw_triangle(35, 210, 49, 198, 49, 222, false);
draw_triangle(63, 210, 49, 198, 49, 222, false);
draw_rectangle(45, 205, 53, 226, false);

dialogue_name.draw(78, 182);
dialogue_body.draw(78, 204, dialogue_typist);

if (dialogue_typist.get_state() >= 1) {
    dialogue_continue.draw(438, 232 + round(dsin(current_time * 0.4) * 2));
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
