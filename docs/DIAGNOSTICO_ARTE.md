# Fase 1 — diagnóstico de arte, rooms e renderização

Auditoria estática dos 21 sprites (metadados e todos os PNGs de frames/layers), dos 3 tilesets, das 2 rooms e das opções de renderização. Inventário completo em `inventario_arte.json`. Não houve alteração de assets nesta fase.

## Achados confirmados

| Prioridade | Local | Evidência e efeito |
| --- | --- | --- |
| Alta | `sprites/spr_tileset_grama` | 1.896 cores RGB visíveis em apenas 13.714 pixels opacos. Tiles de grama têm tons intermediários nas bordas internas, incompatíveis com a paleta curta dos outros tilesets (4 cores). Quantização sem dithering é necessária. |
| Alta | `options/html5/options_html5.yy` | `option_html5_interpolate_pixels=true`; Windows já usa `false`. HTML5 suaviza os pixels. |
| Alta | `objects/obj_camera/Step_0.gml` | A posição interpolada é passada diretamente à câmera, com frações. Deve manter acumulador suave e arredondar apenas a posição exibida. |
| Alta | `objects/obj_player/Draw_0.gml` e `scripts/player_visuals` | Desenho em x/y fracionários, escala variável e rotação geram reamostragem e tamanhos irregulares dos pixels. Desenhar em coordenadas inteiras com escala 1 e espelhamento ±1 resolve a apresentação estrita. |
| Média | `spr_vampire_idle`, `walk`, `jump`, `fall`, `dash` | Todos têm canvas 32×32, mas idle/walk usam origin (16,25) e jump/fall/dash (17,26). Isso introduz deslocamento de 1 pixel ao trocar animação. O conteúdo de dash tem a mesma pose-base deslocada 1 pixel; a origem deve ser corrigida em conjunto com o conteúdo, preservando o alinhamento dos pés. |
| Média | `spr_bat` | Origin (16,30), 4 frames de 32×32, com conteúdo variando de y=1 a 31. O primeiro frame toca a borda inferior. Não foi demonstrado corte de asas; conferir em animação. Usar máscara de colisão fixa para não variar com asas. |
| Média | `spr_vampire_jump` e `spr_vampire_fall` | Jump tem 23 frames/30 fps e fall 37/60 fps. Vários frames finais são repetidos e poses iniciais variam bastante de posição. Timing é determinado também por `player_animation`; verificar a sequência completa em jogo antes de redesenhar. Não eliminar frames existentes. |
| Média | `sprites/spr_hud` | O sprite registrado é 77×26, mas existem quatro PNGs extras de 188×84 não referenciados no `.yy`. São fontes/rascunhos preservados, não frames ativos. Não redimensionar esses PNGs como se fossem frames nem apagá-los. |
| Média | `s_background` | Fundo 320×256 com 39 cores azul/branco, diferente dos tiles góticos de 4 cores verde. Não foi encontrada necessidade de deformá-lo para dimensão de tile; deve ser quantizado preservando canvas. |
| Média | `rooms/rm_level1` | Instâncias com posição fracionária: luzes y=78,4 e 126,4; espinho x=1903,9698/y=481,09613; chão y=497,09613. Colisores do chão também têm escala 0,73287296 (altura fracionária). Arredondar as bordas reais de colisão, não simplesmente arredondar todas as escalas. |
| Média | `obj_candle` na room | Escala X=0,5362608 e Y=0,55172414 de sprite 26×29 produz aproximadamente 14×16 e deforma o pixel. Recomenda-se canvas 16×32 desenhado em escala 1, ou preservar o original e usar renderização específica sem deformação. Confirmar encaixe visual com tiles antes de redesenhar. |
| Média | `rooms/*/Efeito_Gameboy` | Filtro `_filter_colourise` ativo com intensidade 0,9 adiciona cores fora de uma paleta fixa. Para aplicar paleta gótica fiel, iniciar o filtro desativado e manter G como opção visual, ou substituí-lo por shader de quantização com revisão visual. |
| Baixa | `spr_ground`, `spr_wall`, `spr_light` | Sprites 64×64 com alpha uniforme 171, 94 e 233, respectivamente. Servem a colisão/efeitos e não são evidência de antialiasing nas bordas. Não converter toda transparência intermediária automaticamente. |

## Verificações sem falha encontrada

- Tilesets `ts_grass`, `ts_props`, `ts_fundo`: todos usam tiles de 16×16 e bordas de saída de 2 pixels em cada eixo. Nenhuma troca de tamanho de tile é necessária.
- Todos os frames ativos e seus layers têm dimensões iguais ao canvas declarado. A única divergência é composta pelos quatro PNGs extras não usados em `spr_hud`.
- Todos os sprites têm `edgeFiltering=false`. Sprites de personagens e tiles têm alpha binário (0 ou 255), sem antialiasing por alpha. A grama contém interpolação de cores RGB opacas.
- Views principais: 480×270 e viewport 1920×1080 (escala 4×). Isso só garante escala inteira nessa resolução; fullscreen e monitores diferentes ainda precisam de letterbox.
- Sprites de cenário têm dimensões distintas por função (vela, caixão, UI); isso não exige convertê-los todos para 16×16.
- A biblioteca Scribble tem um sprite interno branco de 12×12. Recolorir esse recurso altera a cor base das tintas de texto, por isso deve ser tratado como recurso técnico em vez de arte de cenário.

## Ferramenta localizada

LibreSprite em `C:\Users\SALA\Downloads\libresprite-development-windows-x86_64\libresprite.exe`. O executável existe junto com DLLs e dados. As chamadas de sondagem `--help` e `--batch --version` não devolveram saída imediatamente neste ambiente; isso não prova que a ferramenta funcione em batch. A fase 3 deve validar uma exportação real antes de modificar os arquivos originais. Nenhuma instalação foi feita.

## Proposta para fase 3

1. Paleta autoral gótica de 24 cores, contendo preto azulado, sombras violeta, pedra fria, verdes musgo, osso e rubi. Registrar `.gpl` e RGB/HEX em documento.
2. Executar LibreSprite em batch em cópias, converter a indexado com a paleta sem dithering, retornar RGBA e validar dimensões, alpha e cores.
3. Aplicar aos frames e layers das artes próprias e exportar spritesheets com dados de duração. Manter IDs, nomes e arquivos extras.
4. Estabilizar a origem do vampiro sem deslocar máscara nem pés. Preservar a hitbox durante troca de forma.
5. Desabilitar interpolação em HTML5, usar coordenadas inteiras no desenho/câmera e apresentação 480×270 com escala inteira e barras.
6. Entregar folha de amostras antes/depois e testes manuais de personagens, bordas dos tiles, texto e fullscreen.

## Testes manuais necessários

Abrir no GameMaker, verificar todos os sprites no editor e executar menu/fase com filtro desligado/ligado. Conferir pés entre idle, caminhada, pulo, queda e dash; asas sem corte; vela sem deformação; ausência de frestas nos tiles durante câmera em movimento. Comparar janela e fullscreen em monitor 1366×768, 1920×1080 e outras resoluções disponíveis. Confirmar HTML5 em navegador somente após compilar com o módulo apropriado. Esta auditoria não substitui execução na IDE.
