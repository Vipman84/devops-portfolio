#!/bin/bash
# DevOps Helper (dh) - Universal Linux Assistant
# Made by Vipman84

# Мультиязычность: русский или английский
if [[ "${LANG:0:2}" == "ru" ]]; then
    TITLE="DEVOPS ПОМОЩНИК"
    CHOOSE="Выберите раздел: "
    SYS_TITLE="Система"
    NET_TITLE="Сеть"
    DISK_TITLE="Память и диск"
    PROC_TITLE="Процессы"
    APT_TITLE="Пакеты (apt)"
    GIT_TITLE="Git"
    DOCKER_TITLE="Docker"
    SYSD_TITLE="Systemd"
    EXIT_TITLE="Выход"
    PRESS_ENTER="Нажмите Enter..."
    WRONG="Неверный выбор"
    GOODBYE="До свидания!"
else
    TITLE="DEVOPS HELPER"
    CHOOSE="Select section: "
    SYS_TITLE="System"
    NET_TITLE="Network"
    DISK_TITLE="Disk & Memory"
    PROC_TITLE="Processes"
    APT_TITLE="Packages (apt)"
    GIT_TITLE="Git"
    DOCKER_TITLE="Docker"
    SYSD_TITLE="Systemd"
    EXIT_TITLE="Exit"
    PRESS_ENTER="Press Enter..."
    WRONG="Wrong choice"
    GOODBYE="Goodbye!"
fi

show_menu() {
    echo "+==========================================+"
    echo "|        $TITLE            |"
    echo "+==========================================+"
    echo "|  1. $SYS_TITLE                         |"
    echo "|  2. $NET_TITLE                           |"
    echo "|  3. $DISK_TITLE                         |"
    echo "|  4. $PROC_TITLE                          |"
    echo "|  5. $APT_TITLE                            |"
    echo "|  6. $GIT_TITLE                              |"
    echo "|  7. $DOCKER_TITLE                           |"
    echo "|  8. $SYSD_TITLE                        |"
    echo "|  0. $EXIT_TITLE                                |"
    echo "+==========================================+"
}

system_info() {
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Date: $(date)"
    read -p "$PRESS_ENTER"
}

network_tools() {
    while true; do
        clear
        echo "--- $NET_TITLE ---"
        echo "1. IP addresses"
        echo "2. Ping google.com"
        echo "3. Listening ports"
        echo "4. Check remote port (nc)"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) ip -br addr ;;
            2) ping -c 4 google.com ;;
            3) ss -tlnp ;;
            4) read -p "Host: " host; read -p "Port: " port; nc -zv $host $port ;;
            0) break ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

disk_memory() {
    echo "--- Disk ---"
    df -h /
    echo ""
    echo "--- Memory ---"
    free -h
    read -p "$PRESS_ENTER"
}

process_management() {
    while true; do
        clear
        echo "--- $PROC_TITLE ---"
        echo "1. Top CPU"
        echo "2. Top MEM"
        echo "3. Search"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) ps aux --sort=-%cpu | head -10 ;;
            2) ps aux --sort=-%mem | head -10 ;;
            3) read -p "Name: " n; ps aux | grep $n ;;
            0) break ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

package_management() {
    while true; do
        clear
        echo "--- $APT_TITLE ---"
        echo "1. Update"
        echo "2. Upgrade"
        echo "3. Install"
        echo "4. Remove"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) sudo apt update ;;
            2) sudo apt upgrade -y ;;
            3) read -p "Package: " p; sudo apt install -y $p ;;
            4) read -p "Package: " p; sudo apt remove -y $p ;;
            0) break ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

git_commands() {
    while true; do
        clear
        echo "--- $GIT_TITLE ---"
        echo "1. Status"
        echo "2. Add+Commit+Push"
        echo "3. Log"
        echo "4. Pull"
        echo "5. Install Git"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) git status ;;
            2) read -p "Message: " m; git add -A; git commit -m "$m"; git push ;;
            3) git log --oneline -10 ;;
            4) git pull ;;
            5) sudo apt update && sudo apt install -y git ;;
            0) break ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

docker_commands() {
    while true; do
        clear
        echo "--- $DOCKER_TITLE ---"
        echo "1. Running containers"
        echo "2. All containers"
        echo "3. Images"
        echo "4. Start/Stop"
        echo "5. Install Docker"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) docker ps ;;
            2) docker ps -a ;;
            3) docker images ;;
            4) read -p "Container: " n; read -p "Action (start/stop): " a; docker $a $n ;;
            5) curl -fsSL https://get.docker.com | sudo sh ;;
            0) break ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

systemd_services() {
    while true; do
        clear
        echo "--- $SYSD_TITLE ---"
        echo "1. List services"
        echo "2. Status"
        echo "3. Start"
        echo "4. Stop"
        echo "5. Restart"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) systemctl list-units --type=service ;;
            2) read -p "Service: " s; systemctl status $s ;;
            3) read -p "Service: " s; sudo systemctl start $s ;;
            4) read -p "Service: " s; sudo systemctl stop $s ;;
            5) read -p "Service: " s; sudo systemctl restart $s ;;
            0) break ;;
        esac
        read -p "$PRESS_ENTER"
    done
}

while true; do
    clear
    show_menu
    read -p "$CHOOSE" section
    case $section in
        1) system_info ;;
        2) network_tools ;;
        3) disk_memory ;;
        4) process_management ;;
        5) package_management ;;
        6) git_commands ;;
        7) docker_commands ;;
        8) systemd_services ;;
        0) echo "$GOODBYE"; break ;;
        *) echo "$WRONG"; read -p "$PRESS_ENTER" ;;
    esac
done
