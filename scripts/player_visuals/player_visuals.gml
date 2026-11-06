// Esta camada só altera xscale_draw, yscale_draw e angle_draw usados no Draw.
// hsp, vsp e mask_index nunca são alterados aqui.
/// @description Dispara o stretch visual inicial do pulo sem alterar física ou hitbox.
function player_visual_start_jump() {
    xscale_draw = visual_jump_squash_x;
    yscale_draw = visual_jump_stretch_y;
}

/// @description Dispara a deformação visual do dash na direção informada.
/// @param _direction Direção do dash em graus.
function player_visual_start_dash(_direction) {
    visual_dash_timer = visual_dash_duration;
    visual_dash_direction = _direction;
}

/// @description Atualiza squash, stretch e inclinação visual a partir do estado e velocidade.
function player_update_visuals() {
    var _target_x = 1;
    var _target_y = 1;
    var _target_angle = 0;

    // O morcego possui animação própria; não herda deformações do vampiro.
    if (state != PlayerState.BAT) {
        if (visual_landed) {
            // Impacto é imediato; o retorno à forma neutra é interpolado abaixo.
            xscale_draw = visual_land_squash_x;
            yscale_draw = visual_land_squash_y;
        }

        // Sem sprites de pulo/queda: a velocidade vertical comunica o estado no corpo.
        if (!on_ground && state == PlayerState.NORMAL) {
            if (vsp < 0) {
                var _rise = clamp(abs(vsp) / abs(jump_spd), 0, 1);
                _target_x = lerp(1, visual_air_stretch_x, _rise);
                _target_y = lerp(1, visual_air_stretch_y, _rise);
            } else if (vsp > 0) {
                var _fall = clamp(vsp / max_vsp, 0, 1);
                _target_x = lerp(1, visual_fall_squash_x, _fall);
                _target_y = lerp(1, visual_fall_squash_y, _fall);
                _target_angle = sign(hsp) * visual_fall_tilt * _fall;
            }
        }

        if (visual_dash_timer > 0) {
            var _dash_strength = visual_dash_timer / visual_dash_duration;
            var _vertical = abs(lengthdir_y(1, visual_dash_direction));
            var _dash_x = lerp(visual_dash_stretch, visual_dash_squash, _vertical);
            var _dash_y = lerp(visual_dash_squash, visual_dash_stretch, _vertical);
            _target_x = lerp(_target_x, _dash_x, _dash_strength);
            _target_y = lerp(_target_y, _dash_y, _dash_strength);
            _target_angle = lengthdir_y(visual_dash_tilt, visual_dash_direction) * _dash_strength;
            visual_dash_timer--;
        }
    }

    xscale_draw = lerp(xscale_draw, _target_x, visual_recover_rate);
    yscale_draw = lerp(yscale_draw, _target_y, visual_recover_rate);
    angle_draw = lerp(angle_draw, _target_angle, visual_angle_recover_rate);
    visual_landed = false;
    // Leitura após a colisão: será usada para detectar o próximo pouso real.
    visual_was_on_ground = place_meeting(x, y + 1, [obj_wall, obj_ground]);
}
