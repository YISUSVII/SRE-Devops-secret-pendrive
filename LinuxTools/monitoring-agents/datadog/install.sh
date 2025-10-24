#!/bin/bash
#
# Datadog Agent Installation Script
# Supports Ubuntu, Debian, CentOS, RHEL
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
        VERSION=$VERSION_ID
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
    print_info "Detected: $DISTRO $VERSION"
}

# Install Datadog
install_datadog() {
    print_info "Installing Datadog Agent..."
    
    # Check for API key
    if [ -z "${DD_API_KEY:-}" ]; then
        print_warning "DD_API_KEY not set"
        read -p "Enter your Datadog API Key: " DD_API_KEY
        export DD_API_KEY
    fi
    
    # Install based on distribution
    case "$DISTRO" in
        ubuntu|debian)
            print_info "Installing for Debian/Ubuntu..."
            DD_AGENT_MAJOR_VERSION=7 DD_API_KEY="$DD_API_KEY" DD_SITE="datadoghq.com" \
                bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
            ;;
        rhel|centos|rocky|almalinux)
            print_info "Installing for RHEL/CentOS..."
            DD_AGENT_MAJOR_VERSION=7 DD_API_KEY="$DD_API_KEY" DD_SITE="datadoghq.com" \
                bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
            ;;
        *)
            print_error "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    print_success "Datadog Agent installed successfully!"
}

# Configure Datadog
configure_datadog() {
    print_info "Configuring Datadog Agent..."
    
    local config_dir="/etc/datadog-agent"
    local config_file="$config_dir/datadog.yaml"
    
    if [ -f "$config_file" ]; then
        # Enable logs collection
        sudo sed -i 's/# logs_enabled: false/logs_enabled: true/' "$config_file"
        
        # Enable process monitoring
        sudo sed -i 's/# process_config:/process_config:/' "$config_file"
        sudo sed -i 's/#   enabled: "false"/  enabled: "true"/' "$config_file"
        
        print_success "Datadog configured"
    else
        print_warning "Config file not found at $config_file"
    fi
}

# Start Datadog service
start_datadog() {
    print_info "Starting Datadog Agent..."
    
    if command -v systemctl &> /dev/null; then
        sudo systemctl enable datadog-agent
        sudo systemctl restart datadog-agent
        sudo systemctl status datadog-agent --no-pager
    else
        sudo service datadog-agent start
    fi
    
    print_success "Datadog Agent started"
}

# Check status
check_status() {
    print_info "Checking Datadog Agent status..."
    sudo datadog-agent status || true
}

# Main
main() {
    print_info "Datadog Agent Installation"
    print_info "============================"
    
    detect_distro
    install_datadog
    configure_datadog
    start_datadog
    
    print_success "Datadog installation complete!"
    print_info "Check status with: sudo datadog-agent status"
    print_info "View logs at: /var/log/datadog/"
    
    # Ask to check status
    read -p "Check status now? [y/N]: " check
    if [[ "$check" =~ ^[Yy]$ ]]; then
        check_status
    fi
}

main "$@"
