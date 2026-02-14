@echo off
setlocal EnableDelayedExpansion
openfiles >nul 2>&1
if %errorlevel% neq 0 (echo [!] Run as Admin! & pause & exit /b)

set "ZAPRET_ROOT=%~dp0.."
set "BIN_PATH=%ZAPRET_ROOT%\bin\"
set "LISTS_PATH=%ZAPRET_ROOT%\lists\"
set "WINWS=%BIN_PATH%winws.exe"
set "SRVCNAME=zapret"

:: 1. Add exclusion to Windows Defender
echo [+] Adding folder to Windows Defender exclusions...
powershell -Command "Add-MpPreference -ExclusionPath '%ZAPRET_ROOT%'"

:: 2. Pre-install driver
echo [+] Installing WinDivert driver...
cd /d "%BIN_PATH%"
winws.exe --sys-install

:: 3. Arguments
set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 ^
 --filter-udp=443 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN_PATH%quic_initial_www_google_com.bin" --new ^
 --filter-tcp=80 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake80 --new ^
 --filter-tcp=443 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fake-tls="%BIN_PATH%tls_client_hello_www_google_com.bin"

:: 4. Reinstall Service
echo [+] Reinstalling service...
sc stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1
sc create %SRVCNAME% binPath= "\"%WINWS%\" %ARGS%" DisplayName= "zapret" start= auto
sc start %SRVCNAME%

:: 5. Final check
timeout /t 2
sc query %SRVCNAME% | findstr RUNNING >nul
if %errorlevel% equ 0 (
    echo [OK] Service is RUNNING.
) else (
    echo [X] Service failed to start. Try running bin\winws.exe manually to see error.
)
timeout /t 5
exit
