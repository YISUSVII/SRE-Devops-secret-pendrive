#!/bin/bash
#
# System Benchmark Script
# Performs CPU, memory, and disk benchmarks
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

echo "======================================"
echo "   SYSTEM BENCHMARK"
echo "======================================"
echo "Timestamp: $(date)"

# CPU Benchmark
cpu_benchmark() {
    echo ""
    print_info "CPU Benchmark - Calculating prime numbers"
    echo "======================================"
    
    local start=$(date +%s.%N)
    
    # Calculate primes up to 50000
    echo "Calculating primes up to 50000..."
    for i in {2..50000}; do
        local is_prime=1
        for ((j=2; j*j<=i; j++)); do
            if ((i % j == 0)); then
                is_prime=0
                break
            fi
        done
    done 2>/dev/null
    
    local end=$(date +%s.%N)
    local runtime=$(echo "$end - $start" | bc)
    
    echo "CPU benchmark completed in ${runtime} seconds"
    print_success "CPU benchmark done"
}

# Memory Benchmark
memory_benchmark() {
    echo ""
    print_info "Memory Benchmark"
    echo "======================================"
    
    local total_mem=$(free -m | awk 'NR==2{print $2}')
    local available_mem=$(free -m | awk 'NR==2{print $7}')
    
    echo "Total Memory: ${total_mem}MB"
    echo "Available Memory: ${available_mem}MB"
    
    # Simple memory speed test
    print_info "Testing memory write speed..."
    dd if=/dev/zero of=/tmp/benchmark_test bs=1M count=100 2>&1 | grep copied
    rm -f /tmp/benchmark_test
    
    print_success "Memory benchmark done"
}

# Disk Benchmark
disk_benchmark() {
    echo ""
    print_info "Disk Benchmark"
    echo "======================================"
    
    print_info "Testing disk write speed..."
    dd if=/dev/zero of=/tmp/benchmark_disk bs=1M count=1024 conv=fdatasync 2>&1 | grep copied
    
    print_info "Testing disk read speed..."
    dd if=/tmp/benchmark_disk of=/dev/null bs=1M 2>&1 | grep copied
    
    rm -f /tmp/benchmark_disk
    
    print_success "Disk benchmark done"
}

# Network Benchmark (local)
network_benchmark() {
    echo ""
    print_info "Network Benchmark"
    echo "======================================"
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        local speed=$(cat /sys/class/net/$iface/speed 2>/dev/null || echo "N/A")
        local state=$(cat /sys/class/net/$iface/operstate 2>/dev/null || echo "unknown")
        
        echo "Interface: $iface"
        echo "  State: $state"
        echo "  Speed: ${speed}Mbps"
    done
    
    print_success "Network benchmark done"
}

# System Load Test
load_test() {
    echo ""
    print_info "System Load Test"
    echo "======================================"
    
    echo "Current load average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "CPU cores: $(nproc)"
    echo "Memory usage: $(free -m | awk 'NR==2{printf "%.1f%%", $3/$2*100}')"
    echo "Disk usage: $(df -h / | awk 'NR==2{print $5}')"
    
    print_success "Load test complete"
}

# Main
main() {
    cpu_benchmark
    memory_benchmark
    disk_benchmark
    network_benchmark
    load_test
    
    echo ""
    echo "======================================"
    print_success "All benchmarks completed!"
    echo ""
    echo "Note: For more comprehensive benchmarks, consider:"
    echo "  - sysbench (apt install sysbench)"
    echo "  - fio (apt install fio)"
    echo "  - iperf3 (apt install iperf3)"
}

main "$@"
