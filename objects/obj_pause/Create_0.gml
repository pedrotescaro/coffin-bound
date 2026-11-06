/// @description Pausa por flag, sem remover instâncias do mundo.
cb_boot();
global.is_paused = false;
depth = -10000;
pause_menu = ["CONTINUAR", "REINICIAR CHECKPOINT", "MENU PRINCIPAL"];
selected = 0;
selectLerp = 0;
selectedCol = make_color_rgb(182, 204, 139);
notSelectedCol = make_color_rgb(233, 237, 197);
titleCol = notSelectedCol;
paused_player = noone;
paused_image_speed = 1;

pause_set_active = function(_active) {
    global.is_paused = _active;
    if (_active) {
        selected = 0;
        selectLerp = 0;
        paused_player = instance_find(obj_player, 0);
        if (paused_player != noone) {
            paused_image_speed = paused_player.image_speed;
            paused_player.image_speed = 0;
        }
    } else {
        if (instance_exists(paused_player)) {
            paused_player.image_speed = paused_image_speed;
            paused_player.suppress_action_press = true;
        }
        paused_player = noone;
    }
    cb_play_sfx(snd_cb_ui);
};
