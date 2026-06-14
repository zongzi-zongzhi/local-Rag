@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\silent_start.ps1" -Mode status
echo.
echo 日志位置: %~dp0logs\silent-start.log
pause
