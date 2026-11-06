# Renderização e teste visual

O jogo usa uma imagem lógica de 480×270. `cb_render` apresenta a surface de aplicação no
Post Draw, em múltiplos inteiros, centralizada sobre barras pretas. A GUI recebe a mesma
escala e os mesmos offsets. Janela inicial Windows: 960×540; tamanho mínimo: 480×270.
Áreas de navegador menores que a resolução lógica são recortadas: configure o iframe do
itch.io com pelo menos 480×270, preferencialmente 960×540.

Interpolação está desligada no Windows, HTML5 e na GPU. A câmera guarda posição suave em
`follow_x/follow_y` e apresenta valores arredondados. O jogador é desenhado com escala 1,
espelhamento ±1 e sem rotação. As variáveis antigas de squash/stretch continuam isoladas
da física, mas não deformam a arte no modo estrito. HUD e títulos usam escala inteira.

O filtro retro continua disponível em G, desligado por padrão para exibir a paleta original.
Ele altera as cores exibidas quando ativado. Luz, transparência e efeitos podem produzir
cores intermediárias por composição; os pixels opacos dos arquivos de arte usam a paleta.

A surface de aplicação pertence ao runner e não deve ser liberada com `surface_free`.
O código verifica existência e tamanho após perda de contexto. Não foi criada outra surface.

## Conferência na IDE/runner

1. Abrir menu e fase: imagem centralizada, GUI alinhada e sem esticar a proporção.
2. Testar janela 960×540, fullscreen 1920×1080 e 1366×768. Escalas esperadas: 2×, 4× e 2×.
3. Caminhar lentamente e mover câmera: nenhum pixel deve cintilar por posição fracionária.
4. Comparar pés entre idle, walk, jump, fall e dash; verificar asas nas bordas dos frames.
5. Alternar G: filtro deve mudar somente a apresentação; repetir ao trocar de room.
6. Alternar fullscreen e Alt+Tab várias vezes: conferir recuperação da surface e das barras.
7. Compilar HTML5 e testar dentro do iframe, incluindo fullscreen permitido pelo navegador.

Esses testes visuais ainda não foram executados. Validação estrutural não comprova o resultado.

Referências oficiais: [surface de aplicação](https://manual.gamemaker.io/monthly/en/GameMaker_Language/GML_Reference/Drawing/Surfaces/application_surface.htm),
[desenho manual da surface](https://manual.gamemaker.io/monthly/en/GameMaker_Language/GML_Reference/Drawing/Surfaces/application_surface_draw_enable.htm)
e [escala/offset da GUI](https://manual.gamemaker.io/lts/en/GameMaker_Language/GML_Reference/Cameras_And_Display/display_set_gui_maximise.htm).
