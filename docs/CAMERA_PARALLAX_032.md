# Fundo, parallax e câmera — 0.3.2

## Problemas e correções

- A câmera centralizava o jogador em todos os saltos e usava lerp fixo por frame. Agora roda em End Step, após a física, com suavização exponencial por `delta_time`, dead zone horizontal de 48px e vertical entre 34% e 66% da altura da view.
- A antecipação horizontal alcança 56px e troca de direção suavemente. Quedas rápidas antecipam até 40px abaixo. O enquadramento tem margem para o sprite inteiro e limites da room.
- Os fatores antigos de parallax diferiam entre X e Y. As transformações agora usam os mesmos fatores nos dois eixos e arredondamento inteiro. `Fundo_Distante` move a 0,10× da câmera, `Pedra_Distante` a 0,25×, `Nave_Media` e `Nave_Animada` a 0,50×, `Ornamentos_Proximos` a 0,75×. Piso, perigos e peças apoiadas nas plataformas ficam no mundo a 1×.
- Colunas, vitrais e decoração grande eram escritos em um mesmo tilemap, sobrescrevendo recortes anteriores. Agora são elementos de sprites inteiros em asset layers nativas. Arcos têm intervalos regulares e variantes. Os tiles jogáveis mantêm a geometria anterior.
- Variantes sombreadas de 29 peças foram exportadas pelo LibreSprite em batch, preservando as dimensões e a transparência. Fundo e arquitetura decorativa usam os dois verdes escuros. Uma peça de tijolo repetível cobre o fundo distante.
- A resolução lógica continua 480×270. A apresentação preserva 16:9, com escala inteira e barras quando a janela comporta essa resolução. Janelas menores usam redução proporcional para caber sem recortar a imagem.
- A execução identificou `Draw failed due to invalid input layout`. O shader de paleta era deixado ativo pela configuração da GUI e pela restauração do Scribble. Agora é usado no desenho da application surface e restaurado em seguida. A GUI usa shaders próprios e cores da paleta, com piscar discreto no HUD.

O escopo de uso dos shaders segue a [documentação do GameMaker](https://manual.gamemaker.io/lts/en/GameMaker_Language/GML_Reference/Asset_Management/Shaders/Shaders.htm).

## Verificações realizadas

- Compilação Windows VM no runtime 2026.0.0.23 e inspeção de integridade do ZIP.
- Comparação das células dos tilemaps no `data.win` com os arquivos das três rooms.
- Mesmas instâncias, posições e escalas do backup `ba5effe`, incluindo colisores e perigos.
- Oito testes de câmera, delta_time, inversão de direção, queda, limites, parallax reversível, escala e escopo do shader da GUI. Taxas simuladas de 30, 60 e 144 FPS.
- 269 frames com dimensões e índices válidos, 85 recortes modulares íntegros e 34 regiões de obstáculos dentro do atlas.
- 13 testes de movimento, 13 de serviços/menus e cinco de plataformas/corredor.
- Auditoria de 780 imagens e 783 frames, com zero pixels visíveis fora dos quatro verdes e zero transparências parciais.
- Execução do runner na tela inicial após corrigir o shader, sem novas mensagens de input layout inválido ou erro fatal no intervalo observado. O ambiente registrou ausência de dispositivo de áudio e um aviso de cursor da biblioteca Input.

As prévias são composições estáticas dos dados salvos, com as transformações de parallax aplicadas. A ferramenta de captura da janela falhou com `FrameArrived timed out`. A inspeção visual do jogo e o percurso das fases continuam pendentes.

## Teste manual na IDE

1. Reabra `Coffin Bound final.yyp`. Abra `rm_level1`, `rm_level2` e `rm_level3`. Confira o tileset `ts_modular`, os arcos em `Pedra_Distante` e os sprites inteiros em `Nave_Media`, `Nave_Animada`, `Ornamentos_Proximos`, `Reliquias` e `Reliquias_Animadas`.
2. Salve e reabra o projeto. Confira se a montagem continua nas três rooms.
3. Execute com F5 e inicie um jogo. Ande para ambos os lados e inverta rapidamente a direção. A antecipação deve mudar suavemente, com o vampiro dentro da área visível.
4. Faça saltos curtos, saltos altos e uma queda longa. Confira a estabilidade vertical nos saltos curtos e a visibilidade das plataformas inferiores durante a queda.
5. Percorra a largura das três fases. Confira as bordas esquerda, direita, superior e inferior, sem espaço externo ao mapa ou emendas no fundo. Compare as velocidades das camadas e o alinhamento das peças apoiadas no chão.
6. Teste morcego, dash, morte, checkpoint e transição de room. O respawn deve reposicionar a câmera e o parallax imediatamente. Confira o contato com plataformas fixas e móveis.
7. Teste 960×540, 1366×768, 1920×1080 e F11. Confira proporção, barras, legibilidade da GUI e nitidez. Em janelas menores que 480×270, confira a redução proporcional.
8. Confira menu, diálogos, pausa e HUD. Observe o Output da IDE para erros de shader ou GML.

## Arquivos

- `objects/obj_camera/` — Create e End Step.
- `scripts/cb_camera/` — enquadramento, dead zone e parallax.
- `scripts/cb_render/cb_render.gml` — escala e escopo do shader.
- `scripts/__scribble_class_element/__scribble_class_element.gml` — restauração do shader.
- `objects/obj_level_controller/Create_0.gml` — snap no respawn.
- `objects/obj_player/Draw_64.gml` — cores discretas do HUD.
- `rooms/rm_level1/`, `rooms/rm_level2/`, `rooms/rm_level3/` — montagem das camadas.
- `sprites/spr_bg_*/`, `assets/pecas/fundo/` — variantes sombreadas.
- `tools/arte/fundo_camadas.py`, `montagem_modular.py`, `preview_modular.js` — geração reproduzível.
- `tools/check_camera.cjs`, `check_sprite_frames.py`, `check_compiled_scene.py` e workflow — verificações.
- Projeto, versões, README, changelog, auditorias e prévias.

A lista completa está em `docs/qa/arquivos-camera-0.3.2.txt`.
