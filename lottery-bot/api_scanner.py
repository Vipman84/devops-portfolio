import json, os
from playwright.sync_api import sync_playwright
from captcha_solver import bypass_captcha

STATE_FILE = "data/nloto_state.json"
LOTTERY_PAGE = "https://nloto.ru/lottery/ostatki"   # можно заменить на любую
OUT_DIR = "data/api_captures"
os.makedirs(OUT_DIR, exist_ok=True)

def handle_response(response):
    url = response.url
    content_type = response.headers.get("content-type", "")
    # интересуют только JSON‑ответы от API
    if "json" in content_type and "/api/" in url:
        try:
            body = response.json()
            safe_name = url.replace("/", "_").replace(":", "_").replace("?", "_")
            fname = os.path.join(OUT_DIR, f"{safe_name}.json")
            with open(fname, "w", encoding="utf-8") as f:
                json.dump(body, f, ensure_ascii=False, indent=2)
            print(f"✅ Перехвачен JSON: {url}")
            print(f"   Сохранён в {fname}")
        except Exception as e:
            print(f"⚠️ Ошибка при обработке {url}: {e}")

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, slow_mo=50)
        context = browser.new_context(storage_state=STATE_FILE)
        page = context.new_page()

        # Перехватываем все ответы
        page.on("response", handle_response)

        print(f"🌐 Загружаю {LOTTERY_PAGE}")
        page.goto(LOTTERY_PAGE, timeout=60000)
        page.wait_for_load_state("networkidle")

        # Обходим капчу, если появилась
        bypass_captcha(page)

        # Даём ещё время на подгрузку динамических данных
        print("⏳ Жду подгрузки тиражей...")
        page.wait_for_timeout(15000)

        browser.close()
        print("🏁 Сканирование завершено. Результаты в data/api_captures/")

if __name__ == "__main__":
    main()
