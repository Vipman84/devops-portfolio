import os, time, io
import requests
from PIL import Image
from playwright.sync_api import sync_playwright

STATE_FILE = "data/nloto_state.json"
DEBUG_DIR = "data/captcha_debug"
os.makedirs(DEBUG_DIR, exist_ok=True)

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, slow_mo=50)
        context = browser.new_context(storage_state=STATE_FILE)
        page = context.new_page()

        # 1. Открываем страницу
        page.goto("https://nloto.ru/lottery/digital-8x20", timeout=30000)
        page.wait_for_timeout(2000)
        page.screenshot(path=os.path.join(DEBUG_DIR, "01_page_loaded.png"))
        print("📸 Скриншот 01 – страница загружена")

        # 2. Проверяем наличие капчи
        captcha_img = page.locator("#captcha_image")
        if captcha_img.count() == 0:
            print("✅ Капчи нет, тиражи должны быть видны")
            page.screenshot(path=os.path.join(DEBUG_DIR, "02_no_captcha.png"))
            browser.close()
            return

        print("🔐 Капча обнаружена. Пытаюсь решить...")

        # 3. Сохраняем изображение капчи
        img_src = captcha_img.get_attribute("src")
        if img_src and img_src.startswith("captcha_image.php"):
            img_src = "https://nloto.ru/" + img_src
        print(f"URL капчи: {img_src}")
        response = requests.get(img_src, timeout=15)
        img_path = os.path.join(DEBUG_DIR, "captcha_image.png")
        with open(img_path, "wb") as f:
            f.write(response.content)
        print(f"🖼️ Изображение капчи сохранено в {img_path}")

        # 4. Пробуем решить капчу (используем функцию из captcha_solver, но с логированием)
        from captcha_solver import solve_captcha
        success = solve_captcha(page)
        page.screenshot(path=os.path.join(DEBUG_DIR, "03_after_captcha_attempt.png"))
        print(f"📸 Скриншот 03 – после попытки решения (успех: {success})")

        # 5. Проверяем, исчезла ли капча
        if page.locator("#captcha_image").count() == 0:
            print("✅ Капча пройдена!")
        else:
            print("❌ Капча не пройдена")

        # 6. Ищем тиражи
        page.wait_for_timeout(3000)
        html = page.content()
        with open(os.path.join(DEBUG_DIR, "page.html"), "w", encoding="utf-8") as f:
            f.write(html)
        print("📄 HTML сохранён")

        # Проверяем наличие чисел в HTML
        import re
        numbers_found = re.findall(r'\b\d{1,2}\b', html)
        print(f"🔢 Найдено чисел в HTML: {len(numbers_found)} (первые 30: {numbers_found[:30]})")

        browser.close()

if __name__ == "__main__":
    main()
