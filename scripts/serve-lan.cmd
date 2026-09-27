@echo off
rem Double-click (or run) this to serve the game to phones on the same Wi-Fi.
rem Bypasses PowerShell's script policy for this one run only; nothing on the system changes.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve-lan.ps1" %*
pause
