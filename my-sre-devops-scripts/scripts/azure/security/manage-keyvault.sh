#!/bin/bash

# Azure Key Vault Management Script
# Manages Key Vault operations for secure secret storage

set -e

ACTION="${1:-list}"
VAULT_NAME="${2:-}"
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-my-resource-group}"
LOCATION="${AZURE_LOCATION:-eastus}"

usage() {
  echo "Usage: $0 {create|delete|list|show|set-secret|get-secret} [vault-name] [secret-name] [secret-value]"
  echo ""
  echo "Actions:"
  echo "  create      - Create a new Key Vault"
  echo "  delete      - Delete a Key Vault"
  echo "  list        - List all Key Vaults"
  echo "  show        - Show Key Vault details"
  echo "  set-secret  - Store a secret in Key Vault"
  echo "  get-secret  - Retrieve a secret from Key Vault"
  exit 1
}

case "$ACTION" in
  create)
    if [[ -z "$VAULT_NAME" ]]; then
      echo "Error: Vault name required"
      usage
    fi
    echo "Creating Key Vault: $VAULT_NAME"
    az keyvault create \
      --name "$VAULT_NAME" \
      --resource-group "$RESOURCE_GROUP" \
      --location "$LOCATION" \
      --enable-rbac-authorization false \
      --output table
    ;;
  
  delete)
    if [[ -z "$VAULT_NAME" ]]; then
      echo "Error: Vault name required"
      usage
    fi
    read -p "Delete Key Vault $VAULT_NAME? (yes/no): " confirm
    if [[ "$confirm" == "yes" ]]; then
      az keyvault delete \
        --name "$VAULT_NAME" \
        --resource-group "$RESOURCE_GROUP"
      echo "Key Vault deleted."
    fi
    ;;
  
  list)
    echo "Listing Key Vaults..."
    az keyvault list --output table
    ;;
  
  show)
    if [[ -z "$VAULT_NAME" ]]; then
      echo "Error: Vault name required"
      usage
    fi
    az keyvault show \
      --name "$VAULT_NAME" \
      --output json
    ;;
  
  set-secret)
    SECRET_NAME="${3:-}"
    SECRET_VALUE="${4:-}"
    if [[ -z "$VAULT_NAME" ]] || [[ -z "$SECRET_NAME" ]] || [[ -z "$SECRET_VALUE" ]]; then
      echo "Error: Vault name, secret name, and secret value required"
      usage
    fi
    az keyvault secret set \
      --vault-name "$VAULT_NAME" \
      --name "$SECRET_NAME" \
      --value "$SECRET_VALUE" \
      --output table
    echo "Secret stored successfully!"
    ;;
  
  get-secret)
    SECRET_NAME="${3:-}"
    if [[ -z "$VAULT_NAME" ]] || [[ -z "$SECRET_NAME" ]]; then
      echo "Error: Vault name and secret name required"
      usage
    fi
    az keyvault secret show \
      --vault-name "$VAULT_NAME" \
      --name "$SECRET_NAME" \
      --query value -o tsv
    ;;
  
  *)
    echo "Error: Invalid action"
    usage
    ;;
esac
