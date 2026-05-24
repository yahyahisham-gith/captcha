@echo off
cls
title LOCALTUNNEL HOSTING CONFIGURATOR
color 0E

:port_setup
echo.
:: Defaulting to 3000 for your server.js, but keeping your manual input logic
set /p TARGET_PORT="Enter the Port you are hosting on (e.g. 3000): "
if "%TARGET_PORT%"=="" goto port_setup

:setup_choice
cls
echo.
echo  +-----------------------------------------------------------+
echo  ^|                 LOCALTUNNEL CONNECTION SETUP              ^|
echo  +-----------------------------------------------------------+
echo  ^|  PORT: %TARGET_PORT%                                     ^|
echo  ^|                                                           ^|
echo  ^|  [1] Custom Subdomain (Free, if available)                ^|
echo  ^|  [2] Random Subdomain (Always works)                      ^|
echo  ^|                                                           ^|
echo  +-----------------------------------------------------------+
echo.
set /p mode="Select Mode [1-2]: "

if "%mode%"=="1" goto custom_name
if "%mode%"=="2" goto random_mode
goto setup_choice

:custom_name
echo.
set /p SUBDOMAIN="Enter your preferred name: "
set LT_FLAGS=--subdomain %SUBDOMAIN%
goto start_tunnel

:random_mode
set "SUBDOMAIN=RANDOM_GENERATED"
set "LT_FLAGS="
goto start_tunnel

:start_tunnel
cls
echo [ PROCESS ] Fetching Bypass IP Key...
set "MYIP=OFFLINE"
for /f "tokens=*" %%i in ('curl.exe -s --max-time 5 ifconfig.me') do set "MYIP=%%i"

echo.
echo  +-----------------------------------------------------------+
echo  ^|                 NETWORK TUNNEL: LOCALTUNNEL               ^|
echo  +-----------------------------------------------------------+
echo  ^| REQUESTED: [ %SUBDOMAIN% ]                                ^|
echo  ^| IP KEY:     [ %MYIP% ]                                    ^|
echo  ^| PORT:       [ %TARGET_PORT% ]                             ^|
echo  +-----------------------------------------------------------+
echo.
echo  [ INFO ] Copy the IP KEY above if prompted by Localtunnel.
echo  [ INFO ] If no link appears below, your port might be blocked.
echo.

:: Restoring your exact call structure with the local-host fix
call lt --port %TARGET_PORT% %LT_FLAGS% --local-host 127.0.0.1

echo.
echo  [ ALERT ] Connection lost or Localtunnel failed to start.
timeout /t 10
goto start_tunnel