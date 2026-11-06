/// @description Resolve o movimento e a colisão pixel a pixel contra chão e paredes.
/// Estados calculam velocidade; este script é a única autoridade que altera posição.
function player_resolve_collision() {
    var _hsp_final = round(hsp);
    var _vsp_final = round(vsp);

    if (_hsp_final != 0 && place_meeting(x + _hsp_final, y, [obj_wall, obj_ground])) {
        if (state == PlayerState.DASH) state = PlayerState.NORMAL;
        var _step_h = sign(_hsp_final);
        var _safe_h = 0;
        while (!place_meeting(x + _step_h, y, [obj_wall, obj_ground]) && _safe_h < abs(_hsp_final) + 1) {
            x += _step_h;
            _safe_h++;
        }
        _hsp_final = 0;
        hsp = 0;
    }
    x += _hsp_final;

    if (_vsp_final != 0 && place_meeting(x, y + _vsp_final, [obj_wall, obj_ground])) {
        if (state == PlayerState.DASH && dash_vsp < 0) state = PlayerState.NORMAL;
        // Somente uma colisão descendente encerra a forma de morcego.
        if (state == PlayerState.BAT && _vsp_final > 0 && bat_landing_grace_timer <= 0) {
            player_return_to_human();
        }
        // Só dispara squash ao entrar no chão; colisões de repouso não achatam o idle.
        if (_vsp_final > 0 && !visual_was_on_ground) visual_landed = true;

        var _step_v = sign(_vsp_final);
        var _safe_v = 0;
        while (!place_meeting(x, y + _step_v, [obj_wall, obj_ground]) && _safe_v < abs(_vsp_final) + 1) {
            y += _step_v;
            _safe_v++;
        }
        _vsp_final = 0;
        vsp = 0;
    }
    y += _vsp_final;
}
