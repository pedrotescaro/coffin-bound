# Arte original da cripta

Produzida e exportada no LibreSprite com a paleta **Coffin Gothic 24**, pixels RGBA com
alpha 0/255 e sem antialiasing. PNGs são os atlas de trabalho; arquivos `.aseprite` são as
fontes editáveis, e `*_preview.png` são ampliações nearest de 3× para inspeção.

- `crypt_tiles.png`: 128×128, grade 8×8 de tiles de 16×16. Índice 0 transparente.
- `crypt_decor.png`: 256×192, grade 4×2 de módulos decorativos de 64×96.
- `crypt_atlas.json`: nomes, índices e recortes para montagem do mapa.

Os topos e os corpos jogáveis têm valores mais claros e frios. Arcos, vitrais, pilastras,
grades e elementos de fundo usam sombras escuras. Banners/rubis e musgo introduzem cores
localizadas sem substituir a leitura das plataformas. A arte não cria colisões nem perigos.

Reproduzir as fontes procedurais e exportações:

```powershell
./tools/arte/gerar_cenario.ps1 -LibreSprite 'CAMINHO/libresprite.exe'
```

O gerador redesenha os atlas; faça cópia de suas edições manuais antes de executá-lo.
Os scripts são código próprio sob GPL-3.0-only. A arte é nova do projeto Coffin Bound;
nenhuma licença adicional de reutilização foi atribuída automaticamente aos PNGs/fontes.
Nenhuma imagem ou pixel da imagem usada apenas para obter um canvas RGBA foi reaproveitado.
