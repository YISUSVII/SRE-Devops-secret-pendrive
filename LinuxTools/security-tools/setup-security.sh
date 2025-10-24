#!/bin/bash
#
# Security Tools Setup Script
# Installs security hardening and scanning tools
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
}

# Install security tools
install_security_tools() {
    print_info "Installing security tools..."
    
    sudo $PKG_UPDATE
    
    local tools="fail2ban aide rkhunter lynis chkrootkit"
    
    if [ "$PKG_MANAGER" = "apt" ]; then
        tools="$tools clamav clamav-daemon ufw"
    else
        tools="$tools clamav firewalld"
    fi
    
    sudo $PKG_INSTALL $tools || print_warning "Some tools failed to install"
    
    print_success "Security tools installed"
}

# Setup scripts
setup_scripts() {
    print_info "Setting up security scripts..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    chmod +x "$script_dir"/ssh-hardening/*.sh 2>/dev/null || true
    chmod +x "$script_dir"/firewall-setup/*.sh 2>/dev/null || true
    chmod +x "$script_dir"/vulnerability-scanning/*.sh 2>/dev/null || true
    chmod +x "$script_dir"/compliance-checks/*.sh 2>/dev/null || true
    
    print_success "Scripts configured"
}

# Show menu
show_menu() {
    clear
    echo "=========================================="
    echo "      Security Tools Setup"
    echo "=========================================="
    echo ""
    echo "1. SSH Hardening"
    echo "2. Firewall Setup"
    echo "3. Vulnerability Scanning"
    echo "4. Compliance Checks"
    echo "5. Install All Security Tools"
    echo "6. Exit"
    echo ""
    echo "=========================================="
}

# Main
main() {
    print_info "Security Tools Setup"
    print_info "===================="
    
    detect_package_manager
    
    while true; do
        show_menu
        read -p "Select option [1-6]: " choice
        
        case $choice in
            1)
                print_info "SSH Hardening tools available in ssh-hardening/"
                ;;
            2)
                print_info "Firewall setup scripts available in firewall-setup/"
                ;;
            3)
                print_info "Vulnerability scanning tools available in vulnerability-scanning/"
                ;;
            4)
                print_info "Compliance check scripts available in compliance-checks/"
                ;;
            5)
                install_security_tools
                setup_scripts
                ;;
            6)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                sleep 2
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

main "$@"
