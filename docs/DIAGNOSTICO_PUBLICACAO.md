# Diagnóstico de publicação — fase 1

Auditoria estática em 06/11/2026. Nenhuma compilação, execução ou abertura da IDE foi feita nesta fase.

## Inventário

| Item | Situação original |
| --- | --- |
| Projeto | `Coffin Bound final.yyp`, IDEVersion `2026.0.0.16` |
| Rooms registradas | `rm_menu`, `rm_level1`; menu primeiro |
| Scripts | 451 arquivos GML, 29.177 linhas, incluindo bibliotecas |
| Input | versão 10.4.1 |
| Scribble | versão 9.7.3.3 |
| Áudio | Nenhum WAV, OGG, MP3 ou recurso GMSound; somente `audiogroup_default` |
| Fontes | `monogram.ttf`, atlas Monogram e fallback Droid Sans Mono |
| Licenças incluídas no build | `datafiles/input_license.txt`, `datafiles/scribble_license.txt` |
| Controle | `datafiles/gamecontrollerdb.txt`, com origem SDL_GameControllerDB no cabeçalho |
| GitHub | Sem README, LICENSE, CHANGELOG ou remoto na pasta original |
| Backup | Commit inicial e branch `backup/antes-preparacao-publicacao`, criados antes das alterações |

## Licenças e créditos

- **Input:** MIT, copyright 2024 Julian Adams. O arquivo local também contém o aviso BSD dos dados de blocklist Chromium. Ambos devem permanecer na distribuição.
- **Scribble:** MIT, copyright 2023 Julian Adams. Aviso local preservado.
- **Monogram:** CC0 1.0, por datagoblin/Vinícius Menézio. O autor confirma a licença na [página da fonte](https://datagoblin.itch.io/monogram). Falta registrar essa origem junto dos créditos do projeto.
- **Droid Sans Mono:** a fonte fallback declarada no `.yy` é uma fonte da família Droid. A distribuição original Android é Apache 2.0; a presença de `DroidSansMono.ttf` junto de `MODULE_LICENSE_APACHE2` pode ser conferida na [árvore oficial Android](https://android.googlesource.com/platform/frameworks/base/+/5933a49/data/fonts/). Falta incluir o aviso correspondente se esse fallback continuar distribuído.
- **SDL_GameControllerDB:** licença zlib. O arquivo de mapeamentos informa a origem, mas o projeto não inclui o [aviso de licença upstream](https://github.com/mdqinc/SDL_GameControllerDB/blob/master/LICENSE).
- **Arte do jogo:** autoria e autorização de redistribuição das imagens não estão documentadas. Não é possível deduzir uma licença pelo nome do arquivo. Confirmar autoria/origem antes de colocar todos os assets sob uma licença pública.
- **Filtros/prefabs GameMaker:** os prefabs locais declaram autor GameMaker, mas não trazem uma licença independente. Não atribuir MIT a esses arquivos; documentar como conteúdo fornecido pelo GameMaker, sob os termos aplicáveis da ferramenta.
- **Áudio:** não existe áudio original para licenciar ou ajustar. A fase 4 deverá adicionar somente arquivos com origem e licença explícitas.

A licença do código próprio e a licença dos assets devem ter escopos claros. A escolha da licença e o nome de autoria ainda precisam ser definidos pelo titular.

## Problemas para empacotamento

1. `options/windows/options_windows.yy`: empresa `YoYo Games Ltd`, descrição `A GameMaker Game`, produto `Coffin Bound corrijido` e executável `Coffin Bound corrijido.exe`. Substituir por metadados reais do jogo; autoria depende da definição do titular.
2. `options/html5/options_html5.yy`: título ainda contém `final` e interpolação de pixels está ligada. A fase 3 deverá desligá-la.
3. Projeto foi salvo com IDE 2026.0.0.16. Runtimes encontrados no disco: 2024.11.0.226, 2024.13.0.238, 2024.13.1.242, 2024.14.1.253, 2024.14.2.256 e 2024.14.4.268. Não equivale a afirmar compatibilidade de compilação com o runtime mais antigo.
4. Existe Igor em `C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2024.14.4.268\bin\igor\windows\x64\Igor.exe`, mas ele não está no PATH. Exportação exige runtime compatível e configuração/licença da instalação. Não se deve alterar a versão do projeto para simular compatibilidade.
5. O projeto referencia quatro prefabs em `ForcedPrefabProjectReferences`; somente colourise e vignette existem localmente. Conferir resolução das referências de contrast e blend pela IDE antes de exportar.
6. O `.gitignore` original ignora `*.resource_order`; convém versionar a ordem do projeto, preservando os arquivos existentes. O `.yyz` original também deve permanecer recuperável no backup.

## Memória das bibliotecas

Foram lidos os scripts e rastreados pontos de criação/destruição de mapas, grids, buffers, surfaces e partículas. As estruturas estáticas de Input e Scribble são singletons durante a sessão; não se deve classificá-las como vazamento apenas por não serem destruídas a cada room.

O Scribble possui coleta por referências fracas para grids e vertex buffers em `__scribble_tick`, e `scribble_flush_everything` libera esses caches. As surfaces temporárias de `scribble_font_bake_shader` têm `surface_free` no caminho normal.

**Bug latente confirmado:** `scripts/__scribble_class_font/__scribble_class_font.gml` cria `__kerning_map` na linha 30, mas `__destroy` (linha 168) libera somente `__glyphs_map` e `__glyph_data_grid`. Além disso, `__copy_to` (linha 57) trata o mapa de kerning como propriedade comum: substitui o mapa recém-criado do destino e compartilha o identificador do original. O uso de `scribble_font_duplicate` ou de fontes processadas pode perder o mapa do destino e compartilhar alterações de kerning. Corrigir com `ds_map_copy` específico e destruição do mapa, mantendo propriedade independente de cada fonte. O código próprio atual não chama `scribble_font_duplicate`/`scribble_font_delete`; portanto não há evidência de crescimento contínuo desse mapa durante o gameplay original.

## Fontes oficiais para a fase 5

- [Exportação Windows no GameMaker](https://gamemaker.io/en/help/articles/windows-compiling-your-app): criar executável/pacote pela IDE; preferir pacote ZIP para distribuir a pasta executável completa.
- [SDKs necessários do GameMaker](https://gamemaker.io/en/help/articles/gamemaker-s-required-sdks): VM Windows usa as ferramentas incluídas; YYC requer Visual Studio conforme a versão suportada.
- [Configuração HTML5 no GameMaker](https://gamemaker.io/en/help/articles/setting-up-for-html5): selecionar HTML5 no Target Manager, testar por servidor e gerar o pacote pela IDE.
- [Primeira página no itch.io](https://itch.io/docs/creators/getting-started): capa na proporção 315:250; recomendado 630×500, mínimo 315×250; recomendadas 3–5 capturas.
- [Upload de jogos HTML5](https://itch.io/docs/creators/html5): ZIP com `index.html` e dependências, nomes sensíveis a maiúsculas e caminhos relativos. Validar limites do serviço antes do upload.
- [Instalação do butler](https://itch.io/docs/butler/installing.html) e [envio de builds](https://itch.io/docs/butler/pushing.html): `butler push pasta usuario/jogo:canal --userversion VERSAO`. O canal HTML5 precisa ser marcado como jogável no navegador na página do projeto.

As fontes foram consultadas em 06/11/2026. As instruções de publicação deverão ser conferidas junto do build exportado; a existência da configuração HTML5 não comprova que o jogo já funciona no navegador.

## Teste manual necessário

Abrir o `.yyp` na instalação GameMaker compatível; verificar importação dos prefabs, avisos sobre assets ausentes, fonte Monogram, compilação VM Windows e compilação HTML5. Não publicar até confirmar autoria das artes, executar o checklist de QA e testar os pacotes exportados fora da IDE.
