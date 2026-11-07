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

## Fase 3 — arte e pixels

**Mudou:** paleta gótica de 24 cores aplicada com LibreSprite batch a 20 sprites próprios,
composites/layers/rascunhos preservados e caches dos 3 tilesets (215 PNGs). Exportadas 20
folhas PNG/JSON. Idle/walk têm origem alinhada aos demais sprites do vampiro, mantendo o
offset da máscara; vela agora é 14×16 e as instâncias usam escala 1. Tiles continuam 16×16.
Pulo/queda seguram a pose legível 11, sem reproduzir no ar as deformações extremas das longas
sequências-fonte; todos os frames e seus timings originais continuam nos assets/exportações.

Apresentação 480×270 com escala inteira, barras, GUI alinhada e câmera arredondada. Filtro
retro opcional inicia desligado. Interpolação HTML5 desligada; removidas escalas fracionárias
de jogador, vela, HUD e títulos. Colisores têm bordas inteiras. Retiradas somente duas
referências obsoletas a prefabs inexistentes e sem uso, conforme aviso, sem apagar assets.

**Arquivos:** lista detalhada em `docs/ARTE.md`; `sprites/`, `tilesets/`, `assets/palette/`,
`assets/spritesheets/`, `tools/arte/`, `scripts/cb_render/`, `scripts/player_animation/`,
`scripts/menu_{data,draw}/`, apresentação em `objects/obj_{gameboy,camera,player,candle,light,menu,pause,level_controller}/`,
`rooms/rm_{menu,level1}/*.yy`, `options/html5/options_html5.yy`, `.yyp`, `.gitignore`,
`.gitattributes`, `docs/RENDERIZACAO.md` e esta entrega. O commit permite obter todos os caminhos.

**Verificado:** remapeamento com validação de cores, dimensões, alpha e ausência de cortes;
104 frames reconstruídos das folhas e comparados aos PNGs do projeto. Pipeline executado
novamente para verificar idempotência da geometria. Amostras estáticas inspecionadas como
imagens; nenhuma execução do jogo. Validador estrutural: 0 erros/0 avisos. Regressões de
movimento continuam aprovadas.

**Conferir manualmente:** instruções completas em `docs/RENDERIZACAO.md` e `docs/ARTE.md`.
Conferir pés e máscaras entre animações, asas, legibilidade das poses 11, velas, frestas nos
tiles, texto e barras em 960×540, 1366×768 e 1920×1080; Alt+Tab e fullscreen; HTML5 após compilar.

**Pendente:** aprovação visual em movimento e revisão de timing/poses no runner; fontes e
sprite branco técnico são exceções funcionais ao remapeamento de cores. Composição de luz e
filtro pode produzir outras cores na tela. Origem/licença das artes continua por confirmar.

## Fase 4 — polimento

**Mudou:** menu completo, pausa por flag, game over com retorno ao checkpoint, créditos após
vitória e catálogo de fases com a room existente. Checkpoints/progresso e preferências em
INIs separados. Sete teclas remapeáveis, controle, volumes, filtro e fullscreen Windows.
No HTML5 a interface orienta usar o botão de fullscreen do navegador/itch.io.

Câmera com shake leve limitado à room, poeira/morcego/morte em arrays limitados e nove WAVs
originais CC0 (8 efeitos e loop de 21,33 s), grupos de música/efeitos com carregamento assíncrono.
Corrigido espelhamento da máscara assimétrica: `facing_dir` agora controla só a apresentação.
Entradas de confirmação não disparam ações involuntárias ao retomar, renascer ou fechar diálogo.

**Arquivos:** `scripts/cb_services/`, `scripts/menu_*/`, `scripts/scr_enums/`,
`scripts/player_{input,states,transitions,visuals,health,bat}/`, `objects/obj_{menu,pause,gameboy,player,camera,level_controller,light,candle,dash_trail}/`,
`.yyp`, `sounds/snd_cb_*/`, `tools/generate_audio.py`, `tools/check_movement.cjs`,
`tools/check_services.cjs`, `assets/audio_manifest.json`, `docs/AUDIO.md`,
`docs/POLIMENTO.md` e esta entrega. Nomes e IDs dos assets originais preservados.

**Verificado:** estrutura com 0 erros/0 avisos; 13 regressões matemáticas/input do jogador;
regressões de preferências/progresso em sandbox (ver ferramenta e saída). Áudio regenerado
duas vezes e comparado byte a byte: sem clipping, headers PCM/SHA-256 válidos e borda do loop
com diferença de 36 unidades PCM16. Revisão independente dos INIs, ordem dos fluxos e lifecycle.
As simulações não compilam GML nem reproduzem os eventos do runner.

**Conferir manualmente:** roteiro em `docs/POLIMENTO.md` e audição em `docs/AUDIO.md`.
Especialmente: morrer em todos os checkpoints, fechar/reabrir e continuar; pausar com pulo
segurado; remapear e salvar; controle e desconexão; concluir o caixão; volumes 0/50/100;
três voltas da música; profiler por 10 minutos. HTML5 continua condicionado a build/teste.

**Pendente:** compilação e percurso completo no GameMaker, aprovação visual, audição e
performance. O jogo tem uma fase existente; novas rooms podem ser cadastradas, mas nenhuma
fase adicional foi inventada. Origem/licença das artes originais ainda precisa ser confirmada.

## Fase 5 — publicação

**Mudou:** README em português e inglês, GIF real de asset exportado pelo LibreSprite,
licença integral GPL-3.0 para código próprio de Pedro Tescaro, avisos/licenças de terceiros,
CHANGELOG, `.gitignore` para builds/caches/credenciais e workflow de verificações no GitHub.
Metadados Windows/HTML5 corrigidos. Guia itch.io com texto PT/EN, tags, gênero, capa 630×500,
capturas/GIFs recomendados, exportação Windows/HTML5 e comandos butler. Checklist manual
permanece explícito. O `.yyz` original continua preservado; o `.yyp` é o projeto atualizado.

**Arquivos:** `README.md`, `README.en.md`, `LICENSE`, `THIRD_PARTY_NOTICES.md`, `CHANGELOG.md`,
`licenses/`, `datafiles/{GPL-3.0,third_party_notices}.txt`, `docs/{LICENCAS,ITCH_IO,QA,COMPILACAO}.md`,
`assets/preview/`, `tools/arte/gerar_preview.ps1`, `tools/build.ps1`,
`.github/workflows/verificacoes.yml`, `.gitignore`, opções em `options/`, `.yyp`,
`sounds/snd_cb_*/*.yy`, `tools/generate_audio.py`, `tools/validate_project.py`, adendos ao
diagnóstico e esta entrega. Metadados novos de ordem dos prefabs, gerados pelo compilador,
também são versionados.

**Verificado:** compilação Windows VM por Igor **2026.0.0.23**, saída 0, GML e shaders
compilados; repetida após integrar os avisos de licença e opções finais. Os recursos de som
foram ajustados ao schema GMSound v2 do runtime 2026 e o validador agora verifica esses campos.
Estrutura final: 453 scripts, 14 objetos, 2 rooms, 21 sprites, 3 tilesets e 9 sons;
0 erros/0 avisos. Passaram 13 regressões de movimento/input e 13 de serviços/menus,
determinismo do áudio, validação do GIF e revisão dos arquivos publicáveis.

**GitHub:** destino público solicitado pelo autor: [pedrotescaro/coffin-bound](https://github.com/pedrotescaro/coffin-bound).
O histórico mantém um commit por fase e o backup original. O workflow executa somente as
verificações abertas; a compilação GameMaker exige instalação/licença local.

**Conferir manualmente:** seguir `docs/QA.md`, principalmente percurso até o caixão,
morte/reinício/checkpoints, pausa, save ao reabrir, controles, fullscreen, audição e profiler.
Capturar gameplay verdadeiro e gerar ZIP Windows na IDE para distribuir o runner completo.
O GIF do README é uma prévia de sprite e não comprova funcionamento em jogo.

**Pendente:** HTML5 tentou compilar, mas falta `html5/scripts.html5.zip` no runtime instalado;
instalar módulo compatível e testar no navegador. Não foi feito upload no itch.io nem release
de executável sem QA. Procedência/licença das artes originais continua por documentar, separada
da GPL do código. Os testes manuais não foram marcados como aprovados.

**Correção após a publicação:** o CI Linux identificou que o arquivo
`InputPluginGamepadGetVendorAndProduct.gml` usava capitalização diferente do recurso
`InputPlugInGamepadGetVendorAndProduct`. A capitalização do arquivo foi ajustada, com aviso,
preservando conteúdo e nome do asset. O validador passou a detectar o caso também no Windows.
Essa correção de portabilidade foi registrada em commit adicional de publicação.

## Fase 6 — pacote Windows e validação inicial

**Mudou:** exportação do ZIP Windows completo pelo parâmetro `-Package`, verificador de
conteúdo/CRC/hash e manifesto do pacote. A repetição da exportação identificou um manifesto
antigo entrando na distribuição; cada geração passou a usar uma pasta nova e o verificador
rejeita esse resíduo. Nenhuma mecânica, room, sprite ou outro asset foi alterado.

**Backup:** branch `backup/antes-validacao-windows-2026-11-06`, baseada no commit `4b577c9`.

**Arquivos:** `tools/build.ps1`, `tools/check_package.py`, `docs/QA_WINDOWS.md`,
`docs/qa/windows-0.1.0-package.json`, `docs/COMPILACAO.md`, `docs/QA.md`,
`README.md`, `README.en.md`, `CHANGELOG.md` e esta entrega. Normalização de finais de linha
do relatório original de código, sem mudança de conteúdo. Saídas `.build/` permanecem locais.

**Verificado:** Igor Windows VM/PackageZip terminou com saída 0. ZIP com executável, dados,
música e avisos de licença; CRCs/cabeçalhos/arquivos obrigatórios verificados. O usuário
confirmou menu normal e a sequência Novo jogo → diálogo/Enter → pulo/Espaço → pausa e
retomada/Esc → reinício/R, sem erro e sem pulo/dash involuntário ao retomar/reiniciar.
O relato do usuário está separado das verificações automáticas no relatório desta fase.

**Limite observado:** a captura de janela pela ferramenta falhou; não foram produzidas
screenshots de gameplay nem afirmada aprovação visual autônoma. A primeira tentativa de
lançamento ficou suspensa e foi encerrada; a segunda abriu o executável e o usuário testou.

**Conferir manualmente:** completar a travessia até o caixão; morrer por cada fonte e em
todos os checkpoints; fechar/reabrir e Continuar; opções/remapeamento; controle; fullscreen
e Alt+Tab; ouvir efeitos e música; medir frame time e memória. Instruções em `docs/QA.md`.

**Pendente:** esses testes completos, capturas reais, origem/licença das artes e módulo HTML5.
O ZIP é um candidato local para QA, não uma release final no GitHub/itch.io. O código das
ferramentas e os relatórios são enviados ao repositório público já autorizado.

## Fase 7 — diálogos e retrato no LibreSprite

**Mudou:** interface de diálogo com moldura gótica recortada, detalhes em rubi/dourado,
placa do falante, separadores, rodapé de avanço e retrato detalhado original do vampiro.
Fonte editável e exportações geradas no LibreSprite batch. Retrato 88×96, origem (0,0),
19 cores da paleta gótica e transparência binária. Texto com wrap de 306px, passo de 20px
e folga para as duas linhas existentes. Versão Windows/HTML5 marcada como 0.1.1.

**Backup:** branch `backup/antes-dialogos-com-retrato`, no commit `b4e8ac8` da fase 6.

**Arquivos:** `assets/dialogue/`, `sprites/spr_portrait_vampire/`,
`scripts/cb_dialogue/`, `objects/obj_level_controller/{Create_0,Draw_64}.gml`,
`tools/arte/gerar_retrato.{js,ps1}`, `tools/arte/gerar_preview_dialogo.{js,ps1}`,
`.yyp`, `.resource_order`, opções Windows/HTML5, READMEs, `CHANGELOG.md`,
`docs/DIALOGOS.md`, `docs/LICENCAS.md`, `docs/qa/windows-0.1.1-package.json` e esta entrega.
Nenhum asset anterior apagado ou renomeado.

**Verificado:** fonte ASEprite/PNG e paleta, alpha 0/255, ampliação nearest 3× e igualdade
dos PNGs composite/layer. Prévia estática da composição inspecionada; maior linha 270/306px,
altura 40/44px. Validador: 0 erros/0 avisos, agora com 22 sprites e 454 scripts. Igor
Windows VM/PackageZip: saída 0. ZIP 0.1.1 com nove arquivos e integridade aprovada.

**Conferir manualmente:** no ZIP 0.1.1, selecionar Novo jogo, verificar retrato inteiro,
nome e duas linhas sem cortes; Enter deve revelar/avançar sem pulo extra. Conferir a fala
do Eco da Cripta, pausa/R e fullscreen/filtro. Passos completos em `docs/DIALOGOS.md`.
Os testes básicos aprovados pelo usuário pertencem ao pacote anterior 0.1.0 e não foram
transferidos automaticamente à nova interface.

**Pendente:** confirmar essa apresentação no runner, percurso completo, checkpoints,
controle, audição/performance e capturas reais. HTML5 ainda depende do módulo ausente.
A arte nova tem fonte própria documentada; a procedência dos assets antigos permanece pendente.
Não foi feito upload de executável no itch.io nem release jogável sem esses testes.

## Histórico das fases

| Etapa | Commit |
| --- | --- |
| Backup original | `dd2bf04` |
| Fase 1 — diagnóstico | `7d22466` |
| Fase 2 — código | `15121da` |
| Fase 3 — arte | `07f4dfe` |
| Fase 4 — polimento | `4033299` |
| Fase 5 — publicação | `3d8fecb` (ajuste Linux em `4b577c9`) |
| Fase 6 — pacote e QA inicial | Consultar o commit com mensagem “Fase 6” no histórico |
| Fase 7 — diálogos e retrato | Consultar o commit com mensagem “Fase 7” no histórico |
