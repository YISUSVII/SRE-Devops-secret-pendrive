#!/bin/bash

# GCP IAM Security Audit Script
# Audits IAM policies and service accounts

set -e

PROJECT_ID="${GCP_PROJECT_ID:-}"

if [[ -z "$PROJECT_ID" ]]; then
  PROJECT_ID=$(gcloud config get-value project)
fi

echo "=== GCP IAM Security Audit ==="
echo "Project: $PROJECT_ID"
echo ""

echo "1. Checking IAM Policy Bindings..."
gcloud projects get-iam-policy "$PROJECT_ID" \
  --flatten="bindings[].members" \
  --format="table(bindings.role,bindings.members)"

echo ""
echo "2. Checking Service Accounts..."
gcloud iam service-accounts list \
  --project="$PROJECT_ID" \
  --format="table(email,displayName,disabled)"

echo ""
echo "3. Checking for service accounts with keys..."
for sa in $(gcloud iam service-accounts list --project="$PROJECT_ID" --format="value(email)"); do
  keys=$(gcloud iam service-accounts keys list \
    --iam-account="$sa" \
    --project="$PROJECT_ID" \
    --format="value(name)" \
    --filter="keyType:USER_MANAGED")
  if [[ -n "$keys" ]]; then
    echo "Service Account: $sa has user-managed keys"
    gcloud iam service-accounts keys list \
      --iam-account="$sa" \
      --project="$PROJECT_ID" \
      --format="table(name,validAfterTime,validBeforeTime)"
  fi
done

echo ""
echo "4. Checking for overly permissive roles..."
gcloud projects get-iam-policy "$PROJECT_ID" \
  --flatten="bindings[].members" \
  --filter="bindings.role:(roles/owner OR roles/editor)" \
  --format="table(bindings.role,bindings.members)"

echo ""
echo "5. Checking firewall rules..."
gcloud compute firewall-rules list \
  --project="$PROJECT_ID" \
  --format="table(name,network,direction,sourceRanges.list():label=SRC_RANGES,allowed[].map().firewall_rule().list():label=ALLOW,targetTags.list():label=TARGET_TAGS)"

echo ""
echo "=== Audit Complete ==="
