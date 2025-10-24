#!/bin/bash
#
# Monitoring Agents Setup Script
# Installs and configures monitoring agents for Linux systems
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/var/log/linuxtools"
CONFIG_DIR="/etc/linuxtools/monitoring"

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create directories
create_directories() {
    print_info "Creating monitoring directories..."
    sudo mkdir -p "$LOG_DIR"
    sudo mkdir -p "$CONFIG_DIR"
    print_success "Directories created"
}

# Show menu
show_menu() {
    clear
    echo "=========================================="
    echo "   Monitoring Agents Installation"
    echo "=========================================="
    echo ""
    echo "1. Install Datadog Agent"
    echo "2. Install New Relic Agent"
    echo "3. Install Prometheus Node Exporter"
    echo "4. Install Zabbix Agent"
    echo "5. Install Netdata"
    echo "6. Install All Monitoring Agents"
    echo "7. Exit"
    echo ""
    echo "=========================================="
}

# Install Datadog
install_datadog() {
    print_info "Installing Datadog Agent..."
    if [ -f "$SCRIPT_DIR/datadog/install.sh" ]; then
        bash "$SCRIPT_DIR/datadog/install.sh"
        print_success "Datadog installed"
    else
        print_warning "Datadog install script not found"
    fi
}

# Install New Relic
install_newrelic() {
    print_info "Installing New Relic Agent..."
    if [ -f "$SCRIPT_DIR/newrelic/install.sh" ]; then
        bash "$SCRIPT_DIR/newrelic/install.sh"
        print_success "New Relic installed"
    else
        print_warning "New Relic install script not found"
    fi
}

# Install Prometheus
install_prometheus() {
    print_info "Installing Prometheus Node Exporter..."
    if [ -f "$SCRIPT_DIR/prometheus/setup-node-exporter.sh" ]; then
        bash "$SCRIPT_DIR/prometheus/setup-node-exporter.sh"
        print_success "Prometheus Node Exporter installed"
    else
        print_warning "Prometheus setup script not found"
    fi
}

# Install Zabbix
install_zabbix() {
    print_info "Installing Zabbix Agent..."
    if [ -f "$SCRIPT_DIR/zabbix/agent-install.sh" ]; then
        bash "$SCRIPT_DIR/zabbix/agent-install.sh"
        print_success "Zabbix Agent installed"
    else
        print_warning "Zabbix install script not found"
    fi
}

# Install Netdata
install_netdata() {
    print_info "Installing Netdata..."
    if [ -f "$SCRIPT_DIR/netdata/install.sh" ]; then
        bash "$SCRIPT_DIR/netdata/install.sh"
        print_success "Netdata installed"
    else
        print_warning "Netdata install script not found"
    fi
}

# Install all
install_all() {
    print_info "Installing all monitoring agents..."
    install_datadog
    install_newrelic
    install_prometheus
    install_zabbix
    install_netdata
    print_success "All monitoring agents installed!"
}

# Main
main() {
    create_directories
    
    while true; do
        show_menu
        read -p "Select option [1-7]: " choice
        
        case $choice in
            1) install_datadog ;;
            2) install_newrelic ;;
            3) install_prometheus ;;
            4) install_zabbix ;;
            5) install_netdata ;;
            6) install_all ;;
            7) print_info "Exiting..."; exit 0 ;;
            *) print_error "Invalid option"; sleep 2 ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

main "$@"
