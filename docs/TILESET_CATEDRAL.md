# Tileset modular da catedral — 0.2.4

## Entrega

Backup desta etapa: `backup/antes-tileset-modular`, no commit `40d43f7`.

Foi preparado um **atlas modular 1024×512**, com base de **16×16** e **16 verdes**, a partir
da referência de tileset fornecida por Pedro. O arquivo tem tile0 vazio, 15 peças técnicas
de piso e **52 módulos/materializações** alinhados à grade: blocos, tijolos rachados, musgo,
pilares, arcos, janelas, trepadeiras, raízes, grades, estandartes, lápides, urnas, gárgulas,
teia, cornijas, portais e trechos de plataforma.

- PNG transparente: `assets/tileset/cathedral_16.png`.
- Fonte editável LibreSprite: `assets/tileset/cathedral_16.aseprite`.
- Catálogo sobre fundo escuro: `assets/tileset/catalogue.png`.
- Coordenadas, dimensões e nomes dos módulos: `assets/tileset/modules.json`.
- Recursos nativos: **spr_tileset_catedral** e **ts_catedral_16**.
- Paleta: `art/palette/gameboy-green-16.gpl`, preservando os quatro verdes clássicos.

A adaptação dos módulos e o desenho das peças técnicas/teia foram feitos no LibreSprite
`--batch`, sem interpolação e com alpha binário. Os recortes da referência foram ajustados
às dimensões da grade por nearest; o atlas usa offsets/separadores 0, tile16 e borda de
extrusão 2px na saída do tileset. A interpolação do jogo continua desligada.

A referência é uma imagem fornecida pelo usuário, com autoria/licença original por documentar.
A adaptação não cria uma licença automática para reutilização: veja [Licenças](LICENCAS.md).

## Integração às fases

As três rooms têm duas novas camadas nativas, usando `ts_catedral_16`:

- **Tiles_Catedral_Frente**, profundidade 180: já contém o piso/paredes, pintados de acordo
  com a união dos colisores existentes. Foram usadas peças de meia altura nos túneis.
- **Tiles_Catedral_Decor**, profundidade 650: vazia e pronta para pintar os módulos.

A arquitetura detalhada da etapa anterior continua como fundo. Os módulos decorativos do
novo atlas ficam disponíveis para montar/alterar esse cenário no editor; essa camada não
foi preenchida automaticamente sobre o fundo existente para duplicar suas janelas/raízes.

Os objetos continuam responsáveis pela colisão. Pintar um tile novo altera o visual;
para mudar o percurso, ajuste também os objetos de colisão. Nesta entrega, suas posições,
escalas, eventos e IDs foram preservados. Nenhum asset anterior foi apagado ou renomeado.

## Abrir e usar na IDE

1. Reabra **Coffin Bound final.yyp** para carregar os recursos acrescentados.
2. Em **Tile Sets**, abra **ts_catedral_16**. Confira **Tile Width/Height=16**, offsets e
   separadores em 0; o primeiro tile deve estar transparente.
3. Em **Sprites → tiles**, abra **spr_tileset_catedral** para ver o PNG completo.
4. Abra **rm_level1**, **rm_level2** ou **rm_level3**. Selecione **Tiles_Catedral_Frente**
   para inspecionar os pisos existentes, ou **Tiles_Catedral_Decor** para arquitetura.
5. Na paleta do tileset, selecione um retângulo de vários tiles para pegar um arco, janela
   ou pilar inteiro e pintar o módulo na room. Consulte `modules.json` para os retângulos.
   Os módulos grandes são compostos de vários tiles de 16; não há autotile automático.
6. Para editar arte, abra o `.aseprite` no LibreSprite e exporte mantendo 1024×512 e a paleta.
   Sincronize o PNG composite/layer indicado no `.yy`, ou use o pipeline abaixo.

### Peças técnicas da primeira linha

| Índices | Uso |
| --- | --- |
| 0 | Vazio, reservado pelo GameMaker |
| 1–3 | Canto superior esquerdo, topo, canto superior direito |
| 4–6 | Lateral esquerda, miolo, lateral direita |
| 7–9 | Canto inferior esquerdo, base, canto inferior direito |
| 10–12 | Rachadura, musgo e sombra |
| 13 | Piso somente nos 8px inferiores da célula |
| 14 | Pedra somente nos 8px superiores da célula |
| 15 | Variação de borda superior |

## Reproduzir

```powershell
python tools/arte/tileset_catedral.py --libresprite 'CAMINHO/libresprite.exe'
python tools/arte/gameboy.py
python tools/validate_project.py --strict-warnings
```

O gerador **repinta a camada de frente e reinicializa a camada decorativa vazia**. Preserve
suas edições de room/arte antes de regenerar. Python orquestra, copia arquivos, grava os
metadados e lê imagens na validação; os pixels são produzidos pelo LibreSprite.

## Validação e arquivos alterados

- [Lista exata de arquivos](arquivos-tileset-catedral.txt).
- Auditoria: **311 imagens / 314 frames**, zero pixels visíveis fora dos 16 verdes ou com
  alpha parcial; shaders coerentes com a paleta.
- Atlas 1024×512 e tile0 transparente; camadas com 120×34 células decodificadas.
- Comparação por pixel: **zero diferenças entre alpha dos pisos e união dos sólidos**, nas
  três rooms, incluindo as metades de tile das passagens. As camadas/instâncias anteriores
  permanecem iguais ao backup. [Relatório](qa/tileset-0.2.4.json).
- Validação estrita de recursos: zero erros/avisos.
- Compilação Windows VM e pacote por Igor 2026.0.0.23 aprovados.
  [Manifesto do ZIP](qa/windows-0.2.4-package.json).
- `scene_entrance.png`, `scene_nave.png` e `scene_final.png` são composições estáticas do
  LibreSprite, usando os mesmos dados de tile das rooms; não são capturas do runner.

## Conferir manualmente

Selecione **Windows / VM → Run → Novo jogo**:

1. Confira o alinhamento dos pés, cantos de plataformas e paredes nas três fases.
2. Nas fases 2/3, atravesse de morcego os túneis em x=896 (y=296–311 / y=248–263).
   Os meios tiles devem deixar o vão inteiro livre.
3. Confira ausência de seams/bleeding ao mover a câmera, alternar F11 e redimensionar.
4. Confira a leitura dos perigos e do jogador sobre os 16 verdes; pause/retome e use R.
5. No editor, em uma cópia de teste da room, pinte um arco/janela inteiro na camada Decor
   e confira recorte/transparência. A compilação não comprova essa interação da IDE.

Pendente: essa rodada visual, legibilidade e desempenho no runner. HTML5 mantém a pendência
do módulo de exportação local. A documentação da origem/licença das imagens fornecidas
continua separada do código GPL.
