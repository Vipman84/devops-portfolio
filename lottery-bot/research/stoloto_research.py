import os
import time
from playwright.sync_api import sync_playwright
from dotenv import load_dotenv

load_dotenv()

EMAIL = os.getenv("STOLOTO_EMAIL")
PASSWORD = os.getenv("STOLOTO_PASSWORD")
LOGIN_URL = "https://www.stoloto.ru/login"
HISTORY_CSV = "https://www.stoloto.ru/download/results.csv"  # пример, нужен реальный URL
BUY_PAGE = "https://www.stoloto.ru/ostatki"  # страница конкретной лотереи

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=100)
        context = browser.new_context()
        page = context.new_page()

        # Логин
        page.goto(LOGIN_URL)
        time.sleep(2)
        page.fill("input[name='email']", EMAIL)
        page.fill("input[name='password']", PASSWORD)
        page.click("button[type='submit']")
        time.sleep(3)

        # CSV
        print("[*] Пробую скачать CSV...")
        try:
            response = page.goto(HISTORY_CSV)
            if response and response.ok:
                with open("data/stoloto_history.csv", "wb") as f:
                    f.write(response.body())
                print("[+] CSV сохранён")
            else:
                print(f"[!] Не удалось скачать CSV, статус: {response.status}")
        except Exception as e:
            print(f"[!] Ошибка: {e}")

        # Страница покупки
        page.goto(BUY_PAGE)
        time.sleep(3)
        with open("data/stoloto_buy.html", "w", encoding="utf-8") as f:
            f.write(page.content())
        print("[+] HTML сохранён в data/stoloto_buy.html")

        # Поиск элементов
        print("\n--- Кнопки чисел ---")
        nums = page.locator("button.number, [data-number]")
        for i in range(min(nums.count(), 40)):
            n = nums.nth(i)
            print(n.inner_text(), n.get_attribute("class"), n.get_attribute("id"))

        print("\n--- Поля ввода ---")
        search = page.locator("input[type='search'], input[placeholder*='число']")
        print(f"Найдено: {search.count()}")
        if search.count():
            print(search.first.get_attribute("id"), search.first.get_attribute("placeholder"))

        print("\n--- Кнопки действий ---")
        buy = page.locator("button:has-text('Купить'), a:has-text('Оплатить')")
        print(f"Найдено: {buy.count()}")
        if buy.count():
            print(buy.first.inner_text(), buy.first.get_attribute("class"))

        time.sleep(10)
        browser.close()

if __name__ == "__main__":
    main()
