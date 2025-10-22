#!/bin/bash

# GCP Firewall Management Script
# Manages firewall rules in Google Cloud

set -e

ACTION="${1:-list}"
RULE_NAME="${2:-}"
PROJECT_ID="${GCP_PROJECT_ID:-}"
NETWORK="${NETWORK:-default}"

if [[ -z "$PROJECT_ID" ]]; then
  PROJECT_ID=$(gcloud config get-value project)
fi

usage() {
  echo "Usage: $0 {create|delete|list|show|audit} [rule-name]"
  echo ""
  echo "Actions:"
  echo "  create  - Create a new firewall rule"
  echo "  delete  - Delete a firewall rule"
  echo "  list    - List all firewall rules"
  echo "  show    - Show firewall rule details"
  echo "  audit   - Audit firewall rules for security issues"
  exit 1
}

case "$ACTION" in
  create)
    if [[ -z "$RULE_NAME" ]]; then
      echo "Error: Rule name required"
      usage
    fi
    echo "Creating firewall rule: $RULE_NAME"
    echo "This is a template - customize the allow and source-ranges as needed"
    gcloud compute firewall-rules create "$RULE_NAME" \
      --project="$PROJECT_ID" \
      --network="$NETWORK" \
      --allow=tcp:80,tcp:443 \
      --source-ranges=0.0.0.0/0 \
      --description="Created by SRE script"
    ;;
  
  delete)
    if [[ -z "$RULE_NAME" ]]; then
      echo "Error: Rule name required"
      usage
    fi
    echo "Deleting firewall rule: $RULE_NAME"
    read -p "Are you sure? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
      gcloud compute firewall-rules delete "$RULE_NAME" \
        --project="$PROJECT_ID" \
        --quiet
      echo "Firewall rule deleted."
    fi
    ;;
  
  list)
    echo "Listing firewall rules..."
    gcloud compute firewall-rules list \
      --project="$PROJECT_ID" \
      --format="table(name,network,direction,priority,sourceRanges.list():label=SRC_RANGES,allowed[].map().firewall_rule().list():label=ALLOW)"
    ;;
  
  show)
    if [[ -z "$RULE_NAME" ]]; then
      echo "Error: Rule name required"
      usage
    fi
    gcloud compute firewall-rules describe "$RULE_NAME" \
      --project="$PROJECT_ID"
    ;;
  
  audit)
    echo "Auditing firewall rules for overly permissive access..."
    gcloud compute firewall-rules list \
      --project="$PROJECT_ID" \
      --filter="sourceRanges:(0.0.0.0/0)" \
      --format="table(name,network,sourceRanges.list():label=SRC_RANGES,allowed[].map().firewall_rule().list():label=ALLOW)"
    echo ""
    echo "WARNING: Rules above allow access from anywhere (0.0.0.0/0)"
    ;;
  
  *)
    echo "Error: Invalid action"
    usage
    ;;
esac
