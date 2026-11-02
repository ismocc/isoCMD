@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ============================================================
::  isoCMD - Minimal Windows PE Environment
::  https://github.com/ismocc/isoCMD
:: ============================================================

wpeinit >nul 2>&1
color 04
cls
echo.
echo                     ____              ____
echo  __                /\  _`\    /'\_/`\/\  _`\
echo /\_\    ____    ___\ \ \/\_\ /\      \ \ \/\ \
echo \/\ \  /',__\  / __`\ \ \/_/_\ \ \__\ \ \ \ \ \
echo  \ \ \/\__, `\/\ \L\ \ \ \L\ \\ \ \_/\ \ \ \_\ \
echo   \ \_\/\____/\ \____/\ \____/ \ \_\\ \_\ \____/
echo    \/_/\/___/  \/___/  \/___/   \/_/ \/_/\/___/
echo.
color 0F
echo  isoCMD v1.0  --  Minimal Windows PE Environment
echo  -------------------------------------------------
echo  WinPE drive: X:    Type HELP for available commands
echo.
echo  Scanning for Windows installations...
echo.

set "count=0"
for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if /i not "%%D"=="X" (
        if exist "%%D:\Windows\System32\config\SYSTEM" (
            if not exist "%%D:\sources\boot.wim" (
                set /a count+=1
                set "drive[!count!]=%%D:"
            )
        )
    )
)

if !count! EQU 0 goto NO_WINDOWS

echo  Installations found:
echo.
for /l %%N in (1,1,!count!) do (
    echo    [%%N]  !drive[%%N]!
)
echo.
echo    [N]  Stay in isoCMD ^(X:\^)
echo.

:ASK
set "choice="
set /p "choice=  Select: "
if not defined choice goto ASK
if /i "!choice!"=="N" goto STAY

set "target="
for /l %%N in (1,1,!count!) do (
    if "!choice!"=="%%N" set "target=!drive[%%N]!"
)

if not defined target (
    echo.
    echo  Invalid selection. Enter a number from the list or N.
    echo.
    goto ASK
)

cls
echo  Switching to !target! ...
echo.
cmd /k "!target! & cd \"
goto END

:NO_WINDOWS
echo  No Windows installations detected.
echo.
echo  Possible reasons:
echo    - Drive is uninitialized or unformatted
echo    - Drive is BitLocker encrypted
echo    - Windows is installed but the SYSTEM hive is missing
echo.
echo  Dropping to isoCMD shell on X:
echo.
pause
goto STAY

:STAY
cls
echo  isoCMD  --  X:\
echo  Type EXIT to quit. Type HELP for available commands.
echo.

:END