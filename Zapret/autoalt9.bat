@echo off
setlocal EnableDelayedExpansion

:: Check for Admin rights
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Admin privileges required.
    pause
    exit /b
)

:: Set paths relative to ZAPRET_FOLDER (parent of utils)
set "ZAPRET_ROOT=%~dp0.."
set "BIN_PATH=%ZAPRET_ROOT%\bin\"
set "LISTS_PATH=%ZAPRET_ROOT%\lists\"
set "WINWS=%BIN_PATH%winws.exe"
set "SRVCNAME=zapret"

echo [+] Configuring Zapret Service (Mode: General Alt9)...

:: 1. Stop and delete old service
sc stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

:: 2. Check if winws exists
if not exist "%WINWS%" (
    echo [X] ERROR: %WINWS% not found!
    echo Current path: %~dp0
    pause
    exit /b
)

:: 3. Set Arguments (General Alt9)
set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 ^
 --filter-udp=443 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN_PATH%quic_initial_www_google_com.bin" --new ^
 --filter-tcp=80 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake80 --new ^
 --filter-tcp=443 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fake-tls="%BIN_PATH%tls_client_hello_www_google_com.bin"

:: 4. Create Service
echo [+] Registering service...
sc create %SRVCNAME% binPath= "\"%WINWS%\" %ARGS%" DisplayName= "zapret" start= auto
sc description %SRVCNAME% "Zapret DPI bypass (Auto Alt9)"

:: 5. Start
sc start %SRVCNAME%

if %errorlevel% equ 0 (
    echo.
    echo [OK] Zapret service installed and started successfully!
) else (
    echo [X] Failed to start service.
)
timeout /t 3
exit
