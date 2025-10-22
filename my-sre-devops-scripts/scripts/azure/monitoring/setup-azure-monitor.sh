#!/bin/bash

# Azure Monitor Setup Script
# Sets up monitoring and alerts for Azure resources

set -e

RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-my-resource-group}"
LOCATION="${AZURE_LOCATION:-eastus}"
WORKSPACE_NAME="${WORKSPACE_NAME:-sre-log-analytics}"
ACTION_GROUP_NAME="${ACTION_GROUP_NAME:-sre-alerts}"
EMAIL="${ALERT_EMAIL:-alerts@example.com}"

echo "Setting up Azure Monitor..."

# Create Log Analytics Workspace
echo "Creating Log Analytics Workspace..."
az monitor log-analytics workspace create \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --location "$LOCATION" \
  --output table

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --query id -o tsv)

echo "Log Analytics Workspace created: $WORKSPACE_ID"

# Create action group for alerts
echo "Creating Action Group for notifications..."
az monitor action-group create \
  --name "$ACTION_GROUP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --short-name "SREAlerts" \
  --email-receiver "SRE Team" "$EMAIL" \
  --output table

echo "Azure Monitor setup complete!"
echo "Workspace: $WORKSPACE_NAME"
echo "Action Group: $ACTION_GROUP_NAME"
