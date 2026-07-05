#!/bin/bash
# DevOps Helper (dh) - Universal Linux Assistant
# Made by Vipman84

# Определяем язык (русский или английский)
if [[ "${LANG:0:2}" == "ru" ]]; then
    TITLE="DEVOPS ПОМОЩНИК"
    MENU_SYSTEM="1. Информация о системе"
    MENU_NET="2. Сеть"
    MENU_DISK="3. Память и диск"
    MENU_PROC="4. Процессы"
    MENU_APT="5. Пакеты (apt)"
    MENU_GIT="6. Git"
    MENU_DOCKER="7. Docker"
    MENU_SYSTEMD="8. Systemd"
    MENU_EXIT="0. Выход"
    CHOOSE="Выберите раздел: "
else
    TITLE="DEVOPS HELPER"
    MENU_SYSTEM="1. System Info"
    MENU_NET="2. Network Tools"
    MENU_DISK="3. Disk & Memory"
    MENU_PROC="4. Process Management"
    MENU_APT="5. Package Management (apt)"
    MENU_GIT="6. Git Quick Commands"
    MENU_DOCKER="7. Docker Quick Commands"
    MENU_SYSTEMD="8. Systemd Services"
    MENU_EXIT="0. Exit"
    CHOOSE="Select section: "
fi

show_menu() {
    echo "+==========================================+"
    echo "|        $TITLE            |"
    echo "+==========================================+"
    echo "|  $MENU_SYSTEM                         |"
    echo "|  $MENU_NET                           |"
    echo "|  $MENU_DISK                           |"
    echo "|  $MENU_PROC                          |"
    echo "|  $MENU_APT                            |"
    echo "|  $MENU_GIT                              |"
    echo "|  $MENU_DOCKER                           |"
    echo "|  $MENU_SYSTEMD                        |"
    echo "|  $MENU_EXIT                                |"
    echo "+==========================================+"
}

system_info() {
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "Date: $(date)"
    read -p "Press Enter..."
}

network_tools() {
    while true; do
        clear
        echo "--- Network Tools ---"
        echo "1. Show IP"
        echo "2. Ping google.com"
        echo "3. Listening ports"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) ip -br addr ;;
            2) ping -c 4 google.com ;;
            3) ss -tlnp ;;
            0) break ;;
        esac
        read -p "Press Enter..."
    done
}

disk_memory() {
    echo "--- Disk ---"
    df -h /
    echo ""
    echo "--- Memory ---"
    free -h
    read -p "Press Enter..."
}

process_management() {
    while true; do
        clear
        echo "--- Processes ---"
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
        read -p "Press Enter..."
    done
}

package_management() {
    while true; do
        clear
        echo "--- apt ---"
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
        read -p "Press Enter..."
    done
}

git_commands() {
    while true; do
        clear
        echo "--- Git ---"
        echo "1. Status"
        echo "2. Add+Commit+Push"
        echo "3. Log"
        echo "4. Pull"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) git status ;;
            2) read -p "Message: " m; git add -A; git commit -m "$m"; git push ;;
            3) git log --oneline -10 ;;
            4) git pull ;;
            0) break ;;
        esac
        read -p "Press Enter..."
    done
}

docker_commands() {
    while true; do
        clear
        echo "--- Docker ---"
        echo "1. Running containers"
        echo "2. All containers"
        echo "3. Images"
        echo "4. Start/Stop"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) docker ps ;;
            2) docker ps -a ;;
            3) docker images ;;
            4) read -p "Container: " n; read -p "Action (start/stop): " a; docker $a $n ;;
            0) break ;;
        esac
        read -p "Press Enter..."
    done
}

systemd_services() {
    while true; do
        clear
        echo "--- Systemd ---"
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
        read -p "Press Enter..."
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
        0) echo "Goodbye!"; break ;;
        *) echo "Wrong choice"; read -p "Press Enter..." ;;
    esac
done
