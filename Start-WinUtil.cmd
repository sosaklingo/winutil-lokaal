@echo off
setlocal
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0WinUtil-Lokaal.ps1" -Mode Start
set "winutil_exit=%errorlevel%"
if not "%winutil_exit%"=="0" pause
exit /b %winutil_exit%
