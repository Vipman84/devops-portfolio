import subprocess, time, os, sqlite3, glob, requests, signal
from datetime import datetime

DB_PATH = "data/lottery.db"
LOG_FILE = "data/collector.log"
META_DIR = "data/lottery_meta"
STATE_FILE = "data/nloto_state.json"
CHECK_INTERVAL = 120  # 2 минуты

def site_available():
    try:
        r = requests.head("https://nloto.ru", timeout=10)
        return r.status_code < 500
    except:
        return False

def is_collector_running():
    try:
        result = subprocess.run(["pgrep", "-f", "api_collector.py"], capture_output=True, text=True)
        return bool(result.stdout.strip())
    except:
        return False

def stop_collector():
    subprocess.run(["pkill", "-f", "api_collector.py"], check=False)

def start_collector():
    print(f"[{datetime.now()}] 🚀 Запускаю сборщик тиражей...")
    with open(LOG_FILE, "a") as log:
        return subprocess.Popen(
            ["python", "api_collector.py"],
            stdout=log,
            stderr=log,
            cwd=os.path.dirname(os.path.abspath(__file__)),
            preexec_fn=os.setpgrp
        )

def analyze_logs():
    """Возвращает True, если в логах есть критические ошибки."""
    if not os.path.exists(LOG_FILE):
        return False
    try:
        with open(LOG_FILE, "r") as f:
            lines = f.readlines()[-10:]  # последние 10 строк
        critical = ["Failed to fetch", "SyntaxError", "Timeout", "Error"]
        for line in lines:
            if any(err in line for err in critical):
                return True
    except:
        pass
    return False

def missing_json_lotteries():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    cur.execute("SELECT product_id, name FROM lotteries")
    all_lotteries = cur.fetchall()
    conn.close()
    existing = set()
    for f in glob.glob(os.path.join(META_DIR, "*.json")):
        basename = os.path.basename(f)
        try:
            pid = int(basename.split("_")[0])
            existing.add(pid)
        except:
            pass
    return [(pid, name) for pid, name in all_lotteries if pid not in existing]

def fetch_missing_json():
    missing = missing_json_lotteries()
    if not missing:
        print(f"[{datetime.now()}] ✅ Все JSON-ы уже скачаны.")
        return
    print(f"[{datetime.now()}] 📥 Докачиваю JSON для {len(missing)} лотерей...")
    subprocess.run(["python", "fetch_lottery_json.py"], check=False)

def main():
    print(f"[{datetime.now()}] 👀 Диспетчер стартовал. Проверка каждые {CHECK_INTERVAL} сек.")
    collector_process = None
    last_restart_time = 0

    while True:
        # Если сайт недоступен, не мучаем сборщик
        if not site_available():
            print(f"[{datetime.now()}] ⏳ Сайт недоступен, жду...")
            if collector_process and collector_process.poll() is not None:
                collector_process = None
            time.sleep(CHECK_INTERVAL)
            continue

        # Запускаем сборщик, если не работает
        if not is_collector_running() or (collector_process and collector_process.poll() is not None):
            if collector_process and collector_process.poll() is not None:
                print(f"[{datetime.now()}] 🔄 Сборщик завершился, перезапускаю...")
            else:
                print(f"[{datetime.now()}] ⚠️ Сборщик не запущен. Запускаю.")
            stop_collector()
            time.sleep(5)
            collector_process = start_collector()
            last_restart_time = time.time()
            time.sleep(10)

        # Анализ логов (только если сборщик работает)
        if collector_process and collector_process.poll() is None:
            if analyze_logs():
                print(f"[{datetime.now()}] 🔄 Обнаружены ошибки в логах, перезапускаю сборщик...")
                stop_collector()
                time.sleep(5)
                collector_process = start_collector()
                last_restart_time = time.time()

        # Докачиваем JSON-ы, если есть недостающие и сайт доступен
        if site_available():
            fetch_missing_json()

        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
