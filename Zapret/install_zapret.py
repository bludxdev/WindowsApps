import urllib.request, os, zipfile, io, time, subprocess

# Константы
PATH = r"C:\Need\Programms\zapret-1.9.6"
SRC = "https://github.com/Flowseal/zapret-discord-youtube/releases/download/1.9.6/zapret-discord-youtube-1.9.6.zip"
# Базовый путь к твоим сырым файлам на GitHub
RAW_CONFIGS = "https://raw.githubusercontent.com/bludxdev/WindowsApps/main/Zapret/"

# Список файлов со скриншота
CONFIG_FILES = [
    "game_filter.enabled",
    "help.txt",
    "ipset-all.txt",
    "ipset-exclude.txt",
    "list-exclude.txt",
    "list-general.txt",
    "list-google.txt"
]

def install():
    print(f"--- Installer: Zapret + Custom Configs ---")
    if not os.path.exists(PATH): os.makedirs(PATH)

    try:
        # 1. Загрузка базы
        print("[*] Downloading core files...")
        req = urllib.request.Request(SRC, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as r:
            with zipfile.ZipFile(io.BytesIO(r.read())) as z:
                z.extractall(PATH)
        
        # 2. Загрузка конфигов со скриншота
        print("[*] Applying your custom configurations...")
        for file_name in CONFIG_FILES:
            # Файлы списков (txt) обычно лежат в папке lists, остальное в корне или utils
            sub_folder = "lists" if "list-" in file_name or "ipset-" in file_name else ""
            target_dir = os.path.join(PATH, sub_folder)
            
            if not os.path.exists(target_dir): os.makedirs(target_dir)
            
            file_url = RAW_CONFIGS + file_name
            target_path = os.path.join(target_dir, file_name)
            
            try:
                urllib.request.urlretrieve(file_url, target_path)
                print(f"  [+] Synced: {file_name}")
            except:
                print(f"  [!] Failed to sync: {file_name}")

        # 3. Запуск
        print("[*] Opening documentation and services...")
        h_file = os.path.join(PATH, "help.txt") # Теперь это твой файл
        s_bat = os.path.join(PATH, "service.bat")
        
        if os.path.exists(h_file): os.startfile(h_file)
        if os.path.exists(s_bat):
            subprocess.Popen(['cmd.exe', '/c', 'start', 'cmd.exe', '/k', s_bat], cwd=PATH, shell=True)
            
        print("[+] Installation and configuration complete!")
    except Exception as e:
        print(f"[!] Critical Error: {e}")

    print("\nThis window will close automatically in 3 seconds.")
    time.sleep(3)

if __name__ == "__main__":
    install()
