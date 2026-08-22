@echo off
if exist "%~dp0love\love.exe" (
    start "" "%~dp0love\love.exe" "%~dp0."
    exit /b 0
)
if exist "C:\Program Files\LOVE\love.exe" (
    start "" "C:\Program Files\LOVE\love.exe" "%~dp0."
    exit /b 0
)
love "%~dp0."
