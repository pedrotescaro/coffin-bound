# Polimento e salvamento

## Fluxo

Menu: continuar quando há save, novo jogo, opções, créditos e saída. Pausa com Esc/P ou
Start no controle; continuar, reiniciar o checkpoint ou voltar ao menu. A pausa congela os
Steps do mundo e a animação do jogador, mantendo a interface e o sistema de input ativos.
A confirmação ao retomar/renascer/fechar diálogo não dispara pulo/dash/transformação.

Morte por luz, espinho ou queda entra em DEATH. Após 24 frames, Enter/A ou R retorna ao
checkpoint; Esc/B volta ao menu. O caixão inicia WIN por 120 frames; depois o catálogo
avança à próxima room ou abre os créditos. O catálogo tem somente `rm_level1`, a fase
existente: não foram criadas novas fases.

## Preferências

`coffin_bound_settings.ini`: master/music/sfx, fullscreen, filtro e sete teclas.
Volumes iniciais: 80%, 45%, 70%; recursos de áudio em volume 1. As setas continuam fixas
como alternativas de movimento; navegação de menus é independente do remapeamento.
Remap aceita letras, números, espaço e Shift, rejeita duplicações e G/P/R reservados.
Esc cancela e há timeout de 5 segundos. Controle mantém direcional/analógico, A pulo,
B dash, X morcego, Start pausa (nomes Xbox/equivalentes conforme o dispositivo).

G alterna o filtro; F11 alterna fullscreen no Windows. No HTML5, fullscreen é oferecido
pelo botão do navegador/itch.io; a opção explica essa limitação. Persistência do navegador
depende de storage disponível e pode ser apagada pelo usuário/modo privado.

## Progresso

`coffin_bound_save.ini`: versão 1, índice da fase, checkpoint 0–3, conclusão e mortes.
Não são carregadas posições arbitrárias do arquivo. Saves de versão/nível inválidos são
ignorados e checkpoints são limitados ao catálogo seguro. Novo jogo substitui esse progresso
e preserva as opções. Morte e checkpoint gravam o progresso; continuar usa o último checkpoint.

Spawns: início (56,205); checkpoint 1 (790,118); 2 (1290,230); 3 (1565,342).
Os arquivos ficam no sandbox de salvamento do GameMaker, não na pasta fonte.

## Câmera, efeitos e áudio

Câmera suave com acumuladores, posição inteira e limites da room. Shake máximo usual de
1 pixel no dash/dano e 2 na morte, sem escapar da room. Partículas em arrays: até 96 no
controlador e 64 de queima no jogador, com expiração; rastros se autodestroem. Sem novas
surfaces, ds_lists ou sistemas de partículas manuais para liberar.

A direção visual usa `facing_dir`; `image_xscale` do jogador permanece 1 para impedir
que a máscara assimétrica mude ao virar. Os rastros só usam espelhamento visual.

Nove WAVs originais CC0, grupos separados e carregamento assíncrono, música com um único
handle entre rooms. Licenças, parâmetros e audição pendente em `AUDIO.md`.

## Testes manuais necessários

- Abrir/fechar jogo; novo, continuar, opções, créditos e sair pelo menu.
- Atingir cada checkpoint, fechar o jogo e continuar. Morrer por cada fonte de dano.
- Confirmar game over com Enter/A, R e voltar com Esc/B. Nenhum comando deve saltar ao renascer.
- Pausar em salto, dash, morcego e diálogo; retomar por todos os botões e confirmar que a
  física e o pulo já segurado continuam corretamente. Repetir o ciclo menu/fase dez vezes.
- Remapear sete ações; cancelar, esperar timeout, tentar teclas duplicadas/reservadas,
  restaurar padrão e reabrir o jogo. Testar teclas e controle conectado/desconectado.
- Testar volumes 0/50/100 e gravação, três voltas da música e ausência de loops duplicados.
- Completar a travessia até o caixão e conferir créditos, save de conclusão e novo jogo.
- Testar câmera nos quatro limites, shake, partículas e desempenho por 10 minutos no profiler.

Nenhum teste de compilação, execução, audição ou travessia completa foi realizado. As
verificações automáticas atestam estrutura, arquivos e trechos matemáticos, não o runner.
