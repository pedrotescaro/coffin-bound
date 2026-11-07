# Pipeline de arte com LibreSprite

Requer Python 3 + Pillow para **ler e validar** imagens e LibreSprite com scripts JavaScript. Os pixels são escritos exclusivamente pelo LibreSprite, em modo `--batch`.

```powershell
python -m pip install Pillow
python tools/arte/processar_arte.py --libresprite "C:/caminho/libresprite.exe"
python tools/arte/processar_arte.py --libresprite "C:/caminho/libresprite.exe" --validate-only
```

Executado nesta preparação com LibreSprite 1.1-dev, instalado em Downloads. Não se inclui o executável nem suas dependências no repositório. A configuração `APPDATA` do subprocesso é isolada em `.work/config`, ignorada pelo Git; a configuração pessoal do editor não é modificada.

`processar_arte.py` lê os `.yy` sem alterar IDs, monta jobs e chama `paleta_gotica.js` dentro do LibreSprite. PNGs RGBA usam remapeamento por pixel; os quatro PNGs indexados extras do HUD recebem uma paleta por índice para preservar transparência. O lote é gravado primeiro em `.work/processed` e **todos** os resultados são validados antes de substituir os PNGs do projeto. Confira o Git antes de executar sobre uma edição de arte em andamento.

Verificações: cores pertencem à paleta, canvas correto, alpha exato (ou alpha amostrado por nearest na vela), e nenhum pixel cortado pelo deslocamento de origem. Os PNGs extras do HUD mantêm seus nomes e dimensões. Caches de tile também são remapeados e podem ser regenerados pela IDE. Spritesheet PNG e JSON são produzidos com as opções nativas `--sheet`, `--data`, `--border-padding` e `--shape-padding`.

O ajuste geométrico é idempotente: idle/walk só se deslocam quando ainda têm origem (16,25), e a vela só é reduzida quando ainda mede 26×29. Executar de novo não repete o deslocamento nem a redução. O remapeamento de uma cor já presente na paleta mantém essa cor.

A versão 1.1-dev retorna `app.activeSprite=null` no batch, por isso o script usa `app.open(caminho).sprite`. Esse comportamento é consistente com a [implementação da API de LibreSprite 1.1](https://github.com/LibreSprite/LibreSprite/blob/v1.1/src/app/script/api/app_script.cpp). A API de pixels é documentada no [código oficial de Image](https://github.com/LibreSprite/LibreSprite/blob/v1.1/src/app/script/api/image_script.cpp).

Não se alteram fontes, o sprite branco técnico do Scribble ou nomes de assets. O pipeline não compila o projeto nem confirma o resultado visual na IDE.

## Plataformas, inimigos e armadilhas (0.2.2)

```powershell
python tools/arte/polir_desafios.py --libresprite 'CAMINHO/libresprite.exe'
python tools/arte/gameboy.py
```

O LibreSprite desenha o atlas 256×160 (células de 32), espinho 16×16 e revestimento dos
sólidos das três rooms. As áreas fora dos sólidos são preservadas; a geometria não é alterada.
O wrapper atualiza os PNGs composite/layer mantendo os IDs existentes. Fontes editáveis e
prévias estáticas ficam em `assets/challenges/`. Regenerar sobrescreve edições manuais.
A máscara alfa do espinho conserva os limites anteriores (0,2)–(15,15).
Veja [a entrega e o roteiro manual](../../docs/PLATAFORMAS_INIMIGOS.md).
