#!/bin/bash

# Версии компонентов
JAVA_VERSION="11"
MAVEN_VERSION="3.9.5"
MAVEN_DOWNLOAD_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_INSTALL_DIR="/opt/maven"
DOCKER_COMPOSE_VERSION="1.29.2"

# Проверка команды
check_command() {
  if command -v "$1" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Установка OpenJDK
install_java() {
  echo ">>> Установка OpenJDK ${JAVA_VERSION}..."
  if check_command java; then
    echo "Java уже установлена."
  else
    apt update
    apt install -y openjdk-${JAVA_VERSION}-jdk
    echo ">>> Java установлена."
  fi
}

# Настройка JAVA_HOME
setup_java_home() {
  echo ">>> Настройка JAVA_HOME..."
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
}

# Установка Maven
install_maven() {
  echo ">>> Установка Maven ${MAVEN_VERSION}..."
  if check_command mvn; then
    echo "Maven уже установлен."
  else
    wget -q $MAVEN_DOWNLOAD_URL -O /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt
    ln -s /opt/apache-maven-${MAVEN_VERSION} $MAVEN_INSTALL_DIR
    echo "export PATH=${MAVEN_INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc
    echo ">>> Maven ${MAVEN_VERSION} установлен."
  fi
}

# Исправление прав на Maven
fix_maven_permissions() {
  echo ">>> Исправление прав доступа к Maven..."
  if check_command mvn; then
    MAVEN_BIN=$(which mvn)
    if [ -x "$MAVEN_BIN" ]; then
      echo "✅ Права на Maven уже установлены."
    else
      sudo chmod +x "$MAVEN_BIN"
      echo "✅ Права на Maven исправлены."
    fi
  fi
}

# Установка Docker
install_docker() {
  echo ">>> Установка Docker..."
  if check_command docker; then
    echo "Docker уже установлен."
  else
    apt update
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker $USER
    echo ">>> Docker установлен."
  fi
}

# Установка Docker Compose
install_docker_compose() {
  echo ">>> Установка Docker Compose ${DOCKER_COMPOSE_VERSION}..."
  if check_command docker-compose; then
    echo "Docker Compose уже установлен."
  else
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo ">>> Docker Compose установлен."
  fi
}

# Проверка установленных версий
check_versions() {
  echo ">>> Проверка установленных версий:"
  echo -n "Java: "; java -version
  echo -n "Maven: "; mvn -version
  echo -n "Docker: "; docker --version
  echo -n "Docker Compose: "; docker-compose --version
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

# Запуск всех проверок и исправлений
echo ">>> Запуск настройки и проверки окружения..."
install_java
setup_java_home
install_maven
fix_maven_permissions
install_docker
install_docker_compose
fix_docker_permissions
check_versions
echo ">>> Настройка и проверка завершены. Перезапустите терминал для применения изменений."
