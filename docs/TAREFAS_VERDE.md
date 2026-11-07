# Paleta e dificuldade â€” entregas

## Tarefa 1 â€” paleta

Quatro cores fixas em sprites, frames/layers, fontes bitmap, caches de tiles, atlas,
mapa, jogador, portrait e prÃ©vias PNG. ConversÃ£o realizada no LibreSprite batch;
`tools/arte/gameboy.py` apenas prepara os jobs e lÃª os arquivos para auditoria.
Paleta: `art/palette/gameboy-green.gpl`. TransparÃªncias visÃ­veis sÃ£o binÃ¡rias.
O retrato usa a segunda referÃªncia fornecida pelo usuÃ¡rio, adaptada Ã s quatro cores.

CÃ³digo de cores da UI/partÃ­culas ajustado e shader de quantizaÃ§Ã£o na apresentaÃ§Ã£o;
o shader do Scribble tambÃ©m limita a cor de saÃ­da e alpha. Filtro antigo de colorizaÃ§Ã£o
desativado nas rooms para nÃ£o acrescentar cores. Branco tÃ©cnico em chamadas de tint
Ã© multiplicador neutro, nÃ£o cor exibida deliberadamente.

Arquivos: sprites/fonts/tilesets/assets PNGs e fontes ASEprite, cÃ³digo de cores em
objects e scripts prÃ³prios, `shaders/shd_gameboy`, shader Scribble, `rooms/*`, ferramentas
`gameboy.py/.js`, referÃªncia fornecida em `art/reference`, `.yyp` e este relatÃ³rio.

VerificaÃ§Ã£o: `python tools/arte/gameboy.py` grava `docs/palette-audit.json`.
Resultado inicial: **261 PNGs, zero pixels visÃ­veis fora da paleta, zero alpha parcial**.
O relatÃ³rio final serÃ¡ atualizado apÃ³s as trÃªs tarefas.

Testar na IDE: menu, diÃ¡logo, jogador/morcego, HUD, luz, partÃ­culas, filtro G e fullscreen.
Conferir a paleta tambÃ©m na imagem final; auditoria dos arquivos nÃ£o Ã© captura do runner.

## Tarefa 2 — materiais e obstáculos visuais

Atlas com tijolo normal/rachado/com musgo, bordas lascadas e variantes de canto,
mapa com correntes, teias, ossos, lápides, arcos, grades e caixões. A vegetação agora
usa a mesma linguagem de musgo/trepadeiras. Base 16×16 e origens preservadas.
Arquivos: gerar_cenario.js, gerar_mapa.js, assets/environment e PNGs de spr_crypt_map.
Regerados no LibreSprite; nova auditoria de paleta sem violações.
As formas físicas irregulares/degraus entram na tarefa 3, junto dos colisores,
para não desenhar uma borda que não corresponde ao apoio real.
Testar na IDE: cantos, junções e leitura clara de plataformas contra fundo escuro.
