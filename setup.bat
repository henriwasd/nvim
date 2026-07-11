@echo off
:: Batch wrapper to run the PowerShell setup script with bypass policy
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "setup.ps1"
pause
