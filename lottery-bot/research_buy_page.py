#!/usr/bin/env python3
"""
Основной скрипт для исследования и автоматизации покупки билетов на nloto.ru.
Требует файл сессии data/nloto_state.json и модуль captcha_solver.py в той же папке.
"""
import os
import time
from playwright.sync_api import sync_playwright
from captcha_solver import bypass_captcha

# ─── НАСТРОЙКИ ───────────────────────────────────────────────
STATE_FILE = "data/nloto_state.json"          # путь к файлу сессии
LOTTERY_PAGE = "https://nloto.ru/lottery/ostatki"  # страница лотереи
OUTPUT_DIR = "data"
os.makedirs(OUTPUT_DIR, exist_ok=True)
# ──────────────────────────────────────────────────────────────

def main():
    with sync_playwright() as p:
        # Запускаем браузер (headless=True для фона, False для отладки)
        browser = p.chromium.launch(headless=True, slow_mo=100)
        
        # Создаём контекст с сохранённой сессией
        if os.path.exists(STATE_FILE):
            context = browser.new_context(storage_state=STATE_FILE)
            print("✅ Сессия загружена")
        else:
            context = browser.new_context()
            print("⚠️ Файл сессии не найден, запускаемся без авторизации")
        
        page = context.new_page()
        
        # 1. Переход на страницу лотереи
        print(f"🌐 Перехожу на {LOTTERY_PAGE}")
        page.goto(LOTTERY_PAGE, timeout=30000)
        page.wait_for_load_state("networkidle")
        
        # 2. Обход капчи (если она есть)
        print("🔍 Проверяю наличие капчи...")
        if not bypass_captcha(page):
            print("❌ Не удалось обойти капчу. Возможно, потребуется ручное вмешательство.")
            # Здесь можно отправить уведомление (email/telegram)
        else:
            print("✅ Капча пройдена или отсутствует")
        
        # 3. Сохраняем HTML страницы для анализа
        html_path = os.path.join(OUTPUT_DIR, "buy_page.html")
        with open(html_path, "w", encoding="utf-8") as f:
            f.write(page.content())
        print(f"📄 HTML сохранён в {html_path}")
        
        # 4. Ищем элементы для выбора чисел
        print("\n🔎 Анализ элементов страницы...")
        selectors_to_try = [
            "button.number", "div.number", "[data-number]",
            "button[class*='ball']", "div[class*='ball']",
            "button:has-text('1')", "button:has-text('2')"
        ]
        for sel in selectors_to_try:
            count = page.locator(sel).count()
            if count > 0:
                print(f"  Селектор '{sel}': найдено {count} элементов")
                # Покажем первые 3 элемента
                for i in range(min(count, 3)):
                    elem = page.locator(sel).nth(i)
                    text = elem.inner_text().strip()
                    cls = elem.get_attribute("class") or ""
                    eid = elem.get_attribute("id") or ""
                    print(f"    [{i}] текст='{text}' class='{cls}' id='{eid}'")
        
        # 5. Ищем поле поиска чисел
        print("\n🔎 Поиск поля ввода чисел...")
        search_sel = "input[type='search'], input[placeholder*='число'], input[placeholder*='поиск'], input[aria-label*='число']"
        search_count = page.locator(search_sel).count()
        if search_count > 0:
            for i in range(min(search_count, 3)):
                s = page.locator(search_sel).nth(i)
                ph = s.get_attribute("placeholder") or ""
                sid = s.get_attribute("id") or ""
                print(f"  Поле поиска {i}: id='{sid}' placeholder='{ph}'")
        else:
            print("  Поле поиска не найдено")
        
        # 6. Ищем кнопку покупки/оплаты
        print("\n🔎 Поиск кнопки покупки...")
        buy_sel = "button:has-text('Купить'), button:has-text('Оплатить'), a:has-text('Купить'), button:has-text('В корзину')"
        buy_count = page.locator(buy_sel).count()
        if buy_count > 0:
            for i in range(min(buy_count, 3)):
                b = page.locator(buy_sel).nth(i)
                text = b.inner_text().strip()
                cls = b.get_attribute("class") or ""
                bid = b.get_attribute("id") or ""
                print(f"  Кнопка {i}: текст='{text}' class='{cls}' id='{bid}'")
        else:
            print("  Кнопка покупки не найдена")
        
        # 7. Пример клика по числу (заготовка для автоматической покупки)
        # Допустим, числа представлены кнопками <button class="number">N</button>
        # number_buttons = page.locator("button.number")
        # if number_buttons.count() >= 12:
        #     for i in range(12):
        #         number_buttons.nth(i).click()
        #         time.sleep(0.5)
        #     buy_button = page.locator("button:has-text('Купить')")
        #     if buy_button.count() > 0:
        #         buy_button.first.click()
        #         print("✅ Билет добавлен в корзину")
        
        # Обновляем сессию (на случай изменений)
        context.storage_state(path=STATE_FILE)
        print(f"💾 Сессия сохранена в {STATE_FILE}")
        
        browser.close()
        print("🏁 Исследование завершено.")

if __name__ == "__main__":
    main()
