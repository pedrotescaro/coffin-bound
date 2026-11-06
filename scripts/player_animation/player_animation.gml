/// @description Seleciona animação sem alterar colisão ou transições.
function player_update_animation() {
    var _sprite = spr_vampire_idle;
    var _speed = 1;
    switch (state) {
        case PlayerState.NORMAL:
        case PlayerState.DAMAGE:
            _sprite = (abs(hsp) > 0.15) ? spr_vampire_walk : spr_vampire_idle;
            break;
        case PlayerState.JUMP: _sprite = spr_vampire_jump; break;
        case PlayerState.FALL: _sprite = spr_vampire_fall; break;
        case PlayerState.DASH:
        case PlayerState.TRANSFORM_TO_HUMAN: _sprite = spr_vampire_dash; break;
        case PlayerState.BAT:
            _sprite = spr_bat;
            _speed = bat_wing_speed;
            break;
        case PlayerState.DEATH: _speed = 0; break;
    }
    if (sprite_index != _sprite) image_index = 0;
    sprite_index = _sprite;
    image_speed = _speed;
}
