# Fase 3 — arte padronizada

## O que mudou

- Aplicada a paleta Coffin Gothic de 24 cores, sem dithering, em todos os PNGs dos 20 sprites próprios: composites, layers e quatro fontes PNG extras do HUD. Os três caches dos tilesets também foram remapeados. O sprite técnico branco de Scribble e fontes ficam como exceções funcionais.
- A grama passou de 1.896 cores visíveis para 7 cores da paleta. O alpha foi preservado; tons RGB interpolados deixaram de escapar da paleta.
- `spr_vampire_idle` e `spr_vampire_walk`: pixels deslocados em (+1,+1), origem unificada para (17,26), bbox deslocada igualmente. O deslocamento relativo entre personagem, posição e máscara permanece igual; nenhum pixel foi cortado. Jump/fall/dash já tinham essa origem e foram mantidos.
- Vela reduzida de 26×29 para 14×16 com nearest explícito no LibreSprite, bbox recalculada e origin (0,0) preservada. Instâncias da room devem usar escala 1; essa integração é feita junto à apresentação do jogo.
- Exportadas 20 spritesheets verticais PNG e JSON, com ordem dos frames, origins, FPS e duração. Foram processados 215 PNGs e verificados os 104 frames ativos. Nenhum asset foi apagado, renomeado ou acrescentado ao registro do GameMaker.
- Pipeline reprodutível executado de verdade com LibreSprite 1.1-dev em batch. Configuração isolada no projeto. Segunda execução verificou que origem e tamanho não sofrem transformação acumulativa.
- Na integração de `player_animation`, JUMP e FALL usam a pose 11 (índice iniciado em zero) com `image_speed=0`. Isso comunica o estado com uma pose de corpo legível, sem repetir os longos ciclos originais que encolhiam o personagem. Todos os frames permanecem nos assets e exports; o JSON registra o timing-base do recurso.

## Arquivos alterados

`sprites/*/*.png` e `sprites/*/layers/**/*.png` (exceto Scribble), `sprites/spr_vampire_idle/spr_vampire_idle.yy`, `sprites/spr_vampire_walk/spr_vampire_walk.yy`, `sprites/spr_candle/spr_candle.yy`, `tilesets/*/output_tileset.png`; novos arquivos em `assets/palette/`, `assets/spritesheets/`, `tools/arte/` e este documento. Para a lista completa de caminhos, consulte `git show --name-only` do commit da fase 3.

## Verificado automaticamente

Cada PNG processado foi aberto e comparado com a fonte antes de substituí-la: dimensões, pertença à paleta e alpha. Nos dois sprites deslocados, foi verificado que nenhum conteúdo opaco alcançava as bordas descartadas. Na vela, o alpha corresponde ao pixel amostrado por nearest. Cada frame exportado das 20 folhas foi reconstruído pela região JSON e comparado byte a byte com o composite do projeto.

Amostra da grama e exportações da vela/caminhada foram inspecionadas como imagens; isso não equivale a um teste de animação em jogo. Interpolação, escala inteira, câmera e desenho arredondado são integrados no código de apresentação pelo agente principal.

## O que testar manualmente no GameMaker

1. Abrir o projeto e permitir a regeneração dos caches de tiles. Confirmar que não há alerta de recurso ausente.
2. No Sprite Editor, conferir idle/walk com origin (17,26), pés e máscara na mesma posição relativa; jump/fall/dash alinhados ao trocar animação. Nenhuma asa do morcego deve aparentar corte.
3. Conferir vela de 14×16 em escala 1, encaixada no cenário, luz alinhada e contorno legível.
4. Executar a fase, mover a câmera e examinar frestas/bleeding nos tiles, tremor de subpixel e nitidez em janela/fullscreen. Conferir UI e texto.
5. Comparar o visual com filtro retro desligado (paleta base) e ligado (cores adicionais por efeito). Exportar HTML5 só após testar o módulo e o navegador.
6. Conferir a leitura das poses fixas de subida e queda e as transições no ápice/aterrissagem. Os frames repetidos originais foram preservados nas fontes; o jogo escolhe a pose por estado. Ajustar poses à mão somente se houver leitura ruim em movimento.

## Pendências e limites

Nenhum redesenho integral foi introduzido sem necessidade comprovada. As poses de jump/fall e o alinhamento das asas ainda exigem revisão visual em movimento. Não há sprites novos. A procedência/licença da arte original continua pendente de confirmação do autor; recolorir não resolve esse requisito de publicação. Não foi afirmado funcionamento da IDE, do build Windows nem de HTML5.
