# Arte dos diálogos

- `vampire_portrait.aseprite`: fonte editável criada no LibreSprite.
- `vampire_portrait.png`: arte 88×96 transparente, usada em `spr_portrait_vampire`.
- `vampire_portrait_preview.png`: ampliação nearest 3× para inspeção, sem uso no runner.
- `dialogue_preview.png`: composição estática da interface para revisão; não é screenshot do jogo.

O retrato usa 19 cores da paleta Coffin Gothic 24, com alpha binário. A produção e a
exportação ocorreram no LibreSprite; o pipeline não escreve pixels com Pillow.
Código dos geradores: GPL-3.0-only, como o código próprio do projeto. As imagens são arte
nova do Coffin Bound, sem licença adicional de reutilização declarada; não recebem a GPL
automaticamente. Os assets antigos mantêm sua situação documentada em `docs/LICENCAS.md`.

Reprodução, integração e testes manuais em [DIALOGOS.md](../../docs/DIALOGOS.md).
