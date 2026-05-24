@echo off
title Launch-Station
set "PROJECT_DIR=C:\Users\yahya\Documents\captcha"
cd /d "%PROJECT_DIR%"

:: 1. Start Node with Nodemon
echo [1/2] Starting Node Server...
start "Captcha-Server" cmd /k "nodemon server.js"

:: 2. Start Zrok Host
echo [2/2] Starting Zrok Tunnel...
start "ZROK_TERMINAL" cmd /k "zrok-host.bat"

:: 3. Automate the "1" key press using PowerShell
echo Waiting for tunnel initialization...
timeout /t 3 >nul

powershell -Command "$wshell = New-Object -ComObject WScript.Shell; if($wshell.AppActivate('ZROK_TERMINAL')) { Sleep 1; $wshell.SendKeys('1'); $wshell.SendKeys('{ENTER}') }"

echo Launch sequence complete.
exit