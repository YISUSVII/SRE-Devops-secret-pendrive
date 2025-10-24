#!/bin/bash
#
# Network Tools Setup Script
# Installs network diagnostic and testing tools
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

# Install network tools
install_tools() {
    print_info "Installing network tools..."
    
    sudo $PKG_UPDATE
    
    local tools="nmap tcpdump wireshark-common iperf3 mtr traceroute dnsutils netcat curl wget telnet nload iftop nethogs speedtest-cli"
    
    sudo $PKG_INSTALL $tools || print_warning "Some tools failed to install"
    
    print_success "Network tools installed"
}

# Main
main() {
    print_info "Network Tools Setup"
    print_info "==================="
    
    detect_package_manager
    install_tools
    
    print_success "Network tools installation complete!"
    print_info ""
    print_info "Available tools:"
    print_info "  - nmap: Network scanning"
    print_info "  - iperf3: Network performance testing"
    print_info "  - mtr: Network diagnostic tool"
    print_info "  - speedtest-cli: Internet speed test"
    print_info "  - tcpdump: Packet analyzer"
}

main "$@"
