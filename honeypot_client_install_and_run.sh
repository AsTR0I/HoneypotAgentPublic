#!/bin/bash

# Вывод приветствия
echo "🚀 Добро пожаловать, я honeypot-client, начинаем установку..."

# Определение ОС и архитектуры
OS=$(uname -s)
ARCH=$(uname -m)

echo "🔍 Определена ОС: $OS"
echo "🔍 Определена архитектура: $ARCH"

# Определяем базовый URL для загрузки
BASE_URL="https://raw.githubusercontent.com/AsTR0I/HoneypotAgentPublic/refs/heads/main/builds"

# Определение пути установки
if [ "$OS" == "Linux" ]; then
    INSTALL_PATH="/opt/honeypot-agent"
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
    INSTALL_PATH="/usr/local/honeypot-agent"
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

# Скачивание архива
echo "📥 Скачиваем архив..."
curl -L -o HoneypotAgent.tar.gz "$BIN_URL" 2>&1 | tee -a install_log.txt

# Проверка скачивания
if [ $? -ne 0 ]; then
    echo "❌ Ошибка при скачивании архива."
    exit 1
fi

echo "✅ Архив успешно скачан."

# Создаём директорию установки
mkdir -p "$INSTALL_PATH"

echo "📦 Разархивируем архив..."
tar -xzvf HoneypotAgent.tar.gz -C "$INSTALL_PATH" 2>&1 | tee -a install_log.txt

# Проверка разархивирования
if [ $? -ne 0 ]; then
    echo "❌ Ошибка при разархивировании архива."
    exit 1
fi

echo "✅ Архив успешно разархивирован."

# Проверяем наличие конфига
CONFIG_PATH="$INSTALL_PATH/HoneypotAgent.json"
if [ ! -f "$CONFIG_PATH" ]; then
    echo "❌ Конфиг HoneypotAgent.json не найден. Создаём новый конфиг..."
    echo '{
  "listenports": {
    "tcp": [333,444],
    "udp": [555,666]
  },
  "trigger": {
    "url": "http://honey.cocobri.ru:8088/add-host?token=95a62fbd-76e3-46f2-b454-12d22679916f"
  }
}' > "$CONFIG_PATH"
    echo "✅ Конфиг HoneypotAgent.json был успешно создан."
else
    echo "✅ Конфиг HoneypotAgent.json уже существует."
fi

# Делаем файл исполняемым
chmod +x "$INSTALL_PATH/HoneypotAgent"
chmod -R 755 "$INSTALL_PATH"

echo "✅ Установка завершена."

# Запуск программы
if [ -f "$INSTALL_PATH/HoneypotAgent" ]; then
    echo "🚀 Запускаем HoneypotAgent..."
    "$INSTALL_PATH/HoneypotAgent" > "$INSTALL_PATH/honeypot_output.log" 2>&1 &
    HP_AGENT_PID=$!
    sleep 2
    if ! ps -p $HP_AGENT_PID > /dev/null; then
        echo "❌ Ошибка: HoneypotAgent не запустился или сразу завершился."
        cat "$INSTALL_PATH/honeypot_output.log"
        exit 1
    fi
    echo "✅ HoneypotAgent успешно запущен."
else
    echo "❌ HoneypotAgent не найден по пути $INSTALL_PATH/HoneypotAgent"
    exit 1
fi

# Добавление в cron для автозапуска
CRON_CMD="$INSTALL_PATH/HoneypotAgent &"
if ! crontab -l 2>/dev/null | grep -q "$CRON_CMD"; then
    (crontab -l 2>/dev/null; echo "@reboot $CRON_CMD") | crontab -
    echo "✅ Cron-задача добавлена для автозапуска."
else
    echo "🔄 Cron-задача уже существует."
fi

echo "Очистка временных файлов..."
rm -rf HoneypotAgent.tar.gz install_log.txt

echo "Очистка окончена, приятного использования!"

read -p "Удалить установочный скрипт? (y/N) " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -- "$0"
    echo "Скрипт удалён."
else
    echo "Скрипт сохранён."
fi
