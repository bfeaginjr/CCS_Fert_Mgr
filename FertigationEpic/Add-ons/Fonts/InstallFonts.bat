@echo off
setlocal enabledelayedexpansion

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrative privileges.
    echo Please right-click on this file and select "Run as administrator".
    pause
    exit /B 1
)

set "fontDir=C:\FertigationEpic\Add-ons\Fonts"
set "tempDir=%fontDir%\FontInstallerTemp"

REM Create a temporary directory for extraction inside Fonts folder
md "%tempDir%" 2>nul

REM Extract each zip file to the temporary directory
for %%F in ("%fontDir%\*.zip") do (
    echo Extracting fonts from %%F
    powershell -Command "Expand-Archive -Path '%%F' -DestinationPath '%tempDir%' -Force"
)

REM Install fonts from the temporary directory to Windows Fonts directory
echo Installing fonts to Windows Fonts directory

REM Install TrueType fonts (*.ttf)
echo.
echo Installing TrueType fonts (*.ttf):
for %%I in ("%tempDir%\*.ttf") do (
    echo Installing: %%~nxI
    powershell -Command "Copy-Item '%%I' -Destination '%windir%\Fonts\' -Force"
)

REM Install OpenType fonts (*.otf)
echo.
echo Installing OpenType fonts (*.otf):
for %%I in ("%tempDir%\*.otf") do (
    echo Installing: %%~nxI
    powershell -Command "Copy-Item '%%I' -Destination '%windir%\Fonts\' -Force"
)

REM Clean up temporary files and directory
rd /s /q "%tempDir%"

echo.
echo All fonts installed successfully.
pause
exit
