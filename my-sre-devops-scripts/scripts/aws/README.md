# AWS Scripts

AWS-specific SRE and DevOps automation scripts.

## Available Scripts

### Infrastructure (`infrastructure/`)
- `aws-login-setup.sh` - Install and configure AWS CLI
- `create-vpc.sh` - Create VPC with subnet and Internet Gateway
- `launch-ec2.sh` - Launch EC2 instance with security group

### Monitoring (`monitoring/`)
- `setup-cloudwatch.sh` - Setup SNS topic for alerts
- `create-cloudwatch-alarm.sh` - Create CloudWatch alarms

### Security (`security/`)
- `iam-audit.sh` - Comprehensive IAM security audit
- `manage-security-groups.sh` - Manage EC2 security groups

## Quick Reference

```bash
# Setup
./infrastructure/aws-login-setup.sh

# Create infrastructure
export AWS_REGION="us-east-1"
./infrastructure/create-vpc.sh
export SUBNET_ID="subnet-xxxxx"
./infrastructure/launch-ec2.sh

# Setup monitoring
export ALERT_EMAIL="alerts@example.com"
./monitoring/setup-cloudwatch.sh

# Security audit
./security/iam-audit.sh
```

See [AWS Guide](../../docs/aws-guide.md) for detailed documentation.
