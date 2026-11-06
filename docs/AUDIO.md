# Áudio original do Coffin Bound

Autor/crédito: **Pedro Tescaro**. Todos os WAVs `sounds/snd_cb_*/*.wav` foram criados nesta preparação por síntese matemática determinística, sem samples, gravações, soundfonts ou músicas externas. Os arquivos WAV são dedicados a **CC0 1.0 Universal**. O gerador `tools/generate_audio.py` é código do projeto, sob **GPL-3.0-only**. Essa separação permite reutilizar os sons sem impor a licença do gerador aos WAVs.

Referência da dedicação: [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/). Os avisos gerais de terceiros do projeto continuam aplicáveis às bibliotecas e fontes existentes.

## Arquivos e grupos

| Recurso | Uso | Duração aproximada | Grupo | Licença do WAV |
| --- | --- | --- | --- | --- |
| `snd_cb_jump` | Pulo | 0,14 s | `audiogroup_sfx` | CC0-1.0 |
| `snd_cb_dash` | Dash | 0,18 s | `audiogroup_sfx` | CC0-1.0 |
| `snd_cb_bat` | Transformação em morcego | 0,26 s | `audiogroup_sfx` | CC0-1.0 |
| `snd_cb_hurt` | Recebimento de dano | 0,22 s | `audiogroup_sfx` | CC0-1.0 |
| `snd_cb_death` | Morte | 0,70 s | `audiogroup_sfx` | CC0-1.0 |
| `snd_cb_checkpoint` | Checkpoint | 0,56 s | `audiogroup_sfx` | CC0-1.0 |
| `snd_cb_win` | Vitória | 1,30 s | `audiogroup_sfx` | CC0-1.0 |
| `snd_cb_ui` | Interface | 0,09 s | `audiogroup_sfx` | CC0-1.0 |
| `snd_cb_music` | Loop da cripta | 21,333 s | `audiogroup_music` | CC0-1.0 |

Formato: WAV PCM de 16 bits, mono, 22.050 Hz. SFX têm pico limitado a aproximadamente 0,50 da escala digital; música, 0,34. Todos os recursos `.yy` usam volume 1,0. A mixagem fica centralizada em `cb_services`: volume mestre padrão 0,80, grupo de efeitos 0,70 e grupo de música 0,45, ajustáveis nas opções do jogo. Isso evita aplicar a mesma atenuação no recurso e no grupo. O equilíbrio final precisa ser ouvido com o jogo em execução.

O loop tem oito compassos em 90 BPM, harmonia em ré menor, drone grave e sino discreto. Notas com cauda atravessando o fim são somadas circularmente ao início. O drone usa um número inteiro de ciclos durante o loop, evitando reinício de fase na emenda.

## Reprodução e regeneração

Na raiz do projeto:

```powershell
python tools/generate_audio.py
python tools/generate_audio.py --check
```

O primeiro comando grava os WAVs, seus metadados `.yy` e `assets/audio_manifest.json`. Não modifica o `.yyp`, os objetos ou os eventos. O segundo compara os arquivos existentes com uma nova geração em memória, sem escrever no projeto. Ambos geram os resultados duas vezes para detectar fontes acidentais de não determinismo.

O manifesto registra SHA-256, duração, formato PCM, pico, RMS, quantidade de amostras saturadas e diferença entre a última e a primeira amostra. A validação acusa clipping e rejeita uma diferença de borda do loop maior que 160 unidades PCM16 (cerca de 0,005 da escala). Ela verifica a integridade dos arquivos; não substitui audição nem comprova a qualidade musical.

Não aplicar fades globais ao loop depois de exportá-lo sem conferir a emenda novamente. Ajuste de volume deve ocorrer no mixer/grupo ou na instância de reprodução. Reproduzir música usando um único identificador de áudio e pará-la ao sair do contexto evita loops acumulados a cada retorno ao menu/room.

## QA manual pendente

- Ouvir os nove WAVs e conferir ausência de estalos, distorção ou frequência desagradável.
- Deixar `snd_cb_music` tocar por pelo menos três voltas, com atenção à emenda a cada 21,333 s.
- Testar pulo, dash, transformação, dano contínuo, morte, checkpoint, vitória e navegação; conferir sincronismo e evitar repetição excessiva do som de dano.
- Conferir volume mestre, efeitos e música em 0%, 50% e 100%; salvar opções e reabrir o jogo.
- Entrar e sair de pausa/menu/fase repetidamente; verificar que a música não se duplica.
- Testar com fones e alto-falantes pequenos, mantendo os efeitos legíveis sobre a música.
- Repetir no Windows exportado e, se aprovado para publicação, no HTML5 após interação inicial do usuário, conferindo as restrições de autoplay do navegador.

Nenhum teste de audição ou reprodução no GameMaker foi realizado pelo gerador.
