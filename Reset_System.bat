@echo off
title AimPointAI - System Reset and Process Cleaner
cd /d "%~dp0"

echo ======================================================================
echo    AimPointAI - System Reset and Process Cleaner
echo ======================================================================
echo.
echo Terminating any hanging background processes and releasing locks...

taskkill /f /im AimPointAI.exe 2>nul
taskkill /f /im electron.exe 2>nul

REM Kill python process holding port 8080 if any
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do (
    echo Terminating stale process on port 8080 (PID %%a)...
    taskkill /f /pid %%a 2>nul
)

echo.
echo ======================================================================
echo    SYSTEM CLEANED SUCCESSFULLY! All locks and ports released.
echo ======================================================================
echo You can now cleanly launch:
echo   - AimPointAI-Desktop.bat
echo   - AimPointAI-Standalone.bat
echo.
pause

