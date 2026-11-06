/// @description Inicializa a câmera, o seguimento suave e os limites iniciais da sala.
// === CONFIGURAÇÃO DA CÂMERA ===
cam = view_camera[0];

// Suavização do seguimento (0.1 = suave, 1.0 = imediato)
follow_speed = 0.15;
look_ahead_factor = 6;
look_ahead_x = 0;

// Tamanho da view
view_w = camera_get_view_width(cam);
view_h = camera_get_view_height(cam);

// Centraliza a câmera no player imediatamente no início
if (instance_exists(obj_player)) {
    var _start_x = clamp(obj_player.x - (view_w / 2), 0, max(0, room_width - view_w));
    var _start_y = clamp(obj_player.y - (view_h / 2), 0, max(0, room_height - view_h));
    camera_set_view_pos(cam, _start_x, _start_y);
}

// Acumuladores suaves separados da posição inteira apresentada.
follow_x = camera_get_view_x(cam);
follow_y = camera_get_view_y(cam);
shake_timer = 0;
shake_amount = 0;
