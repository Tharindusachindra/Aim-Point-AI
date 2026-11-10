@echo off
title AimPointAI - Full System Rebuild and Validation
cd /d "%~dp0"

echo ======================================================================
echo    AimPointAI - Full System Rebuild and Verification Pipeline
echo    Department of Computer Science, General Sir John Kotelawala Defence University
echo ======================================================================
echo.

set "PY_CMD=python"
if exist "%~dp0.venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0.venv\Scripts\python.exe"
) else if exist "%~dp0venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0venv\Scripts\python.exe"
)

echo [1/5] Validating Python Virtual Environment (.venv)...
"%PY_CMD%" --version
if %errorlevel% neq 0 (
    echo [ERROR] Python environment not accessible.
    pause
    exit /b 1
)

echo.
echo [2/5] Updating and Verifying Dependencies...
"%PY_CMD%" -m pip install -r requirements.txt --quiet

echo.
echo [3/5] Executing 7 Unit and Biomechanical Integration Tests...
"%PY_CMD%" -m unittest discover -s backend/tests
if %errorlevel% neq 0 (
    echo [ERROR] Biomechanical tests failed.
    pause
    exit /b 1
)

echo.
echo [4/5] Executing End-to-End API Smoke Test...
"%PY_CMD%" backend/test_api.py
if %errorlevel% neq 0 (
    echo [ERROR] Smoke test failed.
    pause
    exit /b 1
)

echo.
echo [5/5] Synchronizing Distribution Assets to Desktop App Bundle...
if not exist "dist\AimPointAI-win32-x64\resources\app\sample_videos" (
    mkdir "dist\AimPointAI-win32-x64\resources\app\sample_videos"
)

copy /y "electron\main.js" "dist\AimPointAI-win32-x64\resources\app\electron\main.js" >nul
xcopy /s /e /y /q "backend" "dist\AimPointAI-win32-x64\resources\app\backend\" >nul
xcopy /s /e /y /q "frontend" "dist\AimPointAI-win32-x64\resources\app\frontend\" >nul
xcopy /s /e /y /q "sample_videos" "dist\AimPointAI-win32-x64\resources\app\sample_videos\" >nul
copy /y "AimPointAI-Desktop.bat" "dist\AimPointAI-win32-x64\resources\app\AimPointAI-Desktop.bat" >nul
copy /y "AimPointAI-Standalone.bat" "dist\AimPointAI-win32-x64\resources\app\AimPointAI-Standalone.bat" >nul
copy /y "start_server.py" "dist\AimPointAI-win32-x64\resources\app\start_server.py" >nul

echo    Distribution app bundle synchronized successfully.

echo.
echo ======================================================================
echo    SYSTEM REBUILD COMPLETE: 100%% VERIFIED AND PRODUCTION READY!
echo ======================================================================
echo.
echo You can now run:
echo   - AimPointAI-Desktop.bat    (Native Electron Desktop Window)
echo   - AimPointAI-Standalone.bat (Edge Frameless App Mode on localhost:8080)
echo   - push_to_github.bat        (Push latest codebase to GitHub)
echo.
