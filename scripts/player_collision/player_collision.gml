/// @description Varre cada pixel e guarda frações entre frames para movimento suave.
function player_resolve_collision() {
    if (state == PlayerState.DEATH || state == PlayerState.WIN) return;
    move_remainder_x += hsp;
    move_remainder_y += vsp;
    var _move_x = sign(move_remainder_x) * floor(abs(move_remainder_x));
    var _move_y = sign(move_remainder_y) * floor(abs(move_remainder_y));
    move_remainder_x -= _move_x;
    move_remainder_y -= _move_y;

    var _direction_x = sign(_move_x);
    repeat (abs(_move_x)) {
        if (place_meeting(x + _direction_x, y, [obj_wall, obj_ground])) {
            hsp = 0;
            move_remainder_x = 0;
            if (state == PlayerState.DASH) {
                state = PlayerState.FALL;
                vsp = 0;
                _move_y = 0;
                move_remainder_y = 0;
            }
            break;
        }
        x += _direction_x;
    }

    var _direction_y = sign(_move_y);
    repeat (abs(_move_y)) {
        if (place_meeting(x, y + _direction_y, [obj_wall, obj_ground])) {
            vsp = 0;
            move_remainder_y = 0;
            if (_direction_y > 0) {
                if (!visual_was_on_ground) visual_landed = true;
                can_dash = true;
                if (state == PlayerState.BAT && bat_landing_grace_timer <= 0) player_return_to_human();
            }
            if (state == PlayerState.DASH) {
                state = PlayerState.FALL;
                hsp = 0;
                move_remainder_x = 0;
            }
            break;
        }
        y += _direction_y;
    }

    // Impede sair pelas laterais/topo; o fundo permanece aberto para morte por queda.
    if (bbox_left < 0) { x -= bbox_left; hsp = 0; move_remainder_x = 0; }
    if (bbox_right >= room_width) { x -= bbox_right - room_width + 1; hsp = 0; move_remainder_x = 0; }
    if (bbox_top < 0) { y -= bbox_top; vsp = max(0, vsp); move_remainder_y = 0; }

    player_update_contacts();
    // Voo fatigado pode pousar sem acumular um pixel vertical neste frame.
    if (state == PlayerState.BAT && on_ground && vsp >= 0 && bat_landing_grace_timer <= 0) player_return_to_human();
    player_sync_human_state();
}
