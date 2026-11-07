# Diálogos — apresentação 0.2.1

A moldura atual segue a segunda referência visual fornecida por Pedro: borda dupla,
cantoneiras esculpidas, florões, janela do retrato, placa do falante e indicação de avanço.
O retrato foi recortado da referência e adaptado no LibreSprite para 88×96, com origem (0,0).
Não é apresentado como desenho original: a fonte está em `art/reference/dialogue-design-reference.png`.

A GUI permanece em 480×270 e escala inteira. A caixa ocupa (26,132)–(453,257), com arte
`spr_dialogue_frame` de 428×126. Retrato em (44,147), placa em (146,144), corpo em (148,173),
rodapé em y=232. O texto fica separado da imagem; wrap de 294 pixels e linhas de 20 pixels.
A maior linha existente tem 270 pixels. O mesmo retrato acompanha o protagonista enquanto
o nome distingue VAMPIRO de ECO DA CRIPTA. As quatro falas e o comportamento Enter/A
foram preservados. Nenhum asset foi removido ou renomeado.

Todas as cores visíveis são #0F380F, #306230, #8BAC0F e #9BBC0F. A referência tem tons
adicionais; os tons pálidos foram aproximados à paleta exigida. Não há gradientes ou AA;
redução nearest e alpha binário. A imagem de referência bruta não é renderizada no jogo.

## Fontes e reprodução

- `assets/dialogue/vampire_portrait.aseprite`: retrato editável.
- `assets/interface/dialogue_frame.aseprite`: moldura sem texto, editável.
- `assets/dialogue/dialogue_preview.png`: composição estática, não captura do runner.
- `tools/arte/interface_referencias.py`: gera toda a nova interface via LibreSprite e
  sincroniza PNGs composite/layer e metadados, preservando IDs existentes.
- `tools/arte/gerar_retrato.ps1`: reproduz apenas o retrato escolhido e prévias nearest.
- `tools/arte/gerar_preview_dialogo.ps1`: exporta as prévias estáticas de diálogo/menu.

```powershell
python tools/arte/interface_referencias.py --libresprite 'CAMINHO/libresprite.exe'
./tools/arte/gerar_retrato.ps1 -LibreSprite 'CAMINHO/libresprite.exe'
./tools/arte/gerar_preview_dialogo.ps1 -LibreSprite 'CAMINHO/libresprite.exe'
python tools/arte/gameboy.py
```

Os geradores sobrescrevem as exportações. Após editar manualmente uma fonte `.aseprite`,
exporte pelo LibreSprite e sincronize os PNGs do frame/layer em vez de regenerar a arte.
As referências fornecidas não recebem automaticamente licença de reutilização por estarem
no repositório; veja [Licenças](LICENCAS.md).

## Conferir na IDE

Abra `Coffin Bound final.yyp`, selecione Windows / VM e execute Run:

1. Novo jogo: confira retrato inteiro, moldura dupla e as duas linhas sem corte.
2. Enter: primeiro revela o texto e depois fecha, sem pulo ou dash involuntário.
3. Na fala ECO DA CRIPTA, confira nome e a maior linha dentro da moldura.
4. Pause/retome, reinicie com R e alterne F11; confira caixa, pixels e posição da GUI.
5. Teste A no controle nas mesmas etapas; a confirmação anterior do teclado não cobre isto.

Compilação e auditoria de arquivos não aprovam a apresentação no runner.
Resultados desta alteração e menu: [Interface e menu](INTERFACE_MENU.md).
