# LinuxTools - Comprehensive Linux System Administration Toolkit

A complete collection of system administration tools, monitoring agents, security utilities, and automation scripts for Linux servers.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Linux](https://img.shields.io/badge/platform-Linux-green.svg)
![Bash](https://img.shields.io/badge/shell-Bash-brightgreen.svg)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Components](#components)
- [Usage Examples](#usage-examples)
- [Documentation](#documentation)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

LinuxTools is a comprehensive toolkit designed for system administrators, SREs, and DevOps engineers managing Linux servers. It provides production-ready scripts for monitoring, security hardening, performance optimization, and automation across all major Linux distributions.

### Supported Distributions

- ✅ Ubuntu (18.04, 20.04, 22.04, 24.04)
- ✅ Debian (9, 10, 11, 12)
- ✅ CentOS (7, 8, Stream)
- ✅ RHEL (7, 8, 9)
- ✅ Amazon Linux 2
- ✅ Rocky Linux
- ✅ AlmaLinux

## ✨ Features

### 📊 Monitoring Agents
- **Datadog** - Full-featured APM and infrastructure monitoring
- **New Relic** - Application performance monitoring
- **Prometheus** - Metrics collection with Node Exporter
- **Zabbix** - Enterprise monitoring solution
- **Netdata** - Real-time performance monitoring

### 🔧 System Analysis
- Comprehensive system reporting (JSON/HTML)
- Performance benchmarking and profiling
- Hardware inventory and diagnostics
- Security auditing capabilities
- Real-time resource monitoring

### 🛡️ Security Tools
- SSH hardening and configuration
- Firewall setup (UFW/Firewalld)
- Vulnerability scanning (Lynis, Rkhunter, ClamAV)
- CIS benchmark compliance checking
- Intrusion detection setup

### 🌐 Network Tools
- Connectivity testing and diagnostics
- Speed benchmarking (iperf3, speedtest)
- Port scanning and service discovery
- Traffic monitoring and analysis
- DNS and routing troubleshooting

### 💾 Backup & Recovery
- Automated backup scripts (rsync, borg)
- Database backup automation
- Disaster recovery procedures
- System migration tools
- Backup verification and integrity checks

### 🐳 Container Tools
- Docker installation and management
- Kubernetes monitoring and health checks
- Container resource optimization
- Log aggregation and analysis

### ☁️ Cloud Tools
- Multi-cloud monitoring (AWS, Azure, GCP)
- Cloud resource management
- Cross-cloud backup strategies
- Cloud security compliance

### 🗃️ Database Tools
- MySQL/PostgreSQL/MongoDB monitoring
- Automated backup and recovery
- Performance tuning helpers
- Query optimization tools

### 🌐 Web Server Tools
- Apache/Nginx performance tuning
- Load balancer health checks
- SSL certificate management
- Access log analysis

### 🤖 Automation Scripts
- User management automation
- Package management helpers
- System maintenance tasks
- Log rotation and cleanup

## 🚀 Quick Start

### One-Line Installation

```bash
# Clone and install
git clone https://github.com/YISUSVII/SRE-Devops-secret-pendrive.git
cd SRE-Devops-secret-pendrive/LinuxTools
sudo ./setup.sh
```

### Quick Setup Examples

```bash
# Install specific components
cd LinuxTools

# Install monitoring agents
sudo bash monitoring-agents/setup-monitoring.sh

# Install security tools
sudo bash security-tools/setup-security.sh

# Run system analysis
bash system-analysis/scripts/system-report.sh
```

## 📦 Installation

### Prerequisites

- Linux operating system (see supported distributions)
- Bash 4.0 or higher
- Root/sudo access for system-wide installation
- Internet connection for package downloads

### Interactive Installation

```bash
cd LinuxTools
sudo ./setup.sh
```

The interactive menu allows you to:
1. Install individual components
2. Install all components at once
3. Configure settings per component

### Manual Component Installation

Each component has its own setup script:

```bash
# Monitoring
sudo bash monitoring-agents/setup-monitoring.sh

# System Analysis
sudo bash system-analysis/setup-analysis.sh

# Security Tools
sudo bash security-tools/setup-security.sh

# And so on...
```

## 📂 Components

### Directory Structure

```
LinuxTools/
├── monitoring-agents/          # Monitoring agent installations
├── system-analysis/           # System analysis and reporting
├── security-tools/            # Security hardening and scanning
├── network-tools/             # Network diagnostics and testing
├── backup-recovery/           # Backup and disaster recovery
├── container-tools/           # Docker and Kubernetes tools
├── cloud-tools/               # Multi-cloud management
├── database-tools/            # Database management scripts
├── web-server-tools/          # Web server optimization
├── automation-scripts/        # System automation
└── docs/                      # Comprehensive documentation
```

## 💡 Usage Examples

### System Analysis

```bash
# Generate comprehensive system report
bash system-analysis/scripts/system-report.sh

# Check system performance
bash system-analysis/scripts/performance-check.sh

# Security audit
bash system-analysis/scripts/security-audit.sh

# Hardware information
bash system-analysis/scripts/hardware-info.sh
```

### Security Hardening

```bash
# Harden SSH configuration
sudo bash security-tools/ssh-hardening/harden-ssh.sh

# Setup firewall
sudo bash security-tools/firewall-setup/setup-ufw.sh

# Run vulnerability scan
sudo bash security-tools/vulnerability-scanning/lynis-audit.sh

# CIS benchmark check
sudo bash security-tools/compliance-checks/cis-benchmark.sh
```

### Monitoring Setup

```bash
# Install Datadog agent
sudo bash monitoring-agents/datadog/install.sh

# Setup Prometheus Node Exporter
sudo bash monitoring-agents/prometheus/setup-node-exporter.sh

# Install Netdata
sudo bash monitoring-agents/netdata/install.sh
```

### Backup Operations

```bash
# Setup rsync backup
bash backup-recovery/automated-backups/rsync-backup.sh

# MySQL backup
bash backup-recovery/automated-backups/mysql-backup.sh

# Borg backup
bash backup-recovery/automated-backups/borg-backup.sh
```

### Network Testing

```bash
# Network connectivity test
bash network-tools/connectivity-tests/network-test.sh

# Speed test
bash network-tools/speed-benchmarks/speedtest.sh

# Port scanner
bash network-tools/connectivity-tests/port-scanner.sh
```

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

### Installation Guides
- [Monitoring Setup Guide](docs/installation-guides/MONITORING_SETUP.md)
- [Security Setup Guide](docs/installation-guides/SECURITY_SETUP.md)
- [Quick Start Guide](docs/installation-guides/QUICK_START.md)

### Best Practices
- [Security Hardening](docs/best-practices/SECURITY_HARDENING.md)
- [Performance Tuning](docs/best-practices/PERFORMANCE_TUNING.md)
- [Backup Strategies](docs/best-practices/BACKUP_STRATEGIES.md)

### Troubleshooting
- [Common Issues](docs/troubleshooting/COMMON_ISSUES.md)
- [Debug Guide](docs/troubleshooting/DEBUG_GUIDE.md)

## 🔧 Requirements

### System Requirements
- **OS**: Linux (RHEL, CentOS, Ubuntu, Debian, etc.)
- **Shell**: Bash 4.0+
- **Memory**: Minimum 512MB RAM (2GB+ recommended)
- **Disk**: 1GB free space
- **Access**: Root or sudo privileges

### Software Dependencies
Most dependencies are auto-installed by setup scripts:
- curl, wget
- git
- net-tools
- sysstat
- Package manager (apt/yum/dnf)

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Script Standards
- Use `#!/bin/bash` shebang
- Include error handling: `set -euo pipefail`
- Color-coded output for readability
- Comprehensive logging
- Cross-distribution compatibility
- Proper documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Linux community for continuous support
- Open-source monitoring tools
- Security research community
- All contributors to this project

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check the documentation in `docs/`
- Review troubleshooting guides

## 🔄 Updates

Keep your LinuxTools installation up to date:

```bash
# Update all tools
sudo ./update-tools.sh

# Check for updates
git pull origin main
```

---

**Made with ❤️ for the Linux SysAdmin community**
