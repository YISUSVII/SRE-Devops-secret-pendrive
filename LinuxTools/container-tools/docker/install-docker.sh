#!/bin/bash
#
# Docker Installation Script
# Installs Docker Engine on Linux systems
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        print_error "Cannot detect distribution"
        exit 1
    fi
}

# Install Docker
install_docker() {
    print_info "Installing Docker..."
    
    case "$DISTRO" in
        ubuntu|debian)
            # Install prerequisites
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl gnupg
            
            # Add Docker's official GPG key
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg
            
            # Set up repository
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Install Docker Engine
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            
        centos|rhel|rocky|almalinux)
            # Install prerequisites
            sudo yum install -y yum-utils
            
            # Set up repository
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            
            # Install Docker Engine
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            
        *)
            print_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    print_success "Docker installed"
}

# Start Docker service
start_docker() {
    print_info "Starting Docker service..."
    
    sudo systemctl enable docker
    sudo systemctl start docker
    
    print_success "Docker service started"
}

# Add user to docker group
add_user_to_group() {
    local current_user=$(whoami)
    
    print_info "Adding user $current_user to docker group..."
    sudo usermod -aG docker $current_user
    
    print_success "User added to docker group"
    print_warning "Log out and back in for group changes to take effect"
}

# Verify installation
verify_installation() {
    print_info "Verifying Docker installation..."
    
    sudo docker run hello-world
    
    print_success "Docker is working correctly!"
}

# Main
main() {
    echo "======================================"
    echo "     Docker Installation"
    echo "======================================"
    echo ""
    
    detect_distro
    install_docker
    start_docker
    add_user_to_group
    verify_installation
    
    print_success "Docker installation complete!"
    print_info ""
    print_info "Useful commands:"
    print_info "  docker ps - List running containers"
    print_info "  docker images - List images"
    print_info "  docker compose up - Start containers from compose file"
}

main "$@"
