#!/bin/bash
#
# Performance Check Script
# Analyzes system performance metrics
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
print_error() { echo -e "${RED}[CRITICAL]${NC} $1"; }

# Check CPU usage
check_cpu() {
    echo ""
    print_info "CPU Performance Check"
    echo "======================================"
    
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d% -f1)
    local load_1=$(uptime | awk -F'load average:' '{print $2}' | awk -F, '{print $1}' | xargs)
    local load_5=$(uptime | awk -F'load average:' '{print $2}' | awk -F, '{print $2}' | xargs)
    local load_15=$(uptime | awk -F'load average:' '{print $2}' | awk -F, '{print $3}' | xargs)
    local cores=$(nproc)
    
    echo "CPU Usage: ${cpu_usage}%"
    echo "Load Average: $load_1 (1min) $load_5 (5min) $load_15 (15min)"
    echo "CPU Cores: $cores"
    
    # Warning if load is high
    local load_threshold=$(awk "BEGIN {print $cores * 0.7}")
    if (( $(echo "$load_1 > $load_threshold" | bc -l) )); then
        print_warning "High CPU load detected!"
    else
        print_success "CPU load is normal"
    fi
    
    # Top CPU processes
    echo ""
    echo "Top 5 CPU consuming processes:"
    ps aux --sort=-%cpu | head -6 | tail -5
}

# Check memory usage
check_memory() {
    echo ""
    print_info "Memory Performance Check"
    echo "======================================"
    
    local total_mem=$(free -m | awk 'NR==2{print $2}')
    local used_mem=$(free -m | awk 'NR==2{print $3}')
    local free_mem=$(free -m | awk 'NR==2{print $4}')
    local mem_percent=$(awk "BEGIN {printf \"%.1f\", ($used_mem/$total_mem)*100}")
    
    echo "Total Memory: ${total_mem}MB"
    echo "Used Memory: ${used_mem}MB (${mem_percent}%)"
    echo "Free Memory: ${free_mem}MB"
    
    if (( $(echo "$mem_percent > 90" | bc -l) )); then
        print_error "Critical memory usage!"
    elif (( $(echo "$mem_percent > 80" | bc -l) )); then
        print_warning "High memory usage"
    else
        print_success "Memory usage is normal"
    fi
    
    # Top memory processes
    echo ""
    echo "Top 5 Memory consuming processes:"
    ps aux --sort=-%mem | head -6 | tail -5
}

# Check disk I/O
check_disk_io() {
    echo ""
    print_info "Disk I/O Performance Check"
    echo "======================================"
    
    if command -v iostat &> /dev/null; then
        iostat -x 1 2 | tail -n +4
        print_success "Disk I/O stats collected"
    else
        print_warning "iostat not available. Install sysstat package"
    fi
}

# Check disk usage
check_disk_usage() {
    echo ""
    print_info "Disk Usage Check"
    echo "======================================"
    
    while IFS= read -r line; do
        local use_percent=$(echo $line | awk '{print $5}' | tr -d '%')
        local mount=$(echo $line | awk '{print $6}')
        
        if [ "$use_percent" -gt 90 ]; then
            print_error "Disk $mount is ${use_percent}% full!"
        elif [ "$use_percent" -gt 80 ]; then
            print_warning "Disk $mount is ${use_percent}% full"
        else
            print_success "Disk $mount is ${use_percent}% full"
        fi
    done < <(df -h | grep -v "tmpfs" | grep -v "loop" | tail -n +2)
}

# Check network performance
check_network() {
    echo ""
    print_info "Network Performance Check"
    echo "======================================"
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        local state=$(cat /sys/class/net/$iface/operstate 2>/dev/null || echo "unknown")
        local rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo "0")
        local tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo "0")
        local rx_mb=$(awk "BEGIN {printf \"%.2f\", $rx_bytes/1024/1024}")
        local tx_mb=$(awk "BEGIN {printf \"%.2f\", $tx_bytes/1024/1024}")
        
        echo "Interface: $iface"
        echo "  State: $state"
        echo "  RX: ${rx_mb}MB"
        echo "  TX: ${tx_mb}MB"
        
        if [ "$state" = "up" ]; then
            print_success "$iface is up"
        else
            print_warning "$iface is $state"
        fi
    done
}

# Check system services
check_services() {
    echo ""
    print_info "Critical Services Check"
    echo "======================================"
    
    local services=("sshd" "cron" "rsyslog")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            print_success "$service is running"
        elif systemctl is-active --quiet "${service}.service" 2>/dev/null; then
            print_success "${service}.service is running"
        else
            print_warning "$service is not running or not installed"
        fi
    done
}

# Performance summary
performance_summary() {
    echo ""
    print_info "Performance Summary"
    echo "======================================"
    
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d% -f1)
    local mem_percent=$(free | awk 'NR==2{printf "%.1f", $3/$2*100}')
    local disk_usage=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
    
    echo "Overall System Health:"
    echo "  CPU Usage: ${cpu_usage}%"
    echo "  Memory Usage: ${mem_percent}%"
    echo "  Root Disk Usage: ${disk_usage}%"
    echo ""
    
    local issues=0
    
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        ((issues++))
        print_warning "High CPU usage detected"
    fi
    
    if (( $(echo "$mem_percent > 80" | bc -l) )); then
        ((issues++))
        print_warning "High memory usage detected"
    fi
    
    if [ "$disk_usage" -gt 80 ]; then
        ((issues++))
        print_warning "High disk usage detected"
    fi
    
    if [ $issues -eq 0 ]; then
        print_success "No performance issues detected"
    else
        print_warning "Found $issues performance issue(s)"
    fi
}

# Main
main() {
    echo "======================================"
    echo "   SYSTEM PERFORMANCE CHECK"
    echo "======================================"
    echo "Timestamp: $(date)"
    
    check_cpu
    check_memory
    check_disk_usage
    check_disk_io
    check_network
    check_services
    performance_summary
    
    echo ""
    echo "======================================"
    print_info "Performance check complete"
}

main "$@"
