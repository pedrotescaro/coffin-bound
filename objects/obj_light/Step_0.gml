/// @description Atualiza pulso, flicker e movimento cíclico das partículas de luz.
// ============================================================
// obj_light — EVENTO STEP
// Atualiza oscilação de brilho e movimento de poeira atmosférica
// ============================================================

pulse_timer += 0.03;
flicker = dsin(pulse_timer * 60) * 3;

// Atualiza poeira luminosa flutuante
for (var i = 0; i < array_length(light_particles); i++) {
    var _p = light_particles[i];
    _p.py += _p.speed_y;
    _p.px += _p.speed_x;
    
    // Reseta partícula ao subir fora do feixe de luz
    if (_p.py < y - light_radius * 0.7) {
        _p.py = y + light_radius * 0.7;
        _p.px = x + random_range(-light_radius * 0.6, light_radius * 0.6);
        _p.alpha = random_range(0.2, 0.6);
    }
}
