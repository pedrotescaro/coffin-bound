if (!global.is_paused) exit;
cb_gui_apply();
draw_set_font(fnt_monogram);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(15,56,15));
draw_set_alpha(1);
draw_rectangle(0, 0, 480, 270, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(15,56,15));
draw_rectangle(76, 65, 404, 211, false);
draw_set_color(make_color_rgb(48,98,48));
draw_rectangle(76, 65, 404, 211, true);
draw_set_color(titleCol);
draw_text_transformed(195, 76, "PAUSA", 2, 2, 0);
for (var _i = 0; _i < array_length(pause_menu); _i++) {
    draw_set_color((_i == selected) ? selectedCol : notSelectedCol);
    draw_text(116, 125 + _i * 24, pause_menu[_i]);
}
draw_set_color(selectedCol);
draw_text(94, round(125 + selectLerp * 24), ">");
draw_set_color(notSelectedCol);
draw_text(98, 223, "ESC / START: CONTINUAR");
draw_set_color(make_color_rgb(155,188,15));
draw_set_alpha(1);
