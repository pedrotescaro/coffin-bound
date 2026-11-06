/// @description Atualiza interações e HUD que dependem da posição final após a colisão.
function player_update_post_step() {
    if (state != PlayerState.WIN && state != PlayerState.BAT) {
        var _coffin = instance_place(x, y, obj_coffin);
        if (_coffin != noone && _coffin.sprite_index != spr_coffin_open) {
            _coffin.sprite_index = spr_coffin_open;
            state = PlayerState.WIN;
            level_won = true;
            win_timer = 120;
        }
    }

    // HUD suaviza em um único ponto para não receber dois lerps no mesmo frame.
    display_hp = lerp(display_hp, hp, 0.15);
    hp_damage_trail = lerp(hp_damage_trail, hp, 0.04);
    display_bat = lerp(display_bat, bat_energy, 0.2);
}
