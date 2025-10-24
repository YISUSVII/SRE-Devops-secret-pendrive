#!/bin/bash
#
# Log Cleanup Script
# Cleans up old log files to free disk space
#

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Configuration
LOG_DIRS=("/var/log" "/var/log/apache2" "/var/log/nginx" "/var/log/mysql")
DAYS_TO_KEEP="${DAYS_TO_KEEP:-30}"

echo "======================================"
echo "     Log Cleanup Script"
echo "======================================"
echo "Keeping logs from last $DAYS_TO_KEEP days"
echo ""

# Check disk space before
print_info "Disk space before cleanup:"
df -h /var

# Clean old logs
print_info "Cleaning logs older than $DAYS_TO_KEEP days..."

for dir in "${LOG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_info "Cleaning $dir..."
        sudo find "$dir" -name "*.log.*" -mtime +$DAYS_TO_KEEP -delete 2>/dev/null || true
        sudo find "$dir" -name "*.gz" -mtime +$DAYS_TO_KEEP -delete 2>/dev/null || true
    fi
done

# Clean journal logs
print_info "Cleaning journal logs..."
sudo journalctl --vacuum-time=${DAYS_TO_KEEP}d || true

# Check disk space after
echo ""
print_info "Disk space after cleanup:"
df -h /var

print_success "Log cleanup complete!"
