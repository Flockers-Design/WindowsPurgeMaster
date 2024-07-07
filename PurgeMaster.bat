@echo off
title PurgeMaster Cleanup Wizard by Flockers Design

:: Initialize crash log file (overwrite mode)
set "crashlog=%~dp0\crashlog.txt"
echo Crash Log > "%crashlog%"
echo ------------------- >> "%crashlog%"
echo. >> "%crashlog%"

:: Initialize logs.json file (overwrite mode)
set "logs=%~dp0\logs.json"
echo { "logs": [] } > "%logs%"

:: Determine current user's profile directory
set "USERPROFILE_DIR=%USERPROFILE%"

:START
cls
echo ===============================
echo   PurgeMaster Cleanup Wizard by Flockers Design
echo ===============================
echo            Support
echo ===============================
echo For support, please contact:
echo Github: https://github.com/Flockers-Design/WindowsPurgeMaster
echo.

:MENU
echo Please select an option:
echo 1. Clean Temporary Files
echo 2. Clean Prefetch Files
echo 3. Empty Recycle Bin
echo 4. Clean Windows Update Cache
echo 5. Clean Temporary Internet Files
echo 6. Delete System Error Memory Dump Files (Option not implemented)
echo 7. Delete Temporary Installation Files (Option not implemented)
echo 8. Clean Registry (Option not implemented)
echo 9. Clean Browser Cache and History (Option not implemented)
echo 10. Clean All (Run Autocleaner.bat)
echo 11. Exit
echo.

set /p option=Enter the number of your choice (1-11): 

:: Validate user input
if "%option%"=="" goto MENU
echo.%option%| findstr /r "^[1-9][0-9]*$" >nul || goto MENU

:: Perform action based on user choice
if %option%==1 (
    call :confirm_cleanup "Clean Temporary Files" "%temp%"
)
if %option%==2 (
    call :confirm_cleanup "Clean Prefetch Files" "C:\Windows\Prefetch"
)
if %option%==3 (
    call :confirm_cleanup "Empty Recycle Bin" "%systemdrive%\$Recycle.Bin"
)
if %option%==4 (
    call :confirm_cleanup "Clean Windows Update Cache" "%windir%\SoftwareDistribution\Download"
)
if %option%==5 (
    call :confirm_cleanup "Clean Temporary Internet Files" "%userprofile%\AppData\Local\Microsoft\Windows\INetCache"
)
if %option%==6 (
    echo Option 6: Delete System Error Memory Dump Files (Not implemented)
    pause
)
if %option%==7 (
    echo Option 7: Delete Temporary Installation Files (Not implemented)
    pause
)
if %option%==8 (
    echo Option 8: Clean Registry (Not implemented)
    pause
)
if %option%==9 (
    echo Option 9: Clean Browser Cache and History (Not implemented)
    pause
)
if %option%==10 (
    echo Performing all cleanups using Autocleaner...
    call "%~dp0\addons\Autocleaner.bat"
    echo All cleanups completed.
    pause
)
if %option%==11 (
    echo Exiting cleanup wizard.
    exit /Exit
)

:: If script reaches here, it indicates an unexpected situation
echo ERROR: Unexpected situation occurred. Please check the crash log: %crashlog%
echo Error occurred in option: %option% >> "%crashlog%"
echo. >> "%crashlog%"
echo Last command: %0 %* >> "%crashlog%"
echo Script location: %~dp0 >> "%crashlog%"
echo Date/Time: %date% %time% >> "%crashlog%"
echo. >> "%crashlog%"
pause
goto START

:: Function to confirm cleanup and perform action
:confirm_cleanup
set "action=%~1"
set "path=%~2"

echo Are you sure you want to %action%? (Y/N)
set /p choice=

if /i "%choice%"=="Y" (
    echo Performing %action%...
    del /s /q /f "%path%\*.*" >nul 2>&1
    rd /s /q "%path%" >nul 2>&1
    mkdir "%path%" >nul 2>&1
    echo %action% completed.
    call :log_cleanup "%action%" "%path%" "MB"
) else (
    echo %action% canceled.
)
pause
goto :eof

:: Function to log cleanup action to logs.json
:log_cleanup
set "category=%~1"
set "path=%~2"
set "unit=%~3"

:: Get current date/time in ISO 8601 format
for /f "usebackq tokens=1,2 delims=." %%a in (`echo %time%`) do (
    set "timestamp=%date%T%%a.%%b"
)

:: Calculate size of cleaned directory
set "beforeSize=0"
for /f "tokens=3" %%a in ('dir "%path%" /s /-c ^| findstr /i "bytes"') do set /a beforeSize+=%%a

:: Perform the cleanup action
del /s /q /f "%path%\*.*" >nul 2>&1

:: Calculate size after cleanup
set "afterSize=0"
for /f "tokens=3" %%a in ('dir "%path%" /s /-c ^| findstr /i "bytes"') do set /a afterSize+=%%a

:: Calculate space cleared
set /a spaceCleared=beforeSize - afterSize

:: Log to logs.json
echo { "category": "%category%", "path": "%path%", "spaceCleared": %spaceCleared%, "unit": "%unit%", "timestamp": "%timestamp%" } >> "%logs%"

goto :eof