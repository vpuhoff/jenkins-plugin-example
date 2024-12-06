#!/bin/bash

# Проверка команды
check_command() {
  if command -v "$1" &>/dev/null; then
    echo "✅ $1 установлен: $($1 --version | head -n 1)"
  else
    echo "❌ $1 не найден. Убедитесь, что он установлен."
    return 1
  fi
}

# Проверка Java
check_java() {
  echo ">>> Проверка Java..."
  if command -v java &>/dev/null; then
    java_version=$(java -version 2>&1 | grep 'version' | awk -F '"' '{print $2}')
    echo "✅ Java установлен: версия $java_version"
  else
    echo "❌ Java не найден. Проверьте установку."
    return 1
  fi

  if [[ -n "$JAVA_HOME" ]]; then
    echo "✅ JAVA_HOME настроен: $JAVA_HOME"
  else
    echo "❌ JAVA_HOME не настроен. Добавьте его в переменные среды."
    return 1
  fi
}

# Проверка Maven
check_maven() {
  echo ">>> Проверка Maven..."
  if command -v mvn &>/dev/null; then
    maven_version=$(mvn -version | grep 'Apache Maven' | awk '{print $3}')
    echo "✅ Maven установлен: версия $maven_version"
  else
    echo "❌ Maven не найден. Проверьте установку."
    return 1
  fi
}

# Проверка Docker
check_docker() {
  echo ">>> Проверка Docker..."
  if command -v docker &>/dev/null; then
    docker_version=$(docker --version | awk '{print $3}' | tr -d ',')
    echo "✅ Docker установлен: версия $docker_version"
  else
    echo "❌ Docker не найден. Проверьте установку."
    return 1
  fi

  echo ">>> Проверка Docker демона..."
  if docker info &>/dev/null; then
    echo "✅ Docker демон работает."
  else
    echo "❌ Docker демон не запущен. Запустите его: sudo systemctl start docker"
    return 1
  fi
}

# Проверка Docker Compose
check_docker_compose() {
  echo ">>> Проверка Docker Compose..."
  if command -v docker-compose &>/dev/null; then
    compose_version=$(docker-compose --version | awk '{print $3}' | tr -d ',')
    echo "✅ Docker Compose установлен: версия $compose_version"
  else
    echo "❌ Docker Compose не найден. Проверьте установку."
    return 1
  fi
}

# Проверка прав доступа к Docker
check_docker_permissions() {
  echo ">>> Проверка прав доступа к Docker..."
  if groups | grep -q docker; then
    echo "✅ Пользователь в группе docker."
  else
    echo "❌ Пользователь не в группе docker. Добавьте себя в группу: sudo usermod -aG docker $USER"
    return 1
  fi
}

# Запуск всех проверок
echo ">>> Проверка окружения..."
check_java
check_maven
check_docker
check_docker_compose
check_docker_permissions

echo ">>> Проверка завершена."
