/// @description Executa exclusivamente a função do estado de movimento atual.
/// A ordem de colisão e animação permanece no Step do obj_player.
function player_update_state() {
    switch (state) {
        case PlayerState.NORMAL: player_state_normal(); break;
        case PlayerState.DASH: player_state_dash(); break;
        case PlayerState.WALL_SLIDE: player_state_wall_slide(); break;
        case PlayerState.TRANSFORM_TO_HUMAN: player_state_transform_human(); break;
        case PlayerState.BAT: player_state_bat(); break;
        case PlayerState.WIN: player_state_win(); break;
    }
}

/// @description Controla caminhada, gravidade, pulo, wall jump e transições do estado normal.
function player_state_normal() {
    if (wall_jump_timer <= 0) {
        var _target_hsp = move_input * walk_spd;
        hsp = lerp(hsp, _target_hsp, on_ground ? accel_ground : accel_air);
    }

    vsp = min(vsp + grv, max_vsp);
    if (move_input != 0 && wall_jump_timer == 0) image_xscale = sign(move_input);
    if (on_ground) can_dash = true;

    if (buffer_counter > 0 && on_wall != 0 && !on_ground) {
        hsp = -on_wall * wall_jump_hsp;
        vsp = wall_jump_vsp;
        buffer_counter = 0;
        wall_stick_timer = 0;
        wall_jump_timer = 10;
        image_xscale = -on_wall;
    } else if (buffer_counter > 0 && coyote_counter > 0) {
        vsp = jump_spd;
        buffer_counter = 0;
        coyote_counter = 0;
        y -= 1;
        player_visual_start_jump();
    }

    if (vsp < 0 && !input_jump_held) vsp = max(vsp, jump_spd / 2.5);
    if (input_dash && can_dash) player_start_dash();
    if (on_wall != 0 && !on_ground && vsp >= 0 && sign(move_input) == on_wall) {
        state = PlayerState.WALL_SLIDE;
        wall_stick_timer = wall_stick_max;
    }
}

/// @description Aplica a velocidade fixa do dash e cria o rastro visual enquanto ele dura.
function player_state_dash() {
    hsp = dash_hsp;
    vsp = dash_vsp;
    dash_timer--;
    if (dash_timer % 2 == 0) {
        var _trail = instance_create_depth(x, y, depth + 1, obj_dash_trail);
        _trail.sprite_index = sprite_index;
        _trail.image_index = image_index;
        _trail.image_xscale = image_xscale;
        _trail.image_blend = COLOR_GB_BRIGHT;
        _trail.image_alpha = 0.6;
    }
    if (dash_timer <= 0) {
        state = PlayerState.NORMAL;
        hsp *= 0.5;
        vsp *= 0.5;
    }
}

/// @description Controla aderência na parede, descida limitada e wall jump.
function player_state_wall_slide() {
    if (on_wall != 0) image_xscale = on_wall;
    if (wall_stick_timer > 0) {
        vsp = 0;
        wall_stick_timer--;
    } else {
        vsp = min(vsp + grv * 0.5, wall_slide_spd);
    }
    hsp = 0;

    if (buffer_counter > 0) {
        state = PlayerState.NORMAL;
        hsp = -on_wall * wall_jump_hsp;
        vsp = wall_jump_vsp;
        buffer_counter = 0;
        wall_stick_timer = 0;
        wall_jump_timer = 10;
        image_xscale = -on_wall;
        can_dash = true;
        return;
    }
    if (on_ground || on_wall == 0 || sign(move_input) == -on_wall) {
        state = PlayerState.NORMAL;
        wall_stick_timer = 0;
        if (on_ground) can_dash = true;
    }
    if (input_dash && can_dash) {
        player_start_dash();
        wall_stick_timer = 0;
    }
}

/// @description Executa a transição de retorno e remove o vampiro de paredes, se necessário.
function player_state_transform_human() {
    hsp = 0;
    vsp = 0;
    transform_timer--;
    if (transform_timer > 0) return;

    state = PlayerState.NORMAL;
    var _safe = 0;
    // Push-out preserva o retorno seguro caso o vampiro esteja dentro de geometria.
    while (place_meeting(x, y, [obj_wall, obj_ground]) && _safe < 64) {
        if (!place_meeting(x, y - 1, [obj_wall, obj_ground])) y--;
        else if (!place_meeting(x, y + 1, [obj_wall, obj_ground])) y++;
        else if (!place_meeting(x + 1, y, [obj_wall, obj_ground])) x++;
        else if (!place_meeting(x - 1, y, [obj_wall, obj_ground])) x--;
        else y--;
        _safe++;
    }
    if (!place_meeting(x, y + 1, [obj_wall, obj_ground])) vsp = -2;
}

/// @description Congela o player durante a vitória e reinicia a sala após o timer.
function player_state_win() {
    hsp = 0;
    vsp = 0;
    win_timer--;
    if (win_timer <= 0) room_restart();
}
