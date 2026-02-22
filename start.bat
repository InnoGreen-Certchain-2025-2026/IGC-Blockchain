@echo off
setlocal enabledelayedexpansion

rem ==========================================================
rem IGC Blockchain Menu (Windows)
rem ==========================================================

rem Ensure working directory is the script location
cd /d "%~dp0"

rem Load .env (if present)
if exist ".env" (
  for /f "usebackq tokens=1* delims==" %%A in (".env") do (
    set "K=%%A"
    set "V=%%B"
    if not "!K!"=="" if /I not "!K:~0,1!"=="#" (
      set "!K!=!V!"
    )
  )
)

set "BASH_OK=0"
set "BASH_EXE=bash.cmd"

if exist "%BASH_EXE%" (
  set "BASH_OK=1"
) else (
  where /Q bash
  if %ERRORLEVEL%==0 (
    set "BASH_OK=1"
    set "BASH_EXE=bash"
  )
)

:menu
echo.
echo =========================================
echo IGC Blockchain - Menu
echo =========================================
echo 1. Reset network (delete data + regenerate)
echo 2. Start nodes (docker compose up -d)
echo 3. Stop nodes (docker compose down)
echo 4. Network status (requires bash)
echo 5. Exit
echo =========================================
set /p choice=Choose [1-5]: 

if "%choice%"=="1" goto reset
if "%choice%"=="2" goto up
if "%choice%"=="3" goto down
if "%choice%"=="4" goto status
if "%choice%"=="5" goto end

echo Invalid choice.
goto menu

:up
echo Starting Besu nodes...
docker compose up -d
goto menu

:down
echo Stopping Besu nodes...
docker compose down
goto menu

:status
if "%BASH_OK%"=="0" (
  echo Bash not found. Install Git Bash or WSL to run scripts\network-status.sh
  goto menu
)
echo Checking network status...
%BASH_EXE% scripts/network-status.sh
goto menu

:reset
if "%BASH_OK%"=="0" (
  echo Bash not found. Install Git Bash or WSL to run scripts\generate-network.sh
  goto menu
)
echo Cleaning nodes data...
rmdir /S /Q nodes\networkFiles 2>nul
for /d %%D in (nodes\node-*) do (
  rmdir /S /Q "%%D\data" 2>nul
)
echo Regenerating network...
%BASH_EXE% scripts/generate-network.sh
goto menu

:end
echo Bye.
endlocal
