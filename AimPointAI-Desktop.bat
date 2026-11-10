@echo off
title AimPointAI Desktop Application
cd /d "%~dp0"

set ELECTRON_RUN_AS_NODE=

echo ======================================================================
echo    AimPointAI - Real-Time Basketball Kinematics Desktop Application
echo    Department of Computer Science, General Sir John Kotelawala Defence University
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

echo [2/2] Launching Native Desktop Window...
if exist "%~dp0node_modules\electron\dist\electron.exe" (
    start "" "%~dp0node_modules\electron\dist\electron.exe" "%~dp0."
) else if exist "%~dp0dist\AimPointAI-win32-x64\AimPointAI.exe" (
    start "" "%~dp0dist\AimPointAI-win32-x64\AimPointAI.exe"
) else (
    start msedge --app=http://localhost:8080 --window-size=1440,920 --app-id=AimPointAI 2>nul
    if %errorlevel% neq 0 start http://localhost:8080
)

echo.
echo AimPointAI launched successfully.
ping -n 2 127.0.0.1 >nul
