# Changelog

## 0.2.1 — 2026-11-07

- Menu com floresta e ruínas da referência fornecida, título em blocos e painéis legíveis.
- Diálogo com moldura dupla ornamentada e retrato adaptado da segunda referência.
- Arte exportada no LibreSprite, com quatro cores exatas e fontes editáveis.
- Conteúdo das falas e ações dos menus preservados; validação visual no runner pendente.

## 0.2.0 — 2026-11-07

- Paleta Game Boy fixa em toda arte/UI/partículas, auditada no LibreSprite.
- Retrato baseado na referência fornecida, adaptado a quatro cores.
- Tijolos gastos, musgo, correntes, teias e ossos.
- Três rooms com dificuldade crescente, checkpoints, one-way, móveis e desmoronáveis.
- Serras, pêndulos, lâminas cíclicas, morcegos e esqueletos por contato.
- Máscara menor do morcego e corredores de transformação; sem combate.
- Balanceamento e travessia completos pendentes de teste manual.

## 0.1.2 — 2026-11-06

- Rosto do vampiro redesenhado no LibreSprite: face maior, olhos rubi, volumes e presas legíveis.
- Novos atlas góticos e composição do mapa com arcos, colunas, vitrais, estandartes e mausoléu.
- Materiais de travessia mais claros, arquitetura de fundo escura e piso antes invisível texturizado.
- Percurso, colisores, armadilhas e checkpoints preservados; camadas visuais antigas mantidas ocultas.
- Fontes editáveis e geradores reproduzíveis para retrato, atlas e mapa.

## 0.1.1 — 2026-11-06

- Caixa de diálogo com moldura gótica, joias, separadores, placa do falante e rodapé de avanço.
- Retrato detalhado original do vampiro em 88×96, desenhado e exportado no LibreSprite.
- Fonte `.aseprite`, PNGs e geradores reproduzíveis; sprite integrado sem alterar assets anteriores.
- Área de texto de 306 pixels e duas linhas com espaçamento inteiro de 20 pixels.
- Compilação e pacote Windows atualizados; conferir a nova interface no runner conforme `docs/DIALOGOS.md`.

## Não lançado — validação Windows (fase 6)

- Adicionada opção `tools/build.ps1 -Package` para exportar o ZIP completo pelo Igor.
- Cada empacotamento usa uma pasta de saída nova e evita resíduos de exportações anteriores.
- Adicionado verificador do pacote e manifesto com arquivos, CRCs e hashes.
- Pacote Windows gerado; menu, Novo jogo, diálogo, pulo, pausa/retomada e reinício confirmados
  pelo usuário na rodada básica com teclado. Relatório em `docs/QA_WINDOWS.md`.
- Gameplay completo, checkpoints, controle, audição e performance continuam pendentes.

## 0.1.0 — 2026-11-06

Preparação do projeto existente para publicação por Pedro Tescaro.

- Backup original em commit e branch `backup/antes-preparacao-publicacao`.
- Diagnóstico de código, arte, eventos, memória, licenças e exportação.
- Colisão varrida com resíduos subpixel; aceleração/fricção, coyote time, jump buffer,
  altura variável, dash, wall jump e transformação revisados.
- Estados explícitos de andar/parado, pulo, queda, morcego, dano, morte e vitória.
- Direção visual separada da máscara de colisão; respawn completo e dano centralizado.
- Paleta gótica de 24 cores, 20 spritesheets e pipeline real de LibreSprite batch.
- Origens alinhadas, vela 14×16, tiles 16×16 e apresentação inteira em 480×270.
- Menu, pausa, game over, créditos, checkpoints/save, opções, teclas e controle.
- Câmera limitada com shake leve; partículas limitadas e nove WAVs originais CC0.
- Correção do ciclo de vida/cópia do mapa de kerning no Scribble.
- README PT/EN, GPL-3.0 para código próprio, avisos de terceiros, guia itch.io e QA.
- Verificações automáticas e compilação Windows VM via Igor 2026.0.0.23.
- Capitalização do arquivo `InputPlugInGamepadGetVendorAndProduct.gml` corrigida para
  checkouts Linux; nome do recurso e conteúdo preservados. Validador detecta essa divergência.

Ainda pendentes: execução e QA manual do jogo, audição, desempenho, capturas reais e
confirmação da procedência das artes. HTML5 requer instalar o módulo ausente no runtime
local e validar o build no navegador. A prévia GIF do README representa um asset.
