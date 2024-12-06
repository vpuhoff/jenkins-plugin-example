#!/bin/bash

# Проверка команды
check_command() {
  if command -v "$1" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Установка Java 17
install_java_17() {
  echo ">>> Проверка установки Java 17..."
  if check_command java; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    if [[ "$JAVA_VERSION" == 17* ]]; then
      echo "✅ Java 17 уже установлена: $JAVA_VERSION"
    else
      echo "❌ Установлена неподходящая версия Java: $JAVA_VERSION. Устанавливаю Java 17..."
      install_java
    fi
  else
    echo "❌ Java не установлена. Устанавливаю Java 17..."
    install_java
  fi
}

# Функция установки Java 17
install_java() {
  sudo apt update
  sudo apt install -y openjdk-17-jdk
  if check_command java; then
    echo "✅ Java 17 успешно установлена: $(java -version 2>&1 | head -n 1)"
  else
    echo "❌ Ошибка установки Java 17. Проверьте репозитории."
    exit 1
  fi
}

# Исправление JAVA_HOME
fix_java_home() {
  echo ">>> Настройка JAVA_HOME..."
  if check_command java; then
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    if ! grep -q "JAVA_HOME" ~/.bashrc; then
      echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
      echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc
      export JAVA_HOME
      export PATH="$JAVA_HOME/bin:$PATH"
      echo "✅ JAVA_HOME настроен: $JAVA_HOME"
    else
      echo "✅ JAVA_HOME уже настроен."
    fi
  else
    echo "❌ Java не установлена. Установите её перед продолжением."
    exit 1
  fi
}

# Исправление прав для Maven
fix_maven_permissions() {
  echo ">>> Проверка Maven..."
  if check_command mvn; then
    echo "✅ Maven уже установлен: $(mvn -version | head -n 1)"
  else
    echo "❌ Maven не найден. Устанавливаю Maven..."
    
    MAVEN_VERSION="3.9.6"
    MAVEN_DOWNLOAD_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
    INSTALL_DIR="/opt/maven"
    
    # Установка Maven
    wget -q "$MAVEN_DOWNLOAD_URL" -O /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    sudo tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt
    sudo ln -s /opt/apache-maven-${MAVEN_VERSION} "$INSTALL_DIR"
    
    # Настройка PATH
    if ! grep -q "MAVEN_HOME" ~/.bashrc; then
      echo "export MAVEN_HOME=$INSTALL_DIR" >> ~/.bashrc
      echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> ~/.bashrc
      export MAVEN_HOME=$INSTALL_DIR
      export PATH="$MAVEN_HOME/bin:$PATH"
    fi

    echo "✅ Maven установлен: $(mvn -version | head -n 1)"
  fi
}

# Установка и проверка Docker Compose
fix_docker_compose() {
  echo ">>> Проверка Docker Compose..."
  if ! check_command docker-compose; then
    echo "❌ Docker Compose не установлен. Устанавливаю..."
    DOCKER_COMPOSE_VERSION="2.20.2"
    sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose установлен: $(docker-compose --version)"
  else
    echo "✅ Docker Compose уже установлен."
  fi
}

# Проверка и добавление пользователя в группу docker
fix_docker_permissions() {
  echo ">>> Проверка прав доступа к Docker..."
  if groups | grep -q docker; then
    echo "✅ Пользователь уже в группе docker."
  else
    sudo usermod -aG docker $USER
    echo "✅ Пользователь добавлен в группу docker. Перезапустите сессию для применения изменений."
  fi
}

# Запуск исправлений
echo ">>> Запуск настройки окружения..."
install_java_17
fix_java_home
fix_maven_permissions
fix_docker_compose
fix_docker_permissions
echo ">>> Настройка завершена. Перезапустите терминал для применения изменений."
