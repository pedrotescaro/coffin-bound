/// @description Atualiza energia, buffers e timers antes da física.
function player_update_resources() {
    if (player_is_human_state(state) || state == PlayerState.DASH || state == PlayerState.WALL_SLIDE) {
        bat_energy = min(bat_energy + bat_recharge_rate, bat_energy_max);
    }
    if (on_ground && vsp >= 0) coyote_counter = coyote_frames;
    else coyote_counter = max(0, coyote_counter - 1);
    if (input_jump_press) buffer_counter = buffer_frames;
    else buffer_counter = max(0, buffer_counter - 1);
    wall_jump_timer = max(0, wall_jump_timer - 1);
    damage_timer = max(0, damage_timer - 1);
    respawn_invulnerability = max(0, respawn_invulnerability - 1);
    mask_index = (state == PlayerState.BAT) ? spr_mask_bat : spr_vampire_idle;
}
