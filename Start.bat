@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "SuperRun.ps1"
pause