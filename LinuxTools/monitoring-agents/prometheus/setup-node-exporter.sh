#!/bin/bash
#
# Prometheus Node Exporter Setup Script
# Installs and configures Node Exporter for metrics collection
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

# Version
NODE_EXPORTER_VERSION="1.7.0"
INSTALL_DIR="/opt/node_exporter"

# Download and install
install_node_exporter() {
    print_info "Installing Prometheus Node Exporter v${NODE_EXPORTER_VERSION}..."
    
    # Create user
    if ! id node_exporter &>/dev/null; then
        sudo useradd --no-create-home --shell /bin/false node_exporter
        print_info "Created node_exporter user"
    fi
    
    # Download
    local arch=$(uname -m)
    local file="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
    local url="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${file}"
    
    cd /tmp
    print_info "Downloading from $url..."
    wget -q "$url"
    tar xzf "$file"
    
    # Install
    sudo mkdir -p "$INSTALL_DIR"
    sudo cp "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" "$INSTALL_DIR/"
    sudo chown -R node_exporter:node_exporter "$INSTALL_DIR"
    
    # Cleanup
    rm -rf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64" "$file"
    
    print_success "Node Exporter installed to $INSTALL_DIR"
}

# Create systemd service
create_systemd_service() {
    print_info "Creating systemd service..."
    
    sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=${INSTALL_DIR}/node_exporter \
    --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/) \
    --collector.netclass.ignored-devices=^(veth.*|docker.*|br-.*|lo)$

[Install]
WantedBy=multi-user.target
EOF
    
    print_success "Systemd service created"
}

# Start service
start_service() {
    print_info "Starting Node Exporter service..."
    
    sudo systemctl daemon-reload
    sudo systemctl enable node_exporter
    sudo systemctl restart node_exporter
    
    sleep 2
    
    if sudo systemctl is-active --quiet node_exporter; then
        print_success "Node Exporter is running"
        sudo systemctl status node_exporter --no-pager
    else
        print_error "Failed to start Node Exporter"
        sudo journalctl -u node_exporter --no-pager -n 20
        exit 1
    fi
}

# Test metrics endpoint
test_metrics() {
    print_info "Testing metrics endpoint..."
    
    sleep 2
    
    if curl -s http://localhost:9100/metrics > /dev/null; then
        print_success "Metrics endpoint is accessible at http://localhost:9100/metrics"
        print_info "Sample metrics:"
        curl -s http://localhost:9100/metrics | grep "^node_" | head -5
    else
        print_error "Metrics endpoint not accessible"
    fi
}

# Main
main() {
    print_info "Prometheus Node Exporter Setup"
    print_info "==============================="
    
    install_node_exporter
    create_systemd_service
    start_service
    test_metrics
    
    print_success "Node Exporter installation complete!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Configure your Prometheus server to scrape this endpoint"
    print_info "2. Add this job to prometheus.yml:"
    print_info ""
    print_info "  - job_name: 'node_exporter'"
    print_info "    static_configs:"
    print_info "      - targets: ['<this-host>:9100']"
    print_info ""
    print_info "Metrics available at: http://localhost:9100/metrics"
}

main "$@"
