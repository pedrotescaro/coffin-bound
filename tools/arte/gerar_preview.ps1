param([Parameter(Mandatory = $true)][string]$LibreSprite)
$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$taskWork = Join-Path $PSScriptRoot '.work/preview'
$taskOutput = Join-Path $taskRoot 'assets/preview/vampiro.gif'
$taskMetadata = Join-Path $taskRoot 'sprites/spr_vampire_walk/spr_vampire_walk.yy'
$taskData = [regex]::Replace([IO.File]::ReadAllText($taskMetadata), ',\s*([}\]])', '$1') | ConvertFrom-Json
New-Item -ItemType Directory -Path $taskWork, (Split-Path $taskOutput), (Join-Path $PSScriptRoot '.work/config/LibreSprite') -Force | Out-Null
for ($taskIndex = 0; $taskIndex -lt $taskData.frames.Count; $taskIndex++) {
    $taskFrame = Join-Path (Split-Path $taskMetadata) ($taskData.frames[$taskIndex].name + '.png')
    Copy-Item -LiteralPath $taskFrame -Destination (Join-Path $taskWork ('frame{0:d3}.png' -f $taskIndex))
}
$taskPriorAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path $PSScriptRoot '.work/config'
    # LibreSprite importa os quatro PNGs numerados como frames e amplia nearest.
    $taskArgs = @('--batch', ('"' + (Join-Path $taskWork 'frame000.png') + '"'), '--scale', '8', '--save-as', ('"' + $taskOutput + '"'))
    $taskProcess = Start-Process -FilePath $LibreSprite -ArgumentList $taskArgs -WindowStyle Hidden -Wait -PassThru
    if ($taskProcess.ExitCode -ne 0 -or !(Test-Path -LiteralPath $taskOutput)) { throw 'Falha ao exportar GIF no LibreSprite.' }
} finally {
    $env:APPDATA = $taskPriorAppData
}
Write-Output 'Preview exportado pelo LibreSprite: 256x256, 4 frames, 100 ms por frame, loop infinito.'
