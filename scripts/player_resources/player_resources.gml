/// @description Atualiza energia, buffers de pulo, coyote time e timers globais do player.
function player_update_resources() {
    // A energia é recarregada apenas fora da forma de morcego.
    if (state == PlayerState.NORMAL || state == PlayerState.DASH || state == PlayerState.WALL_SLIDE) {
        bat_energy = min(bat_energy + bat_recharge_rate, bat_energy_max);
    }

    // Coyote time e buffer tornam o pulo responsivo sem alterar a física base.
    if (on_ground) coyote_counter = coyote_frames;
    else if (coyote_counter > 0) coyote_counter--;
    if (input_jump_press) buffer_counter = buffer_frames;
    if (buffer_counter > 0) buffer_counter--;
    if (wall_jump_timer > 0) wall_jump_timer--;

    // A máscara constante evita mudança de hitbox entre sprites e estados.
    mask_index = spr_vampire_idle;
    prev_state = state;
}
