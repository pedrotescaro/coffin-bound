/// @description Seleciona sprite e velocidade de animação a partir do estado já calculado.
/// A animação é consequência do estado; ela não decide física nem transições.
function player_update_animation() {
    switch (state) {
        case PlayerState.NORMAL:
            image_speed = 1;
            // Pulo e queda são comunicados por squash/stretch, não por sprites próprios.
            sprite_index = (abs(hsp) > 0.5) ? spr_vampire_walk : spr_vampire_idle;
            break;
        case PlayerState.DASH:
            image_speed = 1;
            sprite_index = spr_vampire_dash;
            break;
        case PlayerState.WALL_SLIDE:
            image_speed = 1;
            sprite_index = spr_vampire_idle;
            break;
        case PlayerState.TRANSFORM_TO_HUMAN:
            image_speed = 1;
            sprite_index = spr_vampire_dash;
            break;
        case PlayerState.BAT:
            sprite_index = spr_bat;
            image_speed = bat_wing_speed;
            break;
        case PlayerState.WIN:
            image_speed = 1;
            sprite_index = spr_vampire_idle;
            break;
    }
}
