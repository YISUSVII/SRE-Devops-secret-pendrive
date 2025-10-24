#!/bin/bash
#
# Netdata Installation Script
# Real-time performance monitoring for Linux systems
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

# Install Netdata
install_netdata() {
    print_info "Installing Netdata..."
    
    # Using official kickstart script
    bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel --disable-telemetry
    
    print_success "Netdata installed"
}

# Configure Netdata
configure_netdata() {
    print_info "Configuring Netdata..."
    
    local config_file="/etc/netdata/netdata.conf"
    
    if [ ! -f "$config_file" ]; then
        sudo /usr/sbin/netdata -W set
    fi
    
    # Allow access from network (optional, commented by default)
    # sudo sed -i 's/bind to = localhost/bind to = */' "$config_file"
    
    print_success "Netdata configured"
}

# Start Netdata
start_netdata() {
    print_info "Starting Netdata service..."
    
    if command -v systemctl &> /dev/null; then
        sudo systemctl enable netdata
        sudo systemctl restart netdata
        sudo systemctl status netdata --no-pager
    else
        sudo service netdata start
    fi
    
    print_success "Netdata started"
}

# Show access info
show_info() {
    local ip=$(hostname -I | awk '{print $1}')
    
    print_success "Netdata installation complete!"
    print_info ""
    print_info "Access Netdata dashboard at:"
    print_info "  Local:  http://localhost:19999"
    print_info "  Network: http://${ip}:19999"
    print_info ""
    print_info "Default credentials: none (configure if needed)"
    print_info "Config file: /etc/netdata/netdata.conf"
    print_info "Logs: /var/log/netdata/"
}

# Main
main() {
    print_info "Netdata Installation"
    print_info "===================="
    
    install_netdata
    configure_netdata
    start_netdata
    show_info
}

main "$@"
