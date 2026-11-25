# WinUtil Lokaal — English guide

[Nederlands](README.md) · **English**

## Project overview

Local WinUtil copy for Windows 11 with Dutch and English guides, SHA-256 and PowerShell syntax verification, and an offline launcher.

This package contains the original PowerShell release **26.10.28** of Chris Titus Tech’s Windows Utility (WinUtil). Once extracted, the launcher opens WinUtil in a separate window using the script included in the package.

You’ll need **Windows 11, Windows PowerShell 5.1, and access to a Windows administrator account**. The WinUtil interface is primarily in English.

## Download and launch

1. Open this public GitHub repository and select **Code → Download ZIP**. [Download the ZIP directly](https://github.com/sosaklingo/winutil-lokaal/archive/refs/heads/main.zip).
2. In File Explorer, right-click the ZIP and choose **Extract All**. Keep all the extracted files together.
3. Double-click **Start-WinUtil.cmd** in the extracted folder. Use **Start-WinUtil-Offline.cmd** to open WinUtil in offline mode.
4. Confirm the Windows User Account Control (UAC) prompt. A separate window titled **WinUtil** should appear. If PowerShell stays in front, press **Alt+Tab** to switch to WinUtil.

| File | What it does |
| --- | --- |
| `Start-WinUtil.cmd` | Opens the local copy with the standard features enabled. App installs and other downloads require internet access. |
| `Start-WinUtil-Offline.cmd` | Opens WinUtil with its built-in `-Offline` option. The **Install** tab is disabled. External links and download features still require internet access. |
| `Controleer-WinUtil.cmd` | Verifies the script’s SHA-256 hash and PowerShell syntax. You can run this check with a standard Windows account. It only checks the file. |

WinUtil can change Windows settings when you apply an action in its interface. Read the description of each tweak before applying it.

## Troubleshooting

| What you see | What to do |
| --- | --- |
| Only a PowerShell window appears | Wait a few seconds, then check the taskbar or use **Alt+Tab** to find the **WinUtil** window. |
| The administrator prompt was declined | Run the launcher again and confirm the prompt. On a managed PC, your administrator may restrict script execution. |
| The launcher reports a missing file | Extract the entire ZIP again and run the launcher from that folder. |
| The SHA-256 check fails | Download the package again and run `Controleer-WinUtil.cmd`. The launcher stops when the hash differs from the expected value. |
| **Please select the program(s) to install or upgrade** | Select at least one program on the **Install** tab before choosing **Install/Upgrade**. |
| The window closes or never appears | Note the error message. If WinUtil started logging, paste `%LOCALAPPDATA%\winutil\logs` into the File Explorer address bar and open the newest log. Remove personal information before sharing the relevant excerpt. |

## Source and verification

The included `winutil-26.10.28.ps1` is byte-for-byte identical to the published [WinUtil 26.10.28 release](https://github.com/ChrisTitusTech/winutil/releases/tag/26.10.28). The release file is unsigned. Compare its SHA-256 hash with the digest published by the WinUtil project to verify the copy.

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath .\winutil-26.10.28.ps1
```

```text
d0444cb266953d927e5cee71455f4f1a6da2d5b3cfd7e440dceb4e6b1cbf4f7f
```

The launchers use `-ExecutionPolicy Bypass` for the Windows PowerShell processes they start. System policy stays in place, and any enforced Group Policy takes precedence. The package stays on version 26.10.28. Check the [official WinUtil releases](https://github.com/ChrisTitusTech/winutil/releases) for newer versions.

## License and support

WinUtil Lokaal is an independent launcher package. Chris Titus Tech and the WinUtil contributors develop WinUtil. See the original [MIT license](LICENSE).

Report problems with the launchers or this guide in this repository. Report problems with WinUtil itself to the [official WinUtil issue tracker](https://github.com/ChrisTitusTech/winutil/issues).
