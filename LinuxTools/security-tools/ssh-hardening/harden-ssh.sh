#!/bin/bash
#
# SSH Hardening Script
# Hardens SSH configuration with security best practices
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

SSH_CONFIG="/etc/ssh/sshd_config"
BACKUP_FILE="${SSH_CONFIG}.backup-$(date +%Y%m%d-%H%M%S)"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    exit 1
fi

# Backup current config
backup_config() {
    print_info "Backing up SSH configuration..."
    cp "$SSH_CONFIG" "$BACKUP_FILE"
    print_success "Backup created: $BACKUP_FILE"
}

# Harden SSH
harden_ssh() {
    print_info "Applying SSH hardening..."
    
    # Disable root login
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"
    print_success "Disabled root login"
    
    # Disable password authentication (use keys only)
    read -p "Disable password authentication? [y/N]: " disable_pass
    if [[ "$disable_pass" =~ ^[Yy]$ ]]; then
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSH_CONFIG"
        print_success "Disabled password authentication"
    fi
    
    # Disable empty passwords
    sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSH_CONFIG"
    print_success "Disabled empty passwords"
    
    # Use Protocol 2 only
    if ! grep -q "^Protocol 2" "$SSH_CONFIG"; then
        echo "Protocol 2" >> "$SSH_CONFIG"
    fi
    print_success "Enforced SSH Protocol 2"
    
    # Set login grace time
    sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 60/' "$SSH_CONFIG"
    print_success "Set login grace time to 60 seconds"
    
    # Limit max authentication attempts
    sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSH_CONFIG"
    print_success "Limited max auth tries to 3"
    
    # Disable X11 forwarding
    sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' "$SSH_CONFIG"
    print_success "Disabled X11 forwarding"
    
    # Set max sessions
    sed -i 's/^#*MaxSessions.*/MaxSessions 2/' "$SSH_CONFIG"
    print_success "Limited max sessions to 2"
    
    # Set client alive interval
    sed -i 's/^#*ClientAliveInterval.*/ClientAliveInterval 300/' "$SSH_CONFIG"
    sed -i 's/^#*ClientAliveCountMax.*/ClientAliveCountMax 2/' "$SSH_CONFIG"
    print_success "Configured client alive settings"
    
    # Disable host-based authentication
    sed -i 's/^#*HostbasedAuthentication.*/HostbasedAuthentication no/' "$SSH_CONFIG"
    print_success "Disabled host-based authentication"
    
    # Configure allowed users (optional)
    read -p "Restrict SSH to specific users? [y/N]: " restrict_users
    if [[ "$restrict_users" =~ ^[Yy]$ ]]; then
        read -p "Enter allowed usernames (space-separated): " users
        if ! grep -q "^AllowUsers" "$SSH_CONFIG"; then
            echo "AllowUsers $users" >> "$SSH_CONFIG"
        else
            sed -i "s/^AllowUsers.*/AllowUsers $users/" "$SSH_CONFIG"
        fi
        print_success "Restricted SSH to: $users"
    fi
}

# Test configuration
test_config() {
    print_info "Testing SSH configuration..."
    
    if sshd -t; then
        print_success "SSH configuration is valid"
    else
        print_error "SSH configuration has errors!"
        print_warning "Restoring backup..."
        cp "$BACKUP_FILE" "$SSH_CONFIG"
        exit 1
    fi
}

# Restart SSH service
restart_ssh() {
    print_info "Restarting SSH service..."
    
    if systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null; then
        print_success "SSH service restarted"
    else
        service sshd restart 2>/dev/null || service ssh restart 2>/dev/null
        print_success "SSH service restarted"
    fi
}

# Show summary
show_summary() {
    echo ""
    print_info "SSH Hardening Summary"
    echo "======================================"
    echo "Configuration file: $SSH_CONFIG"
    echo "Backup file: $BACKUP_FILE"
    echo ""
    echo "Applied hardening:"
    echo "  ✓ Disabled root login"
    echo "  ✓ Disabled empty passwords"
    echo "  ✓ Enforced Protocol 2"
    echo "  ✓ Limited authentication attempts"
    echo "  ✓ Configured timeouts"
    echo "  ✓ Disabled X11 forwarding"
    echo ""
    print_warning "IMPORTANT: Test SSH access before closing this session!"
    print_info "To revert changes: cp $BACKUP_FILE $SSH_CONFIG && systemctl restart sshd"
}

# Main
main() {
    echo "======================================"
    echo "      SSH Hardening Script"
    echo "======================================"
    echo ""
    
    print_warning "This script will harden your SSH configuration"
    print_warning "Make sure you have an alternative way to access this system!"
    echo ""
    read -p "Continue? [y/N]: " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Aborted by user"
        exit 0
    fi
    
    backup_config
    harden_ssh
    test_config
    restart_ssh
    show_summary
}

main "$@"
