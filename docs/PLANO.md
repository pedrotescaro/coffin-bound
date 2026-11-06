# Preparação do Coffin Bound para publicação

## Segurança e escopo

Backup integral rastreado no commit `dd2bf04`, branch `backup/antes-preparacao-publicacao`.
Nenhum asset existente será apagado ou renomeado. O arquivo `.yyz` é a exportação original,
não o pacote atualizado. A publicação remota não será feita sem destino informado.

## Fases

1. **Diagnóstico:** inventário, revisão de código, rooms, sprites, texturas, áudio e licenças.
2. **Código:** colisão com resíduos subpixel, estados explícitos, saltos, dash, morcego e resets.
3. **Arte:** paleta gótica única, exportação por LibreSprite, origens/timing e renderização inteira.
4. **Polimento:** menus, pausa, morte/créditos, checkpoint/save, câmera/efeitos, opções e áudio.
5. **Publicação:** README PT/EN, licenças, changelog, guia itch.io/builds e checklist de QA.

Cada fase terá um commit em português e uma entrega em `docs/ENTREGAS.md` com mudanças,
arquivos, testes manuais e pendências. Alterações de fases seguintes só começam após o commit
da fase anterior. O Git foi inicializado neste trabalho porque a pasta recebida não tinha repositório.

## Limite das verificações

Análise estática, integridade de referências e processamento de arquivos podem ser verificados
aqui. Compilação, sensação dos controles, animações, enquadramento, áudio e exportação exigem
o GameMaker/runner compatível e teste manual. Nenhuma dessas etapas será descrita como aprovada
sem evidência de execução. Runtimes locais mais antigos que a IDE declarada não comprovam
compatibilidade com o projeto.
