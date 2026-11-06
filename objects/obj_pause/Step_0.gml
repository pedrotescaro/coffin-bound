var _player = instance_find(obj_player, 0);
if (_player == noone || room == rm_menu) exit;
if (_player.state == PlayerState.DEATH || _player.state == PlayerState.WIN) exit;

var _pause = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P"));
for (var _pad = 0; _pad < 12; _pad++) {
    if (gamepad_is_connected(_pad) && gamepad_button_check_pressed(_pad, gp_start)) _pause = true;
}
if (_pause) {
    pause_set_active(!global.is_paused);
    exit;
}
if (!global.is_paused) exit;

var _vertical = InputRepeat(INPUT_VERB.DOWN) - InputRepeat(INPUT_VERB.UP);
if (_vertical != 0) {
    var _previous = selected;
    selected = clamp(selected + sign(_vertical), 0, array_length(pause_menu) - 1);
    if (selected != _previous) cb_play_sfx(snd_cb_ui);
}
selectLerp = lerp(selectLerp, selected, 0.25);
if (InputPressed(INPUT_VERB.MENU_BACK)) {
    pause_set_active(false);
    exit;
}
if (!InputPressed(INPUT_VERB.MENU_ACCEPT)) exit;
pause_set_active(false);
switch (selected) {
    case 0: break;
    case 1:
        var _controller = instance_find(obj_level_controller, 0);
        if (_controller != noone) _controller.respawn_player();
        else with (_player) player_reset(xstart, ystart);
        break;
    case 2:
        global.dialogue_active = false;
        room_goto(rm_menu);
        break;
}
