#!/bin/bash

# Проверка команды
check_command() {
  if command -v "$1" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Исправление JAVA_HOME
fix_java_home() {
  echo ">>> Исправление JAVA_HOME..."
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
  echo ">>> Исправление прав доступа к Maven..."
  
  # Проверяем, установлен ли Maven
  if check_command mvn; then
    MAVEN_BIN=$(which mvn)
    if [ -x "$MAVEN_BIN" ]; then
      echo "✅ Права на Maven уже установлены."
    else
      sudo chmod +x "$MAVEN_BIN"
      echo "✅ Права на Maven исправлены."
    fi
  else
    echo "❌ Maven не найден. Устанавливаю Maven..."
    
    # Устанавливаем Maven вручную
    MAVEN_VERSION="3.9.5"
    MAVEN_DOWNLOAD_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
    INSTALL_DIR="/opt/maven"
    
    # Скачиваем и устанавливаем Maven
    wget -q "$MAVEN_DOWNLOAD_URL" -O /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    sudo tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt
    sudo ln -s /opt/apache-maven-${MAVEN_VERSION} "$INSTALL_DIR"
    
    # Добавляем Maven в PATH
    if ! grep -q "MAVEN_HOME" ~/.bashrc; then
      echo "export MAVEN_HOME=$INSTALL_DIR" >> ~/.bashrc
      echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> ~/.bashrc
      export MAVEN_HOME=$INSTALL_DIR
      export PATH="$MAVEN_HOME/bin:$PATH"
    fi

    echo "✅ Maven установлен: $(mvn -version | head -n 1)"
  fi
}


# Переустановка Docker Compose
fix_docker_compose() {
  echo ">>> Проверка Docker Compose..."
  if ! check_command docker-compose; then
    echo "❌ Docker Compose не установлен. Устанавливаю..."
    DOCKER_COMPOSE_VERSION="1.29.2"
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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
echo ">>> Запуск исправления окружения..."
fix_java_home
fix_maven_permissions
fix_docker_compose
fix_docker_permissions
echo ">>> Исправления завершены. Перезапустите терминал для применения изменений."
