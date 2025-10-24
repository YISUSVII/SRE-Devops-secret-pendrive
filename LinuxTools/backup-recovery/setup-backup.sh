#!/bin/bash
#
# Backup & Recovery Tools Setup
# Installs backup and recovery utilities
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
    fi
}

# Install backup tools
install_tools() {
    print_info "Installing backup tools..."
    
    sudo $PKG_UPDATE
    
    local tools="rsync borgbackup tar gzip bzip2 xz-utils"
    
    sudo $PKG_INSTALL $tools || print_warning "Some tools failed to install"
    
    print_success "Backup tools installed"
}

# Main
main() {
    print_info "Backup & Recovery Tools Setup"
    print_info "=============================="
    
    detect_package_manager
    install_tools
    
    print_success "Backup tools installation complete!"
    print_info ""
    print_info "Available scripts:"
    print_info "  - rsync-backup.sh: Rsync-based backups"
    print_info "  - borg-backup.sh: Borg encrypted backups"
    print_info "  - mysql-backup.sh: MySQL database backups"
}

main "$@"
