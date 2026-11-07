# Licenças e escopos

O código próprio de Coffin Bound é **GPL-3.0-only**, copyright © 2026 Pedro Tescaro.
O texto integral está em [LICENSE](../LICENSE). Essa escolha foi feita pelo titular para
o código próprio; não substitui os avisos de bibliotecas nem atribui uma licença às imagens.

| Conteúdo | Licença / situação | Aviso |
| --- | --- | --- |
| GML próprio de objetos, player, menu e serviços; ferramentas próprias Python/JS/PowerShell | GPL-3.0-only | [LICENSE](../LICENSE) |
| Input e seus plug-ins | MIT, Julian Adams, 2024; contém dados Chromium com aviso BSD | [Aviso original](../datafiles/input_license.txt) |
| Scribble | MIT, Julian Adams, 2023 | [Aviso original](../datafiles/scribble_license.txt) |
| Monogram, TTF e atlas | CC0-1.0, datagoblin | [Registro da fonte](../licenses/Monogram-CC0.txt) |
| Fallback Droid Sans Mono | Apache-2.0, Android Open Source Project | [NOTICE](../licenses/DroidSansMono-NOTICE.txt), [licença](../licenses/Apache-2.0.txt) |
| `datafiles/gamecontrollerdb.txt` | zlib, SDL_GameControllerDB / Sam Lantinga | [Licença](../licenses/SDL_GameControllerDB-zlib.txt) |
| Nove WAVs originais em `sounds/snd_cb_*/` | CC0-1.0, Pedro Tescaro | [Dedicação](../licenses/Audio-CC0.txt), [manifesto](../assets/audio_manifest.json) |
| Retrato atual, floresta de menu e referências em `art/reference/` | Imagens fornecidas por Pedro e adaptadas no LibreSprite; procedência/licença de origem não documentadas; excluídas da GPL do código | [Diálogos](DIALOGOS.md), [interface](INTERFACE_MENU.md) |
| Molduras e título em blocos de `assets/interface/` | Desenhados no LibreSprite para esta etapa; nenhuma licença adicional de reutilização declarada; excluídos da GPL do código | [Interface](INTERFACE_MENU.md) |
| Cenário novo, atlas e fontes LibreSprite em `assets/environment/` e `spr_crypt_map` | Arte original criada para Coffin Bound; nenhuma licença adicional de reutilização declarada; excluída da GPL do código | [Rosto e mapa](ROSTO_E_MAPA.md) |
| Arte dos desafios em `assets/challenges/`, `spr_challenge_atlas`, espinho redesenhado e novo revestimento dos sólidos | Desenhada no LibreSprite para esta etapa; nenhuma licença adicional de reutilização declarada; excluída da GPL do código. Os fundos preservados conservam a procedência anterior | [Plataformas e inimigos](PLATAFORMAS_INIMIGOS.md) |
| Cenários 0.2.3, referência e fontes em `assets/cathedral/`, `art/reference/cathedral-detailed-reference.png` e `spr_level_green_1/2/3` | Adaptados da referência fornecida por Pedro; procedência/licença de origem não documentadas; excluídos da GPL do código | [Catedral detalhada](CATEDRAL_DETALHADA.md) |
| Tileset modular 0.2.4 em `assets/tileset/`, `spr_tileset_catedral`, `ts_catedral_16` | Adaptado da referência de tileset fornecida por Pedro, com peças técnicas e teia desenhadas no LibreSprite; procedência/licença da referência por documentar, fora da GPL do código | [Tileset da catedral](TILESET_CATEDRAL.md) |
| Paleta Game Boy Green 16 | Rampa de verdes definida nesta etapa, mantendo os quatro tons clássicos; não altera os direitos das imagens | [Arquivo de paleta](../art/palette/gameboy-green-16.gpl) |
| Paleta Coffin Gothic 24 | Paleta definida nesta preparação; não modifica direitos das imagens | [Paleta](../assets/palette/README.md) |
| Sprites, tiles, backgrounds, HUD e derivações/exportações/prévia | Autoria e licença original ainda não documentadas; excluídos da GPL do código | Confirmar procedência e permissão com o titular |
| Prefabs/filtros fornecidos com GameMaker | Termos próprios da distribuição GameMaker; nenhuma relicença GPL é atribuída aqui | Manter metadados e observar os termos da instalação |

As correções locais no Scribble mantêm o aviso MIT original. Elas tratam cópia e destruição
do mapa de kerning e estão identificadas no histórico e no diagnóstico de código. Input,
Scribble e os fontes técnicos não se tornam obras originais do projeto por estarem no repositório.

## Arte original

O projeto foi recebido com os arquivos de imagem existentes, sem uma lista de autores ou
links de origem. Recolorir, redimensionar e exportar esses arquivos não comprova autoria nem
permissão de redistribuição. A licença GPL aplicada ao código não deve ser interpretada como
licença dessas imagens. A publicação pública solicitada pelo titular mantém essa pendência
explícita; reutilizadores precisam obter a licença aplicável antes de redistribuir a arte.

Para encerrar a pendência, registre para cada pack/sprite: autor, URL ou fonte original,
licença, exigência de atribuição e eventuais alterações. Se a arte for integralmente própria,
Pedro Tescaro pode documentar essa autoria e escolher uma licença específica para os assets.

## Distribuir um build

Inclua `LICENSE`, os avisos de terceiros e acesso ao código-fonte correspondente à mesma
versão do executável. O arquivo consolidado `datafiles/third_party_notices.txt` reúne os
avisos aplicáveis ao build e deve ser mantido no pacote. Os textos originais MIT/BSD,
Apache e zlib permanecem preservados. A GPL não concede licenças do GameMaker ou dos SDKs.

Fontes primárias consultadas em 06/11/2026: [Monogram](https://datagoblin.itch.io/monogram),
[Droid/Android NOTICE](https://android.googlesource.com/platform/frameworks/base/+/5933a49/data/fonts/NOTICE),
[SDL_GameControllerDB](https://github.com/mdqinc/SDL_GameControllerDB/blob/master/LICENSE),
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) e
[CC0](https://creativecommons.org/publicdomain/zero/1.0/legalcode).
