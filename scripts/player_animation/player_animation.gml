/// @description Seleciona animação sem alterar colisão ou transições.
function player_update_animation() {
    var _sprite = spr_vampire_idle;
    var _speed = 1;
    var _pose = -1;
    switch (state) {
        case PlayerState.NORMAL:
        case PlayerState.DAMAGE:
            _sprite = (abs(hsp) > 0.15) ? spr_vampire_walk : spr_vampire_idle;
            break;
        // Poses legíveis evitam repetir o squash extremo da sequência-fonte no ar.
        case PlayerState.JUMP: _sprite = spr_vampire_jump; _pose = 11; _speed = 0; break;
        case PlayerState.FALL: _sprite = spr_vampire_fall; _pose = 11; _speed = 0; break;
        case PlayerState.DASH:
        case PlayerState.TRANSFORM_TO_HUMAN: _sprite = spr_vampire_dash; break;
        case PlayerState.BAT:
            _sprite = spr_bat;
            _speed = bat_wing_speed;
            break;
        case PlayerState.DEATH: _speed = 0; break;
    }
    if (_pose >= 0) image_index = min(_pose, sprite_get_number(_sprite) - 1);
    else if (sprite_index != _sprite) image_index = 0;
    sprite_index = _sprite;
    image_speed = _speed;
}
