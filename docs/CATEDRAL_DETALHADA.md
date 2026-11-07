# Catedral detalhada e 16 verdes — 0.2.3

## Entrega

Backup anterior à alteração: `backup/antes-cenario-catedral-detalhada`, em `d2611df`.

O cenário foi adaptado da segunda imagem fornecida por Pedro, usando LibreSprite em batch.
A autorização posterior para mais cores substitui o limite anterior de quatro tons: a
paleta atual contém **16 verdes**, mantendo #0F380F, #306230, #8BAC0F e #9BBC0F como subconjunto.
Os assets anteriores de quatro cores continuam válidos nessa paleta ampliada.

- Arcos em camadas, janelas ogivais, colunas e capitéis esculpidos, raízes, trepadeiras,
  teias e alvenaria desgastada aproveitam os detalhes da referência.
- A imagem de referência é amostrada por nearest 2×, em clusters inteiros; não foi usado
  redimensionamento suave. A vista lógica continua em 480×270 e escala inteira no jogo.
- Os tons adicionais permitem distinguir sombra profunda, pedra em recesso, face exposta
  e realces oliva. Sombras sob as plataformas, faces laterais e bases usam esses tons.
- A pedra das superfícies jogáveis é reaplicada à união exata dos sólidos das três rooms,
  com borda superior clara, cornijas, relevo e pequenos realces nos ornamentos.
- Plataformas antigas contidas na referência são escurecidas como decoração ao fundo.
  A parede central desenhada na imagem é substituída por um trecho de arco; a parede
  jogável é definida somente pela geometria da room.
- Os corredores de morcego das fases 2/3 recebem fundo escuro uniforme para evidenciar
  a passagem. Não foram mudadas posições, medidas, colisões ou regras de movimento.
- Os shaders de apresentação e do Scribble agora preservam os 16 tons. Alpha permanece
  binário, sem antialiasing e sem cores de fora da paleta no resultado dos shaders.

Esta é uma adaptação de imagem fornecida, não uma alegação de autoria original da referência.
O arquivo bruto preservado em `art/reference` não é renderizado diretamente e fica fora da
varredura dos assets exportados. Procedência e licença de origem seguem em [Licenças](LICENCAS.md).

## Arquivos alterados

[Lista exata](arquivos-catedral-detalhada.txt).

| Parte | Caminhos |
| --- | --- |
| Paleta atual | `art/palette/gameboy-green-16.gpl` |
| Referência | `art/reference/cathedral-detailed-reference.png` |
| Fundos exportados | `assets/environment/level1/2/3.png` e PNGs composite/layer de `spr_level_green_1/2/3` |
| Fontes editáveis e prévias | `assets/cathedral/level1/2/3.aseprite`, PNGs entrance/nave/gate/crypt |
| Pipeline | `tools/arte/catedral_detalhada.py`, `.js` |
| Quantização/renderização | `shaders/shd_gameboy/shd_gameboy.fsh`, `shaders/__shd_scribble/__shd_scribble.fsh` |
| Auditoria | `tools/arte/gameboy.py`, `.js`, `docs/palette-audit.json`, workflow de CI |
| Versão e documentação | opções Windows/HTML5, README PT/EN, CHANGELOG, renderização, licenças, avisos e manifestos |

Nenhum asset foi apagado ou renomeado. IDs, origens e dimensões dos sprites registrados
foram preservados. O cenário usa os mesmos recursos de fundo das rooms existentes.

## Reproduzir

```powershell
python tools/arte/catedral_detalhada.py --libresprite 'CAMINHO/libresprite.exe'
python tools/arte/gameboy.py
```

Os pixels são escritos pelo LibreSprite; Python orquestra o editor, copia exports, escreve
metadados e lê/compara imagens. As fontes atuais estão em `assets/cathedral/`. Os geradores
históricos foram mantidos. Se usá-los, execute o gerador da catedral por último para obter
a apresentação atual. Regenerar sobrescreve edições manuais das fontes.

## Verificações

- Auditoria: **304 imagens / 307 frames**, zero pixels visíveis fora dos 16 verdes ou com
  alpha parcial. Verificação inclui todos os frames dos GIFs e os dois shaders.
- Cada cenário 1920×540 usa os 16 tons; PNG composite/layer idênticos à exportação.
- Rooms e arquivos de gameplay comparados ao backup, sem alterações. As aberturas de
  morcego nas fases 2/3 foram conferidas nos pixels do fundo.
- [Relatório de geometria, cores e sincronização](qa/catedral-0.2.3.json).
- Validador estrito de recursos: zero erros/avisos.
- Compilação e pacote Windows VM gerados por Igor 2026.0.0.23.
  [Manifesto do ZIP](qa/windows-0.2.3-package.json).
- Prévias inspecionadas como arte estática; não são capturas do runner.

## Testar manualmente

Reabra **Coffin Bound final.yyp**, selecione **Windows / VM** e use **Run → Novo jogo**:

1. Atravesse as três fases e veja as janelas, raízes, colunas e faces de pedra. Confirme
   que os meios-tons aparecem no runner, inclusive nas sombras; não deve voltar ao aspecto
   de quatro cores. Confira menu, retrato e HUD após a mudança dos shaders.
2. Pouse nas bordas de plataformas fixas, móveis e frágeis: os pés devem coincidir com
   a borda superior clara. As colunas e as estruturas mais escuras atrás delas são decoração.
   Confira se essa diferença visual fica clara durante o movimento da câmera.
3. Nas fases 2/3, atravesse com morcego os túneis em x=896: y=296–311 e y=248–263.
   O vão deve aparecer vazio/escuro, sem raízes ou suportes cobrindo a abertura.
4. Confira leitura de espinhos, esqueletos, morcegos e lâminas sobre o cenário mais rico.
   Teste saltos junto a fundos decorativos para identificar qualquer falsa indicação de piso.
5. Alterne G e F11, redimensione a janela e use Alt+Tab. Confira paleta, pixels, GUI e
   restauração dos shaders. Pause, retome e reinicie com R.
6. Observe a taxa de quadros e o profiler: o shader agora compara 16 cores. O desempenho
   real, inclusive no hardware de destino, ainda precisa ser medido no runner.

## Pendente

Esta rodada de QA visual e de desempenho ainda precisa ser feita. O uso de uma referência
mais rica não comprova, por si só, a legibilidade do percurso. HTML5 continua dependente do
módulo ausente na instalação local e não foi aprovado nesta entrega. A origem/licença das
referências fornecidas permanece por documentar, separada da GPL do código.
