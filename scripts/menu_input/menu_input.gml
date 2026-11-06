/// @description A navegação mantém comandos fixos mesmo após remapear o jogador.
function menu_input_read() {
    menu_input_vertical = InputRepeat(INPUT_VERB.DOWN) - InputRepeat(INPUT_VERB.UP);
    menu_input_horizontal = InputRepeat(INPUT_VERB.RIGHT) - InputRepeat(INPUT_VERB.LEFT);
    menu_input_accept = InputPressed(INPUT_VERB.MENU_ACCEPT);
    menu_input_back = InputPressed(INPUT_VERB.MENU_BACK);
}
