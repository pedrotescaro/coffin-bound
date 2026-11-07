# Resultado de compilação — 06/11/2026

## Windows VM

Compilação via Igor **2026.0.0.23**, runtime LTS da instalação local, concluída com código
de saída 0 e `Igor complete.`. GML, rooms, objetos e shaders foram compilados. Nenhuma
IDE ou janela do jogo foi aberta. Isso valida o compilador, não a execução do runner.

O compilador encontrou incompatibilidade no primeiro formato dos novos sons. Os metadados
foram corrigidos para GMSound v2 do runtime 2026: `channelFormat`, `compressionQuality`
e `exportDir`; campos antigos `bitRate` e `type` foram removidos. O gerador reproduz o
mesmo formato. Nenhum arquivo WAV foi alterado por essa correção.

As saídas e os logs locais ficam em `.build/`, fora do Git. Não foram publicados como
release jogável sem QA. Para compilar novamente, com seus caminhos locais:

```powershell
./tools/build.ps1 -RuntimePath 'CAMINHO_DO_RUNTIME' -UserPath 'PASTA_DO_USUARIO_GAMEMAKER' -Target Windows
```

Use a pasta de usuário da instalação autenticada do GameMaker; não coloque arquivos de
licença, tokens ou configurações pessoais no repositório. Esse script somente compila.
Para pacote executável completo, use Create Executable/ZIP na IDE ou a opção `-Package`:

```powershell
./tools/build.ps1 -RuntimePath 'CAMINHO_DO_RUNTIME' -UserPath 'PASTA_DO_USUARIO_GAMEMAKER' -Target Windows -Package
python tools/check_package.py '.build/windows/package/CoffinBound-windows-0.1.0.zip'
```

O comando PackageZip foi executado na fase 6. O pacote completo, seu manifesto e os limites
da validação inicial estão em [QA Windows](QA_WINDOWS.md). Isso não aprova o percurso completo.

## HTML5

A tentativa gerou código JavaScript, texturas e conversões de áudio, mas o empacotamento
falhou porque o runtime local não contém `html5/scripts.html5.zip`.
Isso é uma dependência de exportação ausente, não uma aprovação de compatibilidade HTML5.
Instale o módulo HTML5 compatível na IDE, compile novamente e teste navegador, input,
storage, fullscreen, shaders e áudio antes de publicar esse alvo.

```powershell
./tools/build.ps1 -RuntimePath 'CAMINHO_DO_RUNTIME_COM_HTML5' -UserPath 'PASTA_DO_USUARIO_GAMEMAKER' -Target HTML5
```

## Verificações que não iniciam o runner

```powershell
python tools/validate_project.py --strict-warnings
node --preserve-symlinks-main tools/check_movement.cjs
node --preserve-symlinks-main tools/check_services.cjs
python tools/generate_audio.py --check
```

Resultados desta preparação: 0 erros/0 avisos estruturais, 13 verificações de movimento/input
e 13 de serviços/menus aprovadas; áudio determinístico sem clipping. O checklist de execução
continua em `QA.md`. O workflow GitHub repete essas verificações; não instala o GameMaker.
