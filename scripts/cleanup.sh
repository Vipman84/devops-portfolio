#!/bin/bash

# cleanup.sh - ротация логов: оставляет последние N строк и архивирует старые

LOG_DIR="${1:-$HOME/devops-portfolio/logs}"   # первый аргумент или папка по умолчанию
KEEP_LINES="${2:-50}"                         # сколько строк оставить (по умолчанию 50)

cd "$LOG_DIR" || { echo "Директория $LOG_DIR не найдена"; exit 1; }

for file in *.log; do
    # пропускаем, если файлов нет
    [ -e "$file" ] || continue

    # считаем текущее количество строк
    LINES=$(wc -l < "$file")

    if [ "$LINES" -gt "$KEEP_LINES" ]; then
        # отрезаем "хвост" из старых строк и сохраняем в архив
# Имя временного файла для старых строк
OLD_FILE="${file}.old"
# Отрезаем старые строки
tail -n +"$((KEEP_LINES + 1))" "$file" > "$OLD_FILE"
# Архивируем их
tar -czf "${file}.tar.gz" "$OLD_FILE" && rm "$OLD_FILE"
echo "$(date): ротация $file — $((LINES - KEEP_LINES)) строк перемещены в ${file}.tar.gz"
    else
        echo "$(date): $file — строк $LINES, ротация не требуется"
    fi
done
