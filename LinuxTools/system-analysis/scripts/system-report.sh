#!/bin/bash
#
# Comprehensive System Report Generator
# Generates detailed JSON and HTML reports of system status
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

# Output files
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="${HOME}/system-reports"
JSON_FILE="$OUTPUT_DIR/system-report-${TIMESTAMP}.json"
HTML_FILE="$OUTPUT_DIR/system-report-${TIMESTAMP}.html"
TXT_FILE="$OUTPUT_DIR/system-report-${TIMESTAMP}.txt"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Initialize JSON
init_json() {
    echo "{" > "$JSON_FILE"
    echo '  "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",' >> "$JSON_FILE"
    echo '  "hostname": "'$(hostname)'",' >> "$JSON_FILE"
}

# System information
collect_system_info() {
    print_info "Collecting system information..."
    
    cat >> "$JSON_FILE" <<EOF
  "system": {
    "hostname": "$(hostname)",
    "fqdn": "$(hostname -f 2>/dev/null || echo 'N/A')",
    "kernel": "$(uname -r)",
    "architecture": "$(uname -m)",
    "os": "$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')",
    "uptime": "$(uptime -p 2>/dev/null || uptime)",
    "load_average": "$(uptime | awk -F'load average:' '{print $2}')"
  },
EOF
}

# CPU information
collect_cpu_info() {
    print_info "Collecting CPU information..."
    
    local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    local cpu_cores=$(nproc)
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d% -f1)
    
    cat >> "$JSON_FILE" <<EOF
  "cpu": {
    "model": "$cpu_model",
    "cores": $cpu_cores,
    "usage_percent": "$cpu_usage"
  },
EOF
}

# Memory information
collect_memory_info() {
    print_info "Collecting memory information..."
    
    local total_mem=$(free -m | awk 'NR==2{print $2}')
    local used_mem=$(free -m | awk 'NR==2{print $3}')
    local free_mem=$(free -m | awk 'NR==2{print $4}')
    local mem_percent=$(awk "BEGIN {printf \"%.2f\", ($used_mem/$total_mem)*100}")
    
    cat >> "$JSON_FILE" <<EOF
  "memory": {
    "total_mb": $total_mem,
    "used_mb": $used_mem,
    "free_mb": $free_mem,
    "usage_percent": "$mem_percent"
  },
EOF
}

# Disk information
collect_disk_info() {
    print_info "Collecting disk information..."
    
    echo '  "disks": [' >> "$JSON_FILE"
    
    local first=true
    while IFS= read -r line; do
        if [ "$first" = false ]; then
            echo "," >> "$JSON_FILE"
        fi
        first=false
        
        local filesystem=$(echo $line | awk '{print $1}')
        local size=$(echo $line | awk '{print $2}')
        local used=$(echo $line | awk '{print $3}')
        local avail=$(echo $line | awk '{print $4}')
        local use_percent=$(echo $line | awk '{print $5}')
        local mount=$(echo $line | awk '{print $6}')
        
        cat >> "$JSON_FILE" <<EOF
    {
      "filesystem": "$filesystem",
      "size": "$size",
      "used": "$used",
      "available": "$avail",
      "use_percent": "$use_percent",
      "mounted_on": "$mount"
    }
EOF
    done < <(df -h | grep -v "tmpfs" | grep -v "loop" | tail -n +2)
    
    echo "" >> "$JSON_FILE"
    echo "  ]," >> "$JSON_FILE"
}

# Network information
collect_network_info() {
    print_info "Collecting network information..."
    
    echo '  "network": {' >> "$JSON_FILE"
    echo '    "interfaces": [' >> "$JSON_FILE"
    
    local first=true
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        if [ "$first" = false ]; then
            echo "," >> "$JSON_FILE"
        fi
        first=false
        
        local ip=$(ip addr show "$iface" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1 || echo "N/A")
        local mac=$(cat /sys/class/net/$iface/address 2>/dev/null || echo "N/A")
        local state=$(cat /sys/class/net/$iface/operstate 2>/dev/null || echo "unknown")
        
        cat >> "$JSON_FILE" <<EOF
      {
        "name": "$iface",
        "ip": "$ip",
        "mac": "$mac",
        "state": "$state"
      }
EOF
    done
    
    echo "" >> "$JSON_FILE"
    echo "    ]" >> "$JSON_FILE"
    echo "  }," >> "$JSON_FILE"
}

# Running processes
collect_process_info() {
    print_info "Collecting process information..."
    
    local total_processes=$(ps aux | wc -l)
    local running_processes=$(ps aux | grep -c " R ")
    local sleeping_processes=$(ps aux | grep -c " S ")
    
    cat >> "$JSON_FILE" <<EOF
  "processes": {
    "total": $total_processes,
    "running": $running_processes,
    "sleeping": $sleeping_processes
  }
EOF
}

# Finalize JSON
finalize_json() {
    echo "}" >> "$JSON_FILE"
}

# Generate HTML report
generate_html() {
    print_info "Generating HTML report..."
    
    cat > "$HTML_FILE" <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>System Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 3px solid #007bff; padding-bottom: 10px; }
        h2 { color: #555; margin-top: 30px; border-bottom: 2px solid #e0e0e0; padding-bottom: 5px; }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 15px; margin: 15px 0; }
        .info-card { background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #007bff; }
        .label { font-weight: bold; color: #666; }
        .value { color: #333; margin-left: 10px; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #007bff; color: white; }
        tr:hover { background: #f5f5f5; }
        .timestamp { color: #888; font-size: 0.9em; }
        .status-ok { color: #28a745; }
        .status-warning { color: #ffc107; }
        .status-error { color: #dc3545; }
    </style>
</head>
<body>
<div class="container">
    <h1>System Report</h1>
    <p class="timestamp">Generated: $(date)</p>
    
    <h2>System Information</h2>
    <div class="info-grid">
        <div class="info-card">
            <span class="label">Hostname:</span><span class="value">$(hostname)</span>
        </div>
        <div class="info-card">
            <span class="label">OS:</span><span class="value">$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')</span>
        </div>
        <div class="info-card">
            <span class="label">Kernel:</span><span class="value">$(uname -r)</span>
        </div>
        <div class="info-card">
            <span class="label">Uptime:</span><span class="value">$(uptime -p 2>/dev/null || uptime)</span>
        </div>
    </div>
    
    <h2>CPU & Memory</h2>
    <div class="info-grid">
        <div class="info-card">
            <span class="label">CPU Model:</span><span class="value">$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)</span>
        </div>
        <div class="info-card">
            <span class="label">CPU Cores:</span><span class="value">$(nproc)</span>
        </div>
        <div class="info-card">
            <span class="label">Total Memory:</span><span class="value">$(free -h | awk 'NR==2{print $2}')</span>
        </div>
        <div class="info-card">
            <span class="label">Used Memory:</span><span class="value">$(free -h | awk 'NR==2{print $3}')</span>
        </div>
    </div>
    
    <h2>Disk Usage</h2>
    <table>
        <tr>
            <th>Filesystem</th>
            <th>Size</th>
            <th>Used</th>
            <th>Available</th>
            <th>Use %</th>
            <th>Mounted On</th>
        </tr>
EOF
    
    df -h | grep -v "tmpfs" | grep -v "loop" | tail -n +2 | while read line; do
        echo "        <tr>" >> "$HTML_FILE"
        echo "            <td>$(echo $line | awk '{print $1}')</td>" >> "$HTML_FILE"
        echo "            <td>$(echo $line | awk '{print $2}')</td>" >> "$HTML_FILE"
        echo "            <td>$(echo $line | awk '{print $3}')</td>" >> "$HTML_FILE"
        echo "            <td>$(echo $line | awk '{print $4}')</td>" >> "$HTML_FILE"
        echo "            <td>$(echo $line | awk '{print $5}')</td>" >> "$HTML_FILE"
        echo "            <td>$(echo $line | awk '{print $6}')</td>" >> "$HTML_FILE"
        echo "        </tr>" >> "$HTML_FILE"
    done
    
    cat >> "$HTML_FILE" <<EOF
    </table>
    
    <h2>Network Interfaces</h2>
    <table>
        <tr>
            <th>Interface</th>
            <th>IP Address</th>
            <th>MAC Address</th>
            <th>State</th>
        </tr>
EOF
    
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        local ip=$(ip addr show "$iface" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1 || echo "N/A")
        local mac=$(cat /sys/class/net/$iface/address 2>/dev/null || echo "N/A")
        local state=$(cat /sys/class/net/$iface/operstate 2>/dev/null || echo "unknown")
        
        echo "        <tr>" >> "$HTML_FILE"
        echo "            <td>$iface</td>" >> "$HTML_FILE"
        echo "            <td>$ip</td>" >> "$HTML_FILE"
        echo "            <td>$mac</td>" >> "$HTML_FILE"
        echo "            <td>$state</td>" >> "$HTML_FILE"
        echo "        </tr>" >> "$HTML_FILE"
    done
    
    cat >> "$HTML_FILE" <<EOF
    </table>
</div>
</body>
</html>
EOF
}

# Generate text report
generate_text() {
    print_info "Generating text report..."
    
    {
        echo "======================================"
        echo "       SYSTEM REPORT"
        echo "======================================"
        echo "Generated: $(date)"
        echo ""
        echo "SYSTEM INFORMATION"
        echo "--------------------------------------"
        echo "Hostname: $(hostname)"
        echo "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')"
        echo "Kernel: $(uname -r)"
        echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
        echo ""
        echo "CPU INFORMATION"
        echo "--------------------------------------"
        echo "Model: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
        echo "Cores: $(nproc)"
        echo ""
        echo "MEMORY INFORMATION"
        echo "--------------------------------------"
        free -h
        echo ""
        echo "DISK USAGE"
        echo "--------------------------------------"
        df -h | grep -v "tmpfs" | grep -v "loop"
        echo ""
        echo "NETWORK INTERFACES"
        echo "--------------------------------------"
        ip addr show
        echo ""
        echo "======================================"
    } > "$TXT_FILE"
}

# Main
main() {
    print_info "Generating System Report"
    print_info "========================="
    
    init_json
    collect_system_info
    collect_cpu_info
    collect_memory_info
    collect_disk_info
    collect_network_info
    collect_process_info
    finalize_json
    
    generate_html
    generate_text
    
    print_success "System reports generated!"
    print_info ""
    print_info "Reports saved to:"
    print_info "  JSON: $JSON_FILE"
    print_info "  HTML: $HTML_FILE"
    print_info "  TEXT: $TXT_FILE"
    print_info ""
    print_info "Open HTML report: file://$HTML_FILE"
}

main "$@"
