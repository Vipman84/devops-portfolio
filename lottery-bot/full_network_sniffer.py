import json, os, time, hashlib
from playwright.sync_api import sync_playwright
from captcha_solver import bypass_captcha

STATE_FILE = "data/nloto_state.json"
OUT_DIR = "data/network_sniff"
os.makedirs(OUT_DIR, exist_ok=True)

requests_log = []
responses_log = []

def handle_request(request):
    requests_log.append({
        "url": request.url,
        "method": request.method,
        "headers": dict(request.headers),
        "post_data": request.post_data
    })

def handle_response(response):
    try:
        body = response.body()[:2000]  # первые 2000 байт
        text = body.decode('utf-8', errors='replace')
    except:
        text = "<binary>"
    
    responses_log.append({
        "url": response.url,
        "status": response.status,
        "headers": dict(response.headers),
        "body_preview": text
    })

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, slow_mo=50)
        context = browser.new_context(storage_state=STATE_FILE)
        page = context.new_page()
        
        # Подписываемся на все запросы и ответы
        page.on("request", handle_request)
        page.on("response", handle_response)

        print("🌐 Открываю https://nloto.ru/lottery/digital-8x20")
        page.goto("https://nloto.ru/lottery/digital-8x20", timeout=60000)
        
        # Обходим капчу, если есть
        bypass_captcha(page)
        
        # Ждем подгрузки тиражей
        print("⏳ Жду загрузки тиражей...")
        try:
            page.wait_for_selector("[class*='ball'],[class*='number'],.draw-numbers", timeout=20000)
            print("✅ Элементы тиражей найдены")
        except:
            print("⚠️ Таймаут ожидания элементов тиражей")
        
        # Дополнительно ждем 10 секунд на все AJAX запросы
        page.wait_for_timeout(10000)
        
        # Сохраняем HTML страницы
        html_path = os.path.join(OUT_DIR, "page.html")
        with open(html_path, "w", encoding="utf-8") as f:
            f.write(page.content())
        print(f"📄 HTML сохранен в {html_path}")
        
        # Сохраняем скриншот
        screenshot_path = os.path.join(OUT_DIR, "screenshot.png")
        page.screenshot(path=screenshot_path, full_page=True)
        print(f"📸 Скриншот сохранен в {screenshot_path}")
        
        # Сохраняем логи запросов и ответов
        log_path = os.path.join(OUT_DIR, "network_log.json")
        with open(log_path, "w", encoding="utf-8") as f:
            json.dump({
                "requests": requests_log,
                "responses": responses_log
            }, f, ensure_ascii=False, indent=2)
        print(f"📊 Лог сетевых запросов сохранен в {log_path}")
        
        # Выводим краткую сводку
        print("\n🔍 Обнаруженные запросы:")
        for req in requests_log:
            print(f"  {req['method']} {req['url']}")
        
        browser.close()
        print("\n🏁 Полный перехват завершен.")

if __name__ == "__main__":
    main()
