#!/bin/bash
# DevOps Helper (dh) - интерактивный справочник с описаниями
# Made by Vipman84 | https://devops.ai-donate.ru

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
    echo "|  1. Файлы и каталоги (УМНЫЙ)          |"
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

# ================== РАЗДЕЛ «ФАЙЛЫ И КАТАЛОГИ» (с описаниями) ==================
section_files() {
    while true; do
        clear
        echo "--- Файлы и каталоги ---"
        echo " 1. Посмотреть содержимое папки — показывает файлы и подпапки, можно переходить внутрь"
        echo " 2. Поиск файлов по имени — поиск по всей системе"
        echo " 3. Перейти в другую папку — список популярных каталогов или ручной ввод"
        echo " 4. Создать файл или папку"
        echo " 5. Удалить файл или папку"
        echo " 0. Назад"
        read -p "Выберите действие: " choice
        case $choice in
            1) browse_directory ;;
            2) search_files ;;
            3) change_directory ;;
            4) create_item ;;
            5) delete_item ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
    done
}

browse_directory() {
    local dir="${1:-$(pwd)}"
    clear
    echo "=== Содержимое каталога: $dir ==="
    echo "  (📁 = папка, 📄 = файл)"
    echo ""
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
    echo "Введите номер для действия (0 - выход, '..' - вверх):"
    read -p "> " num
    
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
        echo "Неверный номер"
        read -p "Нажмите Enter..."
        browse_directory "$dir"
    fi
}

show_file_actions() {
    local file="$1"
    clear
    echo "Файл: $file"
    echo "Размер: $(stat -c%s "$file" 2>/dev/null || echo '?') байт"
    echo "Права: $(stat -c%a "$file" 2>/dev/null || echo '?')"
    echo ""
    echo " 1. Просмотреть (первые 20 строк)"
    echo " 2. Редактировать (nano)"
    echo " 3. Копировать в..."
    echo " 4. Переместить в..."
    echo " 0. Назад"
    read -p "Выберите действие: " action
    case $action in
        1) head -20 "$file"; echo "..."; read -p "Нажмите Enter..." ;;
        2) nano "$file" ;;
        3) read -p "Куда скопировать: " dest; cp -v "$file" "$dest"; read -p "Нажмите Enter..." ;;
        4) read -p "Куда переместить: " dest; mv -v "$file" "$dest"; read -p "Нажмите Enter..." ;;
    esac
}

search_files() {
    clear
    echo "--- Поиск файлов ---"
    read -p "Введите имя или часть имени файла: " pattern
    echo "Ищем файлы по шаблону '*$pattern*'..."
    echo ""
    local results=$(find / -name "*$pattern*" -type f 2>/dev/null | head -20)
    if [ -z "$results" ]; then
        echo "Ничего не найдено."
        read -p "Нажмите Enter..."
        return
    fi
    
    local i=1
    declare -A found
    while IFS= read -r file; do
        echo "  [$i] $file"
        found[$i]="$file"
        ((i++))
    done <<< "$results"
    echo ""
    read -p "Выберите номер для просмотра (0 - отмена): " num
    if [ "$num" -gt 0 ] && [ -n "${found[$num]}" ]; then
        show_file_actions "${found[$num]}"
    fi
}

change_directory() {
    clear
    echo "--- Смена каталога ---"
    echo "Текущий каталог: $(pwd)"
    echo ""
    echo "Часто используемые каталоги:"
    echo "  1. /home       - домашние папки пользователей"
    echo "  2. /var/log    - системные логи"
    echo "  3. /etc        - конфигурационные файлы"
    echo "  4. /tmp        - временные файлы"
    echo "  5. /opt        - дополнительное ПО"
    echo "  6. Ввести путь вручную"
    echo "  0. Отмена"
    read -p "Выбор: " choice
    
    case $choice in
        1) cd /home && browse_directory "$(pwd)" ;;
        2) cd /var/log && browse_directory "$(pwd)" ;;
        3) cd /etc && browse_directory "$(pwd)" ;;
        4) cd /tmp && browse_directory "$(pwd)" ;;
        5) cd /opt && browse_directory "$(pwd)" ;;
        6) read -p "Введите путь: " new_path
           if [ -d "$new_path" ]; then
               cd "$new_path" && echo "Перешли в $(pwd)"
               browse_directory "$(pwd)"
           else
               echo "Каталог не существует"
               read -p "Нажмите Enter..."
           fi ;;
    esac
}

delete_item() {
    clear
    echo "--- Удаление файла или папки ---"
    read -p "Введите путь к файлу/папке для удаления: " target
    if [ -e "$target" ]; then
        echo "Вы уверены, что хотите удалить '$target'? (да/нет)"
        read -p "> " confirm
        if [ "$confirm" = "да" ]; then
            rm -rf "$target" && echo "Удалено" || echo "Ошибка при удалении"
        else
            echo "Отменено"
        fi
    else
        echo "Файл или папка не найдены"
    fi
    read -p "Нажмите Enter..."
}

# ================== РАЗДЕЛ «ПРОЦЕССЫ И СЛУЖБЫ» (с описаниями) ==================
section_processes() {
    while true; do
        clear
        echo "--- Процессы и службы ---"
        echo " 1. Показать запущенные службы (с описанием, можно управлять)"
        echo " 2. Посмотреть логи службы"
        echo " 3. Показать все процессы"
        echo " 4. Завершить процесс"
        echo " 5. Перезапустить службу"
        echo " 0. Назад"
        read -p "Выберите действие: " proc_choice
        case $proc_choice in
            1) list_and_manage_services ;;
            2) view_service_logs ;;
            3) ps aux | head -30; read -p "Нажмите Enter..." ;;
            4) read -p "Введите PID процесса: " pid; kill "$pid" 2>/dev/null && echo "Процесс $pid завершён" || echo "Ошибка"; read -p "Нажмите Enter..." ;;
            5) read -p "Введите имя службы: " svc; sudo systemctl restart "$svc" && echo "Служба $svc перезапущена" || echo "Ошибка"; read -p "Нажмите Enter..." ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
    done
}

list_and_manage_services() {
    clear
    echo "--- Активные службы ---"
    echo ""
    # Получаем список активных служб с описанием
    local services=$(systemctl list-units --type=service --state=running --no-legend | awk '{print $1}' | head -20)
    if [ -z "$services" ]; then
        echo "Нет запущенных служб."
        read -p "Нажмите Enter..."
        return
    fi

    local i=1
    declare -A svc_list
    while IFS= read -r svc; do
        # Получаем описание службы
        local desc=$(systemctl show -p Description "$svc" 2>/dev/null | cut -d= -f2)
        echo "  [$i] $svc — ${desc:-нет описания}"
        svc_list[$i]="$svc"
        ((i++))
    done <<< "$services"
    echo ""
    echo "Доступные действия:"
    echo "  1. Остановить службу"
    echo "  2. Перезапустить службу"
    echo "  3. Показать статус"
    echo "  0. Назад"
    read -p "Выберите действие (затем номер службы): " action
    if [ "$action" = "0" ]; then
        return
    fi
    read -p "Номер службы: " num
    if [ -n "${svc_list[$num]}" ]; then
        local selected="${svc_list[$num]}"
        case $action in
            1) sudo systemctl stop "$selected" && echo "Служба $selected остановлена" || echo "Ошибка" ;;
            2) sudo systemctl restart "$selected" && echo "Служба $selected перезапущена" || echo "Ошибка" ;;
            3) systemctl status "$selected" ;;
        esac
    else
        echo "Неверный номер службы"
    fi
    read -p "Нажмите Enter..."
}

view_service_logs() {
    clear
    echo "--- Логи службы ---"
    echo "Примеры служб: nginx, ssh, docker, cron"
    read -p "Введите имя службы: " svc
    if systemctl is-active --quiet "$svc"; then
        journalctl -u "$svc" --no-pager -n 30
    else
        echo "Служба $svc не найдена или не активна"
    fi
    read -p "Нажмите Enter..."
}

# ================== РАЗДЕЛ «ПОЛЬЗОВАТЕЛИ И ГРУППЫ» (с описаниями) ==================
section_users() {
    while true; do
        clear
        echo "--- Пользователи и группы ---"
        echo " 1. Показать всех пользователей (обычные и системные)"
        echo " 2. Добавить пользователя (создать нового)"
        echo " 3. Удалить пользователя"
        echo " 4. Сменить пароль (свой или другого пользователя)"
        echo " 5. Информация о текущем пользователе"
        echo " 0. Назад"
        read -p "Выберите действие: " user_choice
        case $user_choice in
            1) list_users ;;
            2) read -p "Имя нового пользователя: " uname; sudo useradd -m "$uname" && echo "Пользователь $uname создан" || echo "Ошибка"; read -p "Нажмите Enter..." ;;
            3) list_users
               read -p "Имя пользователя для удаления: " uname
               sudo userdel "$uname" && echo "Пользователь $uname удалён" || echo "Ошибка"
               read -p "Нажмите Enter..." ;;
            4) read -p "Имя пользователя (по умолчанию текущий): " uname
               uname="${uname:-$USER}"
               sudo passwd "$uname"
               read -p "Нажмите Enter..." ;;
            5) clear
               echo "--- Информация о пользователе $USER ---"
               echo "UID: $(id -u)"
               echo "GID: $(id -g)"
               echo "Группы: $(id -Gn)"
               echo "Домашний каталог: $HOME"
               echo "Shell: $SHELL"
               read -p "Нажмите Enter..." ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
    done
}

list_users() {
    clear
    echo "--- Список пользователей ---"
    echo ""
    echo "Обычные пользователи (UID >= 1000):"
    awk -F: '$3 >= 1000 && $1 != "nobody" { printf "  %-15s UID:%-5s Домашний: %s\n", $1, $3, $6 }' /etc/passwd
    echo ""
    echo "Системные пользователи (UID < 1000):"
    awk -F: '$3 < 1000 && $1 != "root" { printf "  %-15s UID:%-5s — %s\n", $1, $3, "системный" }' /etc/passwd | head -10
    echo ""
    echo "Пояснение:"
    echo "  Обычные пользователи — это люди, которые входят в систему."
    echo "  Системные пользователи — служебные учётные записи для работы служб."
    read -p "Нажмите Enter..."
}

# ================== РАЗДЕЛ «СЕТЬ» (с описаниями) ==================
section_network() {
    while true; do
        clear
        echo "--- Сеть и диагностика ---"
        echo " 1. Показать сетевые интерфейсы (IP-адреса, состояние)"
        echo " 2. Проверить доступность хоста (ping)"
        echo " 3. Показать открытые порты (какие службы слушают)"
        echo " 4. Проверить HTTP-заголовки (curl)"
        echo " 5. Трассировка маршрута (traceroute)"
        echo " 6. DNS-запрос (nslookup)"
        echo " 0. Назад"
        read -p "Выберите действие: " net_choice
        case $net_choice in
            1) echo "--- Сетевые интерфейсы ---"
               echo "lo    — локальный интерфейс (внутренняя петля)"
               echo "eth0  — обычно проводной Ethernet"
               echo "wlan0 — обычно Wi-Fi"
               echo ""
               ip -br addr; read -p "Нажмите Enter..." ;;
            2) read -p "Введите хост (по умолчанию google.com): " host
               host="${host:-google.com}"
               ping -c 4 "$host"
               read -p "Нажмите Enter..." ;;
            3) ss -tlnp
               echo ""
               echo "Пояснение:"
               echo "LISTEN — порт слушается, ожидает подключений"
               echo "ESTAB — установлено активное соединение"
               read -p "Нажмите Enter..." ;;
            4) read -p "Введите URL (по умолчанию https://example.com): " url
               url="${url:-https://example.com}"
               curl -I "$url" 2>/dev/null || echo "Не удалось подключиться"
               read -p "Нажмите Enter..." ;;
            5) read -p "Введите хост: " host
               traceroute "$host" 2>/dev/null || echo "traceroute не установлен (apt install traceroute)"
               read -p "Нажмите Enter..." ;;
            6) read -p "Введите домен: " domain
               nslookup "$domain" 2>/dev/null || echo "nslookup не установлен (apt install dnsutils)"
               read -p "Нажмите Enter..." ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
    done
}

# ================== РАЗДЕЛ «УСТАНОВКА ПАКЕТОВ (apt)» (с описаниями) ==================
section_apt() {
    while true; do
        clear
        echo "--- Установка пакетов (apt) ---"
        echo " 1. Обновить список пакетов (apt update) — проверяет наличие новых версий"
        echo " 2. Обновить систему (apt upgrade) — устанавливает все обновления"
        echo " 3. Установить популярные пакеты — список самых востребованных"
        echo " 4. Установить свой пакет — ввести название вручную"
        echo " 5. Удалить пакет — удалить ненужную программу"
        echo " 6. Поиск пакетов — найти пакет по ключевому слову"
        echo " 0. Назад"
        read -p "Выберите действие: " apt_choice
        case $apt_choice in
            1) sudo apt update; read -p "Нажмите Enter..." ;;
            2) sudo apt upgrade -y; read -p "Нажмите Enter..." ;;
            3) install_popular_packages ;;
            4) read -p "Введите название пакета: " pkg; sudo apt install -y "$pkg"; read -p "Нажмите Enter..." ;;
            5) read -p "Введите название пакета: " pkg; sudo apt remove -y "$pkg"; read -p "Нажмите Enter..." ;;
            6) read -p "Введите ключевое слово: " keyword; apt search "$keyword" 2>/dev/null | head -20; read -p "Нажмите Enter..." ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
    done
}

install_popular_packages() {
    clear
    echo "--- Популярные пакеты ---"
    echo " 1. htop           — удобный монитор процессов (лучше, чем top)"
    echo " 2. git            — система контроля версий"
    echo " 3. curl           — утилита для HTTP-запросов и скачивания файлов"
    echo " 4. vim            — мощный текстовый редактор"
    echo " 5. build-essential — компиляторы (gcc, make) для сборки ПО"
    echo " 6. python3-pip    — менеджер пакетов для Python"
    echo " 7. nodejs         — среда выполнения JavaScript (серверная)"
    echo " 8. docker.io      — платформа для контейнеров"
    echo " 0. Назад"
    read -p "Выберите номер пакета: " pkg_choice
    case $pkg_choice in
        1) sudo apt install -y htop ;;
        2) sudo apt install -y git ;;
        3) sudo apt install -y curl ;;
        4) sudo apt install -y vim ;;
        5) sudo apt install -y build-essential ;;
        6) sudo apt install -y python3-pip ;;
        7) sudo apt install -y nodejs ;;
        8) sudo apt install -y docker.io ;;
    esac
    read -p "Нажмите Enter..."
}

# ================== ОСТАЛЬНЫЕ РАЗДЕЛЫ (без изменений) ==================
section_search() {
    while true; do
        clear
        echo "--- Поиск и фильтрация ---"
        echo " 1. grep <слово> <файл>"
        echo " 2. grep -r <слово> <папка>"
        echo " 3. find . -name ..."
        echo " 4. find . -mtime -7"
        echo " 5. find . -size +10M"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) read -p "Слово: " w; read -p "Файл: " f; grep --color "$w" "$f" ;;
            2) read -p "Слово: " w; read -p "Папка: " d; grep -rn "$w" "$d" ;;
            3) read -p "Шаблон: " n; find / -name "$n" 2>/dev/null ;;
            4) find / -mtime -7 2>/dev/null | head -20 ;;
            5) find / -size +10M 2>/dev/null | head -20 ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

section_perms() {
    while true; do
        clear
        echo "--- Права и владельцы ---"
        echo " 1. chmod +x <файл>"
        echo " 2. chmod 755 <файл>"
        echo " 3. chown user:group <ф>"
        echo " 4. ls -l"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) read -p "Файл: " f; chmod +x "$f"; ls -l "$f" ;;
            2) read -p "Файл: " f; chmod 755 "$f"; ls -l "$f" ;;
            3) read -p "Файл: " f; read -p "Владелец:группа: " o; chown "$o" "$f"; ls -l "$f" ;;
            4) ls -l ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

section_archive() {
    while true; do
        clear
        echo "--- Архивация и сжатие ---"
        echo " 1. tar -czf архив.tar.gz папка/"
        echo " 2. tar -xzf архив.tar.gz"
        echo " 3. zip -r архив.zip папка/"
        echo " 4. unzip архив.zip"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) read -p "Имя архива.tar.gz: " a; read -p "Папка: " d; tar -czf "$a" "$d" ;;
            2) read -p "Архив.tar.gz: " a; tar -xzf "$a" ;;
            3) read -p "Имя архива.zip: " a; read -p "Папка: " d; zip -r "$a" "$d" ;;
            4) read -p "Архив.zip: " a; unzip "$a" ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

section_resources() {
    while true; do
        clear
        echo "--- Память / диск / загрузка ---"
        echo " 1. free -h"
        echo " 2. df -h"
        echo " 3. du -sh <папка>"
        echo " 4. uptime"
        echo " 5. uname -a"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) free -h ;;
            2) df -h ;;
            3) read -p "Папка: " d; du -sh "$d" ;;
            4) uptime ;;
            5) uname -a ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

section_ssh() {
    while true; do
        clear
        echo "--- SSH и удалённая работа ---"
        echo " 1. ssh user@host"
        echo " 2. ssh-keygen"
        echo " 3. ssh-copy-id"
        echo " 4. scp файл user@host:"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) read -p "Строка подключения: " conn; ssh $conn ;;
            2) ssh-keygen -t ed25519 ;;
            3) read -p "Строка: " conn; ssh-copy-id $conn ;;
            4) read -p "Файл: " f; read -p "Куда: " dest; scp "$f" "$dest" ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

section_git() {
    while true; do
        clear
        echo "--- Git – шпаргалка ---"
        echo " 1. git status"
        echo " 2. git add -A && git commit -m '...' && git push"
        echo " 3. git log --oneline"
        echo " 4. git pull / git clone <url>"
        echo " 5. git branch / git checkout"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) git status ;;
            2) read -p "Сообщение: " m; git add -A; git commit -m "$m"; git push ;;
            3) git log --oneline -10 ;;
            4) read -p "pull (p) или clone (c): " act
               [[ "$act" == "c" ]] && read -p "URL: " u && git clone "$u" || git pull ;;
            5) read -p "branch / checkout / new: " act
               [[ "$act" == "new" ]] && read -p "Имя ветки: " b && git checkout -b "$b"
               [[ "$act" == "checkout" ]] && read -p "Ветка: " b && git checkout "$b"
               [[ "$act" == "branch" ]] && git branch ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

section_docker() {
    while true; do
        clear
        echo "--- Docker – шпаргалка ---"
        echo " 1. docker ps"
        echo " 2. docker images"
        echo " 3. docker run / start / stop"
        echo " 4. docker build -t имя ."
        echo " 5. docker exec -it <конт> bash"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) docker ps -a ;;
            2) docker images ;;
            3) read -p "Действие (run/start/stop): " act; read -p "Контейнер: " n; docker $act $n ;;
            4) read -p "Имя образа: " img; docker build -t "$img" . ;;
            5) read -p "Контейнер: " n; docker exec -it "$n" bash ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

section_python() {
    while true; do
        clear
        echo "--- Python / pip – быстрый старт ---"
        echo " 1. python3 --version"
        echo " 2. pip list"
        echo " 3. pip install <пакет>"
        echo " 4. python3 -m venv venv"
        echo " 5. source venv/bin/activate"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) python3 --version ;;
            2) pip list 2>/dev/null || echo "pip не установлен" ;;
            3) read -p "Пакет: " p; pip install "$p" ;;
            4) python3 -m venv venv && echo "venv создан" ;;
            5) source venv/bin/activate && echo "Окружение активировано" ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

section_sysinfo() {
    clear
    echo "--- Системная информация ---"
    echo "Hostname : $(hostname)"
    echo "Kernel   : $(uname -r)"
    echo "Uptime   : $(uptime -p)"
    echo "Date     : $(date)"
    echo "Disk     : $(df -h / | tail -1 | awk '{print $5 " used"}')"
    echo "Memory   : $(free -h | awk '/Mem:/{print $3 "/" $2}')"
    read -p "Нажмите Enter..."
}

section_install_stack() {
    while true; do
        clear
        echo "--- Установить Git, Docker, Python ---"
        echo " 1. Установить Git — система контроля версий"
        echo " 2. Установить Docker — платформа для контейнеров"
        echo " 3. Установить Python 3 + pip — язык программирования и менеджер пакетов"
        echo " 4. Установить всё вместе"
        echo " 0. Назад"
        read -p "Выберите действие: " c
        case $c in
            1) sudo apt update && sudo apt install -y git ;;
            2) curl -fsSL https://get.docker.com | sudo sh ;;
            3) sudo apt update && sudo apt install -y python3 python3-pip ;;
            4) sudo apt update && sudo apt install -y git python3 python3-pip
               curl -fsSL https://get.docker.com | sudo sh ;;
            0) break ;;
            *) echo "Неверный выбор"; read -p "Нажмите Enter..." ;;
        esac
        read -p "Нажмите Enter..."
    done
}

show_help() {
    clear
    echo "Справочник охватывает самые частые задачи:"
    echo "  файлы, поиск, права, архивы, сеть, процессы,"
    echo "  ресурсы, пользователи, SSH, apt, Git, Docker, Python."
    echo ""
    echo "Все установщики и шпаргалки уже встроены."
    echo "Чтобы предложить новую команду – пиши в проект."
    read -p "Нажмите Enter..."
}

# ---------- главный цикл ----------
while true; do
    main_menu
    read -p "Выберите раздел: " choice
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
        *) echo "Неверный раздел"; read -p "Нажмите Enter..." ;;
    esac
done
