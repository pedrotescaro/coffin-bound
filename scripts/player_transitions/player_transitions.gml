/// @description Aplica o impulso do dash no mesmo frame da entrada.
function player_start_dash() {
    cb_play_sfx(snd_cb_dash);
    cb_shake(1, 5);
    state = PlayerState.DASH;
    can_dash = false;
    dash_timer = max(0, dash_duration - 1);
    var _direction = (input_move_x == 0 && input_move_y == 0)
        ? ((facing_dir >= 0) ? 0 : 180)
        : point_direction(0, 0, input_move_x, input_move_y);
    dash_hsp = lengthdir_x(dash_spd, _direction);
    dash_vsp = lengthdir_y(dash_spd, _direction);
    hsp = dash_hsp;
    vsp = dash_vsp;
    move_remainder_x = 0;
    move_remainder_y = 0;
    buffer_counter = 0;
    coyote_counter = 0;
    wall_stick_timer = 0;
    player_visual_start_dash(_direction);
}

/// @description Centraliza impulso e resets do wall jump.
function player_start_wall_jump() {
    if (on_wall == 0) return;
    state = PlayerState.JUMP;
    hsp = -on_wall * wall_jump_hsp;
    vsp = wall_jump_vsp;
    facing_dir = -on_wall;
    on_ground = false;
    buffer_counter = 0;
    coyote_counter = 0;
    wall_stick_timer = 0;
    wall_jump_timer = 10;
    move_remainder_x = 0;
    move_remainder_y = 0;
    player_visual_start_jump();
}

/// @description Valida a entrada da habilidade e inicia o morcego.
function player_try_start_bat() {
    if (!input_transform
        || (!player_is_human_state(state) && state != PlayerState.WALL_SLIDE)
        || bat_energy < max(bat_min_to_transform, bat_activation_cost)) return;
    cb_play_sfx(snd_cb_bat);
    var _direction = (input_move_x == 0 && input_move_y == 0)
        ? ((facing_dir >= 0) ? 0 : 180)
        : point_direction(0, 0, input_move_x, input_move_y);
    state = PlayerState.BAT;
    mask_index=spr_mask_bat;
    bat_phase = BatPhase.LAUNCH;
    bat_launch_timer = bat_launch_frames;
    bat_flight_timer = bat_flight_duration;
    bat_fatigue = 0;
    bat_wing_speed = bat_wing_speed_fresh;
    bat_landing_grace_timer = bat_landing_grace_frames;
    bat_energy = max(0, bat_energy - bat_activation_cost);
    hsp = lengthdir_x(bat_launch_speed, _direction);
    vsp = lengthdir_y(bat_launch_speed, _direction);
    move_remainder_x = 0;
    move_remainder_y = 0;
    buffer_counter = 0;
    coyote_counter = 0;
    wall_jump_timer = 0;
    if (input_move_x != 0) facing_dir = sign(input_move_x);
}

/// @description Inicia o retorno visual seguro após o pouso.
function player_return_to_human() {
    var _mask=mask_index;mask_index=spr_vampire_idle;
    if(place_meeting(x,y,[obj_wall,obj_ground])) {mask_index=_mask;return;}
    state = PlayerState.TRANSFORM_TO_HUMAN;
    transform_timer = transform_duration;
    hsp = 0;
    vsp = 0;
    move_remainder_x = 0;
    move_remainder_y = 0;
}

/// @description Reset completo do estado transitório; chamar no escopo do jogador.
function player_reset(_spawn_x, _spawn_y) {
    x = round(_spawn_x);
    y = round(_spawn_y);
    hsp = 0;
    vsp = 0;
    move_remainder_x = 0;
    move_remainder_y = 0;
    mask_index = spr_vampire_idle;
    state = PlayerState.NORMAL;
    prev_state = state;
    on_ground = false;
    on_wall = 0;
    move_input = 0;
    can_dash = true;
    dash_timer = 0;
    dash_hsp = 0;
    dash_vsp = 0;
    coyote_counter = 0;
    buffer_counter = 0;
    wall_jump_timer = 0;
    wall_stick_timer = 0;
    damage_timer = 0;
    respawn_invulnerability = 24;
    was_in_light = false;
    bat_energy = bat_energy_max;
    bat_launch_timer = 0;
    bat_flight_timer = 0;
    bat_fatigue = 0;
    bat_phase = BatPhase.LAUNCH;
    bat_wing_speed = bat_wing_speed_fresh;
    bat_landing_grace_timer = 0;
    transform_timer = 0;
    hp = max_hp;
    display_hp = max_hp;
    hp_damage_trail = max_hp;
    display_bat = bat_energy_max;
    flash_hit = 0;
    damage_pulse = 0;
    burn_particles = [];
    level_won = false;
    win_timer = 0;
    death_timer = 0;
    xscale_draw = 1;
    yscale_draw = 1;
    angle_draw = 0;
    visual_landed = false;
    visual_was_on_ground = false;
    visual_dash_timer = 0;
    visual_dash_direction = 0;
    sprite_index = spr_vampire_idle;
    image_index = 0;
    image_speed = 1;
    image_xscale = 1;
    facing_dir = 1;
    image_yscale = 1;
    image_angle = 0;
    image_alpha = 1;
    image_blend = c_white;
    input_left = false;
    input_right = false;
    input_up = false;
    input_down = false;
    input_jump_press = false;
    input_jump_held = false;
    input_dash = false;
    input_transform = false;
    input_restart = false;
    suppress_action_press = true;
    input_move_x = 0;
    input_move_y = 0;
    player_update_contacts();
    visual_was_on_ground = on_ground;
    player_sync_human_state();
}
