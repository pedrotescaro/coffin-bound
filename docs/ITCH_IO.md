# Publicação no itch.io

Material preparado em 06/11/2026. Preencha os identificadores da sua conta e use somente um build aprovado em [QA](QA.md). A existência deste guia não significa que o upload ou os testes do jogo foram realizados.

## Texto da página — português

**Título:** Coffin Bound

**Subtítulo:** Pule, voe e encontre seu lugar na noite.

**Descrição:**

> O caminho de volta para casa atravessa uma cripta cheia de espinhos, paredes e luzes perigosas. Você é um vampiro em busca do próprio caixão — e, quando os pés não alcançam o próximo salto, suas asas podem abrir outra passagem.
>
> Coffin Bound é um platformer 2D em pixel art com movimento inspirado em Celeste: pulo de altura variável, dash, salto de parede e transformação em morcego. Atravesse uma fase com três checkpoints, experimente as rotas e volte a tentar depois de cada queda.
>
> Inclui opções de volume, filtro retro, remapeamento básico de teclado, suporte a controle e salvamento de progresso. Interface em português. Criado por Pedro Tescaro em GameMaker.

Use o quadro de controles do README abaixo da descrição. Apresente Windows como plataforma disponível somente depois de testar o pacote exportado. Acrescente “jogue no navegador” somente após aprovar a versão HTML5.

## Page copy — English

**Title:** Coffin Bound

**Short description:** Jump, fly, and find your place in the night.

**Description:**

> The way home runs through a crypt filled with spikes, walls and dangerous lights. You are a vampire searching for your coffin — and when your feet cannot reach the next ledge, your wings may reveal another way forward.
>
> Coffin Bound is a 2D pixel art platformer with movement inspired by Celeste: variable-height jumps, dashing, wall jumps and bat transformation. Cross one level with three checkpoints, explore its routes and try again after each fall.
>
> Includes volume options, a retro filter, basic keyboard rebinding, controller support and saved progress. The in-game interface is in Portuguese. Created by Pedro Tescaro in GameMaker.

List Windows only after validating the exported package. Advertise browser play only after approving the HTML5 build.

## Classificação e apresentação

| Campo | Conteúdo sugerido |
| --- | --- |
| Classificação | Games |
| Gênero | Platformer |
| Tags | 2D, Pixel Art, Platformer, Precision Platformer, Vampire, Dark Fantasy, Singleplayer, GameMaker |
| Plataforma inicial | Windows, após QA |
| Plataforma opcional | HTML5, após compilação e QA em navegador |
| Idioma do jogo | Português |
| Autor | Pedro Tescaro |
| Estado | In development enquanto o QA estiver pendente; Released após aprovação |

Escolha na interface as tags equivalentes disponíveis. Não anuncie fases adicionais, versão mobile ou idioma inglês no jogo. O sistema atual tem uma fase, três checkpoints e documentação bilíngue.

O itch.io recomenda capa **630×500 px**, na proporção 315:250; o mínimo é 315×250. Recomenda também **3–5 screenshots**. Essas medidas vêm do [guia oficial para criadores](https://itch.io/docs/creators/getting-started).

Plano de mídia:

1. Captura 960×540 do início da cripta, com personagem, HUD e leitura clara da primeira rota.
2. Captura 960×540 de salto de parede/dash perto de obstáculos, sem overlays de debug.
3. Captura 960×540 da forma morcego atravessando um trecho característico.
4. Captura opcional de checkpoint, indicando seu feedback visual.
5. Captura opcional da aproximação ao caixão, sem mostrar toda a conclusão.

Grave GIFs de **4–8 segundos** com um único acontecimento: wall jump seguido de dash; transformação em morcego e pouso; morte e tentativa seguinte. Capture no runner exportado, em escala inteira, com movimentos reais e sem montar ações que o jogador não consegue fazer. As dimensões/durações de GIF são sugestões de produção, não exigências do serviço.

O arquivo `assets/preview/vampiro.gif` é uma **prévia de sprites**, adequada ao README. Ele não serve como evidência de gameplay. A capa deve usar arte de origem autorizada e texto legível mesmo em miniatura. Não estique uma captura 16:9 para caber na proporção da capa; componha uma moldura adequada.

## Exportar Windows

1. Abra `Coffin Bound final.yyp` numa instalação compatível com a IDE 2026.0.0.16 e selecione o runtime adequado.
2. No Target Manager, escolha **Windows / VM**. VM usa as ferramentas incluídas; YYC requer Visual Studio/SDK compatíveis. Consulte [SDKs oficiais](https://gamemaker.io/en/help/articles/gamemaker-s-required-sdks).
3. Execute pela IDE e complete o QA de jogabilidade. Corrija mensagens de compilação e avisos de recurso ausente antes de prosseguir.
4. Use **Create Executable** e escolha **ZIP**. Guarde a saída numa pasta separada, por exemplo `dist/windows/`, sem misturar fontes ou caches. Veja [Windows: Compiling Your App](https://gamemaker.io/en/help/articles/windows-compiling-your-app).
5. Extraia o ZIP em outra pasta. Execute o `.exe` extraído com todos os arquivos que o GameMaker gerou; não mova apenas o executável.
6. Inclua `LICENSE`, avisos de terceiros e acesso ao código-fonte correspondente à mesma versão. Antes da distribuição, resolva a procedência/licença das artes conforme [Licenças](LICENCAS.md).
7. Teste sem a IDE, com save novo e save existente. Registre versão, runtime, máquina e resultados em [QA](QA.md).

## Exportar HTML5, se aprovado

HTML5 está preparado no código, mas sua compatibilidade precisa ser comprovada no build e no navegador.

1. Selecione **HTML5** no Target Manager e confirme disponibilidade do alvo/runtime na sua instalação. Siga a [configuração oficial GameMaker](https://gamemaker.io/en/help/articles/setting-up-for-html5).
2. Execute pelo servidor de testes da IDE; valide WebGL, texto, entradas, armazenamento, áudio após interação inicial e recuperação de foco.
3. Use **Create Executable**. Exporte a pasta inteira, com `index.html` e a pasta `html5game`/dependências que forem geradas.
4. Crie um ZIP cujo **primeiro nível contenha `index.html`**. Preserve maiúsculas/minúsculas e caminhos relativos. Não compacte uma pasta externa adicional em volta de tudo.
5. Configure o projeto no itch.io como **HTML Game**, marque o arquivo para execução no navegador e use iframe de **960×540**, nunca menor que 480×270. Ative o botão de fullscreen do itch.io; as opções do jogo orientam o jogador a usá-lo.
6. Teste o iframe real em pelo menos dois navegadores disponíveis, incluindo primeira interação para áudio, tecla Esc, fullscreen, controle, reload e retomada do save. Não publique essa variante se qualquer bloqueio impedir a experiência.

O [guia oficial de HTML5 do itch.io](https://itch.io/docs/creators/html5) descreve ZIP, `index.html`, caminhos e limites de arquivos/tamanho. Confira os limites atuais se o export crescer; mantenha apenas os arquivos necessários ao jogo.

## Enviar usando butler

Instale o butler conforme o [manual oficial](https://itch.io/docs/butler/installing.html). Crie o projeto no painel do itch.io e mantenha a página em rascunho enquanto confere seu conteúdo. Os exemplos usam valores ilustrativos: substitua `SEU_USUARIO`, `coffin-bound` e `1.0.0` pelos valores reais. O caminho enviado deve conter somente o build de distribuição aprovado.

```powershell
butler login
butler push-preview "dist/windows" "SEU_USUARIO/coffin-bound:windows" --changes-only
butler push "dist/windows" "SEU_USUARIO/coffin-bound:windows" --userversion "1.0.0"
```

`push-preview` é opcional e compara a pasta ao canal remoto sem criar build. `push` envia e disponibiliza o conteúdo conforme a visibilidade do projeto/canal; execute-o somente depois de revisar a pasta e a página. Para um **canal novo** que precise ficar oculto, o butler aceita `--hidden`; isso não serve para patches ocultos num canal que já existe. Veja [Pushing builds](https://itch.io/docs/butler/pushing.html).

Somente após aprovar HTML5:

```powershell
butler push-preview "dist/html5" "SEU_USUARIO/coffin-bound:html5" --changes-only
butler push "dist/html5" "SEU_USUARIO/coffin-bound:html5" --userversion "1.0.0"
```

Depois do primeiro envio HTML5, marque o canal como **HTML5 / Playable in browser** na edição da página e salve. O nome `html5` sozinho não configura essa opção, conforme o [manual butler](https://itch.io/docs/butler/pushing.html).

Antes de tornar a página pública, confira os downloads pelo próprio itch.io, a licença, as capturas reais, a indicação de idioma, os canais/plataformas, os controles e a versão. Nenhum comando de upload foi executado por este guia.
