param([Parameter(Mandatory = $true)][string]$LibreSprite)
$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$taskWork = Join-Path $PSScriptRoot '.work/dialogue'
New-Item -ItemType Directory -Force -Path $taskWork, (Join-Path $PSScriptRoot '.work/config/LibreSprite'), (Join-Path $taskRoot 'assets/dialogue') | Out-Null
$taskFont = [regex]::Replace([IO.File]::ReadAllText((Join-Path $taskRoot 'fonts/fnt_monogram/fnt_monogram.yy')), ',\s*([}\]])', '$1') | ConvertFrom-Json
$taskTile = [regex]::Replace([IO.File]::ReadAllText((Join-Path $taskRoot 'sprites/spr_tileset_grama/spr_tileset_grama.yy')), ',\s*([}\]])', '$1') | ConvertFrom-Json
$taskOutput = Join-Path $taskRoot 'assets/dialogue/dialogue_preview.png'
$taskJob = @{
    canvas = (Join-Path $taskRoot ('sprites/spr_tileset_grama/' + $taskTile.frames[0].name + '.png')).Replace('\','/')
    atlas = (Join-Path $taskRoot 'fonts/fnt_monogram/fnt_monogram.png').Replace('\','/')
    portrait = (Join-Path $taskRoot 'assets/dialogue/vampire_portrait.png').Replace('\','/')
    output = $taskOutput.Replace('\','/')
    glyphs = $taskFont.glyphs
}
$taskScript = Join-Path $taskWork 'preview.js'
$taskSource = 'var dialoguePreviewJob = ' + ($taskJob | ConvertTo-Json -Compress -Depth 20) + ';' + [Environment]::NewLine + [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'gerar_preview_dialogo.js'))
[IO.File]::WriteAllText($taskScript, $taskSource, [Text.UTF8Encoding]::new($false))
$taskPriorAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path $PSScriptRoot '.work/config'
    $taskArgs = @('--batch', '--script', ('"' + $taskScript + '"'))
    $taskProcess = Start-Process -FilePath $LibreSprite -ArgumentList $taskArgs -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput (Join-Path $taskWork 'stdout.log') -RedirectStandardError (Join-Path $taskWork 'stderr.log')
    if ($taskProcess.ExitCode -ne 0 -or !(Test-Path -LiteralPath $taskOutput)) { throw 'Falha ao produzir prévia no LibreSprite.' }
    $taskLog = [IO.File]::ReadAllText((Join-Path $taskWork 'stdout.log')) + [IO.File]::ReadAllText((Join-Path $taskWork 'stderr.log'))
    if ($taskLog -match 'Error:|terminate called') { throw $taskLog }
} finally {
    $env:APPDATA = $taskPriorAppData
}
Write-Output 'Prévia estática de interface exportada pelo LibreSprite em 480x270; não é captura de gameplay.'
