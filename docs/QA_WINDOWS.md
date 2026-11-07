# Fase 6 — pacote Windows e validação inicial

## Versão desta rodada

- Data local: 06/11/2026.
- Fontes do jogo: commit `4b577c900a40a1b05721b2195a670aa81452dbce`.
- Alvo: Windows x64 / VM, Igor LTS `2026.0.0.23`.
- Backup antes desta fase: branch `backup/antes-validacao-windows-2026-11-06`.
- Ferramentas e documentação desta fase não alteram objetos, sprites, rooms ou mecânicas.

O pacote local é `.build/windows/package/CoffinBound-windows-0.1.0.zip`.
O manifesto versionado em [qa/windows-0.1.0-package.json](qa/windows-0.1.0-package.json)
registra os tamanhos e hashes dos arquivos da geração final. O ZIP é um candidato para QA;
não foi publicado como release jogável ou enviado ao itch.io.

## Gerar e conferir

```powershell
./tools/build.ps1 -RuntimePath 'CAMINHO_DO_RUNTIME' -UserPath 'PASTA_DO_USUARIO_GAMEMAKER' -Target Windows -Package
python tools/check_package.py '.build/windows/package/CoffinBound-windows-0.1.0.zip' --output-manifest '.build/windows/package/manifest.json'
```

Sem `-Package`, o script continua fazendo somente Compile. A opção Package chama
`windows PackageZip`, com a versão obtida dos metadados do jogo. Cada geração usa uma
pasta de saída nova para não incorporar resíduos de uma exportação anterior.
O cache de compilação continua reutilizável. As saídas permanecem fora do Git.

O verificador abre o ZIP sem extrair ou executar: verifica CRCs, caminhos, colisões de
maiúsculas/minúsculas no Windows, arquivos obrigatórios, cabeçalhos e hashes. Rejeita
resíduos como `igor.output.manifest`, saves/configurações pessoais e arquivos de credenciais.
Ele não comprova assinatura digital, jogabilidade ou licença das artes.

## Conteúdo necessário

| Arquivo | Uso |
| --- | --- |
| `CoffinBound.exe` | Runner Windows |
| `data.win` | Dados compilados do jogo |
| `audiogroup_music.dat` | Música do grupo separado |
| `options.ini` | Opções do runner |
| `gamecontrollerdb.txt` | Mapeamentos de controles |
| `GPL-3.0.txt` | Licença do código próprio |
| `input_license.txt` | Avisos originais do Input |
| `scribble_license.txt` | Aviso original do Scribble |
| `third_party_notices.txt` | Avisos consolidados de terceiros |

Extraia tudo em uma pasta separada e abra `CoffinBound.exe`. Não mova somente o executável.
O fonte correspondente está no repositório público; o ZIP não inclui o GameMaker IDE,
arquivos de autenticação, caches ou o histórico Git.

## Evidência de abertura

O executável foi extraído em uma pasta de QA e iniciado sem abrir a IDE. A primeira
tentativa de lançamento da ferramenta expirou e deixou um processo suspenso; esse processo
de teste foi encerrado. A segunda tentativa abriu uma janela intitulada **Coffin Bound**.
A leitura de acessibilidade identificou a janela, sem mensagem de erro acessível.

O usuário confirmou nesta rodada: **“O menu aparece normalmente”**. Essa confirmação aprova
somente a apresentação do menu inicial relatada pelo usuário. A ferramenta de captura
automática falhou com `window capture timed out`; nenhuma captura de gameplay foi produzida
ou apresentada como evidência visual.

Verificação básica adicional solicitada ao usuário: Novo jogo → avançar diálogo com Enter →
pular com Espaço → pausar/retomar com Esc → reiniciar com R. Conferir imagem e ausência de
pulo/dash involuntário ao retomar/reiniciar. O usuário respondeu: **“Tudo passou sem erro”**.

| Verificação básica | Resultado / evidência |
| --- | --- |
| Abertura do menu inicial | Confirmada pelo usuário |
| Novo jogo e diálogo com Enter | Confirmados pelo usuário |
| Pulo com Espaço | Confirmado pelo usuário |
| Pausa/retomada com Esc | Confirmada pelo usuário |
| Reinício com R | Confirmado pelo usuário |
| Imagem correta e ausência de pulo/dash involuntário ao retomar/reiniciar | Confirmadas pelo usuário |

Esse relato cobre o conjunto solicitado, com teclado. Não aprova automaticamente o percurso
completo, todos os contextos de pausa, checkpoints, controle, audição ou performance.

## O que ainda conferir

1. Execute a sequência básica acima e registre qualquer mensagem de erro integral.
2. Atravesse a fase até o caixão; confira morte por luz, espinho e queda e cada checkpoint.
3. Feche/reabra e use Continuar; confira save, opções e remapeamento.
4. Teste controle, fullscreen, Alt+Tab, alinhamento dos pixels e recuperação de janela.
5. Ouça os efeitos e três voltas da música; meça frame time/memória no profiler.
6. Grave capturas reais após validar o jogo. Confirme a procedência das artes antes da
   distribuição do build. HTML5 continua dependente do módulo ausente na instalação local.

O checklist completo continua em [QA.md](QA.md). A geração do ZIP e a confirmação de abertura
não equivalem a concluir esse checklist.

Referências: [Igor por linha de comando](https://manual.gamemaker.io/lts/en/Settings/Building_via_Command_Line.htm)
e [exportação Windows](https://gamemaker.io/en/help/articles/windows-compiling-your-app).
