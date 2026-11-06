/// @description Localiza e ativa inicialmente a camada do filtro visual Game Boy.
// Pega a ID da camada que você criou na Room
camada_filtro = layer_get_id("Efeito_Gameboy");

// Opcional: Já começa com o filtro ativado (true) ou desativado (false)
if (layer_exists(camada_filtro)) layer_set_visible(camada_filtro, true);
