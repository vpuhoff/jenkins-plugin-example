#!/bin/bash

# Configuration variables
PLUGIN_DIR="target"
PLUGIN_NAME="viewfilter"
PLUGIN_NAME_WITH_EXTENSION="viewfilter.jpi"
JENKINS_CONTAINER="jenkins-test"
JENKINS_IMAGE="jenkins/jenkins:lts"
JENKINS_HOME="$PWD/jenkins_home"
PORT=8080
CONTAINER_UID=1000
CONTAINER_GID=1000

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# Error handling function
handle_error() {
    log_error "$1"
    exit 1
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        handle_error "Docker is not running. Please start Docker daemon first."
    fi
}

# Build the plugin
build_plugin() {
    log_info "Building plugin..."
    if ! mvn clean package; then
        handle_error "Plugin build failed"
    fi
    
    cp -r "$PLUGIN_DIR/$PLUGIN_NAME.hpi" "$PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION" 
    
    if [ ! -f "$PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION" ]; then
        handle_error "Plugin file not found at $PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION"
    fi
    
    log_success "Plugin built successfully"
}

# Clean up existing Jenkins container and files
cleanup_existing() {
    log_info "Cleaning up existing Jenkins installation..."
    
    if docker ps -a | grep -q "$JENKINS_CONTAINER"; then
        log_info "Removing existing Jenkins container..."
        docker rm -f "$JENKINS_CONTAINER" || handle_error "Failed to remove existing container"
        log_success "Existing container removed"
    fi

    if [ -f "$JENKINS_HOME/plugins/$PLUGIN_NAME_WITH_EXTENSION" ]; then
        log_info "Removing old plugin..."
        rm -f "$JENKINS_HOME/plugins/$PLUGIN_NAME_WITH_EXTENSION" || handle_error "Failed to remove old plugin"
        log_success "Old plugin removed"
    fi
}

# Setup Jenkins home directory
setup_jenkins_home() {
    log_info "Setting up Jenkins home directory..."
    
    mkdir -p "$JENKINS_HOME/plugins" || handle_error "Failed to create Jenkins home directory"
    
    log_info "Setting permissions..."
    if ! sudo chown -R $CONTAINER_UID:$CONTAINER_GID "$JENKINS_HOME"; then
        handle_error "Failed to set ownership for Jenkins home"
    fi
    
    if ! sudo chmod -R 777 "$JENKINS_HOME"; then
        handle_error "Failed to set permissions for Jenkins home"
    fi
    
    log_success "Jenkins home directory configured"
}

# Install plugin
install_plugin() {
    log_info "Installing plugin..."
    
    if ! cp -rf "$PLUGIN_DIR/$PLUGIN_NAME_WITH_EXTENSION" "$JENKINS_HOME/plugins/"; then
        handle_error "Failed to copy plugin to Jenkins plugins directory"
    fi
    
    log_success "Plugin installed"
}

# Start Jenkins and handle password display appropriately
start_jenkins() {
    log_info "Starting Jenkins container..."
    
    if ! docker run -d --name "$JENKINS_CONTAINER" \
        -p "$PORT:8080" \
        -v "$JENKINS_HOME:/var/jenkins_home" \
        "$JENKINS_IMAGE"; then
        handle_error "Failed to start Jenkins container"
    fi
    
    # Wait for container to start
    sleep 5
    
    if ! docker ps | grep -q "$JENKINS_CONTAINER"; then
        log_error "Container failed to start. Container logs:"
        docker logs "$JENKINS_CONTAINER"
        handle_error "Jenkins container failed to start"
    fi
    
    log_success "Jenkins started successfully at http://localhost:$PORT"

    # Check if Jenkins is already initialized
    if [ -f "$JENKINS_HOME/config.xml" ]; then
        log_info "Jenkins is already initialized. Ready to use."
    else
        log_info "Waiting for Jenkins to initialize..."
        sleep 30
        if [ -f "$JENKINS_HOME/secrets/initialAdminPassword" ]; then
            log_info "Initial admin password:"
            docker exec "$JENKINS_CONTAINER" cat /var/jenkins_home/secrets/initialAdminPassword
        else
            log_warning "Initial admin password file not found. Jenkins may already be configured."
        fi
    fi
    
    # Stream logs
    log_info "Streaming Jenkins logs (Ctrl+C to stop)..."
    docker logs -f "$JENKINS_CONTAINER"
}

# Main execution
main() {
    log_info "Starting plugin build and deployment process..."
    
    # Verify Docker is running
    check_docker
    
    # Build the plugin
    build_plugin
    
    # Clean up existing installation
    cleanup_existing
    
    # Setup Jenkins environment
    setup_jenkins_home
    
    # Install the plugin
    install_plugin
    
    # Start Jenkins
    start_jenkins
    
    # Display initial password
    log_info "Waiting for Jenkins to generate initial admin password..."
    sleep 30
    log_info "Initial admin password:"
    docker exec "$JENKINS_CONTAINER" cat /var/jenkins_home/secrets/initialAdminPassword
    
    # Stream logs
    log_info "Streaming Jenkins logs (Ctrl+C to stop)..."
    docker logs -f "$JENKINS_CONTAINER"
}

# Execute main function
main