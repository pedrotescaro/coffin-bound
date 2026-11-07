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

## Tarefa 3 — três rooms e dificuldade

Escolhas do usuário: três rooms e inimigos por contato, sem combate.
Room1: saltos e one-way; room2: plataforma móvel, desmoronamento, corredor de morcego,
pêndulo e inimigos; room3: combinações de timing antes do caixão final.
Plataforma cai após30frames e retorna180frames depois; lâmina cicla150frames,
com50frames recolhida. Contato com inimigo/serra causa35HP, proteção45frames.
Pausa, diálogo e morte congelam ciclos. Checkpoints x640/1184/1504, spawns porroom.
Máscara morcego8px versus humano18px, corredor16px; retorno humano bloqueado semespaço.

Arquivos: rooms/rm_level1 e novasrm_level2/rm_level3; obj_challenges/cb_challenges;
colisão, contatos, recursos e transiçõesplayer; spr_mask_bat; serviços/controlador;
cenários porroom; ferramentas de geração, testes e workflow. Assets originais preservados.

Testar na IDE: abra Coffin Bound final.yyp e execute Windows/VM pelo menu/Novo jogo.
- Room1: pulo curto/longo, one-way atravessada por baixo e apoio por cima.
- Room2: transporte lateral, cair30frames/reaparecer, morte recupera plataformas.
- Corredor x896: humano não deve passar; morcego passa e retorna fora, sem entrar em parede.
- Lâmina/pêndulo: aviso/ciclo, contato, proteção45frames e dano posterior.
- Pausa/diálogo/morte congelam tudo; despausar não dispara pulo/dash.
- Morrer em cada checkpoint; fechar/reabrir/Continuar; completar três rooms até créditos.
- Conferir degraus e espinhos de teto, paleta/filtro/fullscreen, controle e performance.

Pendente: travessia e ajuste de dificuldade no runner, controle, audição, performance e
HTML5(módulo ausente). Nenhum desses testes manuais foi declarado aprovado.

## Resultado final da varredura

273 imagens PNG/GIF verificadas, **0 pixels visíveis fora das quatro cores**,
**0 pixels com alpha parcial**. Violações: `[]`. Ver `palette-audit.json`.
Listas completas de arquivos: `arquivos-tarefa-1.txt`, `arquivos-tarefa-2.txt` e
`arquivos-tarefa-3.txt`. Auditoria incluída no CI.
31 verificações matemáticas/serviços/apoio aprovadas; não são testes do runner.
