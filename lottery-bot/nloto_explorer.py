import json, os, time
from playwright.sync_api import sync_playwright
from captcha_solver import bypass_captcha, close_popups

START_URL = "https://nloto.ru/"
COOKIES_FILE = "data/nloto_cookies.json"
STATE_FILE = "data/nloto_state.json"
SCREENSHOT_FILE = "data/nloto_screenshot.png"

def is_authenticated(page):
    # Признаки, что мы уже в аккаунте
    indicators = ["Профиль", "Билеты", "Корзина", "Выйти", "Личный кабинет", "Мой профиль"]
    for text in indicators:
        if page.locator(f"text={text}").count() > 0:
            return True
    # Если есть поле ввода телефона – точно не авторизованы
    if page.locator("input[type='tel']").count() > 0:
        return False
    # Если нашли кнопку "Войти" – тоже не авторизованы
    if page.locator("text=Войти").count() > 0:
        return False
    return False  # по умолчанию считаем, что не авторизованы

def manual_input(prompt):
    return input(prompt).strip()

def manual_captcha(page):
    page.screenshot(path=SCREENSHOT_FILE)
    print(f"\n📸 Капча сохранена в {SCREENSHOT_FILE}")
    print("Введите код (или 'r' для обновления, 'q' для выхода):")
    while True:
        code = manual_input("Код: ")
        if code.lower() == 'q':
            return False
        if code.lower() == 'r':
            renew = page.locator("#renew_button")
            if renew.count() > 0:
                renew.click()
                page.wait_for_timeout(2000)
                page.screenshot(path=SCREENSHOT_FILE)
                print("Капча обновлена. Введите новый код:")
                continue
        if code:
            page.fill("#captcha_input", code)
            page.click("#submit_button")
            page.wait_for_timeout(3000)
            if page.locator("#captcha_image").count() == 0:
                return True
            else:
                print("Неверный код. Попробуйте ещё раз.")

def handle_obstacles(page):
    close_popups(page)
    if bypass_captcha(page, max_attempts=1):
        return True
    if page.locator("#captcha_image").count() > 0:
        print("⚠️ Автоматический обход не сработал, требуется ручной ввод.")
        return manual_captcha(page)
    return True

def login(page):
    phone = manual_input("Введите номер телефона (например, 79161234567): ")
    if not phone:
        return False

    # Нажимаем на иконку профиля (обычно в правом верхнем углу)
    profile_icons = page.locator("[class*='profile'], [class*='user'], [class*='avatar'], [class*='login'], [class*='auth']")
    if profile_icons.count() > 0:
        profile_icons.first.click()
        page.wait_for_timeout(2000)

    # Ищем кнопку "Войти" в появившемся меню или на странице
    login_btn = page.locator("text=Войти")
    if login_btn.count() == 0:
        login_btn = page.locator("a:has-text('Войти')")
    if login_btn.count() == 0:
        login_btn = page.locator("button:has-text('Войти')")
    if login_btn.count() == 0:
        login_btn = page.locator("a[href*='login']")
    if login_btn.count() == 0:
        login_btn = page.locator("[class*='login']")

    if login_btn.count() > 0:
        login_btn.first.click()
        page.wait_for_timeout(3000)
    else:
        page.screenshot(path=SCREENSHOT_FILE)
        print(f"📸 Скриншот перед входом сохранён. Скачать: get lottery-bot/{SCREENSHOT_FILE}")
        # Выводим только первые 30 элементов, чтобы избежать таймаута
        all_btns = page.locator("button, a").all()
        print("❌ Не удалось найти кнопку входа. Первые 30 кнопок на странице:")
        for i, btn in enumerate(all_btns[:30]):
            try:
                text = btn.inner_text().strip()[:80]
                href = btn.get_attribute("href") or ""
                print(f"  [{i}] '{text}' -> {href}")
            except:
                print(f"  [{i}] <не удалось прочитать>")
        return False

    if not handle_obstacles(page):
        return False

    phone_input = page.locator("input[type='tel']")
    if phone_input.count() == 0:
        phone_input = page.locator("input[name='phone']")
    if phone_input.count() == 0:
        phone_input = page.locator("input[placeholder*='телефон']")
    if phone_input.count() == 0:
        print("❌ Поле ввода телефона не найдено.")
        page.screenshot(path="data/login_debug.png")
        return False
    phone_input.first.fill(phone)
    print(f"📱 Введён номер {phone}")

    submit_btn = page.locator("button:has-text('Получить'), button:has-text('Далее'), button:has-text('Продолжить')")
    if submit_btn.count() == 0:
        submit_btn = page.locator("button[type='submit']")
    if submit_btn.count() > 0:
        submit_btn.first.click()
        page.wait_for_timeout(5000)
    else:
        print("❌ Кнопка отправки не найдена.")
        return False

    if not handle_obstacles(page):
        return False

    code = manual_input("Введите код из СМС: ")
    if not code:
        return False
    code_input = page.locator("input[placeholder*='код'], input[type='text']")
    if code_input.count() > 0:
        code_input.first.fill(code)
        confirm_btn = page.locator("button:has-text('Подтвердить'), button:has-text('Войти'), button[type='submit']")
        if confirm_btn.count() > 0:
            confirm_btn.first.click()
            page.wait_for_timeout(5000)
        else:
            print("❌ Кнопка подтверждения не найдена.")
            return False
    else:
        print("❌ Поле ввода кода не найдено.")
        return False

    if not handle_obstacles(page):
        return False

    return is_authenticated(page)

def explore_page(page, url):
    print(f"\n🌐 Загружаю {url}")
    page.goto(url, timeout=60000)
    page.wait_for_timeout(3000)

    if not handle_obstacles(page):
        print("❌ Не удалось пройти препятствия на странице.")
        return False

    page.screenshot(path=SCREENSHOT_FILE)
    with open("data/page.html", "w", encoding="utf-8") as f:
        f.write(page.content())
    print(f"📄 HTML сохранён в data/page.html")

    links = page.evaluate("""() => {
        return Array.from(document.querySelectorAll('a[href]'))
            .map(a => ({ text: a.innerText.trim().substring(0, 80), href: a.href }))
            .filter(l => l.href && !l.href.startsWith('javascript'));
    }""")
    print(f"\n🔗 Найдено ссылок: {len(links)}")
    for link in links:
        if any(kw in link['href'] for kw in ['draw', 'result', 'api', 'lottery', 'product', 'ticket']):
            print(f"  ⭐ {link['text']}: {link['href']}")
        else:
            print(f"  {link['text']}: {link['href']}")
    with open("data/links.json", "w", encoding="utf-8") as f:
        json.dump(links, f, ensure_ascii=False, indent=2)
    return True

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        if os.path.exists(STATE_FILE):
            context = browser.new_context(storage_state=STATE_FILE)
        elif os.path.exists(COOKIES_FILE):
            with open(COOKIES_FILE) as f:
                context.add_cookies(json.load(f))
        page = context.new_page()

        page.goto(START_URL, timeout=60000)
        if not handle_obstacles(page):
            print("Не удалось обработать главную страницу.")
            browser.close()
            return

        if not is_authenticated(page):
            print("🔐 Требуется авторизация. Запускаю вход...")
            if not login(page):
                print("❌ Не удалось войти.")
                browser.close()
                return
            context.storage_state(path=STATE_FILE)
            print(f"💾 Сессия сохранена в {STATE_FILE}")
        else:
            print("✅ Уже авторизованы!")

        explore_page(page, START_URL)

        print("\n🔍 Можно ввести другой URL для сканирования или 'exit' для выхода.")
        while True:
            cmd = manual_input(">>> ")
            if cmd.lower() == "exit":
                break
            elif cmd.startswith("http"):
                if not explore_page(page, cmd):
                    print("Не удалось обработать страницу.")
            else:
                print("Введите URL или 'exit'.")

        browser.close()

if __name__ == "__main__":
    main()
