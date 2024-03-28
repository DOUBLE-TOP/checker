#!/bin/bash

# Файл конфигурации Prometheus
CONFIG_FILE="/etc/prometheus/prometheus.yml"

# Раздел для добавления
SCRAPE_CONFIG='
  - job_name: "custom_metrics"
    scrape_interval: 30s
    static_configs:
      - targets: ["localhost:19100"]
        labels:
          job: "custom_job"
'

# Проверяем, существует ли файл
if [ -f "$CONFIG_FILE" ]; then
    # Добавляем новый scrape_config в конец файла
    echo "$SCRAPE_CONFIG" >> $CONFIG_FILE
    echo "Конфигурация добавлена в $CONFIG_FILE"
else
    echo "Файл конфигурации не найден: $CONFIG_FILE"
fi
