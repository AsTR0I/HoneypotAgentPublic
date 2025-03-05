#!/bin/bash

# Вывод приветствия
echo "🚀 Добро пожаловать, я honeypot-client, начинаем установку..."

# Определение ОС и архитектуры
OS=$(uname -s)
ARCH=$(uname -m)

echo "🔍 Определена ОС: $OS"
echo "🔍 Определена архитектура: $ARCH"

# Ссылка на архи
BASE_URL="https://raw.githubusercontent.com/AsTR0I/HoneypotAgentPublic/refs/heads/main/builds"

# Определение ссылки для скачивания в зависимости от ОС и архитектуры
if [ "$OS" == "Linux" ]; then
    case "$ARCH" in
        "x86_64" | "amd64")
            BIN_URL="${BASE_URL}/linux/amd64/HoneypotAgent.tar.gz"
            ;;
        "i386" | "i686")
            BIN_URL="${BASE_URL}/linux/386/HoneypotAgent.tar.gz"
            ;;
        *)
            echo "❌ Неизвестная архитектура для Linux: $ARCH. Скрипт завершает работу."
            exit 1
            ;;
    esac
elif [ "$OS" == "FreeBSD" ]; then
    case "$ARCH" in
        "x86_64" | "amd64")
            BIN_URL="${BASE_URL}/freebsd/amd64/HoneypotAgent.tar.gz"
            ;;
        "i386")
            BIN_URL="${BASE_URL}/freebsd/386/HoneypotAgent.tar.gz"
            ;;
        *)
            echo "❌ Неизвестная архитектура для FreeBSD: $ARCH. Скрипт завершает работу."
            exit 1
            ;;
    esac
else
    echo "❌ Поддерживаются только Linux и FreeBSD. Скрипт завершает работу."
    exit 1
fi

# Печать ссылки для скачивания
echo "🔗 Ссылка для загрузки архива: $BIN_URL"

# Скачиваем архив
echo "📥 Скачиваем архив..."
if [ "$OS" == "Linux" ]; then
    curl -L -o HoneypotAgent.tar.gz "$BIN_URL" 2>&1 | tee -a install_log.txt
elif [ "$OS" == "FreeBSD" ]; then

fi

# Проверка скачивания
if [ $? -eq 0 ]; then
    echo "✅ Архив успешно скачан."
else
    echo "❌ Ошибка при скачивании архива."
    exit 1
fi

# Разархивирование архива
echo "📦 Разархивируем архив..."

# Создаём директорию /opt/honeypot-agent, если её нет
echo "🔄 Создаём директорию /opt/honeypot-agent..."
sudo mkdir -p /opt/honeypot-agent

# Разархивируем в /opt/honeypot-agent
sudo tar -xzvf HoneypotAgent.tar.gz -C /opt/honeypot-agent 2>&1 | tee -a install_log.txt

# Проверка разархивирования
if [ $? -eq 0 ]; then
    echo "✅ Архив успешно разархивирован."
else
    echo "❌ Ошибка при разархивировании архива."
    exit 1
fi

# Проверяем, существует ли файл конфигурации HoneypotAgent.json
CONFIG_PATH="/opt/honeypot-agent/HoneypotAgent.json"
if [ ! -f "$CONFIG_PATH" ]; then
    echo "❌ Конфиг HoneypotAgent.json не найден. Создаём новый конфиг..."
    # Создаём конфиг
    echo '{
  "listenports": {
    "tcp": [333,444],
    "udp": [555,666]
  },
  "trigger": {
    "url": "http://honey.cocobri.ru:8088/add-host?token=95a62fbd-76e3-46f2-b454-12d22679916f"
  }
}' | sudo tee "$CONFIG_PATH" > /dev/null
    echo "✅ Конфиг HoneypotAgent.json был успешно создан."
else
    echo "✅ Конфиг HoneypotAgent.json уже существует."
fi

# Делаем исполняемым файл HoneypotAgent
echo "🔧 Делаем файл HoneypotAgent исполняемым..."
sudo chmod +x /opt/honeypot-agent/HoneypotAgent
sudo chmod -R 755 /opt/honeypot-agent/

# Установка выполнена
echo "✅ Установка завершена."

# Запуск программы от имени администратора
if [ -f /opt/honeypot-agent/HoneypotAgent ]; then
    echo "🚀 Запускаем HoneypotAgent..."
    
    # Запускаем в фоновом режиме и перенаправляем вывод в лог
    sudo /opt/honeypot-agent/HoneypotAgent > /opt/honeypot-agent/honeypot_output.log 2>&1 &
        # Запоминаем PID процесса
    HP_AGENT_PID=$!

    # Ждем 2 секунды, чтобы убедиться, что программа не завершилась с ошибкой
    sleep 2

    # Проверяем, жив ли процесс
    if ! ps -p $HP_AGENT_PID > /dev/null; then
        echo "❌ Ошибка: HoneypotAgent не запустился или сразу завершился."
        cat /opt/honeypot-agent/honeypot_output.log
        exit 1
    fi

    cat  /opt/honeypot-agent/honeypot_output.log

    echo "✅ HoneypotAgent успешно запущен."
else
    echo "❌ HoneypotAgent не найден по пути /opt/honeypot-agent/HoneypotAgent"
    exit 1
fi

# Добавление cron задачи для автозапуска при перезагрузке (если её ещё нет)
if ! crontab -l | grep -q "/opt/honeypot-agent/HoneypotAgent"; then
    (crontab -l ; echo "@reboot sudo /opt/honeypot-agent/HoneypotAgent &") | crontab -
    echo "✅ Cron-задача добавлена для автозапуска."
else
    echo "🔄 Cron-задача уже существует."
fi
echo "✅ Установка и запуск завершены."

echo "Очистка временных файлов..."
sudo rm -rf HoneypotAgent.tar.gz install_log.txt

echo "Очистка окончена, приятного использования!"

read -p "Удалить установочный скрипт? (y/N) " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -- "$0"
    echo "Скрипт удалён."
else
    echo "Скрипт сохранён."
fi