#!/bin/bash

# AWS Security Group Management Script
# Manages EC2 security groups

set -e

ACTION="${1:-list}"
SG_NAME="${2:-}"
VPC_ID="${3:-}"
REGION="${AWS_REGION:-us-east-1}"

usage() {
  echo "Usage: $0 {create|delete|list|show|audit} [sg-name] [vpc-id]"
  echo ""
  echo "Actions:"
  echo "  create  - Create a new security group"
  echo "  delete  - Delete a security group"
  echo "  list    - List all security groups"
  echo "  show    - Show security group details"
  echo "  audit   - Audit security groups for overly permissive rules"
  exit 1
}

case "$ACTION" in
  create)
    if [[ -z "$SG_NAME" ]] || [[ -z "$VPC_ID" ]]; then
      echo "Error: Security group name and VPC ID required"
      usage
    fi
    aws ec2 create-security-group \
      --group-name "$SG_NAME" \
      --description "Security group created by SRE script" \
      --vpc-id "$VPC_ID" \
      --region "$REGION"
    ;;
  
  delete)
    if [[ -z "$SG_NAME" ]]; then
      echo "Error: Security group ID required"
      usage
    fi
    aws ec2 delete-security-group \
      --group-id "$SG_NAME" \
      --region "$REGION"
    echo "Security group deleted."
    ;;
  
  list)
    echo "Listing security groups..."
    aws ec2 describe-security-groups \
      --query 'SecurityGroups[].{ID:GroupId,Name:GroupName,VPC:VpcId}' \
      --output table \
      --region "$REGION"
    ;;
  
  show)
    if [[ -z "$SG_NAME" ]]; then
      echo "Error: Security group ID required"
      usage
    fi
    aws ec2 describe-security-groups \
      --group-ids "$SG_NAME" \
      --region "$REGION" \
      --output json
    ;;
  
  audit)
    echo "Auditing security groups for open access..."
    aws ec2 describe-security-groups \
      --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].{ID:GroupId,Name:GroupName,VPC:VpcId}' \
      --output table \
      --region "$REGION"
    echo ""
    echo "WARNING: Security groups above have rules allowing access from 0.0.0.0/0"
    ;;
  
  *)
    echo "Error: Invalid action"
    usage
    ;;
esac
