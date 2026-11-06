/// @description Segue o player com look-ahead horizontal e impede a câmera de sair da sala.
// === SEGUIR O PLAYER COM SUAVIZAÇÃO E LOOK-AHEAD ===
if (variable_global_exists("is_paused") && global.is_paused) exit;
var _shake_x = 0;
var _shake_y = 0;
if (shake_timer > 0) {
    shake_timer--;
    _shake_x = irandom_range(-shake_amount, shake_amount);
    _shake_y = irandom_range(-shake_amount, shake_amount);
} else shake_amount = 0;
if (instance_exists(obj_player)) {
    // Calculando a antecipação (look-ahead) baseada na velocidade do player
    var _target_look_ahead = obj_player.hsp * look_ahead_factor;
    look_ahead_x = lerp(look_ahead_x, _target_look_ahead, 0.1);

    // Posição alvo: centraliza o player na view com o offset do look-ahead
    var _target_x = (obj_player.x + look_ahead_x) - (view_w / 2);
    var _target_y = obj_player.y - (view_h / 2);
    
    // Limita aos limites da sala (não mostra fora da sala)
    _target_x = clamp(_target_x, 0, max(0, room_width - view_w));
    _target_y = clamp(_target_y, 0, max(0, room_height - view_h));
    
    // Posição atual da câmera
    var _cam_x = follow_x;
    var _cam_y = follow_y;
    
    // Suavização com lerp (seguimento gradual)
    var _new_x = lerp(_cam_x, _target_x, follow_speed);
    var _new_y = lerp(_cam_y, _target_y, follow_speed);
    
    // Aplica a posição da câmera
    follow_x = _new_x;
    follow_y = _new_y;
    camera_set_view_pos(cam,
        clamp(round(follow_x) + _shake_x, 0, max(0, room_width - view_w)),
        clamp(round(follow_y) + _shake_y, 0, max(0, room_height - view_h)));
}
