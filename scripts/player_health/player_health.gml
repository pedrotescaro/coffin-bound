/// @description Aplica dano por luz e atualiza as partículas de queima do player.
/// Dano de luz fica fora dos estados de movimento para funcionar em qualquer forma.
function player_update_health() {
    var _in_light = false;
    var _light_source = instance_nearest(x, y, obj_light);
    if (_light_source != noone && instance_exists(_light_source)) {
        var _radius = variable_instance_exists(_light_source, "light_radius") ? _light_source.light_radius : light_damage_radius;
        if (point_distance(x, y, _light_source.x, _light_source.y) < _radius) _in_light = true;
    }

    if (!_in_light) {
        var _candle = instance_nearest(x, y, obj_candle);
        if (_candle != noone && instance_exists(_candle) && _candle.is_active) {
            if (point_distance(x, y, _candle.x, _candle.y) < light_damage_radius) _in_light = true;
        }
    }

    if (_in_light) {
        hp -= light_damage_rate;
        flash_hit = 2;
        damage_pulse += 0.25;
        for (var p = 0; p < 2; p++) {
            array_push(burn_particles, {
                px: x + random_range(-10, 10), py: y + random_range(-14, 6),
                vx: random_range(-0.6, 0.6), vy: random_range(-1.8, -0.6),
                alpha: 1.0, life: irandom_range(16, 28), max_life: 28, size: random_range(2, 4)
            });
        }
        if (hp <= 0) {
            hp = 0;
            room_restart();
        }
    }

    for (var i = array_length(burn_particles) - 1; i >= 0; i--) {
        var _part = burn_particles[i];
        _part.px += _part.vx;
        _part.py += _part.vy;
        _part.life--;
        _part.alpha = _part.life / _part.max_life;
        if (_part.life <= 0) array_delete(burn_particles, i, 1);
    }

    if (flash_hit > 0) flash_hit--;
}
