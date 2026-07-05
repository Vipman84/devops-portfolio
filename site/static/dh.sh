#!/bin/bash
# ===================================================================
#  DevOps Helper (dh) — интерактивный справочник команд Debian/Ubuntu
#  Made by Vipman84  |  https://devops.ai-donate.ru
# ===================================================================

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

# ================== УМНЫЙ РАЗДЕЛ «ФАЙЛЫ И КАТАЛОГИ» ==================
section_files() {
    while true; do
        clear
        echo "--- Умные файлы и каталоги ---"
        echo " 1. Рекурсивный поиск файлов"
        echo " 2. Рекурсивный поиск каталогов"
        echo " 3. Быстрый переход в каталог"
        echo " 4. Создать файл/каталог"
        echo " 0. $BACK"
        read -p "Выберите действие: " fchoice
        case $fchoice in
            1) smart_find "файл" "f" ;;
            2) smart_find "каталог" "d" ;;
            3) quick_cd ;;
            4) create_item ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
    done
}

smart_find() {
    local type="$1"
    local type_flag="$2"
    local start_dir="/"
    
    read -p "Начальный каталог (по умолчанию /): " start_dir
    start_dir="${start_dir:-/}"
    read -p "Маска имени (например, *.log): " mask
    mask="${mask:-*}"

    echo "Поиск $type в $start_dir по маске '$mask'..."
    local results
    results=$(find "$start_dir" -type "$type_flag" -name "$mask" 2>/dev/null | head -20)
    
    if [ -z "$results" ]; then
        echo "Ничего не найдено."
        read -p "$PRESS_ENTER"
        return
    fi

    local IFS=$'\n'
    local -a arr=($results)
    for i in "${!arr[@]}"; do
        printf "%3d. %s\n" $((i+1)) "${arr[$i]}"
    done

    read -p "Выберите номер (0 – отмена): " num
    if [ "$num" -gt 0 ] && [ "$num" -le "${#arr[@]}" ]; then
        local target="${arr[$((num-1))]}"
        echo "Выбран: $target"
        echo " 1. Просмотреть (cat)"
        echo " 2. Редактировать (nano)"
        echo " 3. Копировать в..."
        echo " 4. Удалить"
        echo " 5. Архивировать (tar.gz)"
        echo " 0. Отмена"
        read -p "Действие: " act
        case $act in
            1) cat "$target" | less ;;
            2) nano "$target" ;;
            3) read -p "Куда скопировать: " dest; cp -v "$target" "$dest" ;;
            4) rm -iv "$target" ;;
            5) tar -czf "${target}.tar.gz" "$target" && echo "Архив создан: ${target}.tar.gz" ;;
            0) return ;;
            *) echo "Неверное действие" ;;
        esac
    fi
    read -p "$PRESS_ENTER"
}

quick_cd() {
    read -p "Введите путь: " newdir
    if [ -d "$newdir" ]; then
        cd "$newdir" && echo "Текущий каталог: $(pwd)"
    else
        echo "Каталог не существует."
    fi
    read -p "$PRESS_ENTER"
}

create_item() {
    echo "Создать: 1 – файл, 2 – каталог"
    read -p "Выбор: " ctype
    read -p "Имя: " name
    case $ctype in
        1) touch "$name" && echo "Файл $name создан" ;;
        2) mkdir -p "$name" && echo "Каталог $name создан" ;;
        *) echo "Неверный выбор" ;;
    esac
    read -p "$PRESS_ENTER"
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
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) read -p "Слово: " w; read -p "Файл: " f; grep --color "$w" "$f" ;;
            2) read -p "Слово: " w; read -p "Папка: " d; grep -rn "$w" "$d" ;;
            3) read -p "Шаблон: " n; find / -name "$n" 2>/dev/null ;;
            4) find / -mtime -7 2>/dev/null | head -20 ;;
            5) find / -size +10M 2>/dev/null | head -20 ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) read -p "Файл: " f; chmod +x "$f"; ls -l "$f" ;;
            2) read -p "Файл: " f; chmod 755 "$f"; ls -l "$f" ;;
            3) read -p "Файл: " f; read -p "Владелец:группа: " o; chown "$o" "$f"; ls -l "$f" ;;
            4) ls -l ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) read -p "Имя архива.tar.gz: " a; read -p "Папка: " d; tar -czf "$a" "$d" ;;
            2) read -p "Архив.tar.gz: " a; tar -xzf "$a" ;;
            3) read -p "Имя архива.zip: " a; read -p "Папка: " d; zip -r "$a" "$d" ;;
            4) read -p "Архив.zip: " a; unzip "$a" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

section_network() {
    while true; do
        clear
        echo "--- Сеть и диагностика ---"
        echo " 1. ip a"
        echo " 2. ping <хост>"
        echo " 3. ss -tlnp"
        echo " 4. curl -I <url>"
        echo " 5. traceroute <хост>"
        echo " 6. nslookup <домен>"
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) ip -br addr ;;
            2) read -p "Хост: " h; ping -c 4 "$h" ;;
            3) ss -tlnp ;;
            4) read -p "URL: " u; curl -I "$u" ;;
            5) read -p "Хост: " h; traceroute "$h" 2>/dev/null || echo "traceroute не установлен" ;;
            6) read -p "Домен: " d; nslookup "$d" 2>/dev/null || echo "nslookup не установлен" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

section_processes() {
    while true; do
        clear
        echo "--- Процессы и службы ---"
        echo " 1. top -n 1"
        echo " 2. ps aux"
        echo " 3. kill <PID>"
        echo " 4. systemctl status"
        echo " 5. journalctl -u <svc>"
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) top -n 1 ;;
            2) ps aux | head -20 ;;
            3) read -p "PID: " p; kill "$p" ;;
            4) read -p "Служба: " s; systemctl status "$s" ;;
            5) read -p "Служба: " s; journalctl -u "$s" --no-pager -n 20 ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) free -h ;;
            2) df -h ;;
            3) read -p "Папка: " d; du -sh "$d" ;;
            4) uptime ;;
            5) uname -a ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

section_users() {
    while true; do
        clear
        echo "--- Пользователи и группы ---"
        echo " 1. whoami"
        echo " 2. id"
        echo " 3. cat /etc/passwd"
        echo " 4. useradd / userdel"
        echo " 5. passwd"
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) whoami ;;
            2) id ;;
            3) cat /etc/passwd ;;
            4) read -p "Добавить (a) или удалить (d): " act; read -p "Имя: " u
               [[ "$act" == "a" ]] && sudo useradd -m "$u" || sudo userdel "$u" ;;
            5) passwd ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) read -p "Строка подключения: " conn; ssh $conn ;;
            2) ssh-keygen -t ed25519 ;;
            3) read -p "Строка: " conn; ssh-copy-id $conn ;;
            4) read -p "Файл: " f; read -p "Куда: " dest; scp "$f" "$dest" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

section_apt() {
    while true; do
        clear
        echo "--- Установка пакетов (apt) ---"
        echo " 1. apt update"
        echo " 2. apt upgrade"
        echo " 3. apt install <пакет>"
        echo " 4. apt remove <пакет>"
        echo " 5. apt search <слово>"
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) sudo apt update ;;
            2) sudo apt upgrade -y ;;
            3) read -p "Пакет: " p; sudo apt install -y "$p" ;;
            4) read -p "Пакет: " p; sudo apt remove -y "$p" ;;
            5) read -p "Слово: " w; apt search "$w" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
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
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) docker ps -a ;;
            2) docker images ;;
            3) read -p "Действие (run/start/stop): " act; read -p "Контейнер: " n; docker $act $n ;;
            4) read -p "Имя образа: " img; docker build -t "$img" . ;;
            5) read -p "Контейнер: " n; docker exec -it "$n" bash ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) python3 --version ;;
            2) pip list 2>/dev/null || echo "pip не установлен" ;;
            3) read -p "Пакет: " p; pip install "$p" ;;
            4) python3 -m venv venv && echo "venv создан" ;;
            5) source venv/bin/activate && echo "Окружение активировано" ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
    read -p "$PRESS_ENTER"
}

section_install_stack() {
    while true; do
        clear
        echo "--- Установить Git, Docker, Python ---"
        echo " 1. Установить Git"
        echo " 2. Установить Docker"
        echo " 3. Установить Python 3 + pip"
        echo " 4. Установить всё вместе"
        echo " 0. $BACK"
        read -p "$CHOOSE: " c
        case $c in
            1) sudo apt update && sudo apt install -y git ;;
            2) curl -fsSL https://get.docker.com | sudo sh ;;
            3) sudo apt update && sudo apt install -y python3 python3-pip ;;
            4) sudo apt update && sudo apt install -y git python3 python3-pip
               curl -fsSL https://get.docker.com | sudo sh ;;
            0) break ;;
            *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
        esac
        read -p "$PRESS_ENTER"
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
