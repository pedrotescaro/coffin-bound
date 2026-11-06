param(
    [Parameter(Mandatory = $true)][string]$RuntimePath,
    [Parameter(Mandatory = $true)][string]$UserPath,
    [ValidateSet('Windows', 'HTML5')][string]$Target = 'Windows'
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$IgorPath = Join-Path $RuntimePath 'bin/igor/windows/x64/Igor.exe'
if (!(Test-Path -LiteralPath $IgorPath)) { throw "Igor não encontrado: $IgorPath" }
$BuildRoot = Join-Path $ProjectRoot ('.build/' + $Target.ToLowerInvariant())
foreach ($Part in @('cache', 'temp', 'out')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $BuildRoot $Part) | Out-Null
}
$OutputName = if ($Target -eq 'HTML5') { 'index.html' } else { 'CoffinBound.win' }
$Arguments = @(
    "--project=$(Join-Path $ProjectRoot 'Coffin Bound final.yyp')",
    "--runtimePath=$RuntimePath", '--runtime=VM', '--config=Default',
    "--cache=$(Join-Path $BuildRoot 'cache')",
    "--temp=$(Join-Path $BuildRoot 'temp')", "--user=$UserPath",
    "--of=$(Join-Path $BuildRoot ('out/' + $OutputName))",
    $Target.ToLowerInvariant(), 'Compile'
)
& $IgorPath @Arguments 2>&1 | Tee-Object -FilePath (Join-Path $BuildRoot 'compile.log')
exit $LASTEXITCODE
