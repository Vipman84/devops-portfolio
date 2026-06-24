---
title: "Развёртывание Kubernetes (k3s) и деплой учебника"
date: 2026-06-24
tags: ["kubernetes", "k3s", "деплой"]
---

## Установка k3s
- Установлен k3s v1.31.1+k3s1 на основном сервере (4 CPU, 4 GB RAM).
- Настроен systemd-сервис для автозапуска.

## Сборка образа
- Создан Dockerfile на основе hugomods/hugo и nginx:alpine.
- При сборке возникла ошибка прав (`permission denied` на `.hugo_build.lock`).
- Решение: в стадии сборки переключиться на `USER root`, что позволило Hugo создавать lock-файл.

## Деплой в Kubernetes
- Образ импортирован в containerd.
- Созданы Deployment (2 реплики) и Service ClusterIP.
- Проверка через `wget` из временного пода подтвердила работу.
- Для внешнего доступа используется `kubectl port-forward` (в будущем — Ingress).

## Как проверить работу
```bash
kubectl run -it --rm debug --image=alpine -- sh -c "wget -qO- http://textbook-svc"
kubectl port-forward svc/textbook-svc 8080:80
