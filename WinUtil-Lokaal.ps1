param(
    [ValidateSet('Verify', 'Start', 'Offline')]
    [string]$Mode = 'Verify',
    [ValidateSet('Auto', 'NL', 'EN')]
    [string]$Language = 'Auto'
)

$ErrorActionPreference = 'Stop'
$winUtilPath = Join-Path $PSScriptRoot 'winutil-26.10.28.ps1'
$expectedHash = 'd0444cb266953d927e5cee71455f4f1a6da2d5b3cfd7e440dceb4e6b1cbf4f7f'
if ($Language -eq 'Auto') {
    if ((Get-UICulture).TwoLetterISOLanguageName -eq 'nl') { $Language = 'NL' }
    else { $Language = 'EN' }
}
function LocalText([string]$NL, [string]$EN) {
    if ($Language -eq 'NL') { return $NL }
    return $EN
}

try {
    if (-not (Test-Path -LiteralPath $winUtilPath -PathType Leaf)) {
        throw (LocalText 'WinUtil-bestand ontbreekt. Pak de volledige ZIP uit.' 'WinUtil file is missing. Extract the complete ZIP.')
    }
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $winUtilPath).Hash
    if ($actualHash -ne $expectedHash) {
        throw ((LocalText 'SHA-256 wijkt af.' 'SHA-256 mismatch.') + " Expected: $expectedHash; actual: $actualHash")
    }
    if ($Mode -eq 'Verify') {
        $tokens = $null
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($winUtilPath, [ref]$tokens, [ref]$parseErrors)
        if ($parseErrors.Count -gt 0) {
            throw ($parseErrors.Message -join [Environment]::NewLine)
        }
        Write-Host (LocalText 'WinUtil 26.10.28: SHA-256 en PowerShell-syntaxis zijn in orde.' 'WinUtil 26.10.28: SHA-256 and PowerShell syntax are valid.')
        exit 0
    }

    # The elevated bootstrap is carried in the command line, not loaded from the
    # user-writable download folder. Paths are encoded as data, not executable text.
    $sourceB64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($winUtilPath))
    $bootstrap = @'
$ErrorActionPreference = 'Stop'
$source = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('__SOURCE_B64__'))
$expected = '__EXPECTED_HASH__'
$offline = '__MODE__' -eq 'Offline'
$language = '__LANGUAGE__'
$stage = $null
$exitCode = 1
function LocalText([string]$NL, [string]$EN) {
    if ($language -eq 'NL') { return $NL }
    return $EN
}
try {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    try {
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw (LocalText 'Administratorrechten zijn vereist.' 'Administrator rights are required.')
        }
    } finally { $identity.Dispose() }

    # Verify the exact byte array that will be staged, after elevation.
    $bytes = [IO.File]::ReadAllBytes($source)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $actual = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '') }
    finally { $sha.Dispose() }
    if ($actual -ne $expected) {
        throw (LocalText 'SHA-256 wijkt af na UAC. Start geblokkeerd.' 'SHA-256 mismatch after UAC. Launch blocked.')
    }

    # Use a fresh administrator-only staging directory under Program Files.
    # This assumes the normal Windows ACLs on Program Files and a trusted launcher.
    $root = [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)
    if ([string]::IsNullOrWhiteSpace($root) -or -not [IO.Directory]::Exists($root)) {
        throw (LocalText 'Program Files is niet beschikbaar.' 'Program Files is unavailable.')
    }
    if (([IO.File]::GetAttributes($root) -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw 'Program Files is a reparse point; refusing to stage.'
    }
    $admins = New-Object Security.Principal.SecurityIdentifier('S-1-5-32-544')
    $system = New-Object Security.Principal.SecurityIdentifier('S-1-5-18')
    $acl = New-Object Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetOwner($admins)
    foreach ($sid in @($admins, $system)) {
        $rule = New-Object Security.AccessControl.FileSystemAccessRule(
            $sid, 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow'
        )
        $acl.AddAccessRule($rule)
    }
    $candidate = Join-Path $root ('WinUtil-Lokaal-' + [Guid]::NewGuid().ToString('N'))
    if ([IO.Directory]::Exists($candidate) -or [IO.File]::Exists($candidate)) {
        throw 'Staging directory already exists.'
    }
    [void][IO.Directory]::CreateDirectory($candidate, $acl)
    $stage = $candidate
    $stagedScript = Join-Path $stage 'winutil-26.10.28.ps1'
    $stream = [IO.File]::Open($stagedScript, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try { $stream.Write($bytes, 0, $bytes.Length) }
    finally { $stream.Dispose() }
    if ((Get-FileHash -LiteralPath $stagedScript -Algorithm SHA256).Hash -ne $expected) {
        throw 'Staged SHA-256 mismatch; launch blocked.'
    }

    # Preserve upstream -File semantics, including PSCommandPath and offline parameter.
    $exe = Join-Path $PSHOME 'powershell.exe'
    $childArgs = @('-NoProfile', '-STA', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $stagedScript))
    if ($offline) { $childArgs += '-Offline' }
    $child = Start-Process -FilePath $exe -WorkingDirectory $stage -ArgumentList $childArgs -Wait -PassThru
    $exitCode = $child.ExitCode
} catch {
    [Console]::Error.WriteLine("WinUtil: $($_.Exception.Message)")
} finally {
    if ($stage) {
        try { Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction Stop }
        catch {
            [Console]::Error.WriteLine((LocalText 'Opruimen mislukt:' 'Cleanup failed:') + " $stage")
            if ($exitCode -eq 0) { $exitCode = 1 }
        }
    }
}
if ($exitCode -ne 0) {
    Write-Host (LocalText 'WinUtil is niet succesvol afgesloten.' 'WinUtil did not exit successfully.')
}
exit $exitCode
'@
    $bootstrap = $bootstrap.Replace('__SOURCE_B64__', $sourceB64).Replace('__EXPECTED_HASH__', $expectedHash).Replace('__MODE__', $Mode).Replace('__LANGUAGE__', $Language)
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($bootstrap))
    Write-Host (LocalText 'Bevestig de Windows-melding. WinUtil wordt veilig voorbereid.' 'Confirm the Windows prompt. WinUtil is being prepared.')
    $exe = Join-Path $PSHOME 'powershell.exe'
    $process = Start-Process -FilePath $exe -WorkingDirectory $PSHOME -ArgumentList @('-NoProfile', '-STA', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $encoded) -Verb RunAs -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw ((LocalText 'WinUtil is afgesloten met foutcode' 'WinUtil exited with code') + " $($process.ExitCode).")
    }
    exit 0
} catch {
    [Console]::Error.WriteLine("WinUtil: $($_.Exception.Message)")
    exit 1
}
