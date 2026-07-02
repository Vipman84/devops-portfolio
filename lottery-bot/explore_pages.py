import json, os, time
from playwright.sync_api import sync_playwright
from captcha_solver import bypass_captcha, close_popups

STATE_FILE = "data/nloto_state.json"
SCREENSHOT_FILE = "data/page_screenshot.png"
HTML_FILE = "data/page.html"
LINKS_FILE = "data/page_links.json"
API_DIR = "data/api_captures"
os.makedirs(API_DIR, exist_ok=True)

TARGET_URLS = [
    "https://nloto.ru/draw-history",               # Архив тиражей
    "https://nloto.ru/lottery/digital-8x20",       # Великолепная 8
]

captured_apis = []

def handle_response(response):
    if "application/json" in response.headers.get("content-type", "") and "/api/" in response.url:
        try:
            body = response.json()
            captured_apis.append({"url": response.url, "body": body})
            print(f"✅ Перехвачен JSON API: {response.url}")
        except:
            pass

def explore_page(page, url):
    print(f"\n🌐 Загружаю {url}")
    page.goto(url, timeout=60000)
    page.wait_for_timeout(3000)
    close_popups(page)
    bypass_captcha(page, max_attempts=1)

    # Сохраняем HTML и скриншот
    page.screenshot(path=SCREENSHOT_FILE)
    with open(HTML_FILE, "w", encoding="utf-8") as f:
        f.write(page.content())
    print(f"📄 HTML сохранён в {HTML_FILE}")

    # Собираем ссылки
    links = page.evaluate("""() => {
        return Array.from(document.querySelectorAll('a[href]'))
            .map(a => ({ text: a.innerText.trim().substring(0, 80), href: a.href }))
            .filter(l => l.href && !l.href.startsWith('javascript'));
    }""")
    with open(LINKS_FILE, "w", encoding="utf-8") as f:
        json.dump(links, f, ensure_ascii=False, indent=2)
    print(f"🔗 Найдено ссылок: {len(links)} (сохранены в {LINKS_FILE})")

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=STATE_FILE)
        page = context.new_page()
        page.on("response", handle_response)

        for url in TARGET_URLS:
            explore_page(page, url)
            time.sleep(2)

        # Сохраняем все перехваченные API-ответы
        for i, api in enumerate(captured_apis):
            safe_name = api["url"].replace("/", "_").replace(":", "_")[:100]
            fname = os.path.join(API_DIR, f"{safe_name}_{i}.json")
            with open(fname, "w", encoding="utf-8") as f:
                json.dump(api["body"], f, ensure_ascii=False, indent=2)

        print(f"\n📊 Всего перехвачено API-ответов: {len(captured_apis)}")
        if captured_apis:
            print("Сохранены в data/api_captures/")

        browser.close()

if __name__ == "__main__":
    main()
