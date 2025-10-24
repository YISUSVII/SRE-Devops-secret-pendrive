
# SRE and DevOps Scripts Repository

Welcome to the **SRE and DevOps Scripts** repository! This repository contains a collection of useful scripts and tools designed to streamline operations, automate infrastructure management, and enhance security across Azure, GCP, and AWS cloud environments, plus comprehensive Linux system administration tools.

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
  - [🐧 LinuxTools - System Administration Toolkit](#linuxtools---system-administration-toolkit)
  - [Cloud-Specific Scripts](#cloud-specific-scripts)
    - [Azure](#azure)
    - [GCP](#gcp)
    - [AWS](#aws)
  - [Common Scripts](#common-scripts)
  - [Initial Setup Scripts](#initial-setup-scripts)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This repository serves as a comprehensive toolkit for Site Reliability Engineers (SREs) and DevOps professionals working with multiple cloud providers and Linux servers. It includes scripts for managing cloud resources, automating monitoring setups, ensuring security compliance, system administration, and more. Whether you're dealing with Azure, GCP, AWS, or managing Linux servers, you'll find production-ready scripts here that help you simplify and automate your operations.

## Features

### 🐧 LinuxTools - System Administration Toolkit

A comprehensive collection of **31+ production-ready scripts** for Linux system administration, monitoring, security, and automation.

**Key Features:**
- 📊 **Monitoring Agents**: Datadog, Prometheus, Netdata, Zabbix, New Relic
- 🔧 **System Analysis**: Performance checks, hardware info, benchmarking, comprehensive reporting
- 🛡️ **Security Tools**: SSH hardening, firewall setup (UFW/Firewalld), vulnerability scanning (Lynis, Rkhunter)
- 🌐 **Network Tools**: Connectivity tests, speed benchmarks, diagnostics
- 💾 **Backup & Recovery**: Automated rsync/borg backups, MySQL backups, disaster recovery
- 🐳 **Container Tools**: Docker installation and monitoring, Kubernetes health checks
- ☁️ **Cloud Integration**: AWS, Azure, GCP monitoring utilities
- 🗃️ **Database Tools**: MySQL, PostgreSQL, MongoDB management
- 🤖 **Automation**: System updates, log cleanup, user management

**Supported Distributions:**
- Ubuntu (18.04, 20.04, 22.04, 24.04)
- Debian (9, 10, 11, 12)
- CentOS (7, 8, Stream)
- RHEL (7, 8, 9)
- Rocky Linux & AlmaLinux

**Quick Start:**
```bash
cd LinuxTools
sudo ./setup.sh
```

**Documentation:**
- [Quick Start Guide](LinuxTools/docs/installation-guides/QUICK_START.md)
- [Monitoring Setup](LinuxTools/docs/installation-guides/MONITORING_SETUP.md)
- [Security Hardening](LinuxTools/docs/best-practices/SECURITY_HARDENING.md)
- [Troubleshooting](LinuxTools/docs/troubleshooting/COMMON_ISSUES.md)

---

### Cloud-Specific Scripts

#### Azure (8 scripts)
**Infrastructure Management:**
- `create-vnet.sh` - Create Virtual Networks with subnets
- `create-vm.sh` - Launch Virtual Machines with SSH key authentication
- `manage-resource-group.sh` - Create, delete, list, and manage resource groups

**Monitoring:**
- `setup-azure-monitor.sh` - Setup Log Analytics workspace and action groups
- `create-metric-alert.sh` - Create metric-based alerts for resources (CPU, memory, etc.)

**Security:**
- `manage-keyvault.sh` - Comprehensive Key Vault management (create, secrets, keys)
- `security-audit.sh` - Audit VMs, NSGs, storage accounts, Key Vaults, and role assignments

#### GCP (8 scripts)
**Infrastructure Management:**
- `create-vpc.sh` - Create VPC networks with custom subnets and firewall rules
- `create-instance.sh` - Launch Compute Engine instances with startup scripts

**Monitoring:**
- `setup-monitoring.sh` - Setup Cloud Monitoring and notification channels
- `create-alert-policy.sh` - Create alert policies for monitoring metrics

**Security:**
- `iam-audit.sh` - Audit IAM policies, service accounts, and permissions
- `manage-firewall.sh` - Create, delete, list, and audit firewall rules

#### AWS (7 scripts)
**Infrastructure Management:**
- `create-vpc.sh` - Create VPCs with subnets, Internet Gateway, and route tables
- `launch-ec2.sh` - Launch EC2 instances with security groups

**Monitoring:**
- `setup-cloudwatch.sh` - Setup SNS topics for alerts
- `create-cloudwatch-alarm.sh` - Create CloudWatch alarms for metrics

**Security:**
- `iam-audit.sh` - Comprehensive IAM security audit (users, keys, MFA, policies)
- `manage-security-groups.sh` - Create, delete, list, and audit security groups

### Common Scripts (9 scripts)

**Backup Management:**
- `database-backup.sh` - Automated MySQL/PostgreSQL backups to AWS S3, Azure Blob, GCS, or local
- `volume-snapshot.sh` - Create volume snapshots across AWS, Azure, and GCP

**CI/CD Pipelines:**
- `setup-github-actions.sh` - Generate GitHub Actions workflow with test, build, and deploy stages
- `setup-gitlab-ci.sh` - Generate GitLab CI pipeline with staging and production deployment

**Container Management:**
- `docker-health-check.sh` - Monitor Docker container health, resource usage, and logs
- `k8s-cluster-health.sh` - Comprehensive Kubernetes cluster health check
- `deploy-to-k8s.sh` - Deploy applications to Kubernetes with best practices

**Total: 29 production-ready scripts** ✨

### Initial Setup Scripts
All scripts include initial setup capabilities:
- **Azure**: `az-login-setup.sh` - Installs Azure CLI, authenticates, and configures subscription
- **GCP**: `gcp-login-setup.sh` - Installs latest gcloud CLI and configures project (updated to latest version)
- **AWS**: `aws-login-setup.sh` - Installs AWS CLI v2 and configures credentials

These setup scripts ensure that you have the necessary CLI tools installed and configured to interact with your cloud environments.

## Getting Started

### Quick Start

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/YISUSVII/SRE-Devops-secret-pendrive.git
   cd SRE-Devops-secret-pendrive/my-sre-devops-scripts
   ```

2. **Install Cloud CLI Tools:**
   ```bash
   # For Azure
   ./scripts/azure/infrastructure/az-login-setup.sh
   
   # For AWS
   ./scripts/aws/infrastructure/aws-login-setup.sh
   
   # For GCP
   ./scripts/gcp/infrastructure/gcp-login-setup.sh
   ```

3. **Configure Environment Variables:**
   
   **Azure:**
   ```bash
   export AZURE_SUBSCRIPTION_ID="your-subscription-id"
   export AZURE_RESOURCE_GROUP="my-rg"
   export AZURE_LOCATION="eastus"
   ```
   
   **AWS:**
   ```bash
   export AWS_REGION="us-east-1"
   # Configure credentials: aws configure
   ```
   
   **GCP:**
   ```bash
   export GCP_PROJECT_ID="your-project-id"
   export GCP_ZONE="us-central1-a"
   ```

4. **Run Scripts:**
   ```bash
   # Example: Create Azure infrastructure
   cd scripts/azure/infrastructure
   ./create-vnet.sh
   ./create-vm.sh
   
   # Example: Setup monitoring
   cd ../monitoring
   export ALERT_EMAIL="alerts@example.com"
   ./setup-azure-monitor.sh
   ```

5. **Review Documentation:**
   - See [docs/azure-guide.md](my-sre-devops-scripts/docs/azure-guide.md) for Azure
   - See [docs/aws-guide.md](my-sre-devops-scripts/docs/aws-guide.md) for AWS
   - See [docs/gcp-guide.md](my-sre-devops-scripts/docs/gcp-guide.md) for GCP
   - See [docs/common-tasks.md](my-sre-devops-scripts/docs/common-tasks.md) for cross-cloud tools

### Example Workflows

**LinuxTools - System Administration:**
```bash
# Generate comprehensive system report
cd LinuxTools/system-analysis/scripts
./system-report.sh

# Harden SSH security
cd LinuxTools/security-tools/ssh-hardening
sudo ./harden-ssh.sh

# Setup monitoring with Prometheus
cd LinuxTools/monitoring-agents/prometheus
sudo ./setup-node-exporter.sh

# Automated MySQL backup
cd LinuxTools/backup-recovery/automated-backups
export MYSQL_PASSWORD="password"
./mysql-backup.sh
```

**Create Complete AWS Infrastructure:**
```bash
cd scripts/aws/infrastructure
./create-vpc.sh
export SUBNET_ID="subnet-xxxxx"  # from output
export KEY_NAME="my-key"
./launch-ec2.sh
```

**Setup Monitoring with Alerts:**
```bash
cd scripts/azure/monitoring
./setup-azure-monitor.sh
export RESOURCE_ID="/subscriptions/.../virtualMachines/my-vm"
./create-metric-alert.sh
```

**Backup Database to Cloud:**
```bash
cd scripts/common/backup
export DB_TYPE="mysql"
export DB_NAME="myapp"
export DB_PASSWORD="password"
export CLOUD_PROVIDER="aws"
export S3_BUCKET="my-backups"
./database-backup.sh
```

**Deploy to Kubernetes:**
```bash
cd scripts/common/containers
export APP_NAME="myapp"
export IMAGE="myregistry/myapp:latest"
export NAMESPACE="production"
./deploy-to-k8s.sh
```

## Repository Structure

```
SRE-Devops-secret-pendrive/
│
├── LinuxTools/                    # 🐧 Linux System Administration Toolkit
│   ├── monitoring-agents/         # Datadog, Prometheus, Netdata, Zabbix, New Relic
│   ├── system-analysis/           # Performance checks, reporting, benchmarks
│   ├── security-tools/            # SSH hardening, firewalls, vulnerability scans
│   ├── network-tools/             # Connectivity tests, diagnostics, benchmarks
│   ├── backup-recovery/           # Automated backups, disaster recovery
│   ├── container-tools/           # Docker, Kubernetes management
│   ├── cloud-tools/               # Multi-cloud monitoring utilities
│   ├── database-tools/            # MySQL, PostgreSQL, MongoDB tools
│   ├── web-server-tools/          # Apache, Nginx optimization
│   ├── automation-scripts/        # System automation and maintenance
│   ├── docs/                      # Comprehensive documentation
│   ├── setup.sh                   # Interactive setup wizard
│   └── README.md                  # Full LinuxTools documentation
│
├── my-sre-devops-scripts/
│   ├── docs/                      # Comprehensive guides
│   │   ├── azure-guide.md         # Azure-specific documentation
│   │   ├── aws-guide.md           # AWS-specific documentation
│   │   ├── gcp-guide.md           # GCP-specific documentation
│   │   └── common-tasks.md        # Cross-cloud tools guide
│   │
│   ├── scripts/
│   │   ├── README.md              # Scripts overview and quick reference
│   │   │
│   │   ├── azure/                 # Azure scripts (8 total)
│   │   │   ├── infrastructure/    # VNet, VMs, resource groups
│   │   │   ├── monitoring/        # Azure Monitor, alerts
│   │   │   └── security/          # Key Vault, security audit
│   │   │
│   │   ├── aws/                   # AWS scripts (7 total)
│   │   │   ├── infrastructure/    # VPC, EC2, networking
│   │   │   ├── monitoring/        # CloudWatch, alarms
│   │   │   └── security/          # IAM audit, security groups
│   │   │
│   │   ├── gcp/                   # GCP scripts (8 total)
│   │   │   ├── infrastructure/    # VPC, Compute Engine
│   │   │   ├── monitoring/        # Cloud Monitoring, alerts
│   │   │   └── security/          # IAM audit, firewall rules
│   │   │
│   │   └── common/                # Cross-cloud scripts (9 total)
│   │       ├── backup/            # Database & volume backups
│   │       ├── cicd/              # GitHub Actions, GitLab CI
│   │       └── containers/        # Docker, Kubernetes tools
│
├── LICENSE
└── README.md
```

## Best Practices

When using these scripts, follow these SRE best practices:

1. **Test First**: Always test scripts in a non-production environment
2. **Version Control**: Track infrastructure changes with git
3. **Environment Variables**: Use environment variables for configuration
4. **Documentation**: Document any customizations or modifications
5. **Security**: Never commit secrets; use cloud provider secret management
6. **Monitoring**: Set up alerts for critical resources
7. **Backups**: Implement regular backup schedules
8. **Tagging**: Use consistent resource tagging for cost tracking
9. **Least Privilege**: Follow the principle of least privilege for IAM
10. **Review Logs**: Regularly review script output and cloud logs

## Prerequisites

- **Operating System**: Linux, macOS, or WSL on Windows
- **Shell**: Bash 4.0 or higher
- **Permissions**: Appropriate cloud provider permissions
- **Tools**: 
  - Azure CLI (installed by setup script)
  - AWS CLI v2 (installed by setup script)
  - GCP gcloud CLI (installed by setup script)
  - Docker (for container scripts)
  - kubectl (for Kubernetes scripts)

## Contributing

We welcome contributions from the community! If you have scripts or improvements to add:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit them (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

Please ensure your scripts follow the repository's coding standards and include appropriate documentation.

## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
