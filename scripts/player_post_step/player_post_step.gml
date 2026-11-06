/// @description Atualiza interações e HUD após a posição final.
function player_update_post_step() {
    if (player_is_human_state(state) || state == PlayerState.WALL_SLIDE) {
        var _coffin = instance_place(x, y, obj_coffin);
        if (_coffin != noone) {
            _coffin.sprite_index = spr_coffin_open;
            state = PlayerState.WIN;
            level_won = true;
            win_timer = 120;
            hsp = 0;
            vsp = 0;
            move_remainder_x = 0;
            move_remainder_y = 0;
        }
    }
    display_hp = lerp(display_hp, hp, 0.15);
    hp_damage_trail = lerp(hp_damage_trail, hp, 0.04);
    display_bat = lerp(display_bat, bat_energy, 0.2);
}
