/// @description Atualiza as leituras compartilhadas de chão e parede antes dos estados.
function player_update_contacts() {
    on_ground = place_meeting(x, y + 1, [obj_wall, obj_ground]);
    on_wall = place_meeting(x + 1, y, [obj_wall, obj_ground])
            - place_meeting(x - 1, y, [obj_wall, obj_ground]);
}
