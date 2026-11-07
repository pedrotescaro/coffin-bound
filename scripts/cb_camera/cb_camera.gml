/// @description Suavização por segundo; conserva a mesma resposta entre taxas de frames.
function cb_camera_blend(_rate, _seconds) {
    return 1 - exp(-_rate * _seconds);
}

/// @description Só desloca o enquadramento quando o foco sai da zona de tolerância.
function cb_camera_deadzone(_origin, _focus, _low, _high) {
    var _screen = _focus - _origin;
    if (_screen < _low) return _focus - _low;
    if (_screen > _high) return _focus - _high;
    return _origin;
}

/// @description Peças na mesma distância recebem exatamente a mesma transformação.
function cb_camera_parallax(_camera_x, _camera_y) {
    var _names = ["Fundo_Distante", "Pedra_Distante", "Nave_Media", "Nave_Animada", "Ornamentos_Proximos"];
    var _rates = [0.10, 0.25, 0.50, 0.50, 0.75];
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _layer = layer_get_id(_names[_i]);
        if (_layer == -1) continue;
        layer_x(_layer, round(_camera_x * (1 - _rates[_i])));
        layer_y(_layer, round(_camera_y * (1 - _rates[_i])));
    }
    // Peças apoiadas no piso e colisões usam as coordenadas do mundo.
}

/// @description Reenquadra imediatamente no início e após um checkpoint.
function cb_camera_snap() {
    look_ahead_x = 0;
    shake_timer = 0;
    shake_amount = 0;
    if (instance_exists(obj_player)) {
        var _focus_x = (obj_player.bbox_left + obj_player.bbox_right) * 0.5;
        var _focus_y = (obj_player.bbox_top + obj_player.bbox_bottom) * 0.5;
        follow_x = clamp(_focus_x - view_w * 0.5, 0, max(0, room_width - view_w));
        follow_y = clamp(_focus_y - view_h * 0.56, 0, max(0, room_height - view_h));
    }
    camera_set_view_pos(cam, round(follow_x), round(follow_y));
    cb_camera_parallax(round(follow_x), round(follow_y));
}
