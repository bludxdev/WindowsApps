@echo off
set "BIN_DIR=%~dp0..\bin"
set "LISTS=%~dp0..\lists"

:: Останавливаем и удаляем старое
sc stop zapret >nul 2>&1
sc delete zapret >nul 2>&1

:: Создаем сервис с чистыми флагами (БЕЗ --sys-install)
:: Важно: после binPath= ОБЯЗАТЕЛЬНО должен быть пробел
sc create zapret binPath= "\"%BIN_DIR%\winws.exe\" --wf-tcp=80,443 --wf-udp=443 --filter-udp=443 --hostlist=\"%LISTS%\list-general.txt\" --dpi-desync=fake --new --filter-tcp=443 --hostlist=\"%LISTS%\list-general.txt\" --dpi-desync=fake,split2" DisplayName= "zapret" start= auto

:: Запускаем
sc start zapret
exit
