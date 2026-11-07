param(
    [Parameter(Mandatory = $true)][string]$RuntimePath,
    [Parameter(Mandatory = $true)][string]$UserPath,
    [ValidateSet('Windows', 'HTML5')][string]$Target = 'Windows',
    [switch]$Package
)
$ErrorActionPreference = 'Stop'
if ($Package -and $Target -ne 'Windows') {
    throw '-Package é suportado apenas para Windows. HTML5 mantém a compilação atual.'
}
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$IgorPath = Join-Path $RuntimePath 'bin/igor/windows/x64/Igor.exe'
if (!(Test-Path -LiteralPath $IgorPath)) { throw "Igor não encontrado: $IgorPath" }
$BuildRoot = Join-Path $ProjectRoot ('.build/' + $Target.ToLowerInvariant())
foreach ($Part in @('cache', 'temp', 'out')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $BuildRoot $Part) | Out-Null
}
$OutputName = if ($Target -eq 'HTML5') { 'index.html' } else { 'CoffinBound.win' }
$BuildOutputDirectory = Join-Path $BuildRoot 'out'
$BuildCommand = 'Compile'
$LogName = 'compile.log'
$PackagePath = $null
if ($Package) {
    $OptionsPath = Join-Path $ProjectRoot 'options/windows/options_windows.yy'
    $VersionMatch = [regex]::Match((Get-Content -LiteralPath $OptionsPath -Raw),
        '"option_windows_version"\s*:\s*"(\d+\.\d+\.\d+(?:\.\d+)?)"')
    if (!$VersionMatch.Success) { throw 'Versão Windows não encontrada nos metadados do projeto.' }
    $Version = $VersionMatch.Groups[1].Value -replace '^(\d+\.\d+\.\d+)\.0$', '$1'
    $PackageDirectory = Join-Path $BuildRoot 'package'
    New-Item -ItemType Directory -Force -Path $PackageDirectory | Out-Null
    $PackagePath = Join-Path $PackageDirectory "CoffinBound-windows-$Version.zip"
    # Uma saída nova impede que manifestos de um empacotamento anterior entrem no ZIP.
    $PackageGeneration = [guid]::NewGuid().ToString('N')
    $BuildOutputDirectory = Join-Path $BuildRoot ('package-stage/' + $PackageGeneration)
    New-Item -ItemType Directory -Force -Path $BuildOutputDirectory | Out-Null
    $BuildCommand = 'PackageZip'
    $LogName = 'package.log'
}
$Arguments = @(
    "--project=$(Join-Path $ProjectRoot 'Coffin Bound final.yyp')",
    "--runtimePath=$RuntimePath", '--runtime=VM', '--config=Default',
    "--cache=$(Join-Path $BuildRoot 'cache')",
    "--temp=$(Join-Path $BuildRoot 'temp')", "--user=$UserPath",
    "--of=$(Join-Path $BuildOutputDirectory $OutputName)"
)
if ($Package) { $Arguments += "--tf=$PackagePath" }
$Arguments += @($Target.ToLowerInvariant(), $BuildCommand)
& $IgorPath @Arguments 2>&1 | Tee-Object -FilePath (Join-Path $BuildRoot $LogName)
$BuildExitCode = $LASTEXITCODE
if ($BuildExitCode -ne 0) { exit $BuildExitCode }
if ($Package) {
    if (!(Test-Path -LiteralPath $PackagePath -PathType Leaf) -or
        (Get-Item -LiteralPath $PackagePath).Length -eq 0) {
        throw "Igor terminou sem gerar o pacote esperado: $PackagePath"
    }
    Write-Output "Pacote gerado: $PackagePath"
    Write-Output "Conferir arquivos: python tools/check_package.py `"$PackagePath`""
}
exit $BuildExitCode
