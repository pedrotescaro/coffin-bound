param([Parameter(Mandatory = $true)][string]$LibreSprite)
$ErrorActionPreference = 'Stop'
$portraitRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$portraitWork = Join-Path $PSScriptRoot '.work/portrait'
$portraitOutput = Join-Path $portraitRoot 'assets/dialogue'
$portraitConfig = Join-Path $PSScriptRoot '.work/config'
New-Item -ItemType Directory -Force -Path $portraitWork, $portraitOutput, (Join-Path $portraitConfig 'LibreSprite') | Out-Null
$portraitPriorAppData = $env:APPDATA
try {
    $env:APPDATA = $portraitConfig
    $portraitScript = Join-Path $PSScriptRoot 'gerar_retrato.js'
    $portraitArguments = @('--batch', '--script', ('"' + $portraitScript + '"'))
    $portraitProcess = Start-Process -FilePath $LibreSprite -ArgumentList $portraitArguments -WorkingDirectory $portraitRoot -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $portraitWork 'stdout.log') -RedirectStandardError (Join-Path $portraitWork 'stderr.log')
    $portraitLog = (Get-Content -LiteralPath (Join-Path $portraitWork 'stdout.log') -Raw) + (Get-Content -LiteralPath (Join-Path $portraitWork 'stderr.log') -Raw)
    if ($portraitProcess.ExitCode -ne 0 -or $portraitLog -match 'Error:|terminate called') { throw "Falha LibreSprite: $portraitLog" }
    foreach ($portraitName in @('vampire_portrait.png', 'vampire_portrait.aseprite')) {
        if (!(Test-Path -LiteralPath (Join-Path $portraitOutput $portraitName))) { throw "Saída ausente: $portraitName" }
    }
    $portraitPreviewArguments = @('--batch', ('"' + (Join-Path $portraitOutput 'vampire_portrait.png') + '"'), '--scale', '3', '--save-as', ('"' + (Join-Path $portraitOutput 'vampire_portrait_preview.png') + '"'))
    $portraitPreviewProcess = Start-Process -FilePath $LibreSprite -ArgumentList $portraitPreviewArguments -WorkingDirectory $portraitRoot -WindowStyle Hidden -Wait -PassThru
    if ($portraitPreviewProcess.ExitCode -ne 0) { throw 'Falha na prévia nearest 3x.' }
    $portraitFaceCrop = Join-Path $portraitWork 'face-crop.png'
    # LibreSprite aplica escala antes de crop em um mesmo comando; separar as etapas.
    $portraitFaceArguments = @('--batch', ('"' + (Join-Path $portraitOutput 'vampire_portrait.png') + '"'), '--crop', '17,16,54,62', '--save-as', ('"' + $portraitFaceCrop + '"'))
    $portraitFaceProcess = Start-Process -FilePath $LibreSprite -ArgumentList $portraitFaceArguments -WorkingDirectory $portraitRoot -WindowStyle Hidden -Wait -PassThru
    if ($portraitFaceProcess.ExitCode -ne 0) { throw 'Falha no recorte de prévia do rosto.' }
    $portraitFacePreviewArguments = @('--batch', ('"' + $portraitFaceCrop + '"'), '--scale', '4', '--save-as', ('"' + (Join-Path $portraitOutput 'vampire_face_preview.png') + '"'))
    $portraitFacePreviewProcess = Start-Process -FilePath $LibreSprite -ArgumentList $portraitFacePreviewArguments -WorkingDirectory $portraitRoot -WindowStyle Hidden -Wait -PassThru
    if ($portraitFacePreviewProcess.ExitCode -ne 0) { throw 'Falha na prévia do rosto nearest 4x.' }
    $portraitSource = Join-Path $portraitOutput 'vampire_portrait.png'
    $portraitHeader = [IO.File]::ReadAllBytes($portraitSource)
    # PNG usa inteiros big-endian no IHDR. Somente leitura; pixels são do LibreSprite.
    $portraitWidth = ($portraitHeader[16] -shl 24) -bor ($portraitHeader[17] -shl 16) -bor ($portraitHeader[18] -shl 8) -bor $portraitHeader[19]
    $portraitHeight = ($portraitHeader[20] -shl 24) -bor ($portraitHeader[21] -shl 16) -bor ($portraitHeader[22] -shl 8) -bor $portraitHeader[23]
    if ($portraitWidth -ne 88 -or $portraitHeight -ne 96) { throw 'O retrato exportado deve medir 88x96.' }
    $portraitMetadata = Join-Path $portraitRoot 'sprites/spr_portrait_vampire/spr_portrait_vampire.yy'
    if (Test-Path -LiteralPath $portraitMetadata) {
        $portraitData = [regex]::Replace([IO.File]::ReadAllText($portraitMetadata), ',\s*([}\]])', '$1') | ConvertFrom-Json
        if ($portraitData.width -ne 88 -or $portraitData.height -ne 96 -or $portraitData.frames.Count -ne 1 -or $portraitData.layers.Count -ne 1) {
            throw 'O asset spr_portrait_vampire esperado tem canvas 88x96, um frame e um layer.'
        }
        $portraitSpriteDirectory = Split-Path $portraitMetadata
        $portraitFrame = $portraitData.frames[0].name
        $portraitLayer = $portraitData.layers[0].name
        $portraitLayerDirectory = Join-Path $portraitSpriteDirectory ('layers/' + $portraitFrame)
        New-Item -ItemType Directory -Path $portraitLayerDirectory -Force | Out-Null
        Copy-Item -LiteralPath $portraitSource -Destination (Join-Path $portraitSpriteDirectory ($portraitFrame + '.png'))
        Copy-Item -LiteralPath $portraitSource -Destination (Join-Path $portraitLayerDirectory ($portraitLayer + '.png'))
        Write-Output 'Composite e layer do spr_portrait_vampire sincronizados, mantendo IDs e metadados.'
    }
} finally {
    $env:APPDATA = $portraitPriorAppData
}
Write-Output 'Retrato 88x96 e fonte ASEprite gerados no LibreSprite; prévia nearest 3x: 264x288; rosto nearest 4x: 216x248.'
