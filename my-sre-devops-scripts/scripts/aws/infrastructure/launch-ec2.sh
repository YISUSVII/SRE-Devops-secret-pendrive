#!/bin/bash

# AWS EC2 Instance Launch Script
# Launches an EC2 instance with best practices

set -e

INSTANCE_NAME="${INSTANCE_NAME:-my-instance}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"
AMI_ID="${AMI_ID:-ami-0c55b159cbfafe1f0}"  # Amazon Linux 2 (update for your region)
KEY_NAME="${KEY_NAME:-my-key}"
REGION="${AWS_REGION:-us-east-1}"
SUBNET_ID="${SUBNET_ID:-}"

if [[ -z "$SUBNET_ID" ]]; then
  echo "Error: SUBNET_ID is required"
  echo "Usage: SUBNET_ID=subnet-xxx $0"
  exit 1
fi

echo "Launching EC2 instance..."
echo "Instance Type: $INSTANCE_TYPE"
echo "Region: $REGION"

# Create security group
SG_ID=$(aws ec2 create-security-group \
  --group-name "${INSTANCE_NAME}-sg" \
  --description "Security group for $INSTANCE_NAME" \
  --vpc-id "$(aws ec2 describe-subnets --subnet-ids $SUBNET_ID --query 'Subnets[0].VpcId' --output text --region $REGION)" \
  --region "$REGION" \
  --query 'GroupId' \
  --output text)

echo "Security Group Created: $SG_ID"

# Add SSH rule
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region "$REGION"

# Launch instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --subnet-id "$SUBNET_ID" \
  --security-group-ids "$SG_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --region "$REGION" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance Launched: $INSTANCE_ID"
echo "Waiting for instance to be running..."

aws ec2 wait instance-running \
  --instance-ids "$INSTANCE_ID" \
  --region "$REGION"

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$REGION" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo ""
echo "=== EC2 Instance Ready ==="
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "SSH: ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$PUBLIC_IP"
