#!/bin/bash
#
# Security Audit Script
# Performs basic security checks on Linux system
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

# Check for root/sudo access
check_permissions() {
    echo ""
    print_info "Permission Check"
    echo "======================================"
    
    if [[ $EUID -eq 0 ]]; then
        print_success "Running with root privileges"
    else
        print_warning "Not running as root - some checks may be limited"
    fi
}

# Check SSH configuration
check_ssh() {
    echo ""
    print_info "SSH Security Check"
    echo "======================================"
    
    if [ -f /etc/ssh/sshd_config ]; then
        # Check PermitRootLogin
        if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
            print_error "Root login via SSH is enabled!"
        else
            print_success "Root login via SSH is disabled"
        fi
        
        # Check PasswordAuthentication
        if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
            print_warning "Password authentication is enabled"
        else
            print_success "Password authentication is disabled"
        fi
        
        # Check Protocol
        if grep -q "^Protocol 1" /etc/ssh/sshd_config; then
            print_error "SSH Protocol 1 is enabled (insecure)!"
        else
            print_success "SSH Protocol is secure"
        fi
    else
        print_warning "SSH config not found"
    fi
}

# Check firewall status
check_firewall() {
    echo ""
    print_info "Firewall Status Check"
    echo "======================================"
    
    if command -v ufw &> /dev/null; then
        local status=$(sudo ufw status | grep "Status:" | awk '{print $2}')
        if [ "$status" = "active" ]; then
            print_success "UFW firewall is active"
        else
            print_warning "UFW firewall is inactive"
        fi
    elif command -v firewall-cmd &> /dev/null; then
        if sudo firewall-cmd --state &> /dev/null; then
            print_success "Firewalld is active"
        else
            print_warning "Firewalld is inactive"
        fi
    elif command -v iptables &> /dev/null; then
        local rules=$(sudo iptables -L -n | wc -l)
        if [ "$rules" -gt 8 ]; then
            print_success "iptables rules are configured"
        else
            print_warning "No iptables rules found"
        fi
    else
        print_error "No firewall found!"
    fi
}

# Check for users with empty passwords
check_empty_passwords() {
    echo ""
    print_info "Empty Password Check"
    echo "======================================"
    
    local empty_pass=$(sudo awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null | wc -l)
    
    if [ "$empty_pass" -gt 0 ]; then
        print_error "Found $empty_pass user(s) with empty passwords!"
        sudo awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null
    else
        print_success "No users with empty passwords"
    fi
}

# Check for users with UID 0
check_uid_zero() {
    echo ""
    print_info "UID 0 Users Check"
    echo "======================================"
    
    local uid_zero=$(awk -F: '($3 == 0) {print $1}' /etc/passwd | grep -v "^root$" | wc -l)
    
    if [ "$uid_zero" -gt 0 ]; then
        print_error "Found non-root users with UID 0:"
        awk -F: '($3 == 0) {print $1}' /etc/passwd | grep -v "^root$"
    else
        print_success "Only root has UID 0"
    fi
}

# Check world-writable files
check_world_writable() {
    echo ""
    print_info "World-Writable Files Check"
    echo "======================================"
    
    print_info "Checking for world-writable files (this may take a while)..."
    local count=$(sudo find / -xdev -type f -perm -0002 2>/dev/null | wc -l)
    
    if [ "$count" -gt 0 ]; then
        print_warning "Found $count world-writable files"
        print_info "Run: find / -xdev -type f -perm -0002 to list them"
    else
        print_success "No world-writable files found"
    fi
}

# Check sudo access
check_sudo() {
    echo ""
    print_info "Sudo Access Check"
    echo "======================================"
    
    if [ -f /etc/sudoers ]; then
        print_info "Users/groups with sudo access:"
        sudo grep -v "^#" /etc/sudoers | grep -v "^$" | grep "%\|^[a-zA-Z]" | head -10
        print_success "Sudoers file exists and is readable"
    else
        print_warning "Sudoers file not found"
    fi
}

# Check listening ports
check_listening_ports() {
    echo ""
    print_info "Listening Ports Check"
    echo "======================================"
    
    if command -v ss &> /dev/null; then
        print_info "Open ports:"
        sudo ss -tuln | grep LISTEN | head -10
        print_success "Port scan complete"
    elif command -v netstat &> /dev/null; then
        print_info "Open ports:"
        sudo netstat -tuln | grep LISTEN | head -10
        print_success "Port scan complete"
    else
        print_warning "Neither ss nor netstat available"
    fi
}

# Check for security updates
check_updates() {
    echo ""
    print_info "Security Updates Check"
    echo "======================================"
    
    if command -v apt-get &> /dev/null; then
        local updates=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l)
        if [ "$updates" -gt 0 ]; then
            print_warning "$updates security updates available"
        else
            print_success "System is up to date"
        fi
    elif command -v yum &> /dev/null; then
        local updates=$(sudo yum list updates --security 2>/dev/null | wc -l)
        if [ "$updates" -gt 3 ]; then
            print_warning "Security updates available"
        else
            print_success "System is up to date"
        fi
    fi
}

# Check failed login attempts
check_failed_logins() {
    echo ""
    print_info "Failed Login Attempts"
    echo "======================================"
    
    if [ -f /var/log/auth.log ]; then
        local failed=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
        if [ "$failed" -gt 100 ]; then
            print_error "High number of failed login attempts: $failed"
        elif [ "$failed" -gt 10 ]; then
            print_warning "Failed login attempts: $failed"
        else
            print_success "Failed login attempts: $failed"
        fi
    elif [ -f /var/log/secure ]; then
        local failed=$(grep "Failed password" /var/log/secure 2>/dev/null | wc -l)
        if [ "$failed" -gt 100 ]; then
            print_error "High number of failed login attempts: $failed"
        elif [ "$failed" -gt 10 ]; then
            print_warning "Failed login attempts: $failed"
        else
            print_success "Failed login attempts: $failed"
        fi
    fi
}

# Security summary
security_summary() {
    echo ""
    print_info "Security Summary"
    echo "======================================"
    
    echo "Security audit completed at $(date)"
    echo ""
    echo "Recommendations:"
    echo "  1. Review and fix any CRITICAL issues immediately"
    echo "  2. Address WARNING items as soon as possible"
    echo "  3. Consider running: lynis audit system (for detailed audit)"
    echo "  4. Keep system updated with security patches"
    echo "  5. Review firewall rules regularly"
}

# Main
main() {
    echo "======================================"
    echo "      SECURITY AUDIT"
    echo "======================================"
    echo "Timestamp: $(date)"
    
    check_permissions
    check_ssh
    check_firewall
    check_empty_passwords
    check_uid_zero
    check_sudo
    check_listening_ports
    check_updates
    check_failed_logins
    check_world_writable
    security_summary
    
    echo ""
    echo "======================================"
    print_info "Security audit complete"
}

main "$@"
