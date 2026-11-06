/// @description Lê ações nomeadas do pacote Inputs para teclado e controle.
/// Estados usam input_* e move_input, sem consultar um dispositivo diretamente.
function player_input() {
    input_left = InputCheck(INPUT_VERB.PLAYER_LEFT);
    input_right = InputCheck(INPUT_VERB.PLAYER_RIGHT);
    input_up = InputCheck(INPUT_VERB.PLAYER_UP);
    input_down = InputCheck(INPUT_VERB.PLAYER_DOWN);
    input_jump_press = InputPressed(INPUT_VERB.PLAYER_JUMP);
    input_jump_held = InputCheck(INPUT_VERB.PLAYER_JUMP);
    input_dash = InputPressed(INPUT_VERB.PLAYER_DASH);
    input_transform = InputPressed(INPUT_VERB.PLAYER_BAT);
    input_restart = keyboard_check_pressed(ord("R"));

    // O cluster preserva intensidade do analógico, enquanto input_* serve às ações digitais.
    input_move_x = InputX(INPUT_CLUSTER.PLAYER_MOVE);
    input_move_y = InputY(INPUT_CLUSTER.PLAYER_MOVE);
    move_input = input_move_x;
    if (input_restart) room_restart();
}
