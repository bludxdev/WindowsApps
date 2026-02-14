@echo off
set "BIN=%~dp0..\bin\"
set "LISTS=%~dp0..\lists\"

echo [+] Stopping old service...
sc stop zapret >nul 2>&1
sc delete zapret >nul 2>&1

echo [+] Registering service...
:: ВАЖНО: Убраны все неподдерживаемые флаги типа --sys-install
sc create zapret binPath= "\"%BIN%winws.exe\" --wf-tcp=80,443 --wf-udp=443 --filter-udp=443 --hostlist=\"%LISTS%list-general.txt\" --dpi-desync=fake --new --filter-tcp=80 --hostlist=\"%LISTS%list-general.txt\" --dpi-desync=fake80 --new --filter-tcp=443 --hostlist=\"%LISTS%list-general.txt\" --dpi-desync=fake,split2" DisplayName= "zapret" start= auto

sc start zapret
exit
