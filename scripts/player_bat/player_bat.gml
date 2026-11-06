/// @description Atualiza a física exclusiva do morcego: impulso, inércia, fadiga e sustentação.
/// Só este estado altera a stamina interna e a velocidade visual das asas.
function player_state_bat() {
    var _h_move = input_move_x;
    var _v_move = input_move_y;
    var _is_moving = (_h_move != 0 || _v_move != 0);

    // A stamina interna cai até 0, mas nunca encerra a transformação no ar.
    var _fatigue_target = clamp(1 - (bat_flight_timer / bat_flight_duration), 0, 1);
    bat_fatigue = lerp(bat_fatigue, _fatigue_target, bat_fatigue_lerp);

    // Todos os efeitos de cansaço usam a mesma fadiga suavizada.
    var _speed_cap = lerp(bat_speed_start, bat_speed_end, bat_fatigue);
    var _bat_gravity = lerp(bat_gravity_start, bat_gravity_end, bat_fatigue);
    var _lift_force = lerp(bat_lift_fresh, bat_lift_tired, bat_fatigue);
    var _wing_target = lerp(bat_wing_speed_fresh, bat_wing_speed_tired, bat_fatigue);
    bat_wing_speed = lerp(bat_wing_speed, _wing_target, bat_fatigue_lerp);
    var _control_accel = (bat_phase == BatPhase.LAUNCH) ? bat_launch_control_accel : bat_control_accel;
    var _target_hsp = 0;
    var _target_vsp = 0;

    if (_is_moving) {
        var _dir = point_direction(0, 0, _h_move, _v_move);
        _target_hsp = lengthdir_x(_speed_cap, _dir);
        _target_vsp = lengthdir_y(_speed_cap, _dir);
    }

    // O input puxa a velocidade para um alvo; não substitui a inércia diretamente.
    hsp = lerp(hsp, _target_hsp, _control_accel);
    vsp = lerp(vsp, _target_vsp, _control_accel);
    if (_v_move < 0) vsp -= _lift_force;
    vsp = min(vsp + _bat_gravity, bat_max_fall_speed);
    if (_h_move != 0) facing_dir = sign(_h_move);

    bat_flight_timer = max(0, bat_flight_timer - 1);
    if (bat_landing_grace_timer > 0) bat_landing_grace_timer--;
    if (bat_phase == BatPhase.LAUNCH) {
        bat_launch_timer--;
        if (bat_launch_timer <= 0) bat_phase = BatPhase.FLIGHT;
    }
}
