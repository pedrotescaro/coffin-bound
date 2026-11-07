# Montagem modular 0.3.1

As camadas estavam vazias nos arquivos salvos pela IDE. O gerador gravava os dados comprimidos sem `TileDataFormat: 1`. A correção grava esse campo e usa zero nas células vazias. A prévia agora lê os dados persistidos das rooms.

Os estandartes, as teias e as gárgulas animados estão em asset layers nativas. As três fases usam o tileset modular. Nenhum asset foi apagado.

## Arquivos alterados nesta correção

- `rooms/rm_level1/rm_level1.yy`
- `rooms/rm_level2/rm_level2.yy`
- `rooms/rm_level3/rm_level3.yy`
- `objects/obj_level_controller/Create_0.gml`
- `tools/arte/montagem_modular.py`
- `tools/check_compiled_scene.py`
- `tilesets/ts_modular/output_tileset.png`
- `options/windows/options_windows.yy`
- `options/html5/options_html5.yy`
- `docs/palette-audit.json`
- `docs/qa/camadas-0.3.1.json`
- `docs/qa/windows-0.3.1-package.json`
- Este relatório

## Verificações realizadas

- Build Windows compilado com o runtime 2026.0.0.23.
- Dados das 12 camadas no `data.win` do ZIP comparados célula por célula com as rooms.
- Validação estrutural com zero erros e zero avisos.
- Auditoria de 636 imagens e 639 frames com zero pixels visíveis fora da paleta e zero transparências parciais.
- Cache PNG do tileset remapeado com LibreSprite em modo batch.

## Conferência manual na IDE

1. Reabra `Coffin Bound final.yyp` para carregar os arquivos atualizados do disco.
2. Abra `rm_level1`, `rm_level2` e `rm_level3`. Confira as camadas `Pedra_Distante`, `Nave_Media`, `Reliquias` e `Piso_Modular`, com o tileset `ts_modular`.
3. Confira os elementos nas camadas `Nave_Animada` e `Reliquias_Animadas`.
4. Salve, feche e reabra o projeto. Confirme que os tiles continuam nas três rooms.
5. Execute com F5. Confira o cenário, parallax, animações, leitura das plataformas e alinhamento entre chão e colisão.
6. Percorra as três fases, testando transformação, perigos, plataformas móveis, morte, checkpoints e saída.

Essas verificações visuais e de jogabilidade continuam pendentes de teste pelo usuário. A prévia `assets/pecas/cena_nave.png` é uma composição estática dos dados salvos e não uma captura do jogo em execução.
