#!/bin/bash

# Cross-Cloud Volume Snapshot Script
# Creates snapshots of volumes/disks across cloud providers

set -e

CLOUD_PROVIDER="${CLOUD_PROVIDER:-}"
RESOURCE_ID="${RESOURCE_ID:-}"
SNAPSHOT_NAME="${SNAPSHOT_NAME:-snapshot-$(date +%Y%m%d-%H%M%S)}"
DESCRIPTION="${DESCRIPTION:-Automated snapshot created by SRE script}"

if [[ -z "$CLOUD_PROVIDER" ]] || [[ -z "$RESOURCE_ID" ]]; then
  echo "Error: CLOUD_PROVIDER and RESOURCE_ID are required"
  echo "Usage: CLOUD_PROVIDER=aws RESOURCE_ID=vol-xxx $0"
  exit 1
fi

echo "Creating volume snapshot..."
echo "Provider: $CLOUD_PROVIDER"
echo "Resource: $RESOURCE_ID"
echo "Snapshot: $SNAPSHOT_NAME"

case "$CLOUD_PROVIDER" in
  aws)
    REGION="${AWS_REGION:-us-east-1}"
    echo "Creating AWS EBS snapshot..."
    SNAPSHOT_ID=$(aws ec2 create-snapshot \
      --volume-id "$RESOURCE_ID" \
      --description "$DESCRIPTION" \
      --tag-specifications "ResourceType=snapshot,Tags=[{Key=Name,Value=$SNAPSHOT_NAME}]" \
      --region "$REGION" \
      --query 'SnapshotId' \
      --output text)
    echo "Snapshot created: $SNAPSHOT_ID"
    echo "Waiting for snapshot to complete..."
    aws ec2 wait snapshot-completed \
      --snapshot-ids "$SNAPSHOT_ID" \
      --region "$REGION"
    echo "Snapshot completed successfully!"
    ;;
  
  azure)
    RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-}"
    if [[ -z "$RESOURCE_GROUP" ]]; then
      echo "Error: AZURE_RESOURCE_GROUP required for Azure"
      exit 1
    fi
    echo "Creating Azure disk snapshot..."
    az snapshot create \
      --resource-group "$RESOURCE_GROUP" \
      --name "$SNAPSHOT_NAME" \
      --source "$RESOURCE_ID" \
      --output table
    echo "Snapshot created successfully!"
    ;;
  
  gcp)
    ZONE="${GCP_ZONE:-us-central1-a}"
    PROJECT_ID="${GCP_PROJECT_ID:-$(gcloud config get-value project)}"
    echo "Creating GCP disk snapshot..."
    gcloud compute disks snapshot "$RESOURCE_ID" \
      --snapshot-names="$SNAPSHOT_NAME" \
      --zone="$ZONE" \
      --project="$PROJECT_ID" \
      --description="$DESCRIPTION"
    echo "Snapshot created successfully!"
    ;;
  
  *)
    echo "Error: Unsupported cloud provider: $CLOUD_PROVIDER"
    exit 1
    ;;
esac

echo "Snapshot process complete!"
