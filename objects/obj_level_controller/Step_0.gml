/// @description Controla armadilhas, checkpoints e dialogos da fase expandida.
if (global.is_paused || !instance_exists(obj_player)) exit;

var _player = instance_find(obj_player, 0);
if (respawn_cooldown > 0) respawn_cooldown--;
checkpoint_timer = max(0, checkpoint_timer - 1);
for (var _i = array_length(fx_particles) - 1; _i >= 0; _i--) {
    var _p = fx_particles[_i];
    _p.px += _p.vx;
    _p.py += _p.vy;
    _p.vy += 0.06;
    _p.life--;
    if (_p.life <= 0) array_delete(fx_particles, _i, 1);
}
if (_player.state == PlayerState.DEATH) {
    if (!death_handled) {
        death_handled = true;
        global.cb.deaths++;
        cb_save_progress();
        cb_play_sfx(snd_cb_death);
        cb_shake(2, 10);
        emit_burst(_player.x, _player.y - 8, 24, make_color_rgb(139,172,15));
    }
    if (_player.death_timer >= 24) {
        if (InputPressed(INPUT_VERB.MENU_ACCEPT) || keyboard_check_pressed(ord("R"))) respawn_player();
        else if (InputPressed(INPUT_VERB.MENU_BACK)) room_goto(rm_menu);
    }
    exit;
}
if (_player.state == PlayerState.WIN) {
    if (!win_handled) {
        win_handled = true;
        cb_play_sfx(snd_cb_win);
        emit_burst(_player.x, _player.y - 8, 24, COLOR_LEVEL_BRIGHT);
    }
    if (_player.win_timer <= 0) cb_complete_level();
    exit;
}

// Checkpoints invisiveis deixam as tentativas curtas, no ritmo de Celeste.
if (checkpoint < 1 && _player.x >= 780) {
    set_checkpoint(1);
}
if (checkpoint < 2 && _player.x >= 1264) {
    set_checkpoint(2);
}
if (checkpoint < 3 && _player.x >= 1536) {
    set_checkpoint(3);
}

if (!global.dialogue_active) {
    if (!dialogue_seen[0]) {
        dialogue_intro_timer--;
        if (dialogue_intro_timer <= 0) {
            dialogue_seen[0] = true;
            start_dialogue("VAMPIRO", "A noite engoliu a trilha.\nMeu caixao deve estar adiante.");
        }
    } else if (!dialogue_seen[1] && _player.x >= 570) {
        dialogue_seen[1] = true;
        start_dialogue("ECO DA CRIPTA", "Os espinhos guardam o caminho.\nPule, escale e use o dash.");
    } else if (!dialogue_seen[2] && _player.x >= 1030) {
        dialogue_seen[2] = true;
        start_dialogue("VAMPIRO", "Quanto mais fundo eu vou,\nmais perto de casa me sinto.");
    } else if (!dialogue_seen[3] && _player.x >= 1510) {
        dialogue_seen[3] = true;
        start_dialogue("ECO DA CRIPTA", "Uma ultima travessia.\nNao olhe para baixo.");
    }
}

if (global.dialogue_active) {
    var _advance = InputPressed(INPUT_VERB.MENU_ACCEPT) || InputPressed(INPUT_VERB.PLAYER_JUMP);

    for (var _pad = 0; _pad < 4; _pad++) {
        if (gamepad_is_connected(_pad) && gamepad_button_check_pressed(_pad, gp_face1)) {
            _advance = true;
        }
    }

    if (_advance) {
        if (dialogue_typist.get_state() < 1) {
            dialogue_typist.skip();
        } else {
            global.dialogue_active = false;
            _player.suppress_action_press = true;
            _player.buffer_counter = 0;
        }
    }
    exit;
}

if (respawn_cooldown <= 0) {
    var _hit_hazard = (_player.bbox_top >= room_height);
    if (!_hit_hazard) {
        _hit_hazard = collision_rectangle(
            _player.bbox_left,
            _player.bbox_top,
            _player.bbox_right,
            _player.bbox_bottom,
            obj_spike,
            false,
            true
        ) != noone;
    }
    if (_hit_hazard && _player.state != PlayerState.WIN && _player.state != PlayerState.DEATH) {
        with (_player) player_die();
    }
}

if (_player.on_ground && !last_grounded) emit_burst(_player.x, _player.bbox_bottom, 6, COLOR_LEVEL_LIGHT);
if (_player.state == PlayerState.BAT && !last_bat) emit_burst(_player.x, _player.y - 8, 12, make_color_rgb(139,172,15));
last_grounded = _player.on_ground;
last_bat = _player.state == PlayerState.BAT;
