# Paleta e dificuldade — entregas

## Tarefa 1 — paleta

Quatro cores fixas em sprites, frames/layers, fontes bitmap, caches de tiles, atlas,
mapa, jogador, portrait e prévias PNG. Conversão realizada no LibreSprite batch;
`tools/arte/gameboy.py` apenas prepara os jobs e lê os arquivos para auditoria.
Paleta: `art/palette/gameboy-green.gpl`. Transparências visíveis são binárias.
O retrato usa a segunda referência fornecida pelo usuário, adaptada às quatro cores.

Código de cores da UI/partículas ajustado e shader de quantização na apresentação;
o shader do Scribble também limita a cor de saída e alpha. Filtro antigo de colorização
desativado nas rooms para não acrescentar cores. Branco técnico em chamadas de tint
é multiplicador neutro, não cor exibida deliberadamente.

Arquivos: sprites/fonts/tilesets/assets PNGs e fontes ASEprite, código de cores em
objects e scripts próprios, `shaders/shd_gameboy`, shader Scribble, `rooms/*`, ferramentas
`gameboy.py/.js`, referência fornecida em `art/reference`, `.yyp` e este relatório.

Verificação: `python tools/arte/gameboy.py` grava `docs/palette-audit.json`.
Resultado inicial: **261 PNGs, zero pixels visíveis fora da paleta, zero alpha parcial**.
O relatório final será atualizado após as três tarefas.

Testar na IDE: menu, diálogo, jogador/morcego, HUD, luz, partículas, filtro G e fullscreen.
Conferir a paleta também na imagem final; auditoria dos arquivos não é captura do runner.
