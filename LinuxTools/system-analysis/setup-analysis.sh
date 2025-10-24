#!/bin/bash
#
# System Analysis Tools Setup
# Installs tools for system reporting, performance checking, and security auditing
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

# Install dependencies
install_dependencies() {
    print_info "Installing system analysis tools..."
    
    sudo $PKG_UPDATE
    
    local tools="sysstat htop iotop lsof strace tcpdump dmidecode hdparm smartmontools pciutils usbutils ethtool iproute2"
    
    sudo $PKG_INSTALL $tools
    
    print_success "System analysis tools installed"
}

# Make scripts executable
setup_scripts() {
    print_info "Setting up analysis scripts..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"
    
    if [ -d "$script_dir" ]; then
        chmod +x "$script_dir"/*.sh 2>/dev/null || true
        print_success "Scripts configured"
    fi
}

# Main
main() {
    print_info "System Analysis Tools Setup"
    print_info "============================"
    
    detect_package_manager
    install_dependencies
    setup_scripts
    
    print_success "System analysis tools installation complete!"
    print_info ""
    print_info "Available scripts:"
    print_info "  - system-report.sh      : Comprehensive system report"
    print_info "  - performance-check.sh  : Performance analysis"
    print_info "  - security-audit.sh     : Security audit"
    print_info "  - hardware-info.sh      : Hardware information"
    print_info "  - benchmark-system.sh   : System benchmarking"
}

main "$@"
