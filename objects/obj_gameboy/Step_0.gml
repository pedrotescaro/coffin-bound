/// @description Alterna a visibilidade do filtro Game Boy quando G é pressionado.
// Aperte 'G' para ligar/desligar o visual de Game Boy
if (layer_exists(camada_filtro) && keyboard_check_pressed(ord("G"))) {
    // Descobre se a camada está visível agora
    var _estado_atual = layer_get_visible(camada_filtro);
    
    // Inverte o estado (se estava ligado, desliga. Se estava desligado, liga)
    layer_set_visible(camada_filtro, !_estado_atual);
}
