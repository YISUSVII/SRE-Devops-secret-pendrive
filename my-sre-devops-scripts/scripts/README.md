# SRE Scripts Collection

Complete collection of SRE and DevOps automation scripts for cloud infrastructure management.

## Directory Structure

```
scripts/
├── aws/                  # AWS-specific scripts
│   ├── infrastructure/   # VPC, EC2, networking
│   ├── monitoring/       # CloudWatch, alarms
│   └── security/         # IAM, security groups
├── azure/               # Azure-specific scripts
│   ├── infrastructure/  # VNet, VMs, resource groups
│   ├── monitoring/      # Azure Monitor, alerts
│   └── security/        # Key Vault, security audit
├── gcp/                 # GCP-specific scripts
│   ├── infrastructure/  # VPC, Compute Engine
│   ├── monitoring/      # Cloud Monitoring, alerts
│   └── security/        # IAM, firewall rules
└── common/              # Cross-cloud scripts
    ├── backup/          # Database and volume backups
    ├── cicd/            # CI/CD pipeline templates
    └── containers/      # Docker and Kubernetes tools
```

## Prerequisites

### Cloud CLI Tools
Run the initial setup scripts to install CLI tools:

```bash
# Azure
./azure/infrastructure/az-login-setup.sh

# AWS
./aws/infrastructure/aws-login-setup.sh

# GCP
./gcp/infrastructure/gcp-login-setup.sh
```

### Configuration
Before running scripts, configure environment variables:

#### Azure
```bash
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_RESOURCE_GROUP="my-resource-group"
export AZURE_LOCATION="eastus"
```

Update SUBSCRIPTION_ID in `azure/infrastructure/az-login-setup.sh`

#### AWS
```bash
export AWS_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

Or run `aws configure`

#### GCP
```bash
export GCP_PROJECT_ID="your-project-id"
export GCP_ZONE="us-central1-a"
```

Update PROJECT_ID in `gcp/infrastructure/gcp-login-setup.sh`

## Quick Start

### Create Infrastructure

#### AWS VPC and EC2
```bash
cd aws/infrastructure
./create-vpc.sh
export SUBNET_ID="subnet-xxxxx"  # from VPC creation output
./launch-ec2.sh
```

#### Azure VNet and VM
```bash
cd azure/infrastructure
./create-vnet.sh
./create-vm.sh
```

#### GCP VPC and Instance
```bash
cd gcp/infrastructure
./create-vpc.sh
./create-instance.sh
```

### Setup Monitoring

#### AWS CloudWatch
```bash
cd aws/monitoring
./setup-cloudwatch.sh
export SNS_TOPIC_ARN="arn:aws:sns:..."  # from setup output
export INSTANCE_ID="i-xxxxx"
./create-cloudwatch-alarm.sh
```

#### Azure Monitor
```bash
cd azure/monitoring
./setup-azure-monitor.sh
export RESOURCE_ID="/subscriptions/..."
./create-metric-alert.sh
```

#### GCP Monitoring
```bash
cd gcp/monitoring
./setup-monitoring.sh
export NOTIFICATION_CHANNEL="projects/.../notificationChannels/..."
./create-alert-policy.sh
```

### Backup Operations

#### Database Backup
```bash
cd common/backup
export DB_TYPE="mysql"
export DB_NAME="myapp"
export DB_PASSWORD="password"
export CLOUD_PROVIDER="aws"
./database-backup.sh
```

#### Volume Snapshot
```bash
cd common/backup
export CLOUD_PROVIDER="aws"
export RESOURCE_ID="vol-xxxxx"
./volume-snapshot.sh
```

### Container Management

#### Docker Health Check
```bash
cd common/containers
./docker-health-check.sh
```

#### Kubernetes Deployment
```bash
cd common/containers
export APP_NAME="myapp"
export IMAGE="myregistry/myapp:latest"
./deploy-to-k8s.sh
```

## Documentation

Comprehensive guides available in `docs/` directory:
- [Azure Guide](../docs/azure-guide.md)
- [AWS Guide](../docs/aws-guide.md)
- [GCP Guide](../docs/gcp-guide.md)
- [Common Tasks](../docs/common-tasks.md)

## Script Permissions

All scripts are executable. If needed, make executable with:
```bash
chmod +x script-name.sh
```

## Best Practices

1. **Test in Non-Production**: Always test scripts in dev/staging environments first
2. **Review Scripts**: Review script contents before execution
3. **Backup First**: Create backups before making infrastructure changes
4. **Use Version Control**: Track changes to scripts in git
5. **Set Variables**: Use environment variables for configuration
6. **Monitor Changes**: Watch logs and metrics after running scripts
7. **Document Custom Changes**: Document any customizations made

## Support

For issues or questions:
1. Check the relevant guide in `docs/` directory
2. Review script comments and usage instructions
3. Check cloud provider documentation
4. Open an issue in the repository

## Security Notes

- Never commit credentials or secrets to version control
- Use cloud provider's secret management services (Key Vault, Secrets Manager, Secret Manager)
- Regularly rotate access keys and passwords
- Review IAM permissions regularly
- Enable MFA for all administrative accounts
- Audit cloud resources regularly using provided security audit scripts