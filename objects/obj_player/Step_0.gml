/// @description Coordena input, recursos, estado, colisão e apresentação.
if (variable_global_exists("is_paused") && global.is_paused) exit;
if (keyboard_check_pressed(vk_f3)) show_debug = !show_debug;
if (variable_global_exists("dialogue_active") && global.dialogue_active) {
    hsp = 0;
    vsp = 0;
    move_remainder_x = 0;
    move_remainder_y = 0;
    move_input = 0;
    image_speed = 0;
    exit;
}

player_update_burn_particles();
if (state == PlayerState.DEATH) {
    death_timer++;
    player_update_post_step();
    exit;
}

prev_state = state;
player_input();
if (input_restart) {
    var _controller = instance_find(obj_level_controller, 0);
    if (_controller != noone) _controller.respawn_player();
    else player_reset(xstart, ystart);
    exit;
}
player_update_contacts();
player_update_resources();
player_update_health();
if (state == PlayerState.DEATH) exit;
player_try_start_bat();
player_update_state();
player_resolve_collision();
player_update_visuals();
player_update_animation();
player_update_post_step();
