#!/bin/bash

# Azure Resource Group Management Script
# Manages resource groups with common SRE operations

set -e

ACTION="${1:-list}"
RESOURCE_GROUP="${2:-}"
LOCATION="${3:-eastus}"

usage() {
  echo "Usage: $0 {create|delete|list|show} [resource-group-name] [location]"
  echo ""
  echo "Actions:"
  echo "  create  - Create a new resource group"
  echo "  delete  - Delete a resource group"
  echo "  list    - List all resource groups"
  echo "  show    - Show details of a resource group"
  exit 1
}

case "$ACTION" in
  create)
    if [[ -z "$RESOURCE_GROUP" ]]; then
      echo "Error: Resource group name required for create action"
      usage
    fi
    echo "Creating resource group: $RESOURCE_GROUP in $LOCATION"
    az group create \
      --name "$RESOURCE_GROUP" \
      --location "$LOCATION" \
      --output table
    ;;
  
  delete)
    if [[ -z "$RESOURCE_GROUP" ]]; then
      echo "Error: Resource group name required for delete action"
      usage
    fi
    echo "Deleting resource group: $RESOURCE_GROUP"
    read -p "Are you sure? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
      az group delete \
        --name "$RESOURCE_GROUP" \
        --yes \
        --no-wait
      echo "Deletion initiated..."
    else
      echo "Cancelled."
    fi
    ;;
  
  list)
    echo "Listing all resource groups..."
    az group list --output table
    ;;
  
  show)
    if [[ -z "$RESOURCE_GROUP" ]]; then
      echo "Error: Resource group name required for show action"
      usage
    fi
    az group show \
      --name "$RESOURCE_GROUP" \
      --output json
    ;;
  
  *)
    echo "Error: Invalid action '$ACTION'"
    usage
    ;;
esac
