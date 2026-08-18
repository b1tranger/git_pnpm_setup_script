@echo off
setlocal enabledelayedexpansion
title Environment Setup - Git, Node.js, and pnpm

cd /d "%~dp0"

echo ========================================================
echo       Starting Environment Setup for Git ^& Node.js
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0files\setup_installer.ps1"

echo.
echo Press any key to exit setup...
pause >nul
