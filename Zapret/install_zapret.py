import urllib.request
import os
import zipfile
import io
import time
import subprocess

INSTALL_DIR = r"C:\Need\Programms\zapret-1.9.6"
ZIP_URL = "https://github.com/Flowseal/zapret-discord-youtube/releases/download/1.9.6/zapret-discord-youtube-1.9.6.zip"

def run():
    print(f"[*] Installing Zapret...")
    if not os.path.exists(INSTALL_DIR): os.makedirs(INSTALL_DIR)

    try:
        req = urllib.request.Request(ZIP_URL, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as r:
            with zipfile.ZipFile(io.BytesIO(r.read())) as z:
                z.extractall(INSTALL_DIR)
        
        # Открываем файлы
        h = os.path.join(INSTALL_DIR, "help.txt")
        s = os.path.join(INSTALL_DIR, "service.bat")
        if os.path.exists(h): os.startfile(h)
        if os.path.exists(s):
            subprocess.Popen(['cmd.exe', '/c', 'start', 'cmd.exe', '/k', s], cwd=INSTALL_DIR, shell=True)
        print("[+] Success!")
    except Exception as e:
        print(f"[!] Error: {e}")

    print("\nClosing and self-destructing in 3 seconds...")
    time.sleep(3)

if __name__ == "__main__":
    run()
