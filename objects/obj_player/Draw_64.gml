/// @description Renderiza HUD, feedback de dano e informações de depuração do player.
// ============================================================
// obj_player — EVENTO DRAW GUI
// HUD com o Sprite Oficial 77x26 (spr_hud: Frame 1 Vazio / Frame 0 Cheio)
// ============================================================

// 1. Trava a resolução da camada GUI em 480x270 (Pixel-Perfect)
cb_gui_apply();
var _gui_w = 480;
var _gui_h = 270;

// Configuração de fonte padrão monogramada
if (font_exists(fnt_monogram)) {
    draw_set_font(fnt_monogram);
} else {
    draw_set_font(-1);
}

// === MENSAGEM DE VITÓRIA ===
if (level_won) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(_gui_w / 2, _gui_h / 2, "COFFIN BOUND!", 2, 2, 0);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}


// ╔════════════════════════════════════════════════════════════╗
// ║  RENDERIZAÇÃO DO HUD 77x26 (spr_hud)                       ║
// ╚════════════════════════════════════════════════════════════╝

var _hud_x = 8;
var _hud_y = 8;
var _scale = 1; // Um pixel do HUD por pixel lógico.

if (sprite_exists(spr_hud)) {
    // 1. Desenha a Moldura com Trilhos Vazios (Frame 1 do spr_hud)
    draw_sprite_ext(spr_hud, 1, _hud_x, _hud_y, _scale, _scale, 0, c_white, 1.0);

    // 2. Rastro de Dano / Sangramento na Barra de HP (Cor Verde Médio)
    var _trail_pct = clamp(hp_damage_trail / max_hp, 0, 1);
    var _hp_pct    = clamp(display_hp / max_hp, 0, 1);
    
    var _trail_fill_w = floor(51 * _trail_pct);
    var _hp_fill_w    = floor(51 * _hp_pct);

    // Rastro atrasado
    if (_trail_fill_w > _hp_fill_w) {
        var _diff_w = _trail_fill_w - _hp_fill_w;
        draw_sprite_part_ext(
            spr_hud, 0,
            18 + _hp_fill_w, 1, _diff_w, 10,
            _hud_x + ((18 + _hp_fill_w) * _scale), _hud_y + (1 * _scale),
            _scale, _scale, COLOR_GB_LIGHT, 0.7
        );
    }

    // 3. Preenchimento de Vida (HP) a partir do Frame 0 (Recorte X:18, Y:1 -> 51x10)
    if (_hp_fill_w > 0) {
        draw_sprite_part_ext(
            spr_hud, 0,
            18, 1, _hp_fill_w, 10,
            _hud_x + (18 * _scale), _hud_y + (1 * _scale),
            _scale, _scale, c_white, 1.0
        );
    }

    // 4. Preenchimento de Energia da habilidade a partir do Frame 0 (Recorte X:18, Y:15 -> 51x10)
    var _bat_pct    = clamp(display_bat / bat_energy_max, 0, 1);
    var _bat_fill_w = floor(51 * _bat_pct);

    var _voo_alpha = 1.0;
    if (bat_energy < 20 || state == PlayerState.BAT) {
        _voo_alpha = 0.5 + (dsin(current_time * 0.8) * 0.5); // Efeito de piscar sutil ao voar ou em bateria baixa
    }

    if (_bat_fill_w > 0) {
        draw_sprite_part_ext(
            spr_hud, 0,
            18, 15, _bat_fill_w, 10,
            _hud_x + (18 * _scale), _hud_y + (15 * _scale),
            _scale, _scale, c_white, _voo_alpha
        );
    }
}


// ╔════════════════════════════════════════════════════════════╗
// ║  PARTÍCULAS E DANO DA LUZ                                  ║
// ╚════════════════════════════════════════════════════════════╝
if (array_length(burn_particles) > 0 && camera_get_view_width(view_camera[0]) > 0) {
    var _cam_x = camera_get_view_x(view_camera[0]);
    var _cam_y = camera_get_view_y(view_camera[0]);
    var _scale_x = _gui_w / camera_get_view_width(view_camera[0]);
    var _scale_y = _gui_h / camera_get_view_height(view_camera[0]);

    for (var i = 0; i < array_length(burn_particles); i++) {
        var _p = burn_particles[i];
        var _screen_x = round((_p.px - _cam_x) * _scale_x);
        var _screen_y = round((_p.py - _cam_y) * _scale_y);
        
        draw_set_color(COLOR_GB_BRIGHT);
        draw_set_alpha(_p.alpha);
        draw_rectangle(_screen_x, _screen_y, _screen_x + _p.size, _screen_y + _p.size, false);
    }
    draw_set_alpha(1.0);
}

if (flash_hit > 0) {
    draw_set_color(COLOR_GB_BRIGHT);
    draw_set_alpha(0.15);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1.0);
}


// ╔════════════════════════════════════════════════════════════╗
// ║  DEBUG HUD (F3)                                           ║
// ╚════════════════════════════════════════════════════════════╝
if (!show_debug) exit;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(COLOR_GB_BRIGHT); 

var _estado_nome = "NORMAL";
switch(state) {
    case PlayerState.NORMAL:             _estado_nome = "NORMAL"; break;
    case PlayerState.JUMP:               _estado_nome = "PULO"; break;
    case PlayerState.FALL:               _estado_nome = "QUEDA"; break;
    case PlayerState.DAMAGE:             _estado_nome = "DANO"; break;
    case PlayerState.DEATH:              _estado_nome = "MORTE"; break;
    case PlayerState.DASH:               _estado_nome = "DASH"; break;
    case PlayerState.WALL_SLIDE:         _estado_nome = "WALL SLIDE"; break;
    case PlayerState.TRANSFORM_TO_HUMAN: _estado_nome = "TRANSFORM -> HUMAN"; break;
    case PlayerState.BAT:                _estado_nome = "BAT"; break;
    case PlayerState.WIN:                _estado_nome = "WIN"; break;
}

var _xx = 10;
var _yy = 45;
var _sep = 14;

draw_text(_xx, _yy, "--- DEBUG PLAYER ---");
_yy += _sep;

draw_text(_xx, _yy, "State: " + _estado_nome);
_yy += _sep;
draw_text(_xx, _yy, "HP: " + string(floor(hp)) + " / " + string(max_hp));
_yy += _sep;
draw_text(_xx, _yy, "Bat Energy: " + string(floor(bat_energy)) + " / " + string(bat_energy_max));
_yy += _sep;
if (state == PlayerState.BAT) {
    var _bat_phase_nome = (bat_phase == BatPhase.LAUNCH) ? "LAUNCH" : "FLIGHT";
    draw_text(_xx, _yy, "Bat: " + _bat_phase_nome + " | Stamina: " + string(floor((1 - bat_fatigue) * 100)) + "%");
    _yy += _sep;
}

draw_set_color(c_white);
