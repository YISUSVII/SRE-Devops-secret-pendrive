#!/bin/bash
#
# Network Connectivity Test Script
# Tests network connectivity and DNS resolution
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[FAIL]${NC} $1"; }

echo "======================================"
echo "   Network Connectivity Test"
echo "======================================"
echo "Timestamp: $(date)"

# Test interfaces
echo ""
print_info "Network Interfaces"
echo "======================================"
ip addr show | grep -E "^[0-9]|inet " | head -20

# Test gateway
echo ""
print_info "Default Gateway"
echo "======================================"
if route -n | grep -q "^0.0.0.0"; then
    gateway=$(route -n | grep "^0.0.0.0" | awk '{print $2}')
    echo "Gateway: $gateway"
    
    if ping -c 3 -W 2 $gateway &> /dev/null; then
        print_success "Gateway $gateway is reachable"
    else
        print_error "Gateway $gateway is NOT reachable"
    fi
else
    print_warning "No default gateway found"
fi

# Test DNS
echo ""
print_info "DNS Resolution Test"
echo "======================================"

test_dns() {
    local domain=$1
    if nslookup $domain &> /dev/null; then
        print_success "DNS resolution for $domain successful"
    else
        print_error "DNS resolution for $domain failed"
    fi
}

test_dns "google.com"
test_dns "github.com"

# Test external connectivity
echo ""
print_info "External Connectivity Test"
echo "======================================"

test_ping() {
    local host=$1
    local name=$2
    if ping -c 3 -W 3 $host &> /dev/null; then
        print_success "$name ($host) is reachable"
    else
        print_error "$name ($host) is NOT reachable"
    fi
}

test_ping "8.8.8.8" "Google DNS"
test_ping "1.1.1.1" "Cloudflare DNS"

# Test HTTP/HTTPS
echo ""
print_info "HTTP/HTTPS Connectivity Test"
echo "======================================"

if curl -s -o /dev/null -w "%{http_code}" https://www.google.com | grep -q "200"; then
    print_success "HTTPS connectivity working"
else
    print_error "HTTPS connectivity failed"
fi

# Show active connections
echo ""
print_info "Active Connections"
echo "======================================"
ss -tuln | grep LISTEN | head -10

echo ""
echo "======================================"
print_info "Network connectivity test complete"
