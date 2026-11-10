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

set "PY_CMD=python"
if exist "%~dp0.venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0.venv\Scripts\python.exe"
) else if exist "%~dp0venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0venv\Scripts\python.exe"
)

echo [1/3] Clearing stale background locks...
taskkill /f /im AimPointAI.exe 2>nul

echo [2/3] Checking AI Biomechanics Server on port 8080...
powershell -NoProfile -Command "
    $portOpen = $false;
    try {
        $res = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/api/health' -TimeoutSec 1 -UseBasicParsing -ErrorAction Stop;
        if ($res.StatusCode -eq 200) { $portOpen = $true; }
    } catch { }
    if (-not $portOpen) { exit 1; } else { exit 0; }
" >nul 2>&1

if %errorlevel% neq 0 (
    echo     Starting Python AI Engine in background...
    start "AimPointAI Server" /min "%PY_CMD%" start_server.py
    
    REM Wait up to 15 seconds for backend to become healthy
    powershell -NoProfile -Command "
        $attempts = 0;
        while ($attempts -lt 15) {
            Start-Sleep -Seconds 1;
            $attempts++;
            try {
                $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/api/health' -TimeoutSec 1 -UseBasicParsing -ErrorAction Stop;
                if ($r.StatusCode -eq 200) { exit 0; }
            } catch { }
        }
        exit 1;
    " >nul 2>&1
)

echo [3/3] Launching Native Desktop Window...
if exist "%~dp0node_modules\electron\dist\electron.exe" (
    start "" "%~dp0node_modules\electron\dist\electron.exe" "%~dp0."
) else if exist "%~dp0dist\AimPointAI-win32-x64\AimPointAI.exe" (
    start "" "%~dp0dist\AimPointAI-win32-x64\AimPointAI.exe"
) else (
    start "" npx electron .
)

echo.
echo AimPointAI Desktop Engine initialized successfully.
timeout /t 3 /nobreak >nul
