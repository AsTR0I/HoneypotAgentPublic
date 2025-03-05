
# HoneypotAgent

## Описание

**HoneypotAgent** – это агент для мониторинга сетевой активности, который прослушивает заданные TCP и UDP порты и отправляет уведомления о входящих соединениях на API.

## Функциональность

- Читает конфигурацию из JSON-файла `HoneypotAgent.json`.
- Прослушивает указанные в конфигурации TCP и UDP порты.
- Фиксирует входящие соединения и отправляет HTTP-запрос на сервер триггеров.
- Ведёт логирование событий в файл `logs/honeypot_agent.log`.
- Автоматически удаляет старые логи (старше 7 дней).

## Формат конфигурации (JSON)

```json
{
  "listenports": {
    "tcp": [80, 443],
    "udp": [53, 161]
  },
  "trigger": {
    "url": "http://example.com/trigger"
  }
}
```

- **listenports.tcp** – список TCP-портов для прослушивания.
- **listenports.udp** – список UDP-портов для прослушивания.
- **trigger.url** – API, куда отправляются уведомления о входящих соединениях.

## Логирование

- Логи записываются в `honeypot_agent.log`.
- Формат записи: `YYYY-MM-DD HH:MM:SS - Сообщение`.
- Если лог-файл отсутствует, он создаётся автоматически.
- Логи старше 7 дней удаляются автоматически.

## Установка (для Unix систем)

1. Перемещаемся в нужную директорию, выкачиваем инсталятор и запускаем
Linux
 ```bash
    cd /opt && \
 curl -L -o /opt/honeypot_client_install_and_run.sh https://raw.githubusercontent.com/AsTR0I/HoneypotAgentPublic/main/honeypot_client_install_and_run.sh && \
 chmod +x /opt/honeypot_client_install_and_run.sh && \
 sh /opt/honeypot_client_install_and_run.sh
   ```

BSD
```bash
    cd /opt && \
fetch -o /opt/honeypot_client_install_and_run.sh https://raw.githubusercontent.com/AsTR0I/HoneypotAgentPublic/main/honeypot_client_install_and_run.sh && \
chmod +x /opt/honeypot_client_install_and_run.sh && \
sh /opt/honeypot_client_install_and_run.sh
   ```
