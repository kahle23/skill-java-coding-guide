@echo off
REM Double-click entry point. Runs the PowerShell installer with execution
REM policy bypassed (default .ps1 files do NOT execute on double-click).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-skills.windows.ps1" %*
pause
