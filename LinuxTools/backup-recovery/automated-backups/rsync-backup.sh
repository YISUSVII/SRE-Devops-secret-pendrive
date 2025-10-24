#!/bin/bash
#
# Rsync Backup Script
# Performs incremental backups using rsync
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

# Configuration
SOURCE_DIR="${SOURCE_DIR:-/home}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="backup-${TIMESTAMP}"
LOG_FILE="/var/log/linuxtools/rsync-backup-${TIMESTAMP}.log"

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Check if rsync is installed
if ! command -v rsync &> /dev/null; then
    print_error "rsync is not installed"
    exit 1
fi

# Create backup directory
create_backup_dir() {
    print_info "Creating backup directory..."
    
    if [ ! -d "$BACKUP_DIR" ]; then
        sudo mkdir -p "$BACKUP_DIR"
        print_success "Created backup directory: $BACKUP_DIR"
    else
        print_info "Backup directory exists: $BACKUP_DIR"
    fi
}

# Perform backup
perform_backup() {
    print_info "Starting rsync backup..."
    print_info "Source: $SOURCE_DIR"
    print_info "Destination: $BACKUP_DIR/$BACKUP_NAME"
    
    local LATEST_LINK="$BACKUP_DIR/latest"
    local BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    
    # Rsync command with options
    sudo rsync -avz \
        --progress \
        --delete \
        --link-dest="$LATEST_LINK" \
        --exclude='*.tmp' \
        --exclude='*.cache' \
        --exclude='lost+found' \
        --log-file="$LOG_FILE" \
        "$SOURCE_DIR/" \
        "$BACKUP_PATH/" 2>&1 | tee -a "$LOG_FILE"
    
    # Update latest symlink
    sudo rm -f "$LATEST_LINK"
    sudo ln -s "$BACKUP_PATH" "$LATEST_LINK"
    
    print_success "Backup completed"
}

# Show backup stats
show_stats() {
    echo ""
    print_info "Backup Statistics"
    echo "======================================"
    echo "Backup location: $BACKUP_DIR/$BACKUP_NAME"
    echo "Log file: $LOG_FILE"
    
    if [ -d "$BACKUP_DIR/$BACKUP_NAME" ]; then
        local size=$(du -sh "$BACKUP_DIR/$BACKUP_NAME" | awk '{print $1}')
        echo "Backup size: $size"
    fi
    
    echo ""
    print_info "Available backups:"
    ls -lh "$BACKUP_DIR" | grep "^d" | tail -5
}

# Main
main() {
    echo "======================================"
    echo "      Rsync Backup Script"
    echo "======================================"
    echo "Timestamp: $(date)"
    echo ""
    
    # Allow override via environment or args
    if [ $# -ge 2 ]; then
        SOURCE_DIR="$1"
        BACKUP_DIR="$2"
    fi
    
    create_backup_dir
    perform_backup
    show_stats
    
    print_success "Backup process complete!"
}

main "$@"
