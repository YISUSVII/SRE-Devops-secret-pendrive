#!/bin/bash
#
# Zabbix Agent 2 Installation Script
# Supports major Linux distributions
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

# Version
ZABBIX_VERSION="6.4"

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION_MAJOR=$(echo $VERSION_ID | cut -d. -f1)
    else
        print_error "Cannot detect distribution"
        exit 1
    fi
    print_info "Detected: $DISTRO $VERSION_ID"
}

# Install Zabbix repository
install_repository() {
    print_info "Installing Zabbix repository..."
    
    case "$DISTRO" in
        ubuntu)
            wget -q "https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VERSION}-1+ubuntu${VERSION_MAJOR}_all.deb"
            sudo dpkg -i "zabbix-release_${ZABBIX_VERSION}-1+ubuntu${VERSION_MAJOR}_all.deb"
            sudo apt-get update
            rm -f "zabbix-release_${ZABBIX_VERSION}-1+ubuntu${VERSION_MAJOR}_all.deb"
            ;;
        debian)
            wget -q "https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_VERSION}-1+debian${VERSION_MAJOR}_all.deb"
            sudo dpkg -i "zabbix-release_${ZABBIX_VERSION}-1+debian${VERSION_MAJOR}_all.deb"
            sudo apt-get update
            rm -f "zabbix-release_${ZABBIX_VERSION}-1+debian${VERSION_MAJOR}_all.deb"
            ;;
        centos|rhel|rocky|almalinux)
            sudo rpm -Uvh "https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/rhel/${VERSION_MAJOR}/x86_64/zabbix-release-${ZABBIX_VERSION}-1.el${VERSION_MAJOR}.noarch.rpm"
            sudo yum clean all
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    print_success "Repository installed"
}

# Install Zabbix Agent
install_agent() {
    print_info "Installing Zabbix Agent 2..."
    
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get install -y zabbix-agent2 zabbix-agent2-plugin-*
            ;;
        centos|rhel|rocky|almalinux)
            sudo yum install -y zabbix-agent2 zabbix-agent2-plugin-*
            ;;
    esac
    
    print_success "Zabbix Agent 2 installed"
}

# Configure agent
configure_agent() {
    print_info "Configuring Zabbix Agent..."
    
    # Ask for Zabbix server
    if [ -z "${ZABBIX_SERVER:-}" ]; then
        read -p "Enter Zabbix Server IP/hostname [127.0.0.1]: " ZABBIX_SERVER
        ZABBIX_SERVER=${ZABBIX_SERVER:-127.0.0.1}
    fi
    
    local config_file="/etc/zabbix/zabbix_agent2.conf"
    
    sudo sed -i "s/^Server=.*/Server=${ZABBIX_SERVER}/" "$config_file"
    sudo sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_SERVER}/" "$config_file"
    sudo sed -i "s/^Hostname=.*/Hostname=$(hostname)/" "$config_file"
    
    print_success "Agent configured for server: $ZABBIX_SERVER"
}

# Start service
start_agent() {
    print_info "Starting Zabbix Agent..."
    
    if command -v systemctl &> /dev/null; then
        sudo systemctl enable zabbix-agent2
        sudo systemctl restart zabbix-agent2
        sudo systemctl status zabbix-agent2 --no-pager
    else
        sudo service zabbix-agent2 start
    fi
    
    print_success "Zabbix Agent started"
}

# Main
main() {
    print_info "Zabbix Agent 2 Installation"
    print_info "==========================="
    
    detect_distro
    install_repository
    install_agent
    configure_agent
    start_agent
    
    print_success "Zabbix Agent installation complete!"
    print_info "Config file: /etc/zabbix/zabbix_agent2.conf"
    print_info "Logs: /var/log/zabbix/zabbix_agent2.log"
}

main "$@"
