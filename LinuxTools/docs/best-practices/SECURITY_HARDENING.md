# Security Hardening Best Practices

This guide covers security hardening best practices for Linux systems using LinuxTools.

## Overview

Security hardening is the process of securing a system by reducing its attack surface and implementing security controls.

## SSH Hardening

### Quick Hardening

```bash
cd LinuxTools/security-tools/ssh-hardening
sudo ./harden-ssh.sh
```

### Manual Hardening Steps

Edit `/etc/ssh/sshd_config`:

```bash
# Disable root login
PermitRootLogin no

# Use SSH keys only
PasswordAuthentication no
PubkeyAuthentication yes

# Disable empty passwords
PermitEmptyPasswords no

# Use Protocol 2
Protocol 2

# Limit authentication attempts
MaxAuthTries 3

# Set timeouts
LoginGraceTime 60
ClientAliveInterval 300
ClientAliveCountMax 2

# Disable X11 forwarding
X11Forwarding no

# Restrict to specific users
AllowUsers user1 user2
```

Apply changes:
```bash
sudo systemctl restart sshd
```

### SSH Key Setup

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy to server
ssh-copy-id user@server

# Test key-based login
ssh user@server
```

## Firewall Configuration

### UFW (Ubuntu/Debian)

```bash
cd LinuxTools/security-tools/firewall-setup
sudo ./setup-ufw.sh
```

Manual configuration:
```bash
# Enable UFW
sudo ufw enable

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Rate limiting for SSH
sudo ufw limit 22/tcp

# Check status
sudo ufw status verbose
```

### Firewalld (RHEL/CentOS)

```bash
# Enable firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Allow services
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Reload
sudo firewall-cmd --reload

# Check status
sudo firewall-cmd --list-all
```

## User Account Security

### Password Policies

Edit `/etc/login.defs`:
```bash
PASS_MAX_DAYS   90
PASS_MIN_DAYS   10
PASS_WARN_AGE   7
PASS_MIN_LEN    12
```

### PAM Configuration

Install and configure pam_pwquality:
```bash
sudo apt-get install libpam-pwquality
```

Edit `/etc/pam.d/common-password`:
```
password requisite pam_pwquality.so retry=3 minlen=12 difok=3
```

### Disable Unused Accounts

```bash
# Lock account
sudo usermod -L username

# Disable shell
sudo usermod -s /sbin/nologin username

# List locked accounts
sudo passwd -S -a | grep "L"
```

## File System Security

### Secure Mount Options

Edit `/etc/fstab`:
```
/tmp    /tmp    tmpfs   defaults,noexec,nosuid,nodev 0 0
/var/tmp /var/tmp tmpfs  defaults,noexec,nosuid,nodev 0 0
```

### Find World-Writable Files

```bash
sudo find / -xdev -type f -perm -0002 -ls
```

### Set Proper Permissions

```bash
# Secure sensitive files
sudo chmod 600 /etc/ssh/sshd_config
sudo chmod 644 /etc/passwd
sudo chmod 640 /etc/shadow
sudo chmod 640 /etc/gshadow
```

## Kernel Hardening

### Sysctl Security Settings

Edit `/etc/sysctl.conf`:

```bash
# IP forwarding
net.ipv4.ip_forward = 0

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Log Martians
net.ipv4.conf.all.log_martians = 1

# Ignore ICMP ping
net.ipv4.icmp_echo_ignore_all = 1

# Enable TCP SYN Cookie protection
net.ipv4.tcp_syncookies = 1

# Enable bad error message protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Enable reverse path filtering
net.ipv4.conf.all.rp_filter = 1
```

Apply settings:
```bash
sudo sysctl -p
```

## Security Scanning

### Lynis Audit

```bash
cd LinuxTools/security-tools/vulnerability-scanning
sudo ./lynis-audit.sh
```

### Rkhunter

```bash
# Install
sudo apt-get install rkhunter

# Update database
sudo rkhunter --update

# Run scan
sudo rkhunter --check
```

### ClamAV

```bash
# Install
sudo apt-get install clamav clamav-daemon

# Update database
sudo freshclam

# Scan system
sudo clamscan -r /home
```

## Intrusion Detection

### Fail2Ban

```bash
# Install
sudo apt-get install fail2ban

# Configure
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit jail.local
sudo vim /etc/fail2ban/jail.local
```

Configuration:
```ini
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

### AIDE (File Integrity)

```bash
# Install
sudo apt-get install aide

# Initialize database
sudo aideinit

# Check integrity
sudo aide --check
```

## Audit Logging

### Enable auditd

```bash
# Install
sudo apt-get install auditd

# Start service
sudo systemctl enable auditd
sudo systemctl start auditd

# Add audit rules
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
sudo auditctl -w /etc/shadow -p wa -k shadow_changes
sudo auditctl -w /etc/ssh/sshd_config -p wa -k sshd_config_changes

# View audit logs
sudo ausearch -k passwd_changes
```

## Application Security

### Disable Unnecessary Services

```bash
# List all services
sudo systemctl list-unit-files --type=service

# Disable service
sudo systemctl disable service-name
sudo systemctl stop service-name
```

### Remove Unnecessary Packages

```bash
# List installed packages
dpkg -l

# Remove package
sudo apt-get remove package-name
sudo apt-get autoremove
```

## Network Security

### Disable IPv6 (if not needed)

Edit `/etc/sysctl.conf`:
```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

### TCP Wrappers

Edit `/etc/hosts.allow`:
```
sshd: 192.168.1.0/24
```

Edit `/etc/hosts.deny`:
```
ALL: ALL
```

## SELinux / AppArmor

### SELinux (RHEL/CentOS)

```bash
# Check status
sestatus

# Set enforcing mode
sudo setenforce 1

# Make permanent
sudo vim /etc/selinux/config
# Set: SELINUX=enforcing
```

### AppArmor (Ubuntu/Debian)

```bash
# Check status
sudo aa-status

# Enable profile
sudo aa-enforce /etc/apparmor.d/usr.bin.program

# Disable profile
sudo aa-disable /etc/apparmor.d/usr.bin.program
```

## Compliance Checking

### CIS Benchmarks

```bash
cd LinuxTools/security-tools/compliance-checks
sudo ./cis-benchmark.sh
```

## Regular Maintenance

### Security Update Schedule

Create cron job:
```bash
sudo crontab -e
```

Add:
```bash
# Daily security updates
0 2 * * * /usr/bin/apt-get update && /usr/bin/apt-get upgrade -y

# Weekly security scan
0 3 * * 0 /path/to/LinuxTools/security-tools/vulnerability-scanning/lynis-audit.sh
```

## Security Checklist

- [ ] SSH hardening applied
- [ ] Firewall configured and enabled
- [ ] Password policies enforced
- [ ] Unnecessary services disabled
- [ ] Security updates automated
- [ ] Intrusion detection configured
- [ ] Audit logging enabled
- [ ] File integrity monitoring active
- [ ] Regular security scans scheduled
- [ ] Backups configured and tested

## References

- CIS Benchmarks
- NIST Security Guidelines
- OWASP Security Best Practices
- Linux Kernel Security Documentation
