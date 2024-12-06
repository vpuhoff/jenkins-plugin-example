#!/bin/bash

# Configuration
JAVA_VERSION="17"
MAVEN_VERSION="3.9.6"
MAVEN_DOWNLOAD_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_INSTALL_DIR="/opt/maven"
DOCKER_COMPOSE_VERSION="2.20.2"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_info() {
    echo -e ">>> $1"
}

# Check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run this script as root (with sudo)"
        exit 1
    fi
}

# Check if a command exists
check_command() {
    if command -v "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Java Management
check_java() {
    log_info "Checking Java installation..."
    if check_command java; then
        java_version=$(java -version 2>&1 | grep 'version' | awk -F '"' '{print $2}')
        if [[ "$java_version" == ${JAVA_VERSION}* ]]; then
            log_success "Java ${JAVA_VERSION} is installed: $java_version"
            return 0
        else
            log_warning "Found Java $java_version, but version ${JAVA_VERSION} is required"
            return 1
        fi
    else
        log_error "Java is not installed"
        return 1
    fi
}

install_java() {
    log_info "Installing Java ${JAVA_VERSION}..."
    apt update
    apt install -y openjdk-${JAVA_VERSION}-jdk
    if check_java; then
        log_success "Java ${JAVA_VERSION} installed successfully"
    else
        log_error "Failed to install Java ${JAVA_VERSION}"
        exit 1
    fi
}

setup_java_home() {
    log_info "Setting up JAVA_HOME..."
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    if ! grep -q "JAVA_HOME" /etc/environment; then
        echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment
        export JAVA_HOME
        log_success "JAVA_HOME configured: $JAVA_HOME"
    else
        log_success "JAVA_HOME already configured"
    fi
}

# Maven Management
check_maven() {
    log_info "Checking Maven installation..."
    # First check PATH
    if command -v mvn &>/dev/null; then
        maven_version=$(mvn -version | grep 'Apache Maven' | awk '{print $3}')
        log_success "Maven is installed: version $maven_version"
        return 0
    fi

    # Check common Maven installation locations
    local maven_locations=(
        "/opt/maven/bin/mvn"
        "/usr/local/bin/mvn"
        "$HOME/apache-maven/bin/mvn"
    )

    for location in "${maven_locations[@]}"; do
        if [ -x "$location" ]; then
            log_success "Maven found at $location"
            # Add Maven to PATH for current session
            export PATH="$(dirname $location):$PATH"
            return 0
        fi
    done

    log_error "Maven is not installed"
    return 1
}

install_maven() {
    log_info "Installing Maven ${MAVEN_VERSION}..."
    if check_command mvn; then
        log_success "Maven already installed"
        return 0
    fi

    wget -q "$MAVEN_DOWNLOAD_URL" -O /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt
    ln -sf /opt/apache-maven-${MAVEN_VERSION} $MAVEN_INSTALL_DIR
    
    # Create and update environment file
    echo "export MAVEN_HOME=$MAVEN_INSTALL_DIR" > /etc/profile.d/maven.sh
    echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> /etc/profile.d/maven.sh
    chmod +x /etc/profile.d/maven.sh
    
    # Update current session
    export MAVEN_HOME=$MAVEN_INSTALL_DIR
    export PATH=$MAVEN_HOME/bin:$PATH
    
    # Verify installation
    if check_maven; then
        log_success "Maven installed successfully"
        rm -f /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    else
        log_error "Maven installation failed"
        return 1
    fi
}

# Docker Management
check_docker() {
    log_info "Checking Docker installation..."
    if check_command docker; then
        docker_version=$(docker --version | awk '{print $3}' | tr -d ',')
        log_success "Docker is installed: version $docker_version"
        
        if docker info &>/dev/null; then
            log_success "Docker daemon is running"
            return 0
        else
            log_error "Docker daemon is not running"
            return 1
        fi
    else
        log_error "Docker is not installed"
        return 1
    fi
}

install_docker() {
    log_info "Installing Docker..."
    apt update
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker
    
    if check_docker; then
        log_success "Docker installed successfully"
    else
        log_error "Failed to install Docker"
        exit 1
    fi
}

check_docker_permissions() {
    log_info "Checking Docker permissions..."
    if groups | grep -q docker; then
        log_success "User is in the docker group"
        return 0
    else
        log_error "User is not in the docker group"
        return 1
    fi
}

fix_docker_permissions() {
    log_info "Adding user to docker group..."
    usermod -aG docker $USER
    log_success "User added to docker group (requires logout/login to take effect)"
}

# Docker Compose Management
check_docker_compose() {
    log_info "Checking Docker Compose installation..."
    if check_command docker-compose; then
        compose_version=$(docker-compose --version | awk '{print $3}' | tr -d ',')
        log_success "Docker Compose is installed: version $compose_version"
        return 0
    else
        log_error "Docker Compose is not installed"
        return 1
    fi
}

install_docker_compose() {
    log_info "Installing Docker Compose ${DOCKER_COMPOSE_VERSION}..."
    curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    if check_docker_compose; then
        log_success "Docker Compose installed successfully"
    else
        log_error "Failed to install Docker Compose"
        exit 1
    fi
}

# Main execution
main() {
    log_info "Starting environment setup and verification..."
    check_root

    # Java setup
    if ! check_java; then
        install_java
    fi
    setup_java_home

    # Maven setup
    if ! check_maven; then
        install_maven
    fi

    # Docker setup
    if ! check_docker; then
        install_docker
    fi
    if ! check_docker_permissions; then
        fix_docker_permissions
    fi

    # Docker Compose setup
    if ! check_docker_compose; then
        install_docker_compose
    fi

    # Final verification
    log_info "Verifying all installations..."
    check_java
    check_maven
    check_docker
    check_docker_compose
    check_docker_permissions

    log_success "Environment setup complete!"
    log_warning "Please log out and log back in for group changes to take effect."
}

# Execute main function
main