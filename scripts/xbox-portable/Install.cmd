@echo off
setlocal
rem Let Windows PowerShell load its own modules when run from a PowerShell 7 terminal.
set "PSModulePath="
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-VeyraXbox.ps1" -Launch %*
set "veyra_exit=%errorlevel%"
if not "%veyra_exit%"=="0" pause
exit /b %veyra_exit%
