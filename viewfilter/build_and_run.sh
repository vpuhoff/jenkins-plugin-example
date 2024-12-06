#!/bin/bash

# Переменные
PLUGIN_DIR="target"
PLUGIN_NAME="viewfilter"  # Имя плагина без расширения
PLUGIN_NAME_WITH_EXTENSION="viewfilter.jpi"  # Имя плагина с расширением .jpi
JENKINS_CONTAINER="jenkins-test"
JENKINS_IMAGE="jenkins/jenkins:lts"
JENKINS_HOME="$PWD/jenkins_home"
PORT=8080

# 1. Сборка плагина\
echo ">>> Сборка плагина..."
mvn clean package  
if [ $? -ne 0 ]; then
    echo "❌ Ошибка: Сборка плагина завершилась с ошибкой."
    exit 1
fi
cp -r "$PLUGIN_DIR/$PLUGIN_NAME.hpi" "$PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION" 
echo "✅ Плагин успешно собран: $PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION"

# Проверка наличия собранного плагина
if [ ! -f "$PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION" ]; then
    echo "❌ Ошибка: Плагин не найден в $PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION"
    exit 1
fi
echo "✅ Плагин найден: $PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION"

# 2. Удаление старого контейнера Jenkins (если существует)
if docker ps -a | grep -q "$JENKINS_CONTAINER"; then
    echo ">>> Удаление старого контейнера Jenkins..."
    docker rm -f "$JENKINS_CONTAINER"
    echo "✅ Старый контейнер удален."
fi

# 3. Удаление старого плагина из директории Jenkins Home
if [ -f "$JENKINS_HOME/plugins/$PLUGIN_NAME_WITH_EXTENSION" ]; then
    echo ">>> Удаление старого плагина из $JENKINS_HOME/plugins/..."
    rm -f "$JENKINS_HOME/plugins/$PLUGIN_NAME_WITH_EXTENSION"
    echo "✅ Старый плагин удален."
fi

# 4. Создание директории для Jenkins
echo ">>> Создание Jenkins Home в $JENKINS_HOME..."
mkdir -p "$JENKINS_HOME/plugins"
echo "✅ Директория для Jenkins Home создана."

# 5. Настройка прав доступа к jenkins_home
echo ">>> Настройка прав доступа к Jenkins Home..."
CONTAINER_UID=1000
CONTAINER_GID=1000

# Меняем владельца и права для текущего пользователя
sudo chown -R $CONTAINER_UID:$CONTAINER_GID "$JENKINS_HOME"
sudo chmod -R 777 "$JENKINS_HOME"
echo "✅ Права доступа для Jenkins Home настроены."

# 6. Копирование плагина в директорию плагинов
echo ">>> Копирование плагина в Jenkins Home..."
cp -rf "$PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION" "$JENKINS_HOME/plugins/"
echo "✅ Плагин скопирован в Jenkins Home."

# 7. Запуск контейнера Jenkins
echo ">>> Запуск контейнера Jenkins..."
docker run -d --name "$JENKINS_CONTAINER" \
    -p "$PORT:8080" \
    -v "$JENKINS_HOME:/var/jenkins_home" \
    "$JENKINS_IMAGE"

if [ $? -ne 0 ]; then
    echo "❌ Ошибка: Не удалось запустить Jenkins."
    exit 1
fi
echo "✅ Jenkins запущен на http://localhost:$PORT"

# 8. Проверка статуса контейнера
echo ">>> Проверка статуса контейнера..."
if ! docker ps | grep -q "$JENKINS_CONTAINER"; then
    echo "❌ Ошибка: Контейнер не запущен."
    docker logs "$JENKINS_CONTAINER"
    exit 1
fi
echo "✅ Контейнер работает."

# 9. Вывод логов контейнера
echo ">>> Логи контейнера Jenkins..."
docker logs -f "$JENKINS_CONTAINER"
