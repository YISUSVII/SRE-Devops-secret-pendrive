#!/bin/bash

# GCP Compute Engine Instance Creation Script
# Launches a VM instance in Google Cloud

set -e

PROJECT_ID="${GCP_PROJECT_ID:-}"
INSTANCE_NAME="${INSTANCE_NAME:-my-instance}"
MACHINE_TYPE="${MACHINE_TYPE:-e2-medium}"
ZONE="${GCP_ZONE:-us-central1-a}"
IMAGE_FAMILY="${IMAGE_FAMILY:-ubuntu-2204-lts}"
IMAGE_PROJECT="${IMAGE_PROJECT:-ubuntu-os-cloud}"
NETWORK="${NETWORK:-default}"
SUBNET="${SUBNET:-default}"

if [[ -z "$PROJECT_ID" ]]; then
  PROJECT_ID=$(gcloud config get-value project)
fi

echo "Creating GCP Compute Engine instance..."
echo "Instance: $INSTANCE_NAME"
echo "Machine Type: $MACHINE_TYPE"
echo "Zone: $ZONE"

# Create instance
gcloud compute instances create "$INSTANCE_NAME" \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  --machine-type="$MACHINE_TYPE" \
  --image-family="$IMAGE_FAMILY" \
  --image-project="$IMAGE_PROJECT" \
  --network="$NETWORK" \
  --subnet="$SUBNET" \
  --boot-disk-size=10GB \
  --boot-disk-type=pd-standard \
  --tags=http-server,https-server \
  --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx'

echo "Waiting for instance to be ready..."
sleep 10

# Get instance details
EXTERNAL_IP=$(gcloud compute instances describe "$INSTANCE_NAME" \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo "=== Instance Created Successfully ==="
echo "Instance Name: $INSTANCE_NAME"
echo "External IP: $EXTERNAL_IP"
echo "SSH: gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID"
