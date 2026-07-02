import json, os, time, sqlite3, sys
from playwright.sync_api import sync_playwright
from captcha_solver import bypass_captcha, close_popups

DB_PATH = "data/lottery.db"
STATE_FILE = "data/nloto_state.json"
HISTORY_PAGE_SIZE = 50
LOG_FILE = "data/collector.log"
SCREENSHOT_FILE = "data/nloto_screenshot.png"  # фиксированный путь для скриншота

def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.executescript("""
    CREATE TABLE IF NOT EXISTS lotteries (
        product_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        url TEXT,
        ticket_price INTEGER,
        draw_schedule TEXT,
        active INTEGER DEFAULT 1
    );
    CREATE TABLE IF NOT EXISTS draws (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lottery_id INTEGER NOT NULL REFERENCES lotteries(product_id),
        draw_number TEXT,
        draw_date TEXT NOT NULL,
        numbers TEXT,
        prize_info TEXT,
        status TEXT DEFAULT 'finished'
    );
    CREATE INDEX IF NOT EXISTS idx_draws_lottery ON draws(lottery_id, draw_date);
    """)
    conn.commit()
    conn.close()

def log(msg):
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} {msg}\n")
    print(msg)

def fetch_json(page, url):
    js = f"async () => {{ const response = await fetch('{url}'); const text = await response.text(); try {{ return JSON.parse(text); }} catch(e) {{ return null; }} }}"
    result = page.evaluate(js)
    if result is None:
        log(f"⚠️ fetch вернул не JSON для {url}")
    return result

def ensure_no_captcha(page):
    close_popups(page)
    page.wait_for_timeout(2000)
    if bypass_captcha(page, max_attempts=2):
        return True
    if page.locator("#captcha_image").count() > 0:
        page.screenshot(path=SCREENSHOT_FILE)
        log(f"📸 Капча сохранена в {SCREENSHOT_FILE}. Скачать: get lottery-bot/{SCREENSHOT_FILE}")
        print("Введите код с картинки (или 'q' для выхода):")
        code = input().strip()
        if code.lower() == 'q':
            return False
        page.fill("#captcha_input", code)
        page.click("#submit_button")
        page.wait_for_timeout(3000)
        if page.locator("#captcha_image").count() == 0:
            return True
        else:
            log("❌ Код не подошёл.")
            return False
    return True

def get_product_list(page):
    data = fetch_json(page, "https://nloto.ru/api/v2/products?types=BINGO&types=DIGITAL&types=BETTING&types=MULTIGAME&types=COMPLEX")
    products = []
    if isinstance(data, list):
        for p in data:
            products.append({
                "product_id": p["productId"],
                "name": p.get("name", str(p["productId"])),
                "url": f"https://nloto.ru/lottery/{p.get('alias', '')}" if p.get('alias') else "",
                "ticket_price": p.get("draw", {}).get("basePrice", 0)
            })
    return products

def get_draw_history(page, product_id, page_num=0, size=HISTORY_PAGE_SIZE):
    url = f"https://nloto.ru/api/v2/products/{product_id}/draws/history?page={page_num}&size={size}"
    data = fetch_json(page, url)
    draws = []
    if isinstance(data, list):
        draws = data
    elif isinstance(data, dict) and "content" in data:
        draws = data["content"]
    return draws

def save_lotteries(products):
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    for p in products:
        cur.execute(
            "INSERT OR REPLACE INTO lotteries (product_id, name, url, ticket_price, draw_schedule, active) VALUES (?,?,?,?,?,1)",
            (p["product_id"], p["name"], p["url"], p["ticket_price"], None)
        )
    conn.commit()
    conn.close()

def save_draws(product_id, draws_data):
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    added = 0
    for d in draws_data:
        draw_number = d.get("drawNum") or d.get("drawNumber") or ""
        draw_date = d.get("drawDate") or d.get("date") or ""
        combination = d.get("combination", {})
        numbers = ""
        if "main" in combination:
            numbers = ",".join(str(n) for n in combination["main"])
        prize_info = json.dumps(d.get("prize", {}), ensure_ascii=False)
        cur.execute(
            "INSERT OR IGNORE INTO draws (lottery_id, draw_number, draw_date, numbers, prize_info, status) VALUES (?,?,?,?,?,?)",
            (product_id, draw_number, draw_date, numbers, prize_info, "finished")
        )
        if cur.rowcount > 0:
            added += 1
    conn.commit()
    conn.close()
    return added

def main(max_pages=None):
    init_db()
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=STATE_FILE)
        page = context.new_page()

        page.goto("https://nloto.ru/", timeout=30000)
        if not ensure_no_captcha(page):
            log("❌ Капча не пройдена, завершение.")
            browser.close()
            return

        log("📡 Загрузка списка лотерей...")
        products = get_product_list(page)
        if not products:
            log("❌ Не удалось получить список лотерей.")
            browser.close()
            return
        log(f"Найдено лотерей: {len(products)}")
        save_lotteries(products)

        for prod in products:
            pid = prod["product_id"]
            name = prod["name"]
            log(f"🎰 {name} (ID {pid})")
            page_num = 0
            while True:
                if max_pages is not None and page_num >= max_pages:
                    break
                draws = get_draw_history(page, pid, page_num)
                if not draws:
                    break
                added = save_draws(pid, draws)
                log(f"  Стр. {page_num}: +{added} тиражей")
                page_num += 1
                time.sleep(0.5)
        browser.close()
    log("🏁 Сбор завершён.")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-pages", type=int)
    args = parser.parse_args()
    main(max_pages=args.max_pages)
