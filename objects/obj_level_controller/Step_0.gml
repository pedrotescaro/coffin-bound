/// @description Controla armadilhas, checkpoints e dialogos da fase expandida.
if (!instance_exists(obj_player)) exit;

var _player = instance_find(obj_player, 0);
if (respawn_cooldown > 0) respawn_cooldown--;

// Checkpoints invisiveis deixam as tentativas curtas, no ritmo de Celeste.
if (checkpoint < 1 && _player.x >= 780) {
    checkpoint = 1;
    respawn_x = 790;
    respawn_y = 118;
}
if (checkpoint < 2 && _player.x >= 1264) {
    checkpoint = 2;
    respawn_x = 1290;
    respawn_y = 230;
}
if (checkpoint < 3 && _player.x >= 1536) {
    checkpoint = 3;
    respawn_x = 1565;
    respawn_y = 342;
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
    var _advance = keyboard_check_pressed(vk_space)
        || keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(ord("E"));

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
        }
    }
    exit;
}

if (respawn_cooldown <= 0) {
    var _hit_hazard = (_player.y > room_height - 12);
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
    if (_hit_hazard) respawn_player();
}
