import json, os, time
from playwright.sync_api import sync_playwright
from captcha_solver import bypass_captcha

STATE_FILE = "data/nloto_state.json"
OUT_DIR = "data/api_v3"
os.makedirs(OUT_DIR, exist_ok=True)

captured = []

def handle_response(response):
    ct = response.headers.get("content-type", "")
    if "json" in ct:   # ловим вообще все JSON‑ответы
        try:
            body = response.json()
            captured.append({"url": response.url, "body": body})
            print(f"✅ JSON: {response.url}")
        except:
            pass

def main():
    global captured
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, slow_mo=50)
        context = browser.new_context(storage_state=STATE_FILE)
        page = context.new_page()
        page.on("response", handle_response)

        print("🌐 Открываю https://nloto.ru/lottery/digital-8x20")
        page.goto("https://nloto.ru/lottery/digital-8x20", timeout=60000)
        bypass_captcha(page)

        print("⏳ Жду подгрузки тиражей...")
        try:
            page.wait_for_selector("[class*='ball'],[class*='number'],.draw-numbers", timeout=15000)
        except:
            pass
        page.wait_for_timeout(10000)

        for i, item in enumerate(captured):
            fname = f"{item['url'].replace('/','_').replace(':','_').replace('?','_')[:100]}_{i}.json"
            path = os.path.join(OUT_DIR, fname)
            with open(path, "w", encoding="utf-8") as f:
                json.dump(item["body"], f, ensure_ascii=False, indent=2)

        print(f"🏁 Сохранено {len(captured)} JSON‑файлов в {OUT_DIR}/")
        browser.close()

if __name__ == "__main__":
    main()
