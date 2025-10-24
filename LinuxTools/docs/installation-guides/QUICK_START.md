# LinuxTools Quick Start Guide

This guide will help you get started with LinuxTools quickly.

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/YISUSVII/SRE-Devops-secret-pendrive.git
cd SRE-Devops-secret-pendrive/LinuxTools
```

### 2. Run the Setup Script

```bash
sudo ./setup.sh
```

The setup script will:
- Detect your Linux distribution
- Install basic dependencies
- Present an interactive menu for component installation

## Quick Examples

### Generate System Report

```bash
cd system-analysis/scripts
./system-report.sh
```

This creates JSON, HTML, and text reports in `~/system-reports/`

### Check System Performance

```bash
cd system-analysis/scripts
./performance-check.sh
```

### Run Security Audit

```bash
cd system-analysis/scripts
sudo ./security-audit.sh
```

### Harden SSH

```bash
cd security-tools/ssh-hardening
sudo ./harden-ssh.sh
```

### Setup Firewall

```bash
cd security-tools/firewall-setup
sudo ./setup-ufw.sh
```

### Install Monitoring Agent

```bash
# Prometheus Node Exporter
cd monitoring-agents/prometheus
sudo ./setup-node-exporter.sh

# Netdata (Real-time monitoring)
cd monitoring-agents/netdata
sudo ./install.sh
```

### Backup System

```bash
# Rsync backup
cd backup-recovery/automated-backups
sudo ./rsync-backup.sh /home /backup

# MySQL backup
export MYSQL_PASSWORD="your-password"
cd backup-recovery/automated-backups
./mysql-backup.sh
```

### Test Network

```bash
cd network-tools/connectivity-tests
./network-test.sh
```

## Component-Specific Installation

### Install Only Monitoring Agents

```bash
sudo ./setup.sh
# Select option 1 from the menu
```

### Install Only Security Tools

```bash
sudo ./setup.sh
# Select option 3 from the menu
```

### Install Everything

```bash
sudo ./setup.sh
# Select option 11 from the menu
```

## Directory Structure

```
LinuxTools/
├── monitoring-agents/      # Datadog, Prometheus, Netdata, etc.
├── system-analysis/        # System reports, performance checks
├── security-tools/         # SSH hardening, firewall, scanning
├── network-tools/          # Connectivity tests, benchmarks
├── backup-recovery/        # Backup scripts and tools
├── container-tools/        # Docker, Kubernetes tools
├── cloud-tools/            # AWS, Azure, GCP monitoring
├── database-tools/         # MySQL, PostgreSQL, MongoDB
├── web-server-tools/       # Apache, Nginx tools
├── automation-scripts/     # System automation
└── docs/                   # Documentation
```

## Common Tasks

### Daily Health Check

```bash
#!/bin/bash
cd /path/to/LinuxTools/system-analysis/scripts
./performance-check.sh
./security-audit.sh | grep -i "critical\|warning"
```

### Weekly System Maintenance

```bash
#!/bin/bash
# Update system
cd /path/to/LinuxTools/automation-scripts/package-management
sudo ./update-system.sh

# Clean logs
cd ../system-maintenance
sudo ./log-cleanup.sh

# Backup
cd /path/to/LinuxTools/backup-recovery/automated-backups
sudo ./rsync-backup.sh /home /backup
```

### Monthly Security Audit

```bash
#!/bin/bash
cd /path/to/LinuxTools/security-tools/vulnerability-scanning
sudo ./lynis-audit.sh
```

## Environment Variables

Many scripts support configuration via environment variables:

```bash
# Backup configuration
export BACKUP_DIR="/backup"
export RETENTION_DAYS="7"

# MySQL backup
export MYSQL_USER="backup_user"
export MYSQL_PASSWORD="password"

# Monitoring agents
export DD_API_KEY="your-datadog-key"
export NEW_RELIC_LICENSE_KEY="your-newrelic-key"
```

## Logs

All scripts log to `/var/log/linuxtools/`:

```bash
# View recent logs
ls -lht /var/log/linuxtools/ | head

# View specific log
tail -f /var/log/linuxtools/system-report-*.log
```

## Configuration Files

Configuration files are stored in `/etc/linuxtools/`:

```bash
ls -la /etc/linuxtools/
```

## Getting Help

1. Check script help:
   ```bash
   ./script-name.sh --help
   ```

2. Review documentation in `docs/`

3. Check troubleshooting guide: `docs/troubleshooting/COMMON_ISSUES.md`

## Next Steps

- Read the [Security Hardening Guide](../best-practices/SECURITY_HARDENING.md)
- Set up [Automated Monitoring](MONITORING_SETUP.md)
- Configure [Backup Strategies](../best-practices/BACKUP_STRATEGIES.md)

## Support

For issues or questions:
- Check existing documentation
- Review script comments
- Open an issue on GitHub
