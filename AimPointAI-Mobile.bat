@echo off
title AimPoint Motion Mobile (Expo)
cd /d "%~dp0"

echo ======================================================================
echo    AimPoint Motion - Cross-Platform Mobile App (Expo / React Native)
echo ======================================================================
echo.
echo [1/2] Checking FastAPI Backend on Port 8080...
netstat -ano | findstr ":8080 " | findstr "LISTENING" >nul
if %errorlevel% neq 0 (
    if exist "%~dp0.venv\Scripts\python.exe" (
        start "" /b "%~dp0.venv\Scripts\python.exe" start_server.py
    ) else (
        start "" /b python start_server.py
    )
    timeout /t 2 /nobreak >nul
)

echo [2/2] Starting Expo Metro Server in mobile\ ...
cd mobile
set EXPO_NO_TELEMETRY=1
call npx expo whoami >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [Tip] iOS Expo Go requires either logging out in the Expo Go phone app
    echo       OR signing in below as "tharindusachindra":
    call npx expo login -u tharindusachindra
)
npx expo start -c
