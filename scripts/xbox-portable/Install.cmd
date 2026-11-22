@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-VeyraXbox.ps1" -Launch %*
set "veyra_exit=%errorlevel%"
if not "%veyra_exit%"=="0" pause
exit /b %veyra_exit%
