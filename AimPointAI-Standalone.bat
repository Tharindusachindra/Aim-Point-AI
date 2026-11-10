@echo off
title AimPointAI Standalone Desktop App
cd /d "%~dp0"

set "PY_CMD=python"
if exist "%~dp0.venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0.venv\Scripts\python.exe"
) else if exist "%~dp0venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0venv\Scripts\python.exe"
)

REM 1. Ensure Python AI backend is active on port 8080
netstat -ano | findstr :8080 >nul
if %errorlevel% neq 0 (
    start "AimPointAI Server" /min "%PY_CMD%" start_server.py
    timeout /t 3 /nobreak >nul
)

REM 2. Launch Standalone Native Window (Frameless Desktop App Mode)
start msedge --app=http://localhost:8080 --window-size=1440,920 --app-id=AimPointAI
exit

