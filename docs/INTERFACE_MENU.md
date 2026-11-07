# Interface e menu — 0.2.1

## Entrega

Backup: branch `backup/antes-interface-floresta`, a partir de `3a2cd68`.

- Diálogo adaptado à segunda imagem: moldura dupla, cantoneiras, florões, placa do nome,
  retrato da referência e espaçamento das duas linhas/rodapé.
- Menu com a floresta e as ruínas da terceira imagem em tela inteira. Título em blocos,
  filetes ornamentados e painel lateral mantêm as opções legíveis sem cobrir toda a floresta.
- Opções, Teclas e Créditos usam painel maior sobre o mesmo cenário. As ações foram mantidas.
- Quatro cores Game Boy, amostragem nearest, alpha 0/255, origem (0,0) e escala 1 na GUI.
- PNGs e fontes `.aseprite` foram produzidos com LibreSprite `--batch`. Python apenas
  orquestra o editor, copia arquivos, grava metadados e lê imagens para validação.

## Arquivos alterados

A lista exata está em [arquivos-interface-menu.txt](arquivos-interface-menu.txt).

| Grupo | Caminhos |
| --- | --- |
| Renderização | `scripts/menu_draw/menu_draw.gml`, `scripts/cb_dialogue/cb_dialogue.gml` |
| Wrap do diálogo | `objects/obj_level_controller/Create_0.gml` |
| Projeto e versão | `Coffin Bound final.yyp`, `options/windows/`, `options/html5/` |
| Sprites novos | `sprites/spr_menu_forest/`, `spr_dialogue_frame/`, `spr_title_coffin/`, `spr_ui_border/` |
| Retrato atualizado | `sprites/spr_portrait_vampire/`, `assets/dialogue/` |
| Novas fontes e exports | `assets/interface/`, `art/reference/dialogue-design-reference.png`, `menu-forest-reference.png` |
| Pipeline LibreSprite | `tools/arte/interface_referencias.js`, `.py`, `gerar_retrato.js`, `gerar_preview_dialogo.js`, `.ps1` |
| Documentação | README PT/EN, CHANGELOG, DIALOGOS, LICENCAS, avisos, auditoria e manifesto Windows |

Nenhum asset foi apagado ou renomeado. As imagens brutas em `art/reference` preservam a
referência recebida e não entram no atlas do jogo. Apenas os derivados de quatro cores são usados.

## Verificações

- Validador estrito de recursos: 0 erros, 0 avisos.
- Regressões de serviços e ações do menu: 13 aprovadas.
- Auditoria de sprites, fontes, assets e prefabs: 286 imagens; 0 pixels visíveis fora
  da paleta, 0 com alpha parcial. Resultado: [palette-audit.json](palette-audit.json).
- Prévias estáticas de menu/diálogo inspecionadas como arte, sem alegar execução do jogo.
- Compilação Windows VM e empacotamento aprovados pelo Igor 2026.0.0.23.
- ZIP `CoffinBound-windows-0.2.1.zip`: nove arquivos, integridade e itens obrigatórios aprovados.
  [Manifesto com SHA-256](qa/windows-0.2.1-package.json).
- Regressões adicionais: 13 de movimento e 5 de desafios aprovadas.

## Testar manualmente

Abra **Coffin Bound final.yyp**, selecione **Windows / VM** e pressione **Run**:

1. Menu: veja floresta/ruínas, título inteiro e cursor legível. Navegue em todas as opções.
   Com save, confira a quinta opção SAIR no painel; sem save, confira quatro opções.
2. Opções → Teclas: percorra as nove linhas, incluindo VOLTAR. Confira texto/realce sem
   corte, ajuste volumes e volte. Abra Créditos e confira os nomes/licenças visíveis.
3. Novo jogo: confira retrato inteiro e duas linhas dentro da moldura. Enter deve revelar
   a fala e depois fechar. Na fala ECO DA CRIPTA, confira a placa mais larga e o texto.
4. F11, redimensionamento de janela e G: confira escala inteira, quatro cores e ausência
   de bordas borradas. Pause/retome e use R; confira ausência de pulo/dash involuntário.
5. Repita navegação/avanço com controle e extraia o ZIP para testar fora da IDE.

## Pendências

A apresentação e interação no runner ainda precisam dessa rodada manual. A aprovação
anterior do menu básico não foi transferida para esta interface. O balanceamento das três
rooms, performance, áudio e HTML5 continuam nas pendências já registradas em QA. A origem
/licença das imagens fornecidas continua por documentar; a GPL do código não licencia a arte.
