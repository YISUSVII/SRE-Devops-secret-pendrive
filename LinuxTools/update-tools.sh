#!/bin/bash
#
# LinuxTools - Update Script
# Updates all installed LinuxTools components to the latest versions
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
LOG_FILE="/var/log/linuxtools/update-$(date +%Y%m%d-%H%M%S).log"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Update monitoring agents
update_monitoring() {
    print_info "Updating monitoring agents..."
    
    if [ -f monitoring-agents/datadog/install.sh ]; then
        print_info "Updating Datadog agent..."
        sudo bash monitoring-agents/datadog/install.sh --update || print_warning "Datadog update failed"
    fi
    
    if [ -f monitoring-agents/prometheus/setup-node-exporter.sh ]; then
        print_info "Updating Prometheus Node Exporter..."
        sudo bash monitoring-agents/prometheus/setup-node-exporter.sh --update || print_warning "Prometheus update failed"
    fi
    
    print_success "Monitoring agents updated"
}

# Update security tools
update_security() {
    print_info "Updating security tools..."
    
    # Update vulnerability databases
    if command -v lynis &> /dev/null; then
        print_info "Updating Lynis database..."
        sudo lynis update info || print_warning "Lynis update failed"
    fi
    
    if command -v rkhunter &> /dev/null; then
        print_info "Updating Rkhunter database..."
        sudo rkhunter --update || print_warning "Rkhunter update failed"
    fi
    
    if command -v freshclam &> /dev/null; then
        print_info "Updating ClamAV database..."
        sudo freshclam || print_warning "ClamAV update failed"
    fi
    
    print_success "Security tools updated"
}

# Update system packages
update_system_packages() {
    print_info "Updating system packages..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get upgrade -y
    elif command -v dnf &> /dev/null; then
        sudo dnf upgrade -y
    elif command -v yum &> /dev/null; then
        sudo yum update -y
    fi
    
    print_success "System packages updated"
}

# Update git repository
update_repository() {
    print_info "Updating LinuxTools repository..."
    
    git fetch origin
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    
    if [ "$LOCAL" != "$REMOTE" ]; then
        print_info "Updates available. Pulling changes..."
        git pull origin main
        print_success "Repository updated"
    else
        print_info "Repository already up to date"
    fi
}

# Main update function
main() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
    
    print_info "Starting LinuxTools update process..."
    print_info "Log file: $LOG_FILE"
    
    # Create log directory if it doesn't exist
    sudo mkdir -p "$(dirname "$LOG_FILE")"
    
    update_repository
    update_system_packages
    update_monitoring
    update_security
    
    print_success "LinuxTools update completed successfully!"
    print_info "Check log file for details: $LOG_FILE"
}

main "$@"
