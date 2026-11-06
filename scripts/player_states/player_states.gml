/// @description Classifica os estados que compartilham a física humana.
function player_is_human_state(_state) {
    return _state == PlayerState.NORMAL || _state == PlayerState.JUMP
        || _state == PlayerState.FALL || _state == PlayerState.DAMAGE;
}

/// @description Aproxima sem ultrapassar o alvo; unidades em pixels/frame.
function player_approach(_value, _target, _amount) {
    return _value + clamp(_target - _value, -_amount, _amount);
}

/// @description Seleciona o estado humano depois de atualizar movimento/contatos.
function player_sync_human_state() {
    if (!player_is_human_state(state) || (state == PlayerState.DAMAGE && damage_timer > 0)) return;
    state = (on_ground && vsp >= 0) ? PlayerState.NORMAL
        : ((vsp < 0) ? PlayerState.JUMP : PlayerState.FALL);
}

/// @description Executa a física do estado atual.
function player_update_state() {
    switch (state) {
        case PlayerState.NORMAL:
        case PlayerState.JUMP:
        case PlayerState.FALL:
        case PlayerState.DAMAGE: player_state_normal(); break;
        case PlayerState.DASH: player_state_dash(); break;
        case PlayerState.WALL_SLIDE: player_state_wall_slide(); break;
        case PlayerState.TRANSFORM_TO_HUMAN: player_state_transform_human(); break;
        case PlayerState.BAT: player_state_bat(); break;
        case PlayerState.WIN: player_state_win(); break;
        case PlayerState.DEATH: hsp = 0; vsp = 0; break;
    }
}

/// @description Caminhada, pulo variável e transições da forma humana.
function player_state_normal() {
    if (wall_jump_timer <= 0) {
        var _target = move_input * walk_spd;
        var _acceleration = on_ground ? accel_ground : accel_air;
        if (abs(move_input) < 0.01) _acceleration = on_ground ? friction_ground : friction_air;
        hsp = player_approach(hsp, _target, _acceleration);
    }

    vsp = min(vsp + grv, max_vsp);
    if (move_input != 0 && wall_jump_timer == 0) facing_dir = sign(move_input);
    if (on_ground) can_dash = true;

    if (buffer_counter > 0 && on_wall != 0 && !on_ground) {
        player_start_wall_jump();
    } else if (buffer_counter > 0 && coyote_counter > 0) {
        vsp = jump_spd;
        buffer_counter = 0;
        coyote_counter = 0;
        on_ground = false;
        move_remainder_y = 0;
        state = PlayerState.JUMP;
        player_visual_start_jump();
    }

    // Soltar o botão corta somente a subida, sem alterar o impulso horizontal.
    if (vsp < 0 && !input_jump_held) vsp = max(vsp, jump_spd / 2.5);
    if (input_dash && can_dash) {
        player_start_dash();
        return;
    }
    if (on_wall != 0 && !on_ground && vsp >= 0 && sign(move_input) == on_wall) {
        state = PlayerState.WALL_SLIDE;
        wall_stick_timer = wall_stick_max;
        return;
    }
    player_sync_human_state();
}

/// @description Mantém a velocidade do dash pelo tempo configurado.
function player_state_dash() {
    if (dash_timer <= 0) {
        hsp *= 0.5;
        vsp *= 0.5;
        state = PlayerState.FALL;
        player_state_normal();
        return;
    }
    hsp = dash_hsp;
    vsp = dash_vsp;
    dash_timer--;
    if (dash_timer mod 2 == 0) {
        var _trail = instance_create_depth(x, y, depth + 1, obj_dash_trail);
        _trail.sprite_index = spr_vampire_dash;
        _trail.image_index = image_index;
        _trail.image_speed = 0;
        _trail.image_xscale = facing_dir;
        _trail.image_blend = COLOR_GB_BRIGHT;
        _trail.image_alpha = 0.6;
    }
}

/// @description Valida a parede antes de aplicar salto ou aderência.
function player_state_wall_slide() {
    if (on_ground || on_wall == 0 || sign(move_input) == -on_wall) {
        state = on_ground ? PlayerState.NORMAL : PlayerState.FALL;
        wall_stick_timer = 0;
        player_state_normal();
        return;
    }
    facing_dir = on_wall;
    if (buffer_counter > 0) {
        player_start_wall_jump();
        return;
    }
    if (input_dash && can_dash) {
        player_start_dash();
        return;
    }
    hsp = 0;
    if (wall_stick_timer > 0) {
        vsp = 0;
        wall_stick_timer--;
    } else {
        vsp = min(vsp + grv * 0.5, wall_slide_spd);
    }
}

/// @description Retorna à física humana; a máscara permanece constante entre formas.
function player_state_transform_human() {
    hsp = 0;
    vsp = 0;
    transform_timer--;
    if (transform_timer <= 0) {
        state = PlayerState.NORMAL;
        player_sync_human_state();
    }
}

/// @description Mantém vitória até o controlador apresentar a conclusão.
function player_state_win() {
    hsp = 0;
    vsp = 0;
    win_timer = max(0, win_timer - 1);
}
