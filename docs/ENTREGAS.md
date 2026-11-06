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
