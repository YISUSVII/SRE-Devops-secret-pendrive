#!/bin/bash
#
# Container Tools Setup
# Installs Docker and Kubernetes monitoring tools
#

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Main
main() {
    print_info "Container Tools Setup"
    print_info "====================="
    
    print_info "Available scripts:"
    print_info "  - docker/install-docker.sh: Install Docker"
    print_info "  - docker/docker-monitor.sh: Monitor Docker containers"
    print_info "  - kubernetes/k8s-monitor.sh: Monitor Kubernetes"
    
    print_success "Container tools ready!"
}

main "$@"
