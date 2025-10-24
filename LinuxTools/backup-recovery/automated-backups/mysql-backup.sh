#!/bin/bash
#
# MySQL Backup Script
# Automated MySQL database backup with compression
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
BACKUP_DIR="${BACKUP_DIR:-/backup/mysql}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

# Check if mysqldump is available
if ! command -v mysqldump &> /dev/null; then
    print_error "mysqldump is not installed"
    exit 1
fi

# Create backup directory
create_backup_dir() {
    print_info "Creating backup directory..."
    mkdir -p "$BACKUP_DIR"
    print_success "Backup directory: $BACKUP_DIR"
}

# Backup all databases
backup_all_databases() {
    print_info "Backing up all MySQL databases..."
    
    local backup_file="$BACKUP_DIR/all-databases-${TIMESTAMP}.sql.gz"
    
    if [ -n "$MYSQL_PASSWORD" ]; then
        mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" \
            --all-databases \
            --single-transaction \
            --quick \
            --lock-tables=false \
            | gzip > "$backup_file"
    else
        mysqldump -u "$MYSQL_USER" \
            --all-databases \
            --single-transaction \
            --quick \
            --lock-tables=false \
            | gzip > "$backup_file"
    fi
    
    print_success "Backup created: $backup_file"
    
    local size=$(du -h "$backup_file" | awk '{print $1}')
    print_info "Backup size: $size"
}

# Backup specific database
backup_database() {
    local db_name="$1"
    print_info "Backing up database: $db_name"
    
    local backup_file="$BACKUP_DIR/${db_name}-${TIMESTAMP}.sql.gz"
    
    if [ -n "$MYSQL_PASSWORD" ]; then
        mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" \
            --databases "$db_name" \
            --single-transaction \
            --quick \
            | gzip > "$backup_file"
    else
        mysqldump -u "$MYSQL_USER" \
            --databases "$db_name" \
            --single-transaction \
            --quick \
            | gzip > "$backup_file"
    fi
    
    print_success "Backup created: $backup_file"
}

# Cleanup old backups
cleanup_old_backups() {
    print_info "Cleaning up backups older than $RETENTION_DAYS days..."
    
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
    
    print_success "Cleanup complete"
}

# Show backup list
show_backups() {
    echo ""
    print_info "Recent Backups"
    echo "======================================"
    ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null | tail -5 || echo "No backups found"
}

# Main
main() {
    echo "======================================"
    echo "     MySQL Backup Script"
    echo "======================================"
    echo "Timestamp: $(date)"
    echo ""
    
    create_backup_dir
    
    if [ $# -eq 0 ]; then
        backup_all_databases
    else
        for db in "$@"; do
            backup_database "$db"
        done
    fi
    
    cleanup_old_backups
    show_backups
    
    print_success "MySQL backup complete!"
}

main "$@"
