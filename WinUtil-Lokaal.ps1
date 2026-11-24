param(
    [ValidateSet('Verify', 'Start', 'Offline')]
    [string]$Mode = 'Verify'
)

$ErrorActionPreference = 'Stop'
$winUtilPath = Join-Path $PSScriptRoot 'winutil-26.10.28.ps1'
$expectedHash = 'd0444cb266953d927e5cee71455f4f1a6da2d5b3cfd7e440dceb4e6b1cbf4f7f'

try {
    if (-not (Test-Path -LiteralPath $winUtilPath -PathType Leaf)) {
        throw 'winutil-26.10.28.ps1 ontbreekt. Pak de volledige ZIP uit in dezelfde map.'
    }

    $actualHash = (Get-FileHash -LiteralPath $winUtilPath -Algorithm SHA256).Hash
    if ($actualHash -ne $expectedHash) {
        throw "SHA-256 wijkt af. Verwacht: $expectedHash. Gevonden: $actualHash."
    }

    if ($Mode -eq 'Verify') {
        $tokens = $null
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($winUtilPath, [ref]$tokens, [ref]$parseErrors)
        if ($parseErrors.Count -gt 0) {
            throw ($parseErrors.Message -join [Environment]::NewLine)
        }
        Write-Host 'WinUtil 26.10.28: SHA-256 en PowerShell-syntaxis zijn in orde.'
        exit 0
    }

    Write-Host 'WinUtil wordt geopend in een apart venster. Bevestig zo nodig de Windows-melding.'
    $powerShellPath = Join-Path $PSHOME 'powershell.exe'
    $launchArguments = @('-NoProfile', '-STA', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $winUtilPath))
    if ($Mode -eq 'Offline') {
        $launchArguments += '-Offline'
    }
    $process = Start-Process -FilePath $powerShellPath -ArgumentList $launchArguments -Verb RunAs -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "WinUtil is afgesloten met foutcode $($process.ExitCode)."
    }
} catch {
    [Console]::Error.WriteLine("WinUtil: $($_.Exception.Message)")
    exit 1
}
