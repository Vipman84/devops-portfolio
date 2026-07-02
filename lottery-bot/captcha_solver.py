import ddddocr, time

ocr = ddddocr.DdddOcr()

def close_popups(page):
    close_selectors = [
        "[class*='close']", "[aria-label='Close']", "button:has-text('Закрыть')",
        "svg[class*='close']", "[class*='popup'] [class*='close']",
        "div[role='button'][class*='close']"
    ]
    for sel in close_selectors:
        elements = page.locator(sel)
        if elements.count() > 0:
            try:
                elements.first.click()
                print(f"Закрыт баннер (селектор: {sel})")
                page.wait_for_timeout(1000)
                return True
            except:
                pass
    return False

def page_has_draws(page):
    try:
        count = page.evaluate("""() => {
            const elements = document.querySelectorAll('[class*="ball"], [class*="number"]');
            for (const el of elements) {
                if (el.innerText.trim().match(/^\d+$/)) return true;
            }
            return false;
        }""")
        return bool(count)
    except:
        return False

def solve_captcha(page, base_url="https://nloto.ru"):
    try:
        # Проверяем, есть ли на странице поле ввода капчи (самый надёжный признак)
        captcha_input = page.locator("#captcha_input")
        if captcha_input.count() == 0:
            # Нет поля ввода – значит, капчи нет, всё отлично
            return True

        captcha_img = page.locator("#captcha_image")
        if captcha_img.count() == 0:
            # Есть поле, но нет картинки – странно, но вернём True
            return True

        img_path = "/tmp/captcha_screenshot.png"
        captcha_img.screenshot(path=img_path)

        with open(img_path, "rb") as f:
            text = ocr.classification(f.read())

        if not text:
            return False

        print(f"Распознано: {text}")
        captcha_input.fill(text)
        page.click("#submit_button")
        page.wait_for_timeout(3000)

        # После отправки снова проверяем, исчезло ли поле капчи
        if page.locator("#captcha_input").count() == 0:
            return True
        else:
            renew_btn = page.locator("#renew_button")
            if renew_btn.count() > 0:
                renew_btn.click()
                page.wait_for_timeout(2000)
            return False
    except Exception as e:
        print(f"Ошибка: {e}")
        return False

def bypass_captcha(page, max_attempts=10):
    for _ in range(max_attempts):
        close_popups(page)
        if page_has_draws(page):
            return True
        if solve_captcha(page):
            return True
        time.sleep(0.5)
    return False
