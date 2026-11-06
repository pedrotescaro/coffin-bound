/// @description Segue o player com look-ahead horizontal e impede a câmera de sair da sala.
// === SEGUIR O PLAYER COM SUAVIZAÇÃO E LOOK-AHEAD ===
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
    var _cam_x = camera_get_view_x(cam);
    var _cam_y = camera_get_view_y(cam);
    
    // Suavização com lerp (seguimento gradual)
    var _new_x = lerp(_cam_x, _target_x, follow_speed);
    var _new_y = lerp(_cam_y, _target_y, follow_speed);
    
    // Aplica a posição da câmera
    camera_set_view_pos(cam, _new_x, _new_y);
}
