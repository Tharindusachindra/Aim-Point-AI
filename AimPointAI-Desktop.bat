@echo off
title AimPointAI Desktop Engine
cd /d "%~dp0"

echo ======================================================================
echo    AimPointAI - Real-Time Basketball Kinematics Desktop Application
echo    Department of Computer Science, General Sir John Kotelawala Defence University
echo ======================================================================
echo.
echo [1/2] Ensuring Python AI & Biomechanics Server is Running...

REM Start server in background if not already running on port 8080
netstat -ano | findstr :8080 >nul
if %errorlevel% neq 0 (
    start /b python start_server.py
    timeout /t 2 /nobreak >nul
)

echo [2/2] Launching Native Desktop Electron Window...
start "" npx electron .

echo.
echo AimPointAI Desktop App launched successfully.
