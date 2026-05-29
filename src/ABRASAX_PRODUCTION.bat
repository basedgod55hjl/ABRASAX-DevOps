@echo off
title ABRASAX PRODUCTION — One-Command Launcher
color 0D
cd /d "%~dp0"
echo.
echo  ^<^<^<  ABRASAX PRODUCTION — ONE-COMMAND LAUNCHER  ^>^>^>
echo  HEX Seed: 4f5349524953424c58434b
echo.
echo  Launching PowerShell production boot ...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0ABRASAX_PRODUCTION.ps1"
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] ABRASAX production encountered an error (code: %errorlevel%^)
    pause
)
