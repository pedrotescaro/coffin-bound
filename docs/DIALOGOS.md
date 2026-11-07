# Fase 7 — diálogos góticos e retrato do vampiro

## O que mudou

A caixa de diálogo agora tem cantos recortados, moldura dupla em pedra, filetes dourados,
joias de rubi, painel do retrato com arco e divisória vertical. O nome do falante tem uma
placa própria; texto em cor de osso, separadores e indicação **REVELAR TEXTO / CONTINUAR**
com **ENTER / A** organizam a leitura.

O novo retrato original do vampiro foi desenhado e exportado no **LibreSprite**, em batch:
cabelo azul-prateado, pele pálida com sombras em clusters, olhos avermelhados, orelhas
pontudas, presas, gola alta vermelha, casaco ornamentado e broche facetado. Não utiliza
fotografia, retrato externo nem pixels reaproveitados de outra arte.

Resolução do retrato: **88×96**, origem superior esquerda (0,0), alpha 0/255, **19 cores**
da paleta Coffin Gothic 24. Ele aparece em escala 1 na GUI lógica de 480×270. A prévia
ampliada usa nearest 3×; não há antialiasing nem escala fracionária na arte.

## Integração

- Recurso novo: `spr_portrait_vampire`; seus PNGs composite/layer correspondem à exportação.
- Renderização reutilizável: `scripts/cb_dialogue/cb_dialogue.gml`.
- `obj_level_controller/Draw_64.gml` chama a renderização somente durante diálogo.
- `Create_0.gml` mantém nome do falante, cores, wrap de 306 pixels e passo de linha de 20 pixels.
- As quatro falas existentes têm duas linhas; a maior linha ocupa 270 dos 306 pixels disponíveis.
- Tipografia, retrato e ornamentos respeitam os limites da caixa (16,140)–(463,257).
- A revelação do texto, Enter/A, pausa, morte, checkpoints e conteúdo das falas foram preservados.
- Nenhum asset anterior foi apagado ou renomeado. A versão do pacote passou a **0.1.1**.

O retrato permanece o do protagonista quando o texto vem do Eco da Cripta; o nome e a cor
do falante diferenciam a voz. Não foi inventado outro personagem ou outra sequência de diálogo.

## Editar e exportar no LibreSprite

Fonte editável: [vampire_portrait.aseprite](../assets/dialogue/vampire_portrait.aseprite).
Exportação: [vampire_portrait.png](../assets/dialogue/vampire_portrait.png).

Para reproduzir o desenho procedural original e atualizar o recurso GameMaker:

```powershell
./tools/arte/gerar_retrato.ps1 -LibreSprite 'CAMINHO/libresprite.exe'
```

O script executa `gerar_retrato.js` no LibreSprite, grava a fonte e os PNGs e sincroniza os
IDs do frame/layer já registrados. A configuração temporária do editor fica isolada em
`tools/arte/.work/`, fora do Git. Python/Pillow foram usados apenas para leitura e validação.

O gerador **redesenha** a fonte: depois de fazer mudanças manuais no `.aseprite`, use a
exportação do próprio LibreSprite em vez de executar o gerador novamente sobre sua edição.
Copie o PNG resultante para o composite/layer indicados no `.yy`, preservando os IDs.

## Verificações e limites

Verificados: dimensões/alpha/paleta, ampliação nearest, fonte ASEprite, correspondência dos
PNGs do GameMaker e geometria/tamanho das quatro falas. Compilação Windows VM e empacotamento
por Igor 2026.0.0.23. As prévias de arte/interface são estáticas, não capturas de gameplay.

Pacote local: `.build/windows/package/CoffinBound-windows-0.1.1.zip`.
[Manifesto do pacote](qa/windows-0.1.1-package.json): nove arquivos esperados, CRCs e hashes
verificados. O verificador rejeitou o pacote intermediário com resíduo e aprovou a geração isolada.

O usuário aprovou a rodada básica da versão 0.1.0, registrada em [QA Windows](QA_WINDOWS.md).
Essa aprovação **não** foi transferida para a nova interface 0.1.1 sem testá-la no runner.

No novo pacote, conferir exatamente:

1. **Novo jogo:** após a introdução, o retrato deve aparecer inteiro, com arco e moldura.
2. **Texto:** as duas linhas devem caber, sem encostar no retrato, na placa do nome ou no rodapé.
3. **Enter:** primeiro revela o restante do texto; depois fecha o diálogo sem disparar pulo.
4. **Eco da Cripta:** confirmar nome/cor corretos e ausência de corte na fala mais longa.
5. **Pausa/retomada e R:** não devem deixar a caixa presa nem provocar ações involuntárias.
6. **Fullscreen:** conferir alinhamento e legibilidade em escala inteira; comparar filtro G ligado/desligado.

O percurso completo, controle, audição, performance, capturas reais e HTML5 continuam no
[checklist de QA](QA.md). O retrato é arte nova do projeto; os avisos de terceiros e a
pendência de procedência das artes antigas continuam separados em [Licenças](LICENCAS.md).
