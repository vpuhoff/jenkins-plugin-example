#!/bin/bash

# Версия Maven
MAVEN_VERSION="3.9.6"
MAVEN_DOWNLOAD_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
INSTALL_DIR="/opt/maven"

echo ">>> Скачивание Maven..."
wget -q "$MAVEN_DOWNLOAD_URL" -O /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz

echo ">>> Установка Maven..."
sudo tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-${MAVEN_VERSION} "$INSTALL_DIR"

echo ">>> Настройка переменных окружения..."
if ! grep -q "MAVEN_HOME" ~/.bashrc; then
  echo "export MAVEN_HOME=$INSTALL_DIR" >> ~/.bashrc
  echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> ~/.bashrc
fi

# Применение изменений для текущей сессии
export MAVEN_HOME=$INSTALL_DIR
export PATH="$MAVEN_HOME/bin:$PATH"

echo ">>> Удаление временных файлов..."
rm /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz

echo ">>> Проверка установки Maven..."
mvn -version

if [ $? -eq 0 ]; then
  echo "✅ Maven успешно установлен!"
else
  echo "❌ Произошла ошибка при установке Maven."
fi
