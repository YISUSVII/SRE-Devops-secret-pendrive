#!/bin/bash

# Azure Virtual Network Creation Script
# This script creates a VNet with a subnet in Azure

set -e

# Configuration
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-my-resource-group}"
LOCATION="${AZURE_LOCATION:-eastus}"
VNET_NAME="${VNET_NAME:-my-vnet}"
VNET_ADDRESS_PREFIX="${VNET_ADDRESS_PREFIX:-10.0.0.0/16}"
SUBNET_NAME="${SUBNET_NAME:-default-subnet}"
SUBNET_ADDRESS_PREFIX="${SUBNET_ADDRESS_PREFIX:-10.0.1.0/24}"

echo "Creating Azure Virtual Network..."
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "VNet Name: $VNET_NAME"
echo "VNet Address: $VNET_ADDRESS_PREFIX"

# Create resource group if it doesn't exist
echo "Ensuring resource group exists..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output table

# Create VNet
echo "Creating Virtual Network..."
az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME" \
  --address-prefix "$VNET_ADDRESS_PREFIX" \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefix "$SUBNET_ADDRESS_PREFIX" \
  --output table

echo "Virtual Network created successfully!"
echo "VNet ID: $(az network vnet show -g $RESOURCE_GROUP -n $VNET_NAME --query id -o tsv)"
