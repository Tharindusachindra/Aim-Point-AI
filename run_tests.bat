@echo off
title AimPointAI - Test Suite Runner
cd /d "%~dp0"

echo ======================================================================
echo    AimPointAI - Automated Biomechanical Test Suite
echo ======================================================================
echo.

set "PY_CMD=python"
if exist "%~dp0.venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0.venv\Scripts\python.exe"
) else if exist "%~dp0venv\Scripts\python.exe" (
    set "PY_CMD=%~dp0venv\Scripts\python.exe"
)

echo Running Unit Tests and Benchmarks...
"%PY_CMD%" -m unittest discover -s backend/tests
if %errorlevel% neq 0 (
    echo [FAIL] Unit tests failed!
    exit /b 1
)

echo.
echo Running API Smoke Test...
"%PY_CMD%" backend/test_api.py
if %errorlevel% neq 0 (
    echo [FAIL] Smoke test failed!
    exit /b 1
)

echo.
echo ======================================================================
echo    ALL 7 TESTS AND SMOKE SUITE PASSED SUCCESSFULLY!
echo ======================================================================
