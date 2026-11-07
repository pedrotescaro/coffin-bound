param([Parameter(Mandatory = $true)][string]$LibreSprite)
$ErrorActionPreference = 'Stop'
$environmentRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$environmentWork = Join-Path $PSScriptRoot '.work/environment'
$environmentOutput = Join-Path $environmentRoot 'assets/environment'
$environmentConfig = Join-Path $PSScriptRoot '.work/config'
New-Item -ItemType Directory -Force -Path $environmentWork, $environmentOutput, (Join-Path $environmentConfig 'LibreSprite') | Out-Null
$environmentPriorAppData = $env:APPDATA
try {
    $env:APPDATA = $environmentConfig
    $environmentScript = Join-Path $PSScriptRoot 'gerar_cenario.js'
    $environmentArguments = @('--batch', '--script', ('"' + $environmentScript + '"'))
    $environmentProcess = Start-Process -FilePath $LibreSprite -ArgumentList $environmentArguments -WorkingDirectory $environmentRoot -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $environmentWork 'stdout.log') -RedirectStandardError (Join-Path $environmentWork 'stderr.log')
    $environmentLog = (Get-Content -LiteralPath (Join-Path $environmentWork 'stdout.log') -Raw) + (Get-Content -LiteralPath (Join-Path $environmentWork 'stderr.log') -Raw)
    if ($environmentProcess.ExitCode -ne 0 -or $environmentLog -match 'Error:|terminate called') { throw "Falha LibreSprite: $environmentLog" }
    foreach ($environmentName in @('crypt_tiles', 'crypt_decor')) {
        foreach ($environmentExtension in @('.png', '.aseprite')) {
            if (!(Test-Path -LiteralPath (Join-Path $environmentOutput ($environmentName + $environmentExtension)))) { throw "Saída ausente: $environmentName$environmentExtension" }
        }
        $environmentPreviewArguments = @('--batch', ('"' + (Join-Path $environmentOutput ($environmentName + '.png')) + '"'), '--scale', '3', '--save-as', ('"' + (Join-Path $environmentOutput ($environmentName + '_preview.png')) + '"'))
        $environmentPreviewProcess = Start-Process -FilePath $LibreSprite -ArgumentList $environmentPreviewArguments -WorkingDirectory $environmentRoot -WindowStyle Hidden -Wait -PassThru
        if ($environmentPreviewProcess.ExitCode -ne 0) { throw "Falha na prévia nearest de $environmentName." }
    }
} finally {
    $env:APPDATA = $environmentPriorAppData
}
Write-Output 'Cenário exportado pelo LibreSprite: tiles128x128 e decoração256x192, fontes ASEprite e previewsnearest3x.'
