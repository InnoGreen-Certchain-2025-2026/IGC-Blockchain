@echo off
setlocal enabledelayedexpansion
call :main
set "SCRIPT_RC=%ERRORLEVEL%"
if not "%SCRIPT_RC%"=="0" (
  echo.
  echo Script stopped with error code %SCRIPT_RC%.
  pause
)
endlocal & exit /b %SCRIPT_RC%

:main
cd /d "%~dp0"

:menu
echo.
echo ================================================
echo IGC Blockchain - Quick Menu
echo ================================================
echo 1. Full setup ^(install + generate-if-missing + start + deploy^)
echo 2. Generate NEW network + deploy contract ^(no docker compose up/down^)
echo 3. Health status ^(network + contract^)
echo 4. Exit
echo ================================================
set /p choice=Choose [1-4]:

if "%choice%"=="1" goto opt_full
if "%choice%"=="2" goto opt_gen_deploy
if "%choice%"=="3" goto opt_status
if "%choice%"=="4" goto end

echo Invalid choice.
goto menu

:opt_full
echo Running full setup...
call :sc_install
if %ERRORLEVEL% NEQ 0 goto menu

if not exist "nodes\networkFiles\genesis.json" (
  echo Genesis not found. Generating network...
  call :infra_generate
  if %ERRORLEVEL% NEQ 0 goto menu
) else (
  echo Genesis already exists. Skipping generate step.
)

echo Starting Besu nodes...
docker compose up -d
if %ERRORLEVEL% NEQ 0 (
  echo Failed to start nodes. Check Docker Desktop and docker compose logs.
  goto menu
)

echo Waiting for node-4 RPC and deploying CertificateRegistry...
set "DEPLOY_OK=0"
for /L %%I in (1,1,3) do (
  echo Deploy attempt %%I/3...
  call :sc_deploy
  if !ERRORLEVEL! EQU 0 (
    set "DEPLOY_OK=1"
    goto deploy_done
  )
  powershell -NoProfile -Command "Start-Sleep -Seconds 3" >nul
)

:deploy_done
if "!DEPLOY_OK!"=="1" (
  echo CertificateRegistry deployment completed.
) else (
  echo CertificateRegistry deployment failed after 3 attempts.
  echo You can deploy manually:
  echo   cd smart-contracts
  echo   npx hardhat run scripts/deploy.js --network besu
)
echo Full setup completed.
goto menu

:opt_gen_deploy
echo Running: generate NEW network + deploy contract...
echo Note: this option does not run docker compose up/down.
call :infra_generate
if %ERRORLEVEL% NEQ 0 (
  echo Generate network failed.
  goto menu
)
call :sc_install
if %ERRORLEVEL% NEQ 0 (
  echo Dependency install check failed.
  goto menu
)
call :sc_deploy
if %ERRORLEVEL% NEQ 0 (
  echo Deploy failed. Ensure Besu nodes are already running.
  goto menu
)
echo Generate + deploy completed.
goto menu

:opt_status
call :status_full
goto menu

:sc_install
where /Q npm
if %ERRORLEVEL% NEQ 0 (
  echo npm not found. Install Node.js ^(includes npm^) and retry.
  exit /b 1
)
if not exist "smart-contracts\node_modules" (
  echo Installing smart-contracts dependencies...
  pushd smart-contracts
  call npm install
  set "RC=%ERRORLEVEL%"
  popd
  exit /b %RC%
)
echo smart-contracts dependencies already installed.
exit /b 0

:sc_deploy
call :sc_install
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
pushd smart-contracts
call npx hardhat run scripts/deploy.js --network besu
set "RC=%ERRORLEVEL%"
popd
exit /b %RC%

:infra_generate
set "BASH_EXE="
if exist "bash.cmd" (
  set "BASH_EXE=bash.cmd"
) else (
  where /Q bash
  if %ERRORLEVEL%==0 set "BASH_EXE=bash"
)
if "%BASH_EXE%"=="" (
  echo Bash not found. Install Git Bash or WSL to run scripts\generate-network.sh
  exit /b 1
)
echo Cleaning nodes data...
rmdir /S /Q nodes\networkFiles 2>nul
for /d %%D in (nodes\node-*) do (
  rmdir /S /Q "%%D\data" 2>nul
)
echo Regenerating network...
%BASH_EXE% scripts/generate-network.sh
exit /b %ERRORLEVEL%

:status_network
set "BASH_EXE="
if exist "bash.cmd" (
  set "BASH_EXE=bash.cmd"
) else (
  where /Q bash
  if %ERRORLEVEL%==0 set "BASH_EXE=bash"
)
if "%BASH_EXE%"=="" (
  echo Bash not found. Install Git Bash or WSL to run scripts\network-status.sh
  exit /b 1
)
%BASH_EXE% scripts/network-status.sh
exit /b %ERRORLEVEL%

:status_contract
set "CERT_ADDR="
set "CERT_STATUS="
if not exist "smart-contracts\certificate-contract.json" (
  echo CertificateRegistry: no certificate-contract.json found ^(skip contract check^)
  exit /b 0
)
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "$j=Get-Content 'smart-contracts\certificate-contract.json' -Raw | ConvertFrom-Json; $j.address"`) do set "CERT_ADDR=%%A"
if "!CERT_ADDR!"=="" (
  echo CertificateRegistry: cannot read address from certificate-contract.json
  exit /b 1
)
for /f "usebackq delims=" %%R in (`powershell -NoProfile -Command "$addr='!CERT_ADDR!'; try { $body=@{jsonrpc='2.0';method='eth_getCode';params=@($addr,'latest');id=1} | ConvertTo-Json -Compress; $resp=Invoke-RestMethod -Uri 'http://localhost:8548' -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 8; if($null -eq $resp.result -or $resp.result -eq '0x'){ 'MISSING' } else { 'OK' } } catch { 'RPC_ERR' }"`) do set "CERT_STATUS=%%R"
if "!CERT_STATUS!"=="OK" (
  echo CertificateRegistry: DEPLOYED ^(!CERT_ADDR!^)
  exit /b 0
)
if "!CERT_STATUS!"=="MISSING" (
  echo CertificateRegistry: NOT FOUND on current chain ^(!CERT_ADDR!^)
  echo Hint: deploy again if network was reset.
  exit /b 0
)
echo CertificateRegistry: CHECK FAILED ^(cannot query node-4 RPC^)
exit /b 1

:status_full
echo Checking network status...
call :status_network
echo.
echo Checking CertificateRegistry deployment on node-4 RPC...
call :status_contract
exit /b 0

:end
echo Bye.
exit /b 0
