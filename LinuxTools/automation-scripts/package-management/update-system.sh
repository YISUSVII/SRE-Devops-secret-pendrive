#!/bin/bash
#
# System Update Script
# Updates all system packages safely
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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot detect distribution"
    exit 1
fi

echo "======================================"
echo "    System Update Script"
echo "======================================"
echo "Distribution: $DISTRO"
echo "Timestamp: $(date)"
echo ""

# Update based on distribution
case "$DISTRO" in
    ubuntu|debian)
        print_info "Updating package lists..."
        apt-get update
        
        print_info "Upgrading packages..."
        apt-get upgrade -y
        
        print_info "Dist-upgrade..."
        apt-get dist-upgrade -y
        
        print_info "Autoremove..."
        apt-get autoremove -y
        
        print_info "Autoclean..."
        apt-get autoclean
        ;;
        
    centos|rhel|rocky|almalinux)
        print_info "Updating packages..."
        yum update -y || dnf update -y
        
        print_info "Autoremove..."
        yum autoremove -y || dnf autoremove -y
        ;;
        
    *)
        print_warning "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

print_success "System update complete!"

# Check if reboot is required
if [ -f /var/run/reboot-required ]; then
    print_warning "System reboot is required"
    read -p "Reboot now? [y/N]: " reboot
    if [[ "$reboot" =~ ^[Yy]$ ]]; then
        print_info "Rebooting system..."
        reboot
    fi
fi
