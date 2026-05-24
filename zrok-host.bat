@echo off
title ZROK_TERMINAL
color 0b
set ZROK_NAME=captcha

taskkill /f /im zrok.exe >nul 2>&1

:menu
cls
echo ===========================================================
echo                  ZROK TUNNEL INTERFACE
echo ===========================================================
echo [ NAME ] %ZROK_NAME%
echo [ URL  ] https://%ZROK_NAME%.share.zrok.io
echo ===========================================================

echo SELECT INTERFACE MODE:
echo [1] TUI Mode      (Visual Dashboard)
echo [2] Headless Mode (Simple Text Logs)

set /p UI_CHOICE="Select Option [1-2]: "

if "%UI_CHOICE%"=="1" (
       zrok share reserved %ZROK_NAME% || pause
) else if "%UI_CHOICE%"=="2" (
       zrok share reserved %ZROK_NAME% --headless || pause
) else (
       goto menu
)
