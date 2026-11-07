/// @description Caixa de dialogo inspirada em Celeste, renderizada pelo Scribble.
if (global.is_paused || !instance_exists(obj_player)) exit;
cb_gui_apply();
draw_set_font(fnt_monogram);
if (obj_player.state == PlayerState.DEATH) {
    draw_set_alpha(1);
    draw_set_color(COLOR_LEVEL_DARKEST);
    draw_rectangle(50, 72, 430, 212, false);
    draw_set_alpha(1);
    draw_set_color(COLOR_LEVEL_BRIGHT);
    draw_rectangle(50, 72, 430, 212, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(240, 88, "FIM DE JOGO");
    draw_text(240, 116, "TENTATIVAS: " + string(global.cb.deaths));
    if (obj_player.death_timer >= 24) {
        draw_text(240, 148, "ENTER / A: VOLTAR AO CHECKPOINT");
        draw_text(240, 174, "ESC / B: MENU     R: TENTAR");
    }
    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(155,188,15));
    exit;
}
if (checkpoint_timer > 0 && !global.dialogue_active) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(COLOR_LEVEL_BRIGHT);
    draw_text(240, 12, "CHECKPOINT SALVO");
    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(155,188,15));
}
if (!global.dialogue_active) exit;
cb_dialogue_draw();
