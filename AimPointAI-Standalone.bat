@echo off
title AimPointAI Standalone Desktop App
cd /d "%~dp0"

set "PY_CMD=python"
if exist "%~dp0.venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0.venv\Scripts\python.exe"
) else if exist "%~dp0venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0venv\Scripts\python.exe"
)

echo ======================================================================
echo    AimPointAI - Standalone Desktop Launcher
echo ======================================================================
echo.

echo [1/2] Verifying Python AI Backend Server...
powershell -NoProfile -Command "
    $portOpen = $false;
    try {
        $res = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/api/health' -TimeoutSec 1 -UseBasicParsing -ErrorAction Stop;
        if ($res.StatusCode -eq 200) { $portOpen = $true; }
    } catch { }
    if (-not $portOpen) { exit 1; } else { exit 0; }
" >nul 2>&1

if %errorlevel% neq 0 (
    echo     Starting server in background...
    start "AimPointAI Server" /min "%PY_CMD%" start_server.py
    
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

echo [2/2] Launching AimPointAI Desktop Window...
start msedge --app=http://localhost:8080 --window-size=1440,920 --app-id=AimPointAI 2>nul
if %errorlevel% neq 0 (
    start http://localhost:8080
)

echo.
echo AimPointAI is running at http://localhost:8080
timeout /t 3 /nobreak >nul
