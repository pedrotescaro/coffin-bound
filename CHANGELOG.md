# Changelog

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
