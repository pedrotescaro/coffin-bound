/// @description Inicia o dash e configura sua direção, velocidade e feedback visual.
/// Transições centralizadas evitam esquecer resets de timers ou velocidade.
function player_start_dash() {
    state = PlayerState.DASH;
    can_dash = false;
    dash_timer = dash_duration;
    var _h_input = input_move_x;
    var _v_input = input_move_y;
    var _direction = (_h_input == 0 && _v_input == 0)
                   ? ((image_xscale == 1) ? 0 : 180)
                   : point_direction(0, 0, _h_input, _v_input);
    dash_hsp = lengthdir_x(dash_spd, _direction);
    dash_vsp = lengthdir_y(dash_spd, _direction);
    player_visual_start_dash(_direction);
}

/// @description Valida a entrada da habilidade e inicia o morcego com impulso imediato.
function player_try_start_bat() {
    if (!input_transform
    || (state != PlayerState.NORMAL && state != PlayerState.WALL_SLIDE)
    || bat_energy < max(bat_min_to_transform, bat_activation_cost)) return;

    var _h_input = input_move_x;
    var _v_input = input_move_y;
    var _direction = (_h_input == 0 && _v_input == 0)
                   ? ((image_xscale >= 0) ? 0 : 180)
                   : point_direction(0, 0, _h_input, _v_input);

    state = PlayerState.BAT;
    bat_phase = BatPhase.LAUNCH;
    bat_launch_timer = bat_launch_frames;
    bat_flight_timer = bat_flight_duration;
    bat_fatigue = 0;
    bat_wing_speed = bat_wing_speed_fresh;
    bat_landing_grace_timer = bat_landing_grace_frames;
    bat_energy = max(0, bat_energy - bat_activation_cost);
    hsp = lengthdir_x(bat_launch_speed, _direction);
    vsp = lengthdir_y(bat_launch_speed, _direction);
    if (_h_input != 0) image_xscale = _h_input;
}

/// @description Inicia o retorno visual seguro do morcego para a forma humana.
function player_return_to_human() {
    // O retorno só é solicitado pelo pouso do morcego no resolvedor de colisão.
    state = PlayerState.TRANSFORM_TO_HUMAN;
    transform_timer = transform_duration;
}
