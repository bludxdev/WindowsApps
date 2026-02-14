@echo off
setlocal EnableDelayedExpansion

:: Проверка прав администратора
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Ошибка: Требуются права администратора.
    echo Запустите файл от имени администратора.
    pause
    exit /b
)

:: Установка путей относительно расположения батника
set "BIN_PATH=%~dp0bin\"
set "LISTS_PATH=%~dp0lists\"
set "WINWS=%BIN_PATH%winws.exe"
set "SRVCNAME=zapret"

echo [+] Настройка службы Zapret (Режим: General Alt9)...

:: 1. Остановка и удаление старой службы, если она есть
sc stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

:: 2. Проверка наличия исполняемого файла
if not exist "%WINWS%" (
    echo [X] Ошибка: %WINWS% не найден!
    pause
    exit /b
)

:: 3. Формирование аргументов (Аналог выбора General Alt9)
:: Параметры включают десинхронизацию для HTTP/HTTPS и QUIC
set ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 ^
 --filter-udp=443 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN_PATH%quic_initial_www_google_com.bin" --new ^
 --filter-tcp=80 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake80 --new ^
 --filter-tcp=443 --hostlist="%LISTS_PATH%list-general.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fake-tls="%BIN_PATH%tls_client_hello_www_google_com.bin"

:: 4. Создание службы
echo [+] Регистрация службы в системе...
sc create %SRVCNAME% binPath= "\"%WINWS%\" %ARGS%" DisplayName= "zapret" start= auto
sc description %SRVCNAME% "Zapret DPI bypass (Auto Alt9)"

:: 5. Запуск
sc start %SRVCNAME%

if %errorlevel% equ 0 (
    echo.
    echo [OK] Служба Zapret успешно установлена и запущена!
) else (
    echo [X] Ошибка при запуске службы.
)

pause
