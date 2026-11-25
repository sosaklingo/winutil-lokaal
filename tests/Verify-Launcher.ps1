$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$exe = Join-Path $PSHOME 'powershell.exe'
$launcher = Join-Path $root 'WinUtil-Lokaal.ps1'
$release = 'winutil-26.10.28.ps1'
function Assert-Exit([string]$path, [string]$language, [int]$expected) {
    $p = Start-Process -FilePath $exe -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"{0}"' -f $path),'-Mode','Verify','-Language',$language) -NoNewWindow -Wait -PassThru
    if ($p.ExitCode -ne $expected) {
        throw "Expected exit $expected; got $($p.ExitCode): $path ($language)"
    }
}
# Check the embedded elevated bootstrap's PowerShell syntax without executing it.
$source = [IO.File]::ReadAllText($launcher)
$match = [regex]::Match($source, "(?ms)^\s*[$]bootstrap = @'\r?\n(.*?)\r?\n'@")
if (-not $match.Success) { throw 'Embedded bootstrap not found.' }
$tokens = $null
$errors = $null
[void][Management.Automation.Language.Parser]::ParseInput($match.Groups[1].Value, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors.Message -join '; ') }
Assert-Exit $launcher 'NL' 0
Assert-Exit $launcher 'EN' 0
$testDir = Join-Path ([IO.Path]::GetTempPath()) ('WinUtil test ' + [Guid]::NewGuid().ToString('N'))
try {
    [void][IO.Directory]::CreateDirectory($testDir)
    Copy-Item -LiteralPath $launcher -Destination $testDir
    $testLauncher = Join-Path $testDir 'WinUtil-Lokaal.ps1'
    Assert-Exit $testLauncher 'EN' 1
    Copy-Item -LiteralPath (Join-Path $root $release) -Destination $testDir
    Assert-Exit $testLauncher 'EN' 0
    [IO.File]::AppendAllText((Join-Path $testDir $release), "# tampered")
    Assert-Exit $testLauncher 'NL' 1
} finally {
    if (Test-Path -LiteralPath $testDir) { Remove-Item -LiteralPath $testDir -Recurse -Force }
}
Write-Host 'Launcher verification, language, missing-file, tamper and bootstrap syntax checks passed.'
