/// @description Atualiza partículas sem produzir novos efeitos em morte/vitória.
function player_update_burn_particles() {
    for (var _i = array_length(burn_particles) - 1; _i >= 0; _i--) {
        var _particle = burn_particles[_i];
        _particle.px += _particle.vx;
        _particle.py += _particle.vy;
        _particle.life--;
        _particle.alpha = _particle.life / _particle.max_life;
        if (_particle.life <= 0) array_delete(burn_particles, _i, 1);
    }
    flash_hit = max(0, flash_hit - 1);
}

/// @description Centraliza dano e entrada na morte; quantidade em HP.
function player_take_damage(_amount) {
    if (_amount <= 0 || respawn_invulnerability > 0
        || state == PlayerState.DEATH || state == PlayerState.WIN) return;
    hp = max(0, hp - _amount);
    flash_hit = 2;
    if (hp <= 0) {
        player_die();
    } else if (!was_in_light && player_is_human_state(state)) {
        cb_play_sfx(snd_cb_hurt);
        cb_shake(1, 5);
        state = PlayerState.DAMAGE;
        damage_timer = 10;
    }
}

/// @description Morte única para luz, espinhos e queda; controlador decide o retorno.
function player_die() {
    if (state == PlayerState.DEATH || state == PlayerState.WIN) return;
    hp = 0;
    state = PlayerState.DEATH;
    death_timer = 0;
    hsp = 0;
    vsp = 0;
    move_remainder_x = 0;
    move_remainder_y = 0;
    dash_timer = 0;
    buffer_counter = 0;
    coyote_counter = 0;
    visual_dash_timer = 0;
    image_speed = 0;
}

/// @description Examina todas as luzes e velas ativas, sem depender da mais próxima.
function player_update_health() {
    if (state == PlayerState.DEATH || state == PlayerState.WIN) return;
    var _in_light = false;
    var _count = instance_number(obj_light);
    for (var _i = 0; _i < _count; _i++) {
        var _source = instance_find(obj_light, _i);
        if (point_distance(x, y, _source.x, _source.y) < _source.light_radius) {
            _in_light = true;
            break;
        }
    }
    if (!_in_light) {
        _count = instance_number(obj_candle);
        for (var _j = 0; _j < _count; _j++) {
            var _candle = instance_find(obj_candle, _j);
            if (_candle.is_active && point_distance(x, y, _candle.x, _candle.y) < light_damage_radius) {
                _in_light = true;
                break;
            }
        }
    }
    if (_in_light) {
        player_take_damage(light_damage_rate);
        if (respawn_invulnerability <= 0 && state != PlayerState.DEATH) {
            damage_pulse += 0.25;
            // Limite explícito evita crescimento caso o efeito seja ajustado depois.
            repeat (min(2, max(0, 64 - array_length(burn_particles)))) {
                array_push(burn_particles, {
                    px: x + irandom_range(-10, 10), py: y + irandom_range(-14, 6),
                    vx: random_range(-0.6, 0.6), vy: random_range(-1.8, -0.6),
                    alpha: 1, life: irandom_range(16, 28), max_life: 28,
                    size: irandom_range(1, 2)
                });
            }
        }
    }
    was_in_light = _in_light;
}
