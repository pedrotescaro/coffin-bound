/// @description Lê as ações de navegação do menu pelo sistema Inputs.
function menu_input_read()
{
    // O eixo positivo move a seleção para baixo na lista.
    menu_input_vertical = InputRepeat(INPUT_VERB.DOWN) - InputRepeat(INPUT_VERB.UP);
    menu_input_accept = InputPressed(INPUT_VERB.MENU_ACCEPT);
    menu_input_back = InputPressed(INPUT_VERB.MENU_BACK);
}
