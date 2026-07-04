#!/bin/bash
# DevOps Helper (dh) - Made by Vipman84

show_help() {
    echo "============================================"
    echo "        DevOps Helper (dh)"
    echo "        Made by Vipman84"
    echo "============================================"
    echo " servers        - list servers"
    echo " ssh            - show SSH connections"
    echo " memory         - free memory"
    echo " disk           - free disk space"
    echo " processes      - top 10 processes"
    echo " status         - collector status"
    echo " logs           - collector logs"
    echo " restart        - restart collector"
    echo " draws          - top 10 lotteries"
    echo " captcha        - check captcha"
    echo " site           - check nloto.ru"
    echo " metadata       - JSON metadata"
    echo " rules          - extract rules"
    echo " gitstatus      - repo status"
    echo " gitpush        - quick push"
    echo " gitlog         - commit log"
    echo " forecast       - update forecasts"
    echo " ollama         - Ollama status"
    echo " aitest         - test Ollama"
    echo " system         - uptime, date, user"
    echo " help           - show this menu"
}

case "${1:-help}" in
    servers)   echo "Main: 89.208.32.130:19070 devops"; echo "Bots: 45.90.218.165:22 root"; echo "VPN: 94.142.137.251:2222 admin" ;;
    ssh)       echo "ssh -p 19070 devops@89.208.32.130"; echo "ssh root@45.90.218.165"; echo "ssh -p 2222 admin@94.142.137.251" ;;
    memory)    free -h ;;
    disk)      df -h / ;;
    processes) ps aux --sort=-%mem | head -10 ;;
    status)    ps aux | grep -v grep | grep api_collector.py && echo "Collector is running" || echo "Collector is not running" ;;
    logs)      tail -20 ~/lottery-bot/data/collector.log ;;
    restart)   pkill -f api_collector.py; sleep 1; cd ~/lottery-bot; nohup python api_collector.py >> data/collector.log 2>&1 & echo "Collector restarted" ;;
    draws)     cd ~/lottery-bot && sqlite3 data/lottery.db "SELECT name, COUNT(*) FROM draws d JOIN lotteries l ON d.lottery_id=l.product_id GROUP BY d.lottery_id ORDER BY COUNT(*) DESC LIMIT 10;" ;;
    captcha)   tail -5 ~/lottery-bot/data/collector.log | grep -E "Recognized|Error|Captcha" || echo "No captcha data in recent logs" ;;
    site)      curl -s -o /dev/null -w "%{http_code}" https://nloto.ru | grep -q 200 && echo "nloto.ru is reachable" || echo "nloto.ru is unreachable" ;;
    metadata)  ls -la ~/lottery-bot/data/lottery_meta/ ;;
    rules)     cd ~/lottery-bot && source venv/bin/activate && python extract_rules.py ;;
    gitstatus) cd ~/devops-portfolio && git status ;;
    gitpush)   cd ~/devops-portfolio && git add -A && git commit -m "Quick commit" && git push && echo "Changes pushed" ;;
    gitlog)    cd ~/devops-portfolio && git log --oneline -10 ;;
    forecast)  cd ~/lottery-bot && source venv/bin/activate && python lottery_analyzer.py; cd ~/devops-portfolio && git add -A && git commit -m "Updated forecasts" && git push && echo "Forecasts updated" ;;
    ollama)    systemctl is-active ollama && echo "Ollama is running" || echo "Ollama is stopped" ;;
    aitest)    curl -s http://localhost:11434/api/generate -d '{"model":"llama3.2:3b","prompt":"Hello, how are you?","stream":false}' | python3 -c "import sys,json; print(json.load(sys.stdin)['response'])" 2>/dev/null || echo "Ollama not responding" ;;
    system)    echo "Uptime: $(uptime -p)"; echo "Date: $(date)"; echo "User: $(whoami)"; uname -a ;;
    *)         show_help ;;
esac
