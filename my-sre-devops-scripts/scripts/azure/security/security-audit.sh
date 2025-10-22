#!/bin/bash

# Azure Security Audit Script
# Performs basic security checks on Azure resources

set -e

RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-}"

echo "=== Azure Security Audit ==="
echo ""

# Check for public IP addresses
echo "1. Checking for VMs with public IPs..."
az vm list-ip-addresses --output table

echo ""
echo "2. Checking Network Security Groups..."
if [[ -n "$RESOURCE_GROUP" ]]; then
  az network nsg list --resource-group "$RESOURCE_GROUP" --output table
else
  az network nsg list --output table
fi

echo ""
echo "3. Checking Storage Account public access..."
az storage account list --query "[].{Name:name,AllowBlobPublicAccess:allowBlobPublicAccess}" --output table

echo ""
echo "4. Checking for Key Vaults..."
az keyvault list --query "[].{Name:name,EnableSoftDelete:properties.enableSoftDelete,EnablePurgeProtection:properties.enablePurgeProtection}" --output table

echo ""
echo "5. Checking Role Assignments (Privileged)..."
az role assignment list --all --query "[?roleDefinitionName=='Owner' || roleDefinitionName=='Contributor'].{Principal:principalName,Role:roleDefinitionName,Scope:scope}" --output table

echo ""
echo "=== Audit Complete ==="
echo "Review the output above for potential security issues."
