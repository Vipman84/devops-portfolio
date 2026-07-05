#!/bin/bash
# DevOps Helper (dh) - Universal Linux Assistant
# Made by Vipman84

show_menu() {
    echo "╔══════════════════════════════════════════╗"
    echo "║        🧰 DEVOPS HELPER (dh)            ║"
    echo "╠══════════════════════════════════════════╣"
    echo "║  1. System Info                         ║"
    echo "║  2. Network Tools                       ║"
    echo "║  3. Disk & Memory                       ║"
    echo "║  4. Process Management                  ║"
    echo "║  5. Package Management (apt)            ║"
    echo "║  6. Git Quick Commands                  ║"
    echo "║  7. Docker Quick Commands               ║"
    echo "║  8. Systemd Services                    ║"
    echo "║  0. Exit                                ║"
    echo "╚══════════════════════════════════════════╝"
}

system_info() {
    echo "--- System Information ---"
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
        echo "1. Show IP addresses"
        echo "2. Ping google.com"
        echo "3. Show listening ports"
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
        read -p "Press Enter..."
    done
}

disk_memory() {
    echo "--- Disk Usage ---"
    df -h /
    echo ""
    echo "--- Memory ---"
    free -h
    read -p "Press Enter..."
}

process_management() {
    while true; do
        clear
        echo "--- Process Management ---"
        echo "1. Top 10 by CPU"
        echo "2. Top 10 by Memory"
        echo "3. Search process"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) ps aux --sort=-%cpu | head -10 ;;
            2) ps aux --sort=-%mem | head -10 ;;
            3) read -p "Name: " name; ps aux | grep $name ;;
            0) break ;;
        esac
        read -p "Press Enter..."
    done
}

package_management() {
    while true; do
        clear
        echo "--- Package Management (apt) ---"
        echo "1. Update list"
        echo "2. Upgrade all"
        echo "3. Install package"
        echo "4. Remove package"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) sudo apt update ;;
            2) sudo apt upgrade -y ;;
            3) read -p "Package: " pkg; sudo apt install -y $pkg ;;
            4) read -p "Package: " pkg; sudo apt remove -y $pkg ;;
            0) break ;;
        esac
        read -p "Press Enter..."
    done
}

git_commands() {
    while true; do
        clear
        echo "--- Git Quick Commands ---"
        echo "1. Status"
        echo "2. Add all & commit & push"
        echo "3. Log (last 10)"
        echo "4. Pull"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) git status ;;
            2) read -p "Commit message: " msg; git add -A; git commit -m "$msg"; git push ;;
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
        echo "--- Docker Quick Commands ---"
        echo "1. List running containers"
        echo "2. List all containers"
        echo "3. List images"
        echo "4. Start/Stop container"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) docker ps ;;
            2) docker ps -a ;;
            3) docker images ;;
            4) read -p "Container name: " name; read -p "Action (start/stop): " action; docker $action $name ;;
            0) break ;;
        esac
        read -p "Press Enter..."
    done
}

systemd_services() {
    while true; do
        clear
        echo "--- Systemd Services ---"
        echo "1. List all services"
        echo "2. Status of a service"
        echo "3. Start a service"
        echo "4. Stop a service"
        echo "5. Restart a service"
        echo "0. Back"
        read -p "Choice: " c
        case $c in
            1) systemctl list-units --type=service ;;
            2) read -p "Service: " svc; systemctl status $svc ;;
            3) read -p "Service: " svc; sudo systemctl start $svc ;;
            4) read -p "Service: " svc; sudo systemctl stop $svc ;;
            5) read -p "Service: " svc; sudo systemctl restart $svc ;;
            0) break ;;
        esac
        read -p "Press Enter..."
    done
}

while true; do
    clear
    show_menu
    read -p "Select section: " section
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
