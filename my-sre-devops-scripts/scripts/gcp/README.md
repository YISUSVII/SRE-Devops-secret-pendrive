# GCP Scripts

Google Cloud Platform-specific SRE and DevOps automation scripts.

## Available Scripts

### Infrastructure (`infrastructure/`)
- `gcp-login-setup.sh` - Install and configure GCP CLI (gcloud)
- `create-vpc.sh` - Create VPC network with custom subnet
- `create-instance.sh` - Launch Compute Engine instance

### Monitoring (`monitoring/`)
- `setup-monitoring.sh` - Setup Cloud Monitoring and notification channels
- `create-alert-policy.sh` - Create alert policies

### Security (`security/`)
- `iam-audit.sh` - Comprehensive IAM security audit
- `manage-firewall.sh` - Manage firewall rules

## Quick Reference

```bash
# Setup
./infrastructure/gcp-login-setup.sh

# Create infrastructure
export GCP_PROJECT_ID="my-project"
./infrastructure/create-vpc.sh
./infrastructure/create-instance.sh

# Setup monitoring
export ALERT_EMAIL="alerts@example.com"
./monitoring/setup-monitoring.sh

# Security audit
./security/iam-audit.sh
```

See [GCP Guide](../../docs/gcp-guide.md) for detailed documentation.
