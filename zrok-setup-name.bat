@echo off
title SYSTEM - NAME CONFIGURATOR (zrok v1.0)
color 0d
cls

:: FOLDER CONFIG
set TARGET_DIR=C:\Users\yahya\Documents\captcha
set TARGET_FILE=%TARGET_DIR%\zrok-host.bat

echo ===========================================================
echo                 CAPTCHA TUNNEL CONFIGURATOR
echo ===========================================================
echo.

:: --- CLEANUP SECTION ---
echo [ PROCESS ] Terminating existing zrok processes...
taskkill /f /im zrok.exe >nul 2>&1

:: AUTH REMOVED: It will now stay logged in.

:input_port
set /p PORT="Enter the Port (e.g. 3000): "
if "%PORT%"=="" goto input_port

:input_name
set /p NAME="Enter the Reserved Name (min 4 chars): "
if "%NAME%"=="" goto input_name

echo.
echo [ PROCESS ] Attempting to reserve %NAME%...
zrok reserve public http://localhost:%PORT% --unique-name %NAME% || (
    echo.
    echo [ ERROR ] Name already taken or reservation failed.
    pause
    goto input_name
)

echo [ PROCESS ] Generating Host File at %TARGET_FILE%...

(
echo @echo off
echo title ZROK_TERMINAL
echo color 0b
echo set ZROK_NAME=%NAME%
echo.
echo taskkill /f /im zrok.exe ^>nul 2^>^&1
echo.
echo :menu
echo cls
echo echo ===========================================================
echo echo                  ZROK TUNNEL INTERFACE
echo echo ===========================================================
echo echo [ NAME ] %%ZROK_NAME%%
echo echo [ URL  ] https://%%ZROK_NAME%%.share.zrok.io
echo echo ===========================================================
echo.
echo echo SELECT INTERFACE MODE:
echo echo [1] TUI Mode      ^(Visual Dashboard^)
echo echo [2] Headless Mode ^(Simple Text Logs^)
echo.
echo set /p UI_CHOICE="Select Option [1-2]: "
echo.
echo if "%%UI_CHOICE%%"=="1" (
echo        zrok share reserved %%ZROK_NAME%% ^|^| pause
echo ^) else if "%%UI_CHOICE%%"=="2" (
echo        zrok share reserved %%ZROK_NAME%% --headless ^|^| pause
echo ^) else (
echo        goto menu
echo ^)
) > "%TARGET_FILE%"

echo.
echo [ SUCCESS ] Configured! Run Start.bat to launch everything.
pause