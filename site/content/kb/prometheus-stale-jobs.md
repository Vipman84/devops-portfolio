---
title: "Prometheus: старые job'ы не удаляются из Grafana"
date: 2026-06-24
tags: ["prometheus", "grafana", "мониторинг", "инцидент"]
---

## Проблема
После переименования `job` в конфиге Prometheus старые названия (`node`, `target-node`) продолжали отображаться в выпадающем списке дашборда Grafana, хотя в `prometheus.yml` их уже не было.

## Диагностика
API `label/job/values` показывал все когда-либо существовавшие значения метки `job`. Причина: Prometheus хранит временные ряды в `/var/lib/prometheus` до истечения срока хранения (15 дней). Даже после удаления `job_name` из конфига старые метрики остаются в базе.

## Решение
Очистка хранилища Prometheus:
```bash
sudo systemctl stop prometheus
sudo rm -rf /var/lib/prometheus/*
sudo systemctl start prometheus
