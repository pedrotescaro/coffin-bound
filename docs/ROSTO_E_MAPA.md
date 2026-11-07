# Fase 8 — rosto e cenário da cripta

## Rosto

O retrato foi redesenhado no LibreSprite, mantendo canvas **88×96**, origem, IDs e paleta.
A face ocupa mais espaço: olhos rubi abertos com pupila/reflexo, nariz mais curto, planos
das têmporas, maçãs e maxilar, boca definida e duas presas. Cabelo e gola continuam góticos.
Não se trata de ampliar o PNG antigo: os clusters do rosto foram redesenhados.

Fonte: `assets/dialogue/vampire_portrait.aseprite`. Exportações: PNG usado no sprite,
prévia completa 3× e `vampire_face_preview.png`, recorte facial nearest 4×. O gerador
`tools/arte/gerar_retrato.ps1` atualiza composite/layer do GameMaker sem mudar os IDs.
A prévia de diálogo foi regenerada com o retrato novo.

## Mapa

A fase mantém **1920×540**, a mesma câmera, percurso, colisores, espinhos, luzes, caixão
e checkpoints. A mudança é de composição e leitura visual:

- **Entrada, x=0–640:** arcos baixos, lápides, estandartes e pedra menos ruidosa.
- **Nave, x=640–1200:** arquitetura alta, colunas, vitrais e superfícies de travessia claras.
- **Cripta descendente, x=1200–1920:** ruínas, raízes e mausoléu junto ao caixão.
- Marcas decorativas nos três checkpoints; não criam coleta, colisão ou interação nova.
- O piso antes invisível em **(448,528), 512×16** passa a ter textura na parte dentro da room.

As superfícies claras indicam a geometria física; apoios e arquitetura escuros são cenário.
Vitrais mais luminosos ficam alinhados às fontes de luz perigosas existentes. Não foram
acrescentadas novas áreas de dano para combinar com a decoração.

O cenário é uma imagem estática original `crypt_map.png`, em 1920×540, feita e exportada
no LibreSprite a partir dos novos atlas. Ela usa a camada Background da room em escala 1.
Os seis tilemaps anteriores ficam preservados e ocultos, sem apagar ou renomear assets.
Player, espinhos, velas, caixão e luzes continuam como instâncias do jogo, sem serem
desenhados dentro da imagem usada pelo runner.

## Fontes e reprodução

Em `assets/environment/`:

- `crypt_tiles.png` e `.aseprite`: atlas 128×128, grade de tiles 16×16.
- `crypt_decor.png` e `.aseprite`: oito módulos góticos, 64×96 cada.
- `crypt_atlas.json`: nomes e recortes dos tiles/módulos.
- `crypt_map.png` e `.aseprite`: cenário final da room.
- `crypt_map_overview.png` e cortes da entrada/nave/cripta: reconstruções estáticas com
  instâncias para inspeção; não são screenshots do runner.

```powershell
./tools/arte/gerar_retrato.ps1 -LibreSprite 'CAMINHO/libresprite.exe'
./tools/arte/gerar_preview_dialogo.ps1 -LibreSprite 'CAMINHO/libresprite.exe'
./tools/arte/gerar_cenario.ps1 -LibreSprite 'CAMINHO/libresprite.exe'
./tools/arte/gerar_mapa.ps1 -LibreSprite 'CAMINHO/libresprite.exe'
```

Os geradores redesenham suas fontes; preserve cópias de edições manuais antes de executá-los.
Os pixels são escritos pelo LibreSprite. Python lê metadados e valida arquivos; não pinta
as imagens finais. Arte nova do projeto e código dos geradores mantêm os escopos separados
em [Licenças](LICENCAS.md).

## Testes manuais necessários

No pacote **0.1.2**, conferir:

1. Novo jogo e diálogo inicial: rosto, olhos e presas legíveis, retrato inteiro e texto sem corte.
2. Percorrer os três setores: todas as superfícies claras devem coincidir com o apoio real;
   não interpretar colunas escuras do fundo como plataformas.
3. Conferir a faixa de chão em x=448–960/y=528, agora visível, e os espinhos próximos.
4. Conferir contraste de player, espinhos e luzes, com filtro G desligado e ligado.
5. Ativar os checkpoints, morrer/reiniciar e concluir no caixão: posições e fluxos devem ser os mesmos.
6. Mover a câmera até os quatro limites, usar fullscreen/Alt+Tab e medir desempenho no profiler.

A revisão das imagens estáticas e a compilação não aprovam esses testes automaticamente.
A rodada básica relatada pelo usuário na versão 0.1.0 permanece como evidência histórica,
sem ser atribuída às mudanças visuais novas.
