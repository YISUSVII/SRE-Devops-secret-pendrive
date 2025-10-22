# GCP SRE Tools Guide

This guide covers all GCP-specific tools and scripts available in the SRE toolkit.

## Prerequisites

- GCP CLI (gcloud) installed (run `gcp-login-setup.sh` to install)
- Active GCP project
- Appropriate IAM permissions

## Infrastructure Management

### Create VPC
Creates a VPC network with custom subnet.

```bash
export GCP_PROJECT_ID="my-project"
export NETWORK_NAME="production-vpc"
export SUBNET_NAME="app-subnet"
export SUBNET_REGION="us-central1"

./scripts/gcp/infrastructure/create-vpc.sh
```

### Create Compute Instance
Launches a VM instance in Google Cloud.

```bash
export INSTANCE_NAME="web-server-01"
export MACHINE_TYPE="e2-medium"
export GCP_ZONE="us-central1-a"

./scripts/gcp/infrastructure/create-instance.sh
```

## Monitoring

### Setup Cloud Monitoring
Enables Cloud Monitoring and creates notification channels.

```bash
export ALERT_EMAIL="alerts@mycompany.com"
./scripts/gcp/monitoring/setup-monitoring.sh
```

### Create Alert Policy
Sets up alert policies for monitoring metrics.

```bash
export ALERT_NAME="high-cpu-alert"
export NOTIFICATION_CHANNEL="projects/xxx/notificationChannels/yyy"
./scripts/gcp/monitoring/create-alert-policy.sh
```

## Security

### IAM Audit
Comprehensive IAM security audit.

```bash
./scripts/gcp/security/iam-audit.sh
```

### Manage Firewall Rules
Create, delete, list, or audit firewall rules.

```bash
# List all firewall rules
./scripts/gcp/security/manage-firewall.sh list

# Audit firewall rules for open access
./scripts/gcp/security/manage-firewall.sh audit

# Create firewall rule (customize the script as needed)
./scripts/gcp/security/manage-firewall.sh create allow-http
```

## Best Practices

1. **VPC Design**: Use custom VPC networks with specific subnet ranges
2. **Firewall Rules**: Implement least privilege access
3. **IAM**: Use service accounts for applications
4. **Service Account Keys**: Minimize usage of service account keys
5. **Cloud Monitoring**: Set up alerts for critical metrics
6. **Labels**: Use consistent labeling strategy
7. **Private Google Access**: Enable for subnets that need GCP API access
