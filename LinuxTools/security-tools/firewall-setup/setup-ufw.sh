#!/bin/bash
#
# UFW Firewall Setup Script
# Configures UFW with security best practices
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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    exit 1
fi

# Install UFW
install_ufw() {
    print_info "Installing UFW..."
    
    if ! command -v ufw &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y ufw
        else
            print_error "UFW not available for this distribution"
            exit 1
        fi
    fi
    
    print_success "UFW is installed"
}

# Configure UFW
configure_ufw() {
    print_info "Configuring UFW firewall..."
    
    # Reset UFW to defaults
    ufw --force reset
    
    # Set default policies
    ufw default deny incoming
    ufw default allow outgoing
    print_success "Set default policies"
    
    # Allow SSH (important!)
    read -p "SSH port [22]: " ssh_port
    ssh_port=${ssh_port:-22}
    ufw allow $ssh_port/tcp comment "SSH"
    print_success "Allowed SSH on port $ssh_port"
    
    # Common services
    read -p "Allow HTTP (port 80)? [y/N]: " allow_http
    if [[ "$allow_http" =~ ^[Yy]$ ]]; then
        ufw allow 80/tcp comment "HTTP"
        print_success "Allowed HTTP"
    fi
    
    read -p "Allow HTTPS (port 443)? [y/N]: " allow_https
    if [[ "$allow_https" =~ ^[Yy]$ ]]; then
        ufw allow 443/tcp comment "HTTPS"
        print_success "Allowed HTTPS"
    fi
    
    # Custom ports
    read -p "Add custom port rules? [y/N]: " custom_ports
    if [[ "$custom_ports" =~ ^[Yy]$ ]]; then
        while true; do
            read -p "Enter port/protocol (e.g., 3306/tcp) or 'done': " port_rule
            if [ "$port_rule" = "done" ]; then
                break
            fi
            read -p "Comment for this rule: " comment
            ufw allow $port_rule comment "$comment"
            print_success "Allowed $port_rule"
        done
    fi
    
    # Rate limiting for SSH
    ufw limit $ssh_port/tcp
    print_success "Enabled rate limiting for SSH"
    
    # Enable logging
    ufw logging on
    print_success "Enabled firewall logging"
}

# Enable UFW
enable_ufw() {
    print_info "Enabling UFW..."
    
    print_warning "This will activate the firewall with the configured rules"
    read -p "Continue? [y/N]: " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        ufw --force enable
        print_success "UFW firewall enabled"
    else
        print_info "UFW not enabled"
        exit 0
    fi
}

# Show status
show_status() {
    echo ""
    print_info "UFW Firewall Status"
    echo "======================================"
    ufw status verbose
}

# Main
main() {
    echo "======================================"
    echo "     UFW Firewall Setup"
    echo "======================================"
    echo ""
    
    install_ufw
    configure_ufw
    enable_ufw
    show_status
    
    echo ""
    print_success "UFW firewall setup complete!"
    print_info "Manage with: ufw status, ufw allow, ufw deny, ufw delete"
}

main "$@"
