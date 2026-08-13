@echo off
:: Batch wrapper to run the PowerShell uninstall script with bypass policy
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "uninstall.ps1"
pause
