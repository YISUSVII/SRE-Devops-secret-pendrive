# AWS SRE Tools Guide

This guide covers all AWS-specific tools and scripts available in the SRE toolkit.

## Prerequisites

- AWS CLI installed (run `aws-login-setup.sh` to install)
- AWS account with appropriate permissions
- AWS credentials configured

## Infrastructure Management

### Create VPC
Creates a VPC with subnet, Internet Gateway, and route table.

```bash
export VPC_NAME="production-vpc"
export VPC_CIDR="10.0.0.0/16"
export AWS_REGION="us-east-1"

./scripts/aws/infrastructure/create-vpc.sh
```

### Launch EC2 Instance
Launches an EC2 instance with security group.

```bash
export INSTANCE_NAME="web-server-01"
export INSTANCE_TYPE="t2.micro"
export KEY_NAME="my-keypair"
export SUBNET_ID="subnet-xxxxx"

./scripts/aws/infrastructure/launch-ec2.sh
```

## Monitoring

### Setup CloudWatch
Creates SNS topic for alerting.

```bash
export ALERT_EMAIL="alerts@mycompany.com"
./scripts/aws/monitoring/setup-cloudwatch.sh
```

### Create CloudWatch Alarm
Sets up alarms for EC2 metrics.

```bash
export INSTANCE_ID="i-xxxxx"
export SNS_TOPIC_ARN="arn:aws:sns:us-east-1:xxx:sre-alerts"
./scripts/aws/monitoring/create-cloudwatch-alarm.sh
```

## Security

### IAM Audit
Comprehensive IAM security audit.

```bash
./scripts/aws/security/iam-audit.sh
```

### Manage Security Groups
Create, delete, list, or audit security groups.

```bash
# List all security groups
./scripts/aws/security/manage-security-groups.sh list

# Audit security groups for open access
./scripts/aws/security/manage-security-groups.sh audit
```

## Best Practices

1. **VPC Design**: Use multiple availability zones for high availability
2. **Security Groups**: Implement least privilege access
3. **IAM**: Use roles instead of access keys when possible
4. **MFA**: Enable MFA for all IAM users
5. **CloudWatch**: Monitor all critical resources
6. **Tagging**: Use consistent tagging strategy
