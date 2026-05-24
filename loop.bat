@echo off
:start
cls
echo [SYSTEM] Starting Script Chain...

:: Run your test
call npm run test
echo.

:: Run your hello
call npm run hello
echo.

:: Run your loop notice
echo [SYSTEM] Loop Starting please wait...
timeout /t 5

:: Go back to the top and do it again
goto start