/// @description Coordena a ordem de atualização do player sem conter regras de estado.
// obj_player — EVENTO STEP
// Coordena a atualização do jogador; cada sistema vive em scripts/player.

// Dialogos congelam apenas o movimento do jogador. O controlador da fase
// continua ativo para animar e avancar a caixa de texto.
if (variable_global_exists("dialogue_active") && global.dialogue_active) {
    hsp = 0;
    vsp = 0;
    move_input = 0;
    image_speed = 0;
    exit;
}

player_input();
player_update_contacts();
player_update_health();
player_update_resources();
player_try_start_bat();
player_update_state();
player_resolve_collision();
player_update_visuals();
player_update_animation();
player_update_post_step();
