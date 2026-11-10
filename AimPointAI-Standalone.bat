@echo off
title AimPointAI Standalone Desktop App
cd /d "%~dp0"

echo ======================================================================
echo    AimPointAI - Standalone Desktop Launcher
echo ======================================================================
echo.

set "PY_CMD=python"
if exist "%~dp0.venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0.venv\Scripts\python.exe"
) else if exist "%~dp0venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0venv\Scripts\python.exe"
)

echo [1/2] Checking Python AI Backend on port 8080...
netstat -ano | findstr 127.0.0.1:8080 >nul 2>&1
if %errorlevel% neq 0 (
    netstat -ano | findstr 0.0.0.0:8080 >nul 2>&1
)
if %errorlevel% neq 0 (
    echo     Starting Python AI Engine in background...
    start "AimPointAI Server" /min "%PY_CMD%" start_server.py
    ping -n 4 127.0.0.1 >nul
)

echo [2/2] Opening AimPointAI Window...
start msedge --app=http://localhost:8080 --window-size=1440,920 --app-id=AimPointAI 2>nul
if %errorlevel% neq 0 (
    start http://localhost:8080
)

echo.
echo AimPointAI is live at http://localhost:8080
ping -n 2 127.0.0.1 >nul
