/// @description Reserva para sincronizar futuras animações de transformação pelo Animation End.
// ============================================================
// obj_player — EVENTO ANIMATION END
// Usado quando tiver o sprite spr_vampire_transform
// ============================================================

// Por enquanto a transição usa timer (transform_timer no Step).
// Quando criar spr_vampire_transform, descomentar e
// remover o sistema de timer do Step:

// if (state == PlayerState.TRANSFORM_TO_HUMAN) {
//     state = PlayerState.NORMAL;
//     sprite_index = spr_vampire_idle;
//     
//     // Push-out: empurra o player pra fora se ficou dentro de parede
//     var _safe = 0;
//     while (place_meeting(x, y, [obj_wall, obj_ground]) && _safe < 64) {
//         if (!place_meeting(x, y - 1, [obj_wall, obj_ground])) y--;
//         else if (!place_meeting(x, y + 1, [obj_wall, obj_ground])) y++;
//         else if (!place_meeting(x + 1, y, [obj_wall, obj_ground])) x++;
//         else if (!place_meeting(x - 1, y, [obj_wall, obj_ground])) x--;
//         else y--;
//         _safe++;
//     }
//     if (!on_ground) vsp = -2;
// }
