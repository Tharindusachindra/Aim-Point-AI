@echo off
title AimPointAI Desktop Engine
cd /d "%~dp0"

REM Clear IDE terminal environment variable override if active
set ELECTRON_RUN_AS_NODE=

echo ======================================================================
echo    AimPointAI - Real-Time Basketball Kinematics Desktop Application
echo    Department of Computer Science, General Sir John Kotelawala Defence University
echo ======================================================================
echo.
echo [1/2] Ensuring Python AI & Biomechanics Server is Running...

set "PY_CMD=python"
if exist "%~dp0.venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0.venv\Scripts\python.exe"
) else if exist "%~dp0venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0venv\Scripts\python.exe"
)

REM Start server in background if not already running on port 8080
netstat -ano | findstr :8080 >nul
if %errorlevel% neq 0 (
    start /b "" "%PY_CMD%" start_server.py
    timeout /t 2 /nobreak >nul
)

echo [2/2] Launching Native Desktop Electron Window...
if exist "%~dp0node_modules\electron\dist\electron.exe" (
    start "" "%~dp0node_modules\electron\dist\electron.exe" "%~dp0."
) else (
    start "" npx electron .
)

echo.
echo AimPointAI Desktop App launched successfully.

