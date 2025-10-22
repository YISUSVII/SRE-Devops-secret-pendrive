#!/bin/bash

# AWS VPC Creation Script
# Creates a VPC with subnets and Internet Gateway

set -e

VPC_NAME="${VPC_NAME:-my-vpc}"
VPC_CIDR="${VPC_CIDR:-10.0.0.0/16}"
SUBNET_CIDR="${SUBNET_CIDR:-10.0.1.0/24}"
REGION="${AWS_REGION:-us-east-1}"

echo "Creating AWS VPC..."
echo "VPC CIDR: $VPC_CIDR"
echo "Region: $REGION"

# Create VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block "$VPC_CIDR" \
  --region "$REGION" \
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$VPC_NAME}]" \
  --query 'Vpc.VpcId' \
  --output text)

echo "VPC Created: $VPC_ID"

# Enable DNS hostnames
aws ec2 modify-vpc-attribute \
  --vpc-id "$VPC_ID" \
  --enable-dns-hostnames \
  --region "$REGION"

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$VPC_NAME-igw}]" \
  --region "$REGION" \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

echo "Internet Gateway Created: $IGW_ID"

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
  --vpc-id "$VPC_ID" \
  --internet-gateway-id "$IGW_ID" \
  --region "$REGION"

# Create Subnet
SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id "$VPC_ID" \
  --cidr-block "$SUBNET_CIDR" \
  --region "$REGION" \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$VPC_NAME-subnet}]" \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Subnet Created: $SUBNET_ID"

# Create route table
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id "$VPC_ID" \
  --region "$REGION" \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$VPC_NAME-rt}]" \
  --query 'RouteTable.RouteTableId' \
  --output text)

echo "Route Table Created: $ROUTE_TABLE_ID"

# Create route to Internet Gateway
aws ec2 create-route \
  --route-table-id "$ROUTE_TABLE_ID" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "$IGW_ID" \
  --region "$REGION"

# Associate route table with subnet
aws ec2 associate-route-table \
  --subnet-id "$SUBNET_ID" \
  --route-table-id "$ROUTE_TABLE_ID" \
  --region "$REGION"

echo ""
echo "=== VPC Setup Complete ==="
echo "VPC ID: $VPC_ID"
echo "Subnet ID: $SUBNET_ID"
echo "Internet Gateway ID: $IGW_ID"
echo "Route Table ID: $ROUTE_TABLE_ID"
