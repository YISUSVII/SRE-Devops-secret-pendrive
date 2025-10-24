#!/bin/bash
#
# LinuxTools - Main Setup Script
# This script sets up the LinuxTools environment and installs selected components
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging configuration
LOG_DIR="/var/log/linuxtools"
CONFIG_DIR="/etc/linuxtools"
INSTALL_DIR="/opt/linuxtools"

# Print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
        VERSION=$(cat /etc/redhat-release | grep -oP '\d+\.\d+')
    else
        DISTRO="unknown"
        VERSION="unknown"
    fi
    
    print_info "Detected Distribution: $DISTRO $VERSION"
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
        PKG_UPDATE="apt-get update"
        PKG_INSTALL="apt-get install -y"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="dnf check-update || true"
        PKG_INSTALL="dnf install -y"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        PKG_UPDATE="yum check-update || true"
        PKG_INSTALL="yum install -y"
    else
        print_error "No supported package manager found"
        exit 1
    fi
    
    print_info "Package Manager: $PKG_MANAGER"
}

# Create required directories
create_directories() {
    print_info "Creating required directories..."
    
    sudo mkdir -p "$LOG_DIR"
    sudo mkdir -p "$CONFIG_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    
    sudo chmod 755 "$LOG_DIR"
    sudo chmod 755 "$CONFIG_DIR"
    sudo chmod 755 "$INSTALL_DIR"
    
    print_success "Directories created successfully"
}

# Install basic dependencies
install_dependencies() {
    print_info "Installing basic dependencies..."
    
    sudo $PKG_UPDATE
    
    local deps="curl wget git vim net-tools"
    
    sudo $PKG_INSTALL $deps
    
    print_success "Dependencies installed successfully"
}

# Display menu
show_menu() {
    clear
    echo "=========================================="
    echo "     LinuxTools Setup Menu"
    echo "=========================================="
    echo ""
    echo "1.  Install Monitoring Agents"
    echo "2.  Install System Analysis Tools"
    echo "3.  Install Security Tools"
    echo "4.  Install Network Tools"
    echo "5.  Install Backup & Recovery Tools"
    echo "6.  Install Container Tools"
    echo "7.  Install Cloud Tools"
    echo "8.  Install Database Tools"
    echo "9.  Install Web Server Tools"
    echo "10. Install Automation Scripts"
    echo "11. Install All Components"
    echo "12. Exit"
    echo ""
    echo "=========================================="
}

# Install monitoring agents
install_monitoring() {
    print_info "Installing Monitoring Agents..."
    bash monitoring-agents/setup-monitoring.sh
    print_success "Monitoring agents installed"
}

# Install system analysis tools
install_analysis() {
    print_info "Installing System Analysis Tools..."
    bash system-analysis/setup-analysis.sh
    print_success "System analysis tools installed"
}

# Install security tools
install_security() {
    print_info "Installing Security Tools..."
    bash security-tools/setup-security.sh
    print_success "Security tools installed"
}

# Install network tools
install_network() {
    print_info "Installing Network Tools..."
    bash network-tools/setup-network.sh
    print_success "Network tools installed"
}

# Install backup tools
install_backup() {
    print_info "Installing Backup & Recovery Tools..."
    bash backup-recovery/setup-backup.sh
    print_success "Backup & recovery tools installed"
}

# Install container tools
install_containers() {
    print_info "Installing Container Tools..."
    bash container-tools/setup-containers.sh
    print_success "Container tools installed"
}

# Install cloud tools
install_cloud() {
    print_info "Installing Cloud Tools..."
    bash cloud-tools/setup-cloud.sh
    print_success "Cloud tools installed"
}

# Install database tools
install_database() {
    print_info "Installing Database Tools..."
    bash database-tools/setup-databases.sh
    print_success "Database tools installed"
}

# Install web server tools
install_webserver() {
    print_info "Installing Web Server Tools..."
    bash web-server-tools/setup-webserver.sh
    print_success "Web server tools installed"
}

# Install automation scripts
install_automation() {
    print_info "Installing Automation Scripts..."
    bash automation-scripts/setup-automation.sh
    print_success "Automation scripts installed"
}

# Install all components
install_all() {
    print_info "Installing all components..."
    install_monitoring
    install_analysis
    install_security
    install_network
    install_backup
    install_containers
    install_cloud
    install_database
    install_webserver
    install_automation
    print_success "All components installed successfully!"
}

# Main function
main() {
    # Check if running as root for initial setup
    if [[ $EUID -ne 0 ]] && [[ "$1" != "--user" ]]; then
        print_warning "This script should be run as root for initial setup"
        print_info "Run with --user flag if you want to skip system-wide installation"
        exit 1
    fi
    
    print_info "Starting LinuxTools Setup..."
    print_info "================================"
    
    detect_distro
    detect_package_manager
    create_directories
    install_dependencies
    
    # Interactive menu
    while true; do
        show_menu
        read -p "Please select an option [1-12]: " choice
        
        case $choice in
            1) install_monitoring ;;
            2) install_analysis ;;
            3) install_security ;;
            4) install_network ;;
            5) install_backup ;;
            6) install_containers ;;
            7) install_cloud ;;
            8) install_database ;;
            9) install_webserver ;;
            10) install_automation ;;
            11) install_all ;;
            12) 
                print_info "Exiting setup..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-12."
                sleep 2
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
