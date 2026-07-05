#!/bin/bash
# DevOps Helper (dh) – Made by Vipman84
# Интерактивный помощник для Debian/Ubuntu

set -o pipefail

# ---------- мультиязычность ----------
if [[ "${LANG:0:2}" == "ru" ]]; then
    TITLE="DEVOPS-ПОМОЩНИК (dh)"
    CHOOSE="Выберите раздел"
    EXIT_MSG="Выход"
    BACK="Назад"
    PRESS_ENTER="Нажмите Enter для продолжения..."
    WRONG="Неверный пункт"
else
    TITLE="DEVOPS HELPER (dh)"
    CHOOSE="Select section"
    EXIT_MSG="Exit"
    BACK="Back"
    PRESS_ENTER="Press Enter to continue..."
    WRONG="Wrong choice"
fi

# ---------- главное меню ----------
main_menu() {
    clear
    echo "+========================================+"
    echo "|        $TITLE           |"
    echo "+========================================+"
    echo "|  1. Файлы и каталоги                  |"
    echo "|  2. Поиск и фильтрация                |"
    echo "|  3. Права и владельцы                 |"
    echo "|  4. Архивация и сжатие                |"
    echo "|  5. Сеть и диагностика                |"
    echo "|  6. Процессы и службы                 |"
    echo "|  7. Память / диск / загрузка          |"
    echo "|  8. Пользователи и группы             |"
    echo "|  9. SSH и удалённая работа            |"
    echo "| 10. Установка пакетов (apt)           |"
    echo "| 11. Git – шпаргалка                   |"
    echo "| 12. Docker – шпаргалка                |"
    echo "| 13. Python / pip – быстрый старт      |"
    echo "| 14. Системная информация              |"
    echo "| 15. Установить Git, Docker, Python    |"
    echo "|  h. Справка по меню                   |"
    echo "|  0. $EXIT_MSG                         |"
    echo "+========================================+"
}

# ================== 1. ФАЙЛЫ И КАТАЛОГИ (умный) ==================
section_files() {
    while true; do
        clear
        echo "--- Файлы и каталоги ---"
        echo " 1. Посмотреть содержимое папки"
        echo " 2. Поиск файлов по имени"
        echo " 3. Перейти в другую папку"
        echo " 4. Создать файл или папку"
        echo " 5. Удалить файл или папку"
        echo " 0. $BACK"
        read -p "Выберите действие: " choice
        case $choice in
            1) browse_directory ;;
            2) search_files ;;
            3) change_directory ;;
            4) create_item ;;
            5) delete_item ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

browse_directory() {
    local dir="${1:-$(pwd)}"
    clear
    echo "=== Содержимое: $dir ==="
    local i=1
    declare -A items
    while IFS= read -r item; do
        if [ -d "$dir/$item" ]; then
            echo "  [$i] 📁 $item/"
        else
            echo "  [$i] 📄 $item"
        fi
        items[$i]="$item"
        ((i++))
    done < <(ls -1A "$dir" 2>/dev/null)
    echo ""
    echo "0 – выход, .. – вверх"
    read -p "Номер: " num
    if [ "$num" = "0" ]; then
        return
    elif [ "$num" = ".." ]; then
        cd .. && browse_directory "$(pwd)"
    elif [ -n "${items[$num]}" ]; then
        local target="$dir/${items[$num]}"
        if [ -d "$target" ]; then
            cd "$target" && browse_directory "$(pwd)"
        else
            show_file_actions "$target"
        fi
    else
        echo "Неверный номер"; read -p "$PRESS_ENTER"
        browse_directory "$dir"
    fi
}

show_file_actions() {
    local file="$1"
    clear
    echo "Файл: $file"
    echo "Размер: $(stat -c%s "$file" 2>/dev/null || echo '?') байт"
    echo " 1. Просмотреть (первые 20 строк)"
    echo " 2. Редактировать (nano)"
    echo " 3. Копировать в..."
    echo " 4. Переместить в..."
    echo " 0. Назад"
    read -p "Действие: " act
    case $act in
        1) head -20 "$file"; echo "..."; read -p "$PRESS_ENTER" ;;
        2) nano "$file" ;;
        3) read -p "Куда: " d; cp -v "$file" "$d"; read -p "$PRESS_ENTER" ;;
        4) read -p "Куда: " d; mv -v "$file" "$d"; read -p "$PRESS_ENTER" ;;
    esac
}

search_files() {
    clear
    read -p "Имя или часть имени файла: " pattern
    echo "Ищем '*$pattern*' по всей системе (до 20 результатов)..."
    local results=$(find / -name "*$pattern*" -type f 2>/dev/null | head -20)
    if [ -z "$results" ]; then
        echo "Ничего не найдено."; read -p "$PRESS_ENTER"; return
    fi
    local i=1
    declare -A found
    while IFS= read -r f; do
        echo "  [$i] $f"
        found[$i]="$f"
        ((i++))
    done <<< "$results"
    read -p "Номер для просмотра (0 – отмена): " num
    if [ "$num" -gt 0 ] && [ -n "${found[$num]}" ]; then
        show_file_actions "${found[$num]}"
    fi
}

change_directory() {
    clear
    echo "Текущий каталог: $(pwd)"
    echo ""
    echo "Часто используемые:"
    echo "  /home, /var/log, /etc, /tmp, /opt"
    echo " 1. Выбрать из списка"
    echo " 2. Ввести путь вручную"
    echo " 0. Отмена"
    read -p "Выбор: " c
    case $c in
        1) read -p "Каталог: " d; [ -d "$d" ] && cd "$d" && browse_directory "$(pwd)" || echo "Не существует"; read -p "$PRESS_ENTER" ;;
        2) read -p "Путь: " p; [ -d "$p" ] && cd "$p" && browse_directory "$(pwd)" || echo "Не существует"; read -p "$PRESS_ENTER" ;;
    esac
}

create_item() {
    clear
    echo "1 – файл, 2 – каталог"
    read -p "Тип: " t
    read -p "Имя: " n
    case $t in 1) touch "$n" && echo "Файл $n создан";; 2) mkdir -p "$n" && echo "Каталог $n создан";; *) echo "Неверно";; esac
    read -p "$PRESS_ENTER"
}

delete_item() {
    clear
    read -p "Путь к файлу/папке: " target
    [ -e "$target" ] || { echo "Не найдено"; read -p "$PRESS_ENTER"; return; }
    read -p "Удалить '$target'? (да/нет): " c
    [ "$c" = "да" ] && rm -rf "$target" && echo "Удалено" || echo "Отменено"
    read -p "$PRESS_ENTER"
}

# ================== 2. ПОИСК И ФИЛЬТРАЦИЯ ==================
section_search() {
    while true; do
        clear
        echo "--- Поиск и фильтрация ---"
        echo " 1. Найти строку в файле"
        echo " 2. Найти строку в файлах каталога"
        echo " 3. Найти файлы по имени"
        echo " 4. Найти файлы, изменённые за 7 дней"
        echo " 5. Найти файлы больше 10 МБ"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) read -p "Строка: " s; read -p "Файл: " f; grep --color "$s" "$f" || echo "Не найдено"; read -p "$PRESS_ENTER" ;;
            2) read -p "Строка: " s; read -p "Каталог: " d; grep -rn "$s" "$d" || echo "Не найдено"; read -p "$PRESS_ENTER" ;;
            3) search_files ;;
            4) find / -mtime -7 2>/dev/null | head -20; read -p "$PRESS_ENTER" ;;
            5) find / -size +10M 2>/dev/null | head -20; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 3. ПРАВА ==================
section_perms() {
    while true; do
        clear
        echo "--- Права и владельцы ---"
        echo " 1. Показать права (ls -l)"
        echo " 2. Сделать исполняемым (chmod +x)"
        echo " 3. Установить права 755"
        echo " 4. Сменить владельца (chown)"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) ls -la; read -p "$PRESS_ENTER" ;;
            2) read -p "Файл: " f; chmod +x "$f" 2>/dev/null && echo "Готово" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            3) read -p "Файл/папка: " f; chmod 755 "$f" 2>/dev/null && echo "Готово" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            4) read -p "Файл/папка: " f; read -p "Владелец:группа: " o; chown "$o" "$f" 2>/dev/null && echo "Готово" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 4. АРХИВАЦИЯ ==================
section_archive() {
    while true; do
        clear
        echo "--- Архивация и сжатие ---"
        echo " 1. Создать tar.gz"
        echo " 2. Распаковать tar.gz"
        echo " 3. Создать zip"
        echo " 4. Распаковать zip"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) read -p "Имя архива.tar.gz: " a; read -p "Папка: " d; tar -czf "$a" "$d" && echo "Архив создан" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            2) read -p "Архив.tar.gz: " a; tar -xzf "$a" && echo "Распакован" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            3) read -p "Имя архива.zip: " a; read -p "Папка: " d; zip -r "$a" "$d" && echo "Архив создан" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            4) read -p "Архив.zip: " a; unzip "$a" && echo "Распакован" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 5. СЕТЬ ==================
section_network() {
    while true; do
        clear
        echo "--- Сеть и диагностика ---"
        echo " 1. Показать IP-адреса"
        echo " 2. Ping"
        echo " 3. Открытые порты"
        echo " 4. Проверить HTTP-заголовки"
        echo " 5. Трассировка (traceroute)"
        echo " 6. DNS-запрос (nslookup)"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) ip -br addr; read -p "$PRESS_ENTER" ;;
            2) read -p "Хост: " h; ping -c 4 "$h"; read -p "$PRESS_ENTER" ;;
            3) ss -tlnp; read -p "$PRESS_ENTER" ;;
            4) read -p "URL: " u; curl -I "$u" 2>/dev/null || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            5) read -p "Хост: " h; traceroute "$h" 2>/dev/null || echo "Не установлен"; read -p "$PRESS_ENTER" ;;
            6) read -p "Домен: " d; nslookup "$d" 2>/dev/null || echo "Не установлен"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 6. ПРОЦЕССЫ ==================
section_processes() {
    while true; do
        clear
        echo "--- Процессы и службы ---"
        echo " 1. Список процессов"
        echo " 2. Завершить процесс по PID"
        echo " 3. Статус службы"
        echo " 4. Перезапустить службу"
        echo " 5. Логи службы (последние 20 строк)"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) ps aux | head -20; read -p "$PRESS_ENTER" ;;
            2) read -p "PID: " p; kill "$p" 2>/dev/null && echo "Сигнал отправлен" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            3) read -p "Служба: " s; systemctl status "$s" 2>/dev/null || echo "Не найдена"; read -p "$PRESS_ENTER" ;;
            4) read -p "Служба: " s; sudo systemctl restart "$s" 2>/dev/null && echo "Перезапущена" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            5) read -p "Служба: " s; journalctl -u "$s" --no-pager -n 20 2>/dev/null || echo "Не найдена"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 7. ПАМЯТЬ / ДИСК ==================
section_resources() {
    while true; do
        clear
        echo "--- Память / диск / загрузка ---"
        echo " 1. Свободная память"
        echo " 2. Свободное место на дисках"
        echo " 3. Размер папки"
        echo " 4. Время работы"
        echo " 5. Версия ядра"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) free -h; read -p "$PRESS_ENTER" ;;
            2) df -h; read -p "$PRESS_ENTER" ;;
            3) read -p "Папка: " d; du -sh "$d" 2>/dev/null || echo "Не найдена"; read -p "$PRESS_ENTER" ;;
            4) uptime; read -p "$PRESS_ENTER" ;;
            5) uname -a; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 8. ПОЛЬЗОВАТЕЛИ ==================
section_users() {
    while true; do
        clear
        echo "--- Пользователи и группы ---"
        echo " 1. Кто я?"
        echo " 2. Мои группы"
        echo " 3. Список пользователей"
        echo " 4. Добавить пользователя"
        echo " 5. Удалить пользователя"
        echo " 6. Сменить пароль"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) whoami; read -p "$PRESS_ENTER" ;;
            2) id; read -p "$PRESS_ENTER" ;;
            3) cat /etc/passwd; read -p "$PRESS_ENTER" ;;
            4) read -p "Имя: " u; sudo useradd -m "$u" && echo "Добавлен" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            5) read -p "Имя: " u; sudo userdel "$u" && echo "Удалён" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            6) passwd; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 9. SSH ==================
section_ssh() {
    while true; do
        clear
        echo "--- SSH и удалённая работа ---"
        echo " 1. Подключиться"
        echo " 2. Создать SSH-ключ"
        echo " 3. Скопировать ключ на сервер"
        echo " 4. Передать файл (scp)"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) read -p "user@host: " conn; ssh $conn;;
            2) ssh-keygen -t ed25519; read -p "$PRESS_ENTER" ;;
            3) read -p "user@host: " conn; ssh-copy-id $conn; read -p "$PRESS_ENTER" ;;
            4) read -p "Файл: " f; read -p "user@host:путь: " dest; scp "$f" "$dest"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 10. APT ==================
section_apt() {
    while true; do
        clear
        echo "--- Установка пакетов (apt) ---"
        echo " 1. Обновить список пакетов"
        echo " 2. Обновить систему"
        echo " 3. Установить пакет"
        echo " 4. Удалить пакет"
        echo " 5. Поиск пакета"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) sudo apt update; read -p "$PRESS_ENTER" ;;
            2) sudo apt upgrade -y; read -p "$PRESS_ENTER" ;;
            3) read -p "Пакет: " p; sudo apt install -y "$p"; read -p "$PRESS_ENTER" ;;
            4) read -p "Пакет: " p; sudo apt remove -y "$p"; read -p "$PRESS_ENTER" ;;
            5) read -p "Ключевое слово: " w; apt search "$w"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 11. GIT ==================
section_git() {
    while true; do
        clear
        echo "--- Git – шпаргалка ---"
        echo " 1. Статус репозитория"
        echo " 2. Быстрый коммит и пуш"
        echo " 3. Лог коммитов"
        echo " 4. Клонировать репозиторий"
        echo " 5. Создать ветку"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) git status; read -p "$PRESS_ENTER" ;;
            2) read -p "Сообщение: " m; git add -A; git commit -m "$m"; git push; read -p "$PRESS_ENTER" ;;
            3) git log --oneline -10; read -p "$PRESS_ENTER" ;;
            4) read -p "URL: " u; git clone "$u"; read -p "$PRESS_ENTER" ;;
            5) read -p "Имя ветки: " b; git checkout -b "$b"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 12. DOCKER ==================
section_docker() {
    while true; do
        clear
        echo "--- Docker – шпаргалка ---"
        echo " 1. Запущенные контейнеры"
        echo " 2. Все контейнеры"
        echo " 3. Образы"
        echo " 4. Запустить контейнер"
        echo " 5. Остановить контейнер"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) docker ps; read -p "$PRESS_ENTER" ;;
            2) docker ps -a; read -p "$PRESS_ENTER" ;;
            3) docker images; read -p "$PRESS_ENTER" ;;
            4) read -p "Имя образа: " img; read -p "Имя контейнера: " n; docker run -d --name "$n" "$img"; read -p "$PRESS_ENTER" ;;
            5) read -p "Контейнер: " n; docker stop "$n"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 13. PYTHON ==================
section_python() {
    while true; do
        clear
        echo "--- Python / pip – быстрый старт ---"
        echo " 1. Версия Python"
        echo " 2. Список пакетов (pip)"
        echo " 3. Установить пакет"
        echo " 4. Создать виртуальное окружение"
        echo " 5. Активировать окружение"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) python3 --version 2>/dev/null || echo "Не установлен"; read -p "$PRESS_ENTER" ;;
            2) pip list 2>/dev/null || echo "pip не установлен"; read -p "$PRESS_ENTER" ;;
            3) read -p "Пакет: " p; pip install "$p" 2>/dev/null || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            4) python3 -m venv venv && echo "Окружение создано" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            5) source venv/bin/activate && echo "Активировано" || echo "Ошибка"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

# ================== 14. СИСТЕМНАЯ ИНФОРМАЦИЯ ==================
section_sysinfo() {
    clear
    echo "--- Системная информация ---"
    echo "Hostname : $(hostname)"
    echo "Kernel   : $(uname -r)"
    echo "Uptime   : $(uptime -p)"
    echo "Date     : $(date)"
    echo "Disk     : $(df -h / | tail -1 | awk '{print $5 " used"}')"
    echo "Memory   : $(free -h | awk '/Mem:/{print $3 "/" $2}')"
    read -p "$PRESS_ENTER"
}

# ================== 15. УСТАНОВКА СТЕКА ==================
section_install_stack() {
    while true; do
        clear
        echo "--- Установить Git, Docker, Python ---"
        echo " 1. Git"
        echo " 2. Docker"
        echo " 3. Python 3 + pip"
        echo " 4. Всё вместе"
        echo " 0. $BACK"
        read -p "Выбор: " c
        case $c in
            1) sudo apt update && sudo apt install -y git && echo "Готово"; read -p "$PRESS_ENTER" ;;
            2) curl -fsSL https://get.docker.com | sudo sh && echo "Готово"; read -p "$PRESS_ENTER" ;;
            3) sudo apt update && sudo apt install -y python3 python3-pip && echo "Готово"; read -p "$PRESS_ENTER" ;;
            4) sudo apt update && sudo apt install -y git python3 python3-pip; curl -fsSL https://get.docker.com | sudo sh; echo "Готово"; read -p "$PRESS_ENTER" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

show_help() {
    clear
    echo "Это интерактивный помощник по Debian/Ubuntu."
    echo "Выбирайте раздел и следуйте подсказкам."
    echo "Все команды выполняются сразу."
    read -p "$PRESS_ENTER"
}

# ---------- главный цикл ----------
while true; do
    main_menu
    read -p "$CHOOSE: " choice
    case $choice in
        1) section_files ;;
        2) section_search ;;
        3) section_perms ;;
        4) section_archive ;;
        5) section_network ;;
        6) section_processes ;;
        7) section_resources ;;
        8) section_users ;;
        9) section_ssh ;;
       10) section_apt ;;
       11) section_git ;;
       12) section_docker ;;
       13) section_python ;;
       14) section_sysinfo ;;
       15) section_install_stack ;;
       h|H) show_help ;;
        0) echo "Goodbye!"; break ;;
        *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
    esac
done
