#!/bin/bash
#
# New Relic Infrastructure Agent Installation
# Supports major Linux distributions
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

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        print_error "Cannot detect distribution"
        exit 1
    fi
    print_info "Detected: $DISTRO"
}

# Install New Relic
install_newrelic() {
    print_info "Installing New Relic Infrastructure Agent..."
    
    # Check for license key
    if [ -z "${NEW_RELIC_LICENSE_KEY:-}" ]; then
        print_warning "NEW_RELIC_LICENSE_KEY not set"
        read -p "Enter your New Relic License Key: " NEW_RELIC_LICENSE_KEY
        export NEW_RELIC_LICENSE_KEY
    fi
    
    case "$DISTRO" in
        ubuntu|debian)
            curl -s https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | sudo apt-key add -
            echo "deb https://download.newrelic.com/infrastructure_agent/linux/apt $DISTRO main" | \
                sudo tee /etc/apt/sources.list.d/newrelic-infra.list
            sudo apt-get update
            sudo apt-get install -y newrelic-infra
            ;;
        centos|rhel|rocky|almalinux)
            sudo curl -o /etc/yum.repos.d/newrelic-infra.repo \
                https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
            sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
            sudo yum install -y newrelic-infra
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    print_success "New Relic installed"
}

# Configure New Relic
configure_newrelic() {
    print_info "Configuring New Relic..."
    
    local config_file="/etc/newrelic-infra.yml"
    
    sudo tee "$config_file" > /dev/null <<EOF
license_key: ${NEW_RELIC_LICENSE_KEY}
display_name: $(hostname)
log_file: /var/log/newrelic-infra/newrelic-infra.log
verbose: 0
EOF
    
    print_success "New Relic configured"
}

# Start service
start_newrelic() {
    print_info "Starting New Relic service..."
    
    if command -v systemctl &> /dev/null; then
        sudo systemctl enable newrelic-infra
        sudo systemctl restart newrelic-infra
        sudo systemctl status newrelic-infra --no-pager
    else
        sudo service newrelic-infra start
    fi
    
    print_success "New Relic started"
}

# Main
main() {
    print_info "New Relic Infrastructure Agent Setup"
    print_info "====================================="
    
    detect_distro
    install_newrelic
    configure_newrelic
    start_newrelic
    
    print_success "New Relic installation complete!"
    print_info "Check logs at: /var/log/newrelic-infra/"
    print_info "View data in New Relic One dashboard"
}

main "$@"
