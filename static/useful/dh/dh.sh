#!/bin/bash

main_menu() {
    clear
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║        📋 DEVOPS ПОМОЩНИК               ║"
    echo "╠══════════════════════════════════════════╣"
    echo "║  1. Серверы и инфраструктура            ║"
    echo "║  2. Сборщик и данные                    ║"
    echo "║  3. Git и деплой                        ║"
    echo "║  4. AI и нейросети                      ║"
    echo "║  5. Система и утилиты                   ║"
    echo "║  0. Выход                               ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
}

menu_servers() {
    while true; do
        clear
        echo "--- Серверы и инфраструктура ---"
        echo "1. Показать серверы"
        echo "2. SSH-подключения"
        echo "3. Память"
        echo "4. Диск"
        echo "5. Процессы"
        echo "6. Статус k3s, Prometheus, Grafana"
        echo "0. Назад"
        read -p "Выбор: " c
        case $c in
            1) echo "Основной: 89.208.32.130:19070 devops"; echo "Боты: 45.90.218.165:22 root"; echo "VPN: 94.142.137.251:2222 admin";;
            2) echo "ssh -p 19070 devops@89.208.32.130"; echo "ssh root@45.90.218.165"; echo "ssh -p 2222 admin@94.142.137.251";;
            3) free -h;;
            4) df -h /;;
            5) ps aux --sort=-%mem | head -10;;
            6) echo "k3s: $(systemctl is-active k3s)"; echo "Prometheus: $(systemctl is-active prometheus)"; echo "Grafana: $(systemctl is-active grafana-server)";;
            0) break;;
        esac
        read -p "Нажмите Enter..."
    done
}

menu_collector() {
    while true; do
        clear
        echo "--- Сборщик и данные ---"
        echo "1. Статус сборщика"
        echo "2. Логи сборщика"
        echo "3. Перезапустить сборщик"
        echo "4. Тиражи (топ-10)"
        echo "5. Проверить капчу"
        echo "6. Проверить сайт nloto"
        echo "7. JSON-метаданные"
        echo "8. Извлечь правила"
        echo "0. Назад"
        read -p "Выбор: " c
        case $c in
            1) ps aux | grep -v grep | grep api_collector.py && echo "✅ Сборщик работает" || echo "❌ Сборщик не запущен";;
            2) tail -20 ~/lottery-bot/data/collector.log;;
            3) pkill -f api_collector.py; sleep 1; cd ~/lottery-bot; nohup python api_collector.py >> data/collector.log 2>&1 & echo "Сборщик перезапущен";;
            4) cd ~/lottery-bot && sqlite3 data/lottery.db "SELECT name, COUNT(*) FROM draws d JOIN lotteries l ON d.lottery_id=l.product_id GROUP BY d.lottery_id ORDER BY COUNT(*) DESC LIMIT 10;";;
            5) tail -5 ~/lottery-bot/data/collector.log | grep -E "Распознано|Ошибка|Капча" || echo "Нет данных о капче в последних логах";;
            6) curl -s -o /dev/null -w "%{http_code}" https://nloto.ru | grep -q 200 && echo "✅ nloto.ru доступен" || echo "❌ nloto.ru недоступен";;
            7) ls -la ~/lottery-bot/data/lottery_meta/;;
            8) cd ~/lottery-bot && source venv/bin/activate && python extract_rules.py;;
            0) break;;
        esac
        read -p "Нажмите Enter..."
    done
}

menu_git() {
    while true; do
        clear
        echo "--- Git и деплой ---"
        echo "1. Статус репозитория"
        echo "2. Быстрый пуш (add, commit, push)"
        echo "3. Лог коммитов"
        echo "4. Обновить прогнозы и деплой"
        echo "0. Назад"
        read -p "Выбор: " c
        case $c in
            1) cd ~/devops-portfolio && git status;;
            2) cd ~/devops-portfolio && git add -A && git commit -m "Быстрый коммит" && git push && echo "✅ Изменения отправлены";;
            3) cd ~/devops-portfolio && git log --oneline -10;;
            4) cd ~/lottery-bot && source venv/bin/activate && python lottery_analyzer.py; cd ~/devops-portfolio && git add -A && git commit -m "Обновлены прогнозы" && git push && echo "Прогнозы обновлены";;
            0) break;;
        esac
        read -p "Нажмите Enter..."
    done
}

menu_ai() {
    while true; do
        clear
        echo "--- AI и нейросети ---"
        echo "1. Статус Ollama"
        echo "2. Тестовый запрос к Ollama"
        echo "0. Назад"
        read -p "Выбор: " c
        case $c in
            1) systemctl is-active ollama && echo "✅ Ollama работает" || echo "❌ Ollama остановлен";;
            2) curl -s http://localhost:11434/api/generate -d '{"model":"llama3.2:3b","prompt":"Привет, как дела?","stream":false}' | python3 -c "import sys,json; print(json.load(sys.stdin)['response'])" 2>/dev/null || echo "❌ Ollama не отвечает";;
            0) break;;
        esac
        read -p "Нажмите Enter..."
    done
}

menu_system() {
    while true; do
        clear
        echo "--- Система и утилиты ---"
        echo "1. Uptime, дата, пользователь"
        echo "2. Версия ядра"
        echo "0. Назад"
        read -p "Выбор: " c
        case $c in
            1) echo "Uptime: $(uptime -p)"; echo "Дата: $(date)"; echo "Пользователь: $(whoami)";;
            2) uname -a;;
            0) break;;
        esac
        read -p "Нажмите Enter..."
    done
}

while true; do
    main_menu
    read -p "Выберите раздел: " section
    case $section in
        1) menu_servers;;
        2) menu_collector;;
        3) menu_git;;
        4) menu_ai;;
        5) menu_system;;
        0) echo "Пока!"; break;;
        *) echo "Неверный раздел"; read -p "Нажмите Enter...";;
    esac
done
