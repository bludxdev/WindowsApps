@echo off
set "Z_BIN=%~dp0..\bin\winws.exe"
set "Z_LIST=%~dp0..\lists\list-general.txt"

sc stop zapret >nul 2>&1
sc delete zapret >nul 2>&1

:: Регистрируем без лишних наворотов
sc create zapret binPath= "\"%Z_BIN%\" --wf-tcp=80,443 --wf-udp=443 --filter-udp=443 --hostlist=\"%Z_LIST%\" --dpi-desync=fake --new --filter-tcp=443 --hostlist=\"%Z_LIST%\" --dpi-desync=fake,split2" DisplayName= "zapret" start= auto

sc start zapret
exit
