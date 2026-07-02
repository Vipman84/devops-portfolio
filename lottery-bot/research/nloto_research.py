import sys, time, os
from playwright.sync_api import sync_playwright
from dotenv import load_dotenv

load_dotenv()

SITES = {
    "stoloto": {
        "login_url": "https://www.stoloto.ru/login",
        "csv_url": "https://www.stoloto.ru/download/results.csv",
        "buy_url": "https://www.stoloto.ru/ostatki",
        "email": os.getenv("STOLOTO_EMAIL"),
        "password": os.getenv("STOLOTO_PASSWORD"),
        "selectors": {
            "email_input": "input[name='email']",
            "password_input": "input[name='password']",
            "submit_btn": "button[type='submit']",
            "number_btn": "button.number, [data-number]",
            "search_input": "input[type='search'], input[placeholder*='число']",
            "buy_btn": "button:has-text('Купить'), a:has-text('Оплатить')"
        }
    },
    "nloto": {
        "login_url": "https://nloto.ru/login",
        "csv_url": "https://nloto.ru/export/results.csv",
        "buy_url": "https://nloto.ru/lottery/ostatki",
        "email": os.getenv("NLOTO_EMAIL"),
        "password": os.getenv("NLOTO_PASSWORD"),
        "selectors": {
            "email_input": "input[type='email']",
            "password_input": "input[type='password']",
            "submit_btn": "button[type='submit']",
            "number_btn": "div.number, button[data-ball]",
            "search_input": "input[placeholder*='Поиск числа']",
            "buy_btn": "button:has-text('Оплатить'), a:has-text('Купить')"
        }
    }
}

def main(site_name):
    cfg = SITES.get(site_name)
    if not cfg:
        print(f"Неизвестный сайт: {site_name}")
        sys.exit(1)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=100)
        page = browser.new_page()

        # Логин
        page.goto(cfg["login_url"])
        time.sleep(2)
        page.fill(cfg["selectors"]["email_input"], cfg["email"])
        page.fill(cfg["selectors"]["password_input"], cfg["password"])
        page.click(cfg["selectors"]["submit_btn"])
        time.sleep(3)

        # CSV
        print("[*] Скачивание CSV...")
        try:
            resp = page.goto(cfg["csv_url"])
            if resp and resp.ok:
                with open(f"data/{site_name}_history.csv", "wb") as f:
                    f.write(resp.body())
                print("[+] CSV сохранён")
            else:
                print(f"[!] Статус: {resp.status if resp else 'нет ответа'}")
        except Exception as e:
            print(f"[!] Ошибка CSV: {e}")

        # Страница покупки
        page.goto(cfg["buy_url"])
        time.sleep(3)
        with open(f"data/{site_name}_buy.html", "w", encoding="utf-8") as f:
            f.write(page.content())
        print(f"[+] HTML сохранён в data/{site_name}_buy.html")

        # Элементы
        print("\n--- Кнопки чисел ---")
        nums = page.locator(cfg["selectors"]["number_btn"])
        print(f"Найдено: {nums.count()}")
        for i in range(min(nums.count(), 30)):
            n = nums.nth(i)
            print(n.inner_text(), n.get_attribute("class"), n.get_attribute("id"))

        print("\n--- Поиск ---")
        search = page.locator(cfg["selectors"]["search_input"])
        print(f"Найдено: {search.count()}")
        if search.count():
            print(search.first.get_attribute("placeholder"), search.first.get_attribute("id"))

        print("\n--- Кнопка покупки ---")
        buy = page.locator(cfg["selectors"]["buy_btn"])
        print(f"Найдено: {buy.count()}")
        if buy.count():
            print(buy.first.inner_text(), buy.first.get_attribute("class"))

        time.sleep(10)
        browser.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Укажите сайт: stoloto или nloto")
        sys.exit(1)
    main(sys.argv[1])
