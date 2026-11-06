# Entregas por fase

Este documento registra verificações feitas e testes ainda necessários. Os relatórios de
diagnóstico descrevem a versão original e mantêm seus achados mesmo depois das correções.

## Fase 1 — diagnóstico

**Mudou:** inventário e revisão estática de objetos, scripts, duas rooms, sprites e tilesets;
diagnóstico de física/eventos/memória, arte e publicação. Nenhuma mecânica ou asset alterado.

**Arquivos:** `docs/PLANO.md`, `docs/DIAGNOSTICO_CODIGO.md`,
`docs/DIAGNOSTICO_ARTE.md`, `docs/inventario_arte.json`,
`docs/DIAGNOSTICO_PUBLICACAO.md`, `docs/ENTREGAS.md`.

**Achados prioritários:** colisão não varre o trajeto inteiro; perda de resíduos subpixel;
escala do jogador afetada pelo analógico; pausa persistente duplicada; morte/vitória e reset
inconsistentes; preferências sem persistência; escalas fracionárias e HTML5 interpolado;
avisos de terceiros ausentes; nenhum áudio incluído.

**Conferir manualmente:** abrir o projeto sem salvar por cima do backup; conferir dependências
dos filtros, fontes e versão do runtime. Registrar uma execução de referência para comparar
movimento, salto, dash/morcego, morte e reinício após as próximas fases.

**Pendente:** compilação e perfil de memória na IDE; revisão visual em movimento; autoria das
artes e escolha da licença do código. A leitura estática das bibliotecas não substitui perfil
de execução nem comprova ausência de todos os bugs.

## Fase 2 — código

**Mudou:** colisão varre o caminho inteiro e preserva resíduos subpixel; aceleração e fricção
limitadas; coyote time, buffer e altura variável corrigidos. Dash tem prioridade de transição;
morcego usa direção ±1 sem escalar a hitbox com analógico. Máquina de estados agora distingue
andar/parado, pulo, queda, dano e morte, além de dash/parede/morcego/transformação/vitória.
Morte e reset foram centralizados; fontes de luz são examinadas individualmente. Pausa deixou
de ser persistente. Corrigidos input no Draw e propriedade/destruição do mapa de kerning Scribble.

**Arquivos:** `scripts/player_*/*.gml`, `scripts/scr_enums/scr_enums.gml`,
`scripts/__scribble_class_font/__scribble_class_font.gml`, `objects/obj_player/{Create_0,Step_0,Draw_64}.gml`,
`objects/obj_level_controller/{Create_0,Step_0}.gml`, `objects/obj_pause/obj_pause.yy`,
`objects/obj_gameboy/{Create_0,Step_0}.gml`, `objects/obj_light/Draw_0.gml`,
`tools/validate_project.py`, `tools/check_movement.cjs` e esta entrega.

**Verificado:** validador estático com 0 erros; 2 avisos de prefabs já ausentes no original.
Dez regressões matemáticas executam trechos do GML em sandbox JavaScript: parede/chão de 1px,
velocidade alta, resíduos positivos/negativos, gravidade fracionária, fim de dash em parede,
imobilidade final, coyote, buffer, corte do pulo e validação de wall jump. Isso não compila GML
nem testa as máscaras do runner. Comandos: `python tools/validate_project.py` e
`node --preserve-symlinks-main tools/check_movement.cjs`. `git diff --check` sem erros.

**Conferir manualmente:** pulo pressionado até 6 frames antes de pousar; sair da borda e pular
dentro de 6 frames; comparar toque curto e pulo segurado; dash contra parede/teto/chão finos;
wall jump ao perder contato; analógico suave; morcego junto ao teto e pouso; luz fatal após
checkpoint; F3 e R; repetir menu→fase→reinício sem acumular pausa. Conferir animações pulo/queda
que passam a usar os assets existentes, sem afirmar que suas poses já foram aprovadas.

**Pendente:** compilação e sensação no runner, especialmente dash ajustado para 7,5 px/frame
durante 9 frames. A tela de morte e o fluxo de conclusão serão ligados na fase 4; até lá DEATH
espera o controlador. Arte, áudio, save e menus completos continuam nas fases seguintes.
Nenhum asset apagado ou renomeado.
