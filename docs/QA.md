# Checklist final de QA

Marque somente após testar e registrar evidência. As verificações estáticas já feitas estão em [Entregas](ENTREGAS.md); elas não aprovam estes testes do runner. Na fase 6, o usuário confirmou menu inicial, Novo jogo, diálogo/Enter, pulo/Espaço, pausa/retomada/Esc e reinício/R sem erro e sem ações involuntárias ao retomar/reiniciar. Evidência e limites dessa rodada em [QA Windows](QA_WINDOWS.md); os demais itens continuam pendentes.

Registro da rodada:

| Campo | Preencher |
| --- | --- |
| Data / responsável | |
| Commit / versão do build | |
| Versão IDE / runtime | |
| Alvo: Windows VM / YYC / HTML5 | |
| Sistema / navegador / hardware / controle | |
| Resolução e escala usadas | |
| Resultado / issues / capturas | |

## Compilação e início

- [ ] Abrir o `.yyp` sem recursos ausentes e registrar avisos da IDE/runtime.
- [x] Gerar e executar build Windows VM, registrando resultado da compilação (fase 6).
- [x] Extrair o ZIP de QA em outra pasta e iniciar o executável sem a IDE aberta (fase 6; menu confirmado pelo usuário).
- [ ] Com save novo, conferir menu, opções, créditos e início da fase.
- [ ] Confirmar que o menu não cria pausas/controladores duplicados após dez retornos.
- [ ] Conferir que confirmar Novo jogo não dispara pulo/dash/transformação no primeiro frame.

## Movimento, colisão e fase

- [ ] Caminhar, acelerar, frear e inverter direção com teclado e analógico parcial.
- [ ] Comparar toque curto de pulo com pulo segurado; conferir ápice e aterrissagem.
- [ ] Pular até seis frames após sair da borda; conferir fim da tolerância.
- [ ] Apertar pulo até seis frames antes de pousar; conferir execução do buffer.
- [ ] Usar dash nas oito direções contra paredes, chão e teto finos; verificar travessia indevida e travamento.
- [ ] Conferir wall slide/jump, perda de contato com a parede e retorno do controle horizontal.
- [ ] Transformar junto do chão/teto, virar com analógico e voltar à forma humana em espaço estreito.
- [ ] Conferir energia, recarga, fadiga do morcego e ausência de alteração da máscara com direção/escala.
- [ ] Completar a única fase do início ao caixão, sem usar debug/restart para atravessar obstáculos.
- [ ] Conferir transições entre andar, subida, queda, morcego, dano, morte e vitória.
- [ ] Confirmar que a vitória encerra o movimento e abre os créditos uma única vez.

## Morte, checkpoints e save

- [ ] Morrer por espinhos, queda e luz; conferir vida, tela de morte, partículas e som.
- [ ] Testar Tentar novamente e Voltar ao menu após morrer.
- [ ] Morrer antes do primeiro checkpoint e depois de cada um dos três checkpoints.
- [ ] Conferir posição segura de respawn, vida/energia restauradas e proteção inicial.
- [ ] Fechar e reabrir após cada checkpoint; Continuar deve retomar o checkpoint salvo.
- [ ] Reiniciar com R e pela pausa; confirmar ausência de salto involuntário no respawn.
- [ ] Conferir contador de mortes; uma morte deve contar uma vez.
- [ ] Concluir, fechar/reabrir e conferir estado de conclusão e opção Continuar.
- [ ] Iniciar Novo jogo com progresso salvo; conferir reset do progresso e preservação das preferências.
- [ ] Testar ausência/versão inválida de save em uma cópia dos arquivos, mantendo backup dos saves reais.

## Interface, opções e dispositivos

- [ ] Pausar e retomar durante pulo, dash, morcego e diálogo; conferir timers/movimento congelados.
- [ ] Segurar uma ação ao retomar; conferir ausência de acionamento involuntário.
- [ ] Avançar/pular diálogo com teclado e controle, sem pulo extra ao fechá-lo.
- [ ] Ajustar volumes geral, efeitos e música em 0%, 50% e 100%; fechar/reabrir e confirmar persistência.
- [ ] Remapear as sete ações; testar tecla repetida, reservada, cancelamento e tempo esgotado.
- [ ] Restaurar teclas padrão e conferir alternativas fixas de setas.
- [ ] Navegar menus e jogar somente com controle; testar analógico, direcional, A/B/X e Start.
- [ ] Desconectar/reconectar o controle durante fase e pausa; confirmar que o teclado continua utilizável.
- [ ] Sair pelo menu Windows, reabrir e conferir preferências/progresso.

## Pixels, câmera e áudio

- [ ] Conferir 960×540, 1366×768 e 1920×1080: escala inteira, barras, proporção e GUI alinhada.
- [ ] Conferir câmera nos quatro limites da room, shake e retorno após respawn.
- [ ] Fazer movimento lento e olhar frestas de tiles, bleeding, subpixel e nitidez do texto.
- [ ] Conferir pés/origens/máscaras entre idle, walk, jump, fall, dash e morcego.
- [ ] Conferir legibilidade das poses fixas de salto/queda e timing das animações.
- [ ] Alternar filtro G, fullscreen/F11 e Alt+Tab; conferir recuperação da surface e estado do filtro entre rooms.
- [ ] Ouvir todos os SFX e pelo menos três voltas da música; seguir [QA de áudio](AUDIO.md).
- [ ] Repetir entradas/saídas de menu/fase; música não pode acumular instâncias.

## Performance e memória

Meta de projeto: **60 FPS**, com orçamento médio de aproximadamente **16,67 ms por frame**. Trata-se de uma meta a medir, não de um desempenho já demonstrado.

- [ ] Registrar FPS e tempo por frame no menu, em movimento, sob luz e durante bursts de morte/morcego.
- [ ] Jogar por pelo menos dez minutos e repetir vinte mortes/respawns e dez retornos ao menu.
- [ ] Usar profiler e registrar memória, instâncias, partículas/arrays e custo de draw/colisão.
- [ ] Verificar ausência de crescimento contínuo de memória ou instâncias após ciclos repetidos.
- [ ] Testar Alt+Tab/fullscreen repetidamente e conferir recuperação sem novas surfaces acumuladas.
- [ ] Registrar travamentos, picos e hardware; corrigir regressões antes de marcar aprovado.

## HTML5 — somente se o alvo for publicado

- [ ] Compilar HTML5 e testar por servidor, sem usar `file://` como validação.
- [ ] Conferir `index.html` na raiz do ZIP, caminhos relativos e erros de console/rede.
- [ ] Testar iframe itch.io em dois navegadores disponíveis, com viewport mínimo 480×270.
- [ ] Após interação inicial, conferir áudio, teclas, controle e foco ao trocar de aba.
- [ ] Testar botão fullscreen do itch.io/navegador e sair com Esc.
- [ ] Recarregar, fechar/reabrir e conferir persistência com armazenamento permitido.
- [ ] Se armazenamento for bloqueado, documentar a limitação e verificar comportamento sem crash.
- [ ] Sair pelo menu deve orientar fechar a aba, sem fluxo quebrado.

## Pacote e publicação

- [ ] Confirmar origem, autor e licença/permissão de redistribuição das artes originais e derivações.
- [ ] Conferir LICENSE GPL-3.0-only do código, avisos MIT/BSD/Apache/zlib e dedicação CC0 dos WAVs.
- [ ] Incluir avisos no build e disponibilizar código-fonte correspondente à versão distribuída.
- [ ] Gravar 3–5 screenshots reais e GIFs de gameplay; distinguir a prévia de sprites do README.
- [ ] Produzir capa autorizada 630×500 e conferir sua legibilidade em miniatura.
- [ ] Conferir texto/idioma/plataformas da página e comandos do [guia itch.io](ITCH_IO.md).
- [ ] Revisar pasta final antes do butler; excluir caches, dados pessoais e credenciais.
- [ ] Baixar pelo itch.io e testar a cópia recebida antes de anunciar a publicação.

Resultado final da rodada: **pendente**. Registre pendências com reprodução, alvo, captura/log e responsável; não marque a versão como pronta somente porque o validador estático passou.
