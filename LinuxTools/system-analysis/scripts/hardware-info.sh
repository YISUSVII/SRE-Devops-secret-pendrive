#!/bin/bash
#
# Hardware Information Script
# Collects detailed hardware information
#

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }

echo "======================================"
echo "   HARDWARE INFORMATION"
echo "======================================"
echo "Timestamp: $(date)"

# System Information
echo ""
print_info "System Information"
echo "======================================"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
if [ -f /etc/os-release ]; then
    echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
fi

# CPU Information
echo ""
print_info "CPU Information"
echo "======================================"
lscpu | head -20

# Memory Information
echo ""
print_info "Memory Information"
echo "======================================"
if command -v dmidecode &> /dev/null && [[ $EUID -eq 0 ]]; then
    sudo dmidecode -t memory | grep -A3 "Memory Device" | head -20
else
    free -h
    echo ""
    cat /proc/meminfo | head -10
fi

# Disk Information
echo ""
print_info "Disk Information"
echo "======================================"
lsblk
echo ""
df -h

# Network Hardware
echo ""
print_info "Network Hardware"
echo "======================================"
if command -v lspci &> /dev/null; then
    lspci | grep -i network
fi
if command -v lshw &> /dev/null && [[ $EUID -eq 0 ]]; then
    sudo lshw -C network -short
else
    ip link show
fi

# PCI Devices
echo ""
print_info "PCI Devices"
echo "======================================"
if command -v lspci &> /dev/null; then
    lspci | head -20
fi

# USB Devices
echo ""
print_info "USB Devices"
echo "======================================"
if command -v lsusb &> /dev/null; then
    lsusb
fi

echo ""
echo "======================================"
print_success "Hardware information collection complete"
