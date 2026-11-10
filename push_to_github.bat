@echo off
title Push AimPointAI to GitHub
cd /d "%~dp0"

echo ======================================================================
echo    Pushing AimPointAI to GitHub Repository:
echo    https://github.com/Tharindusachindra/Aim-Point-AI.git
echo ======================================================================
echo.

set "GIT_CMD=git"
if exist "C:\Program Files\Git\cmd\git.exe" (
    set "GIT_CMD=C:\Program Files\Git\cmd\git.exe"
)

echo Using Git: "%GIT_CMD%"
echo.
"%GIT_CMD%" push -u origin main

echo.
if %errorlevel% equ 0 (
    echo ======================================================================
    echo  SUCCESS: Code pushed to https://github.com/Tharindusachindra/Aim-Point-AI.git
    echo ======================================================================
) else (
    echo [ERROR] Push failed. If prompted, please complete GitHub sign-in in the window.
)
echo.
pause

