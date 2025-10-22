#!/bin/bash

# Azure Virtual Machine Creation Script
# Creates a Linux VM with best practices for SRE operations

set -e

# Configuration
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-my-resource-group}"
LOCATION="${AZURE_LOCATION:-eastus}"
VM_NAME="${VM_NAME:-my-vm}"
VM_SIZE="${VM_SIZE:-Standard_B2s}"
IMAGE="${VM_IMAGE:-UbuntuLTS}"
ADMIN_USERNAME="${ADMIN_USERNAME:-azureuser}"

echo "Creating Azure Virtual Machine..."
echo "Resource Group: $RESOURCE_GROUP"
echo "VM Name: $VM_NAME"
echo "Size: $VM_SIZE"

# Create VM
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --location "$LOCATION" \
  --size "$VM_SIZE" \
  --image "$IMAGE" \
  --admin-username "$ADMIN_USERNAME" \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --output table

# Get VM details
VM_IP=$(az vm show -d -g "$RESOURCE_GROUP" -n "$VM_NAME" --query publicIps -o tsv)

echo "VM created successfully!"
echo "Public IP: $VM_IP"
echo "SSH: ssh $ADMIN_USERNAME@$VM_IP"
