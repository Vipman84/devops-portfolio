import sqlite3, re, os
from playwright.sync_api import sync_playwright

HTML_FILE = "data/draws_page.html"
DB_PATH = "data/lottery.db"
LOTTERY_ID = 1

def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.executescript("""
    CREATE TABLE IF NOT EXISTS lotteries (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        url TEXT
    );
    CREATE TABLE IF NOT EXISTS draws (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lottery_id INTEGER NOT NULL REFERENCES lotteries(id),
        draw_number TEXT,
        draw_date TEXT NOT NULL,
        numbers TEXT,
        prize_info TEXT,
        status TEXT DEFAULT 'finished'
    );
    CREATE INDEX IF NOT EXISTS idx_draws_lottery ON draws(lottery_id, draw_date);
    """)
    conn.execute("INSERT OR IGNORE INTO lotteries (id, name, url) VALUES (?, ?, ?)",
                 (LOTTERY_ID, "Digital 8x20", "https://nloto.ru/lottery/digital-8x20"))
    conn.commit()
    conn.close()

def parse_draws():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto("file:///home/devops/lottery-bot/" + HTML_FILE)
        page.wait_for_timeout(2000)
        numbers = page.evaluate("""() => {
            const nums = [];
            document.querySelectorAll('[class*="ball"], [class*="number"]').forEach(el => {
                const n = parseInt(el.innerText);
                if (!isNaN(n)) nums.push(n);
            });
            return nums;
        }""")
        browser.close()
        if not numbers:
            text = page.inner_text("body")
            matches = re.findall(r'(\d{1,2}\s+){11}\d{1,2}', text)
            numbers = []
            for m in matches:
                numbers.extend([int(x) for x in m.split()])
        draws = [numbers[i:i+12] for i in range(0, len(numbers), 12)]
        return draws

def save_draws(draws):
    if not draws:
        print("❌ Тиражи не найдены в HTML.")
        return
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    added = 0
    for draw in draws:
        if len(draw) != 12:
            continue
        numbers_str = ",".join(str(n) for n in sorted(draw))
        cur.execute(
            "INSERT OR IGNORE INTO draws (lottery_id, draw_number, draw_date, numbers, status) VALUES (?, ?, datetime('now'), ?, 'finished')",
            (LOTTERY_ID, None, numbers_str)
        )
        if cur.rowcount > 0:
            added += 1
    conn.commit()
    conn.close()
    print(f"✅ Добавлено тиражей: {added}")

if __name__ == "__main__":
    init_db()
    draws = parse_draws()
    print(f"Найдено тиражей: {len(draws)}")
    save_draws(draws)
    conn = sqlite3.connect(DB_PATH)
    for row in conn.execute("SELECT draw_date, numbers FROM draws ORDER BY id DESC LIMIT 3"):
        print(f"  {row[0]}: {row[1]}")
    conn.close()
