# Diagnóstico de código — Fase 1

Revisão em 06/11/2026. Estado original preservado no commit `dd2bf04` e na branch `backup/antes-preparacao-publicacao`.

## Método e limites

Leitura dos eventos e scripts próprios do jogador, menu, pausa, controlador de fase, câmera, vela, luz, filtro e rastros. Inspeção da configuração de Input e dos caminhos de alocação/coleta das bibliotecas Input e Scribble. A revisão das bibliotecas não equivale a leitura manual integral de cada implementação nem a profiling. Não houve compilação com Igor, execução na IDE ou validação visual.

As linhas abaixo referem-se ao projeto original. Alterações posteriores podem deslocá-las.

## Bugs e física

| Gravidade | Arquivo e linha | Achado e correção proposta |
|---|---|---|
| Alta | `scripts/player_collision/player_collision.gml:7,20` | O trajeto só é percorrido se o destino final colidir. Deslocamentos grandes podem atravessar obstáculos finos. Percorrer cada pixel sempre. |
| Alta | `scripts/player_collision/player_collision.gml:4–5` | `round(hsp/vsp)` descarta resíduos a cada frame. Movimento lento e gravidade perdem deslocamento. Acumular resíduos subpixel e aplicar deslocamento inteiro. |
| Alta | `scripts/player_transitions/player_transitions.gml:39` | `image_xscale = _h_input` transforma intensidade do analógico em escala da máscara. Usar o sinal para orientação. |
| Alta | `objects/obj_pause/obj_pause.yy` e `rooms/rm_level1/rm_level1.yy:114` | Pausa persistente e outra instância criada por entrada/reinício acumulam controladores. Usar singleton ou instância não persistente. |
| Alta | `scripts/player_health/player_health.gml:31` | Morte por luz reinicia a room e ignora checkpoints. Centralizar morte e respawn. |
| Média | `scripts/player_states/player_states.gml:41–44` | Dash recém-iniciado pode ser sobrescrito por wall slide no mesmo frame. Retornar após a transição. |
| Média | `scripts/player_states/player_states.gml:79–91` | Wall jump é avaliado antes de validar contato; `on_wall=0` permite impulso sem parede e zera orientação. Validar contato primeiro. |
| Média | `objects/obj_level_controller/Create_0.gml:52` | Respawn parcial deixa vitória, timers, buffers, efeitos e deformações anteriores. Centralizar reset completo. |
| Média | `scripts/player_health/player_health.gml:5–15` | Só examina a fonte mais próxima: vela apagada pode esconder outra ativa, e raio maior de outra luz é ignorado. Examinar fontes elegíveis. |
| Média | `scripts/player_health/player_health.gml` e `scripts/player_post_step/player_post_step.gml` | Dano continua durante WIN e pode interromper vitória. Bloquear dano e interações nos estados finais. |
| Média | `scripts/player_resources/player_resources.gml:11–12` | Buffer recém-criado é decrementado imediatamente. Corrigir ordem para duração configurada. |
| Média | `scripts/player_states/player_states.gml:36` | `y -= 1` no salto altera posição fora do resolvedor e pode penetrar teto. Remover deslocamento especial. |
| Média | `scripts/player_states/player_states.gml:111–118` | Push-out arbitrário de até 64 pixels pode terminar dentro da geometria. A máscara constante dispensa esse caminho normal; recuperação precisa de posição segura. |
| Média | `scripts/player_states/player_states.gml:127` | Vitória apenas reinicia a mesma fase após dois segundos; falta conclusão/créditos. |

## Eventos, organização e nomes

- `objects/obj_player/Draw_64.gml:20–22`: consulta teclado e muda `show_debug` em Draw; mover para Step.
- `objects/obj_pause/Step_0.gml:9–10`: `_key_up` lê baixo e `_key_down` lê cima. A aritmética compensa, mas nomes induzem erro.
- `scripts/menu_data/menu_data.gml`, `scripts/menu_actions/menu_actions.gml` e `objects/obj_gameboy/Create_0.gml`: preferências locais se perdem; filtro nasce ligado independentemente da escolha.
- `objects/obj_light/Draw_0.gml`: restaura alpha, mas deixa cor de desenho alterada.
- Jogador já possui scripts por responsabilidade, coyote time, buffer e altura variável. O enum usa NORMAL para andar/pular/cair e não tem estados explícitos de dano e morte.
- Duplicação: morte em HP, espinhos e queda; resets parciais; cores e resolução GUI 480×270 repetidas; menu e pausa usam fluxos distintos de input/navegação.
- `hsp`, `vsp`, `grv`, `selectLerp`, `cursorLevitate` misturam abreviações e convenções; preservar compatibilidade e comentar unidades ao refatorar, evitando renomeações em massa sem necessidade.

## Memória

Não há alocação manual de surface, DS ou sistema de partículas no código próprio revisado. Partículas são arrays limitados por vida ou quantidade; rastros se autodestroem. Isso não substitui medição de memória durante execução.

Input e Scribble mantêm caches globais intencionais. Scribble tem coleta de grids e vertex buffers em `scripts/__scribble_tick/__scribble_tick.gml` e descarte em `scripts/scribble_flush_everything/scribble_flush_everything.gml`; não destruir esses recursos enquanto a biblioteca está ativa.

Vazamento latente verificável: `scripts/__scribble_class_font/__scribble_class_font.gml:30` cria `__kerning_map`, porém `__destroy()` na linha 168 destrói apenas mapa de glifos e grid, omitindo o mapa de kerning. O jogo atual não chama `scribble_font_delete`, então não há evidência de crescimento por esse caminho durante a partida. Acrescentar descarte correspondente.

Não foi identificado erro conclusivo de compilação por inspeção. Enums e ações de Input utilizados estão definidos. A confirmação exige compilação na versão compatível do GameMaker.

## Conferir manualmente

1. Movimento lento por teclado e analógico, gravidade e inversão de direção.
2. Coyote time, buffer ao aterrissar, pulo curto/longo e salto sob teto.
3. Wall slide/jump em bordas; dash contra paredes e obstáculos finos.
4. Morcego com analógico parcialmente inclinado e retorno ao pousar.
5. Morte por luz, vela, espinhos e queda; reset completo em cada checkpoint.
6. Repetir menu → fase → reiniciar → menu para detectar duplicação da pausa.
7. Vitória sob luz; pausa por teclado/controle; foco da janela.
8. Perfil de instâncias, memória e frame time por pelo menos 15 minutos e várias reinicializações.
