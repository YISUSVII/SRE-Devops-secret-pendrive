#!/bin/bash

# Azure Metric Alert Creation Script
# Creates metric-based alerts for Azure resources

set -e

RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-my-resource-group}"
ALERT_NAME="${ALERT_NAME:-high-cpu-alert}"
RESOURCE_ID="${RESOURCE_ID:-}"
ACTION_GROUP_NAME="${ACTION_GROUP_NAME:-sre-alerts}"
METRIC_NAME="${METRIC_NAME:-Percentage CPU}"
THRESHOLD="${THRESHOLD:-80}"

if [[ -z "$RESOURCE_ID" ]]; then
  echo "Error: RESOURCE_ID is required"
  echo "Usage: RESOURCE_ID=/subscriptions/xxx/... $0"
  exit 1
fi

echo "Creating metric alert: $ALERT_NAME"

# Get action group ID
ACTION_GROUP_ID=$(az monitor action-group show \
  --name "$ACTION_GROUP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query id -o tsv)

# Create metric alert
az monitor metrics alert create \
  --name "$ALERT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --scopes "$RESOURCE_ID" \
  --condition "avg $METRIC_NAME > $THRESHOLD" \
  --description "Alert when $METRIC_NAME exceeds $THRESHOLD%" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --action "$ACTION_GROUP_ID" \
  --output table

echo "Metric alert created successfully!"
