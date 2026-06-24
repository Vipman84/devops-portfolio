---
title: "Хронология настройки и решённые проблемы"
date: 2026-06-24
tags: ["история"]
---

## Пройденные этапы
Linux → Bash → Git → Docker → CI/CD → Caddy/HTTPS → Prometheus + Grafana → База знаний.

## Ключевые проблемы
- Восстановление SSH (сервер 3)
- Подмена символов в VNC
- Старые job'ы в Grafana (очистка хранилища Prometheus)

## Kubernetes (k3s)
- Установлен k3s, создан systemd-сервис.
- Собран Docker-образ учебника, импортирован в containerd.
- Развёрнут Deployment и Service.
- Решена проблема прав Hugo в контейнере (переход на root).
