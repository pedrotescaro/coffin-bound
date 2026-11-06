# Preview do vampiro

`vampiro.gif` é uma prévia do **asset de caminhada**, não uma captura de gameplay nem comprovação de execução do jogo.

- Quatro frames originais de `spr_vampire_walk`, com a paleta Coffin Gothic.
- Canvas de 256×256, ampliado 8× por nearest no LibreSprite; fundo transparente.
- Ciclo infinito de 400 ms, com 100 ms por frame (10 fps), timing nativo de importação do LibreSprite. O asset do jogo permanece a 8 fps (125 ms); esta prévia usa 10 fps e não altera o jogo.
- Nenhum frame ou metadado do asset do GameMaker foi alterado para criar esta prévia.

Reproduzir no PowerShell:

```powershell
./tools/arte/gerar_preview.ps1 -LibreSprite "C:/caminho/libresprite.exe"
```

LibreSprite faz a importação da sequência, ampliação e exportação GIF em `--batch`. A saída GIF é usada diretamente, sem edição posterior de pixels ou metadados. Pillow foi usado apenas para conferir quantidade de frames, dimensões, duração, alpha e correspondência dos pixels com os originais.

Para a página do itch.io, substituir ou complementar esta prévia com capturas reais do menu, do salto, da transformação e dos checkpoints após testar o build. A prévia mantém as pendências de autoria/licença da arte original.
