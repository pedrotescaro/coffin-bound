/// @description Atualiza chama, recarga o dash do player e gerencia o respawn da vela.
// === ESTADO ATIVO: VELA ACESA ===
if (is_active) {
    // --- EFEITO DE FLICKER (piscar da chama) ---
    flicker_timer++;
    if (flicker_timer >= flicker_speed) {
        flicker_timer = 0;
        flicker_speed = irandom_range(3, 8);
        // Varia levemente a escala Y para simular a chama oscilando
        image_yscale = base_yscale + random_range(-0.03, 0.03);
    }
    
    // --- COLISÃO COM PLAYER: Recarrega o Dash! ---
    var _player = instance_place(x, y, obj_player);
    if (_player != noone && !_player.can_dash) {
        // Recarrega o dash no ar (como gemas do Celeste!)
        _player.can_dash = true;
        
        // Desativa a vela temporariamente
        is_active = false;
        respawn_timer = respawn_time;
        image_alpha = 0.2; // Fica quase invisível (apagada)
        image_yscale = base_yscale;
    }
}
// === ESTADO INATIVO: VELA APAGADA (COOLDOWN) ===
else {
    respawn_timer--;
    if (respawn_timer <= 0) {
        is_active = true;
        image_alpha = 1.0; // Volta a brilhar
    }
}
