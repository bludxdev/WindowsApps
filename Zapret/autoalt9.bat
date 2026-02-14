@echo off
setlocal EnableDelayedExpansion

:: Проверка прав админа
openfiles >nul 2>&1
if %errorlevel% neq 0 (exit /b)

set "ZAPRET_ROOT=%~dp0.."
set "BIN_PATH=%ZAPRET_ROOT%\bin\"
set "LISTS_PATH=%ZAPRET_ROOT%\lists\"
set "WINWS=%BIN_PATH%winws.exe"
set "SRVCNAME=zapret"

echo [+] Cleaning old service...
sc stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

:: Настройки для твоей версии v72.9
set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 ^
 --filter-udp=443 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN_PATH%quic_initial_www_google_com.bin" --new ^
 --filter-tcp=80 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake80 --new ^
 --filter-tcp=443 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fake-tls="%BIN_PATH%tls_client_hello_www_google_com.bin"

echo [+] Registering service...
sc create %SRVCNAME% binPath= "\"%WINWS%\" %ARGS%" DisplayName= "zapret" start= auto
sc description %SRVCNAME% "Zapret DPI bypass"
sc start %SRVCNAME%

echo [+] Done.
exit
