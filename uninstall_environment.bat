@echo off
setlocal enabledelayedexpansion
title Environment Uninstall - Git, Node.js, and pnpm

cd /d "%~dp0"

echo ========================================================
echo       Starting Environment Uninstall for Git ^& Node.js
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0files\uninstall_installer.ps1"

echo.
echo Press any key to exit setup...
pause >nul
