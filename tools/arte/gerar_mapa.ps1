param([Parameter(Mandatory = $true)][string]$LibreSprite)
$ErrorActionPreference = 'Stop'
$mapRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$mapWork = Join-Path $PSScriptRoot '.work/mapa'
$mapConfig = Join-Path $PSScriptRoot '.work/config'
New-Item -ItemType Directory -Force -Path $mapWork, (Join-Path $mapConfig 'LibreSprite') | Out-Null
& python (Join-Path $PSScriptRoot 'gerar_mapa.py')
if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar os dados da fase.' }
$mapOldAppData = $env:APPDATA
try {
    $env:APPDATA = $mapConfig
    $mapCanvasSource = Join-Path $mapRoot 'sprites/s_background/f03ddb17-a0c4-4c9d-a5d9-477a8f246711.png'
    $mapCanvas = Join-Path $mapWork 'canvas.png'
    $mapArguments = @('--batch', ('"' + $mapCanvasSource + '"'), '--scale', '6', '--save-as', ('"' + $mapCanvas + '"'))
    $mapProcess = Start-Process -FilePath $LibreSprite -ArgumentList $mapArguments -WorkingDirectory $mapRoot -WindowStyle Hidden -Wait -PassThru
    if ($mapProcess.ExitCode -ne 0) { throw 'Falha criando canvas temporário.' }
    $mapArguments = @('--batch', '--script', ('"' + (Join-Path $mapWork 'gerar.js') + '"'))
    $mapProcess = Start-Process -FilePath $LibreSprite -ArgumentList $mapArguments -WorkingDirectory $mapRoot -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $mapWork 'stdout.log') -RedirectStandardError (Join-Path $mapWork 'stderr.log')
    $mapLog = (Get-Content -LiteralPath (Join-Path $mapWork 'stdout.log') -Raw) + (Get-Content -LiteralPath (Join-Path $mapWork 'stderr.log') -Raw)
    if ($mapProcess.ExitCode -ne 0 -or $mapLog -match 'Error:|terminate called') { throw "Falha no LibreSprite: $mapLog" }
    foreach ($mapFile in @('crypt_map.png', 'crypt_map.aseprite', 'crypt_map_overview.png', 'crypt_map_entrance.png', 'crypt_map_nave.png', 'crypt_map_crypt.png')) {
        if (!(Test-Path -LiteralPath (Join-Path $mapRoot ('assets/environment/' + $mapFile)))) { throw "Saída ausente: $mapFile" }
    }
    # Atualiza somente os PNGs do recurso já registrado; preserva nomes e IDs do GameMaker.
    $mapMetadataPath = Join-Path $mapRoot 'sprites/spr_crypt_map/spr_crypt_map.yy'
    if (Test-Path -LiteralPath $mapMetadataPath) {
        $mapMetadata = [regex]::Replace((Get-Content -LiteralPath $mapMetadataPath -Raw), ',\s*([}\]])', '$1') | ConvertFrom-Json
        if ($mapMetadata.width -ne 1920 -or $mapMetadata.height -ne 540 -or $mapMetadata.frames.Count -ne 1 -or $mapMetadata.layers.Count -ne 1) {
            throw 'O recurso spr_crypt_map precisa manter canvas1920x540, um frame e um layer.'
        }
        $mapSpriteDirectory = Split-Path -Parent $mapMetadataPath
        $mapFrame = $mapMetadata.frames[0].name
        $mapLayer = $mapMetadata.layers[0].name
        $mapLayerDirectory = Join-Path $mapSpriteDirectory ('layers/' + $mapFrame)
        New-Item -ItemType Directory -Force -Path $mapLayerDirectory | Out-Null
        $mapPNG = Join-Path $mapRoot 'assets/environment/crypt_map.png'
        Copy-Item -LiteralPath $mapPNG -Destination (Join-Path $mapSpriteDirectory ($mapFrame + '.png'))
        Copy-Item -LiteralPath $mapPNG -Destination (Join-Path $mapLayerDirectory ($mapLayer + '.png'))
    }
} finally {
    $env:APPDATA = $mapOldAppData
}
Write-Output 'Mapa 1920x540, fonte ASEprite e prévias estáticas exportados pelo LibreSprite.'
