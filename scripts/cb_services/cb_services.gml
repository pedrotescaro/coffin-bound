/// @description Preferências e progresso são arquivos independentes no sandbox do jogo.
function cb_boot() {
    if (variable_global_exists("cb")) return;
    global.cb = {
        master: 0.8, music: 0.45, sfx: 0.7, fullscreen: false, filter: false,
        keys: [ord("A"), ord("D"), ord("W"), ord("S"), vk_space, ord("C"), ord("F")],
        has_save: false, level: 0, checkpoint: 0, completed: false,
        deaths: 0, music_handle: -1
    };
    global.cb_levels = [rm_level1,rm_level2,rm_level3];
    global.cb_open_credits = false;
    global.is_paused = false;
    global.dialogue_active = false;
    ini_open("coffin_bound_settings.ini");
    global.cb.master = clamp(ini_read_real("audio", "master", 0.8), 0, 1);
    global.cb.music = clamp(ini_read_real("audio", "music", 0.45), 0, 1);
    global.cb.sfx = clamp(ini_read_real("audio", "sfx", 0.7), 0, 1);
    global.cb.fullscreen = ini_read_real("display", "fullscreen", 0) != 0;
    global.cb.filter = ini_read_real("display", "filter", 0) != 0;
    var _defaults = variable_clone(global.cb.keys);
    var _invalid = false;
    for (var _i = 0; _i < 7; _i++) {
        var _key = floor(ini_read_real("controls", string(_i), _defaults[_i]));
        if (!cb_key_valid(_key)) _invalid = true;
        global.cb.keys[_i] = _key;
        for (var _j = 0; _j < _i; _j++) {
            if (global.cb.keys[_j] == _key) _invalid = true;
        }
    }
    ini_close();
    if (_invalid) global.cb.keys = _defaults;
    cb_bindings_apply();

    if (file_exists("coffin_bound_save.ini")) {
        ini_open("coffin_bound_save.ini");
        var _version = ini_read_real("progress", "version", 0);
        var _level = floor(ini_read_real("progress", "level", -1));
        if (_version == 1 && _level >= 0 && _level < array_length(global.cb_levels)) {
            global.cb.has_save = true;
            global.cb.level = _level;
            global.cb.checkpoint = clamp(floor(ini_read_real("progress", "checkpoint", 0)), 0, 3);
            global.cb.completed = ini_read_real("progress", "completed", 0) != 0;
            global.cb.deaths = max(0, floor(ini_read_real("progress", "deaths", 0)));
        }
        ini_close();
    }
    global.cb_filter = global.cb.filter;
    // Navegadores só permitem fullscreen em resposta direta ao input do usuário.
    if (os_browser == browser_not_a_browser) window_set_fullscreen(global.cb.fullscreen);
    else global.cb.fullscreen = window_get_fullscreen();
    audio_group_load(audiogroup_music);
    audio_group_load(audiogroup_sfx);
    cb_apply_audio();
}

function cb_key_valid(_key) {
    var _allowed = (_key >= ord("A") && _key <= ord("Z"))
        || (_key >= ord("0") && _key <= ord("9")) || _key == vk_space || _key == vk_shift;
    return _allowed && _key != ord("G") && _key != ord("P") && _key != ord("R");
}

function cb_key_name(_key) {
    switch (_key) {
        case vk_space: return "ESPACO";
        case vk_shift: return "SHIFT";
        case vk_left: return "ESQUERDA";
        case vk_right: return "DIREITA";
        case vk_up: return "CIMA";
        case vk_down: return "BAIXO";
    }
    return chr(_key);
}

function cb_bindings_apply() {
    var _verbs = [INPUT_VERB.PLAYER_LEFT, INPUT_VERB.PLAYER_RIGHT, INPUT_VERB.PLAYER_UP,
        INPUT_VERB.PLAYER_DOWN, INPUT_VERB.PLAYER_JUMP, INPUT_VERB.PLAYER_DASH, INPUT_VERB.PLAYER_BAT];
    var _arrows = [vk_left, vk_right, vk_up, vk_down];
    for (var _i = 0; _i < 7; _i++) {
        InputBindingSet(false, _verbs[_i], global.cb.keys[_i], 0);
        InputBindingSet(false, _verbs[_i], (_i < 4) ? _arrows[_i] : undefined, 1);
    }
}

function cb_save_settings() {
    ini_open("coffin_bound_settings.ini");
    ini_write_real("audio", "master", global.cb.master);
    ini_write_real("audio", "music", global.cb.music);
    ini_write_real("audio", "sfx", global.cb.sfx);
    ini_write_real("display", "fullscreen", global.cb.fullscreen);
    ini_write_real("display", "filter", global.cb.filter);
    for (var _i = 0; _i < 7; _i++) ini_write_real("controls", string(_i), global.cb.keys[_i]);
    ini_close();
}

function cb_apply_filter() {
    global.cb_filter = global.cb.filter;
    var _layer = layer_get_id("Efeito_Gameboy");
    if (layer_exists(_layer)) layer_set_visible(_layer, global.cb_filter);
}

function cb_toggle_fullscreen() {
    if (os_browser != browser_not_a_browser) return;
    window_set_fullscreen(!window_get_fullscreen());
    global.cb.fullscreen = window_get_fullscreen();
    cb_save_settings();
}

function cb_apply_audio() {
    audio_master_gain(global.cb.master);
    audio_group_set_gain(audiogroup_music, global.cb.music, 0);
    audio_group_set_gain(audiogroup_sfx, global.cb.sfx, 0);
}

function cb_audio_update() {
    if (audio_group_is_loaded(audiogroup_music)
        && (global.cb.music_handle < 0 || !audio_is_playing(global.cb.music_handle))) {
        global.cb.music_handle = audio_play_sound(snd_cb_music, 0, true);
    }
}

function cb_play_sfx(_sound) {
    if (audio_group_is_loaded(audiogroup_sfx)) audio_play_sound(_sound, 1, false);
}

function cb_save_progress() {
    ini_open("coffin_bound_save.ini");
    ini_write_real("progress", "version", 1);
    ini_write_real("progress", "level", global.cb.level);
    ini_write_real("progress", "checkpoint", global.cb.checkpoint);
    ini_write_real("progress", "completed", global.cb.completed);
    ini_write_real("progress", "deaths", global.cb.deaths);
    ini_close();
    global.cb.has_save = true;
}

function cb_start_game(_new) {
    if (_new) {
        global.cb.level = 0;
        global.cb.checkpoint = 0;
        global.cb.completed = false;
        global.cb.deaths = 0;
        cb_save_progress();
    }
    global.is_paused = false;
    global.dialogue_active = false;
    room_goto(global.cb_levels[global.cb.level]);
}

function cb_complete_level() {
    if (global.cb.level + 1 < array_length(global.cb_levels)) {
        global.cb.level++;
        global.cb.checkpoint = 0;
        cb_save_progress();
        room_goto(global.cb_levels[global.cb.level]);
    } else {
        global.cb.completed = true;
        cb_save_progress();
        global.cb_open_credits = true;
        room_goto(rm_menu);
    }
}

function cb_shake(_amount, _frames) {
    if (!instance_exists(obj_camera)) return;
    with (obj_camera) {
        shake_amount = max(shake_amount, _amount);
        shake_timer = max(shake_timer, _frames);
    }
}

function cb_burst(_x, _y, _count, _colour) {
    var _controller = instance_find(obj_level_controller, 0);
    if (_controller != noone) _controller.emit_burst(_x, _y, _count, _colour);
}
