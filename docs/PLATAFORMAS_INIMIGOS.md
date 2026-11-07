# Plataformas, inimigos e armadilhas — 0.2.2

## O que mudou

Backup: `backup/antes-arte-plataformas-inimigos`, em `2b4ff7f`. Esse commit preserva os
metadados que a IDE havia reformatado antes desta alteração. Nenhum asset foi apagado
ou renomeado.

- **Plataformas fixas:** blocos maiores de pedra, cornija, juntas alternadas, peças de
  canto esculpidas, rachaduras e musgo em pequenas placas laterais. A borda superior clara
  distingue a superfície de apoio da arquitetura de fundo.
- **Passarelas:** segmentos com bordas e suportes vazados. **Móveis:** chapas rebitadas e
  ornamento metálico. **Frágeis:** pedra irregular e rachada, com variante de aviso e farelos
  durante a contagem já existente. As peças são repetidas em 16px, sem alongar a textura.
- **Morcegos hostis:** membranas, dedos, orelhas, presas e olhos; quatro poses de asas.
- **Esqueletos:** crânio, dentes, costelas, juntas e quatro poses de caminhada, com direção
  visual acompanhando o deslocamento.
- **Serras:** disco dentado com eixo e facetas. **Pêndulos:** machado duplo em corrente de
  elos. **Lâminas:** quatro pontas giratórias, carcaça recolhida e aviso durante a parte
  final do intervalo seguro existente. As poses são desenhadas em pixels, sem rotacionar
  o bitmap por ângulos fracionários.
- **Espinhos:** uma ponta metálica larga e facetada por tile 16×16, com base rebitada.
  Instâncias largas agora repetem os tiles, mantendo a máscara escalada da instância.

Paleta única: #0F380F, #306230, #8BAC0F, #9BBC0F. Alpha binário e nenhum antialiasing.
Tudo foi desenhado/exportado no **LibreSprite --batch**. Python apenas orquestra, copia
exports, escreve metadados e lê/compara imagens.

## Arquivos alterados

[Lista completa](arquivos-plataformas-inimigos.txt).

| Parte | Arquivos principais |
| --- | --- |
| Desenho dos desafios | `objects/obj_challenges/Draw_0.gml` |
| Espinhos em repetição | `objects/obj_spike/Draw_0.gml`, `obj_spike.yy` |
| Recorte do atlas | `scripts/cb_challenges/cb_challenges.gml` (função de desenho acrescentada) |
| Sprite novo | `sprites/spr_challenge_atlas/` e registro no `.yyp` |
| Arte atualizada | PNGs de `spr_spike`, `spr_level_green_1/2/3` e `assets/environment/level1/2/3.png` |
| Fontes e exportações | `assets/challenges/*.aseprite`, PNGs e prévias |
| Pipeline | `tools/arte/polir_desafios.py`, `.js` |
| Versão/documentação | opções Windows/HTML5, CHANGELOG, licenças, auditorias e esta entrega |

O atlas tem 256×160, células de 32×32 e origem (0,0). Índices 0–11: plataformas de 16×16;
12–15: morcego; 16–19: esqueleto; 20–23: serra; 24–27: pêndulo; 28–31: lâmina;
32–33: carcaça e aviso. As poses avançam a cada sete ticks. O tick permanece congelado
pelas condições de pausa, diálogo, morte e vitória que já existiam.

## Verificações

- Comparação das três imagens de fase: nenhuma mudança fora da união dos sólidos.
- Rooms, posições, larguras, scripts Create/Begin Step dos desafios e metadados da máscara
  do espinho preservados. Alfa antes/depois do espinho: (0,2)–(15,15), ambos 16×16.
  [Comparação registrada](qa/arte-desafios-0.2.2.json).
- Auditoria: 292 imagens, zero pixels visíveis fora da paleta ou com alpha parcial.
  [Resultado](palette-audit.json).
- Validação estrita de recursos e regressões de apoio/corredor executadas.
- Compilação Windows VM por Igor 2026.0.0.23 e pacote 0.2.2 gerados.
  [Manifesto do ZIP](qa/windows-0.2.2-package.json).
- Prévias estáticas `preview_sheet.png` e `preview_scene.png` inspecionadas como arte;
  não são capturas do runner nem comprovação de travessia.

## Testar na IDE

Abra **Coffin Bound final.yyp**, selecione **Windows / VM** e use **Run → Novo jogo**.

1. **Primeira fase:** confira a passarela em x=272, y=400: deve ter espessura, suportes e
   borda de apoio clara. Atravesse por baixo e aterrisse nela. Confira os blocos/cantos
   das plataformas fixas e o disco dentado perto de x=1096, y=320.
2. **Segunda fase:** confira a plataforma móvel perto de x=352, y=368 e as frágeis em
   (1328,320)/(1424,288). A superfície visual deve coincidir com os pés ao pousar. Ao
   pisar nas frágeis, confira rachadura/farelos, queda e reaparecimento.
3. Confira o esqueleto perto de (1248,310), o morcego em (1540,252), o pêndulo em (760,180)
   e a lâmina em (1460,240). Veja poses inteiras, mudança de direção e elos da corrente.
   O intervalo recolhido/aviso da lâmina deve terminar junto da ativação do perigo.
4. Nos espinhos do fundo dos buracos e nos trechos elevados, veja pontas largas repetidas,
   sem esticar o tile. Teste contato pela ponta e pelas laterais, sem aceitar dano visível
   fora do alcance anterior. O limite de colisão dos inimigos continua o retângulo de
   20×20; pontas decorativas podem ultrapassar alguns pixels e precisam de revisão visual.
5. Pause durante animação/aviso: poses, ciclos e farelos devem congelar. Retome, morra e
   reinicie com R. Confira as três rooms, F11 e G, sem borrões ou salto de alinhamento.

## Pendente

É necessária essa rodada no runner, especialmente encaixe dos pés, leitura dos perigos e
alcance visual em relação à colisão. A compilação e as comparações de arquivos não aprovam
jogabilidade. Balanceamento completo, performance e HTML5 seguem no checklist geral de QA.
