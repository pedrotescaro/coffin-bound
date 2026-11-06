# Spritesheets exportadas pelo LibreSprite

Uma folha PNG vertical e um JSON por sprite próprio. São exportações auxiliares: o GameMaker continua utilizando os frames e IDs originais em `sprites/`, sem novos assets registrados no `.yyp`.

- Ordem dos frames corresponde ao `.yy`, também registrada em `coffin_bound.frame_order`.
- `frame` descreve a região exata de cada imagem na folha. Há 1 pixel transparente entre frames e na borda externa; não usar a folha como tileset sem ler o JSON.
- `duration` foi ajustado para milissegundos a partir do FPS original do `.yy`; `fps` preserva o valor exato. O arredondamento para milissegundos não altera a duração interna do GameMaker.
- Sprites estáticos têm `static=true`; HUD com FPS zero tem duração zero e deve usar seleção explícita do frame.
- O jogo pode modular `image_speed` (por exemplo asas cansadas); a exportação registra o timing-base, não simula os estados do jogador.
- `manifest.json` registra quantidade de PNGs processados, exclusões técnicas, verificações e dimensões por sprite.

Reprodução: ver `../../tools/arte/README.md`. Não editar estas folhas para alterar o jogo: editar os sprites do projeto e reexportar.
