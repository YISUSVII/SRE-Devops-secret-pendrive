#!/bin/bash

# GCP VPC Creation Script
# Creates a VPC network with subnet in Google Cloud

set -e

PROJECT_ID="${GCP_PROJECT_ID:-}"
NETWORK_NAME="${NETWORK_NAME:-my-vpc}"
SUBNET_NAME="${SUBNET_NAME:-my-subnet}"
SUBNET_REGION="${SUBNET_REGION:-us-central1}"
SUBNET_RANGE="${SUBNET_RANGE:-10.0.1.0/24}"

if [[ -z "$PROJECT_ID" ]]; then
  PROJECT_ID=$(gcloud config get-value project)
fi

echo "Creating GCP VPC Network..."
echo "Project: $PROJECT_ID"
echo "Network: $NETWORK_NAME"
echo "Subnet: $SUBNET_NAME"

# Create VPC network
gcloud compute networks create "$NETWORK_NAME" \
  --project="$PROJECT_ID" \
  --subnet-mode=custom \
  --bgp-routing-mode=regional

echo "VPC Network created: $NETWORK_NAME"

# Create subnet
gcloud compute networks subnets create "$SUBNET_NAME" \
  --project="$PROJECT_ID" \
  --network="$NETWORK_NAME" \
  --region="$SUBNET_REGION" \
  --range="$SUBNET_RANGE" \
  --enable-private-ip-google-access

echo "Subnet created: $SUBNET_NAME"

# Create firewall rule for SSH
gcloud compute firewall-rules create "${NETWORK_NAME}-allow-ssh" \
  --project="$PROJECT_ID" \
  --network="$NETWORK_NAME" \
  --allow=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --description="Allow SSH access"

# Create firewall rule for internal traffic
gcloud compute firewall-rules create "${NETWORK_NAME}-allow-internal" \
  --project="$PROJECT_ID" \
  --network="$NETWORK_NAME" \
  --allow=tcp:0-65535,udp:0-65535,icmp \
  --source-ranges="$SUBNET_RANGE" \
  --description="Allow internal traffic"

echo ""
echo "=== VPC Setup Complete ==="
echo "Network: $NETWORK_NAME"
echo "Subnet: $SUBNET_NAME ($SUBNET_RANGE)"
echo "Region: $SUBNET_REGION"
