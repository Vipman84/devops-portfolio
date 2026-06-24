markdown
---
title: "Неделя 1: Linux, Bash и первый сервер"
date: 2026-06-17
---

## Цель
Настроить сервер с нуля, обеспечить безопасный доступ и написать первый скрипт автоматизации.

## 1. Аренда сервера и первый вход
- Арендован VDS с Debian 12 (4 ядра, 4 ГБ ОЗУ, порт SSH `19070`).
- Подключаемся по SSH под root:
  ```bash
  ssh -p 19070 root@<IP>
2. Настройка безопасности
Создание пользователя и запрет root-входа
bash
adduser devops
usermod -aG sudo devops
passwd devops
Редактируем /etc/ssh/sshd_config:

text
Port 19070
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
Перезапускаем SSH: systemctl restart sshd.

Настройка фаервола UFW
bash
apt update && apt install ufw -y
ufw allow 19070/tcp
ufw enable
ufw status verbose
3. Вход по SSH-ключу
На локальной машине генерируем ключ:

bash
ssh-keygen -t ed25519 -C "devops@portfolio"
ssh-copy-id -p 19070 devops@<IP>
Теперь подключаемся без пароля:

bash
ssh -p 19070 devops@<IP>
4. Первый Bash-скрипт: ротация логов
Создаём cleanup.sh в папке ~/devops-portfolio/scripts/:

bash
#!/bin/bash
LOG_DIR="${1:-$HOME/devops-portfolio/logs}"
KEEP_LINES="${2:-50}"

cd "$LOG_DIR" || { echo "Директория $LOG_DIR не найдена"; exit 1; }

for file in *.log; do
    [ -e "$file" ] || continue
    LINES=$(wc -l < "$file")
    if [ "$LINES" -gt "$KEEP_LINES" ]; then
        OLD_FILE="${file}.old"
        tail -n +"$((KEEP_LINES + 1))" "$file" > "$OLD_FILE"
        tar -czf "${file}.tar.gz" "$OLD_FILE" && rm "$OLD_FILE"
        head -n "$KEEP_LINES" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        echo "$(date): ротация $file — $((LINES - KEEP_LINES)) строк в ${file}.tar.gz"
    else
        echo "$(date): $file — строк $LINES, ротация не требуется"
    fi
done
Делаем исполняемым: chmod +x cleanup.sh.

5. Инициализация Git-репозитория
bash
git init
git config --global user.name "DevOps Student"
git config --global user.email "devops@example.com"
git add .
git commit -m "Первый коммит: структура и скрипт cleanup.sh"
Создаём репозиторий на GitHub и связываем:

bash
git remote add origin git@github.com:Vipman84/devops-portfolio.git
git push -u origin main
Итог
Сервер защищён (нестандартный порт, UFW, доступ только по ключу).

Написан полезный скрипт автоматизации.

Настроен Git и GitHub — теперь каждый шаг фиксируется в репозитории.
