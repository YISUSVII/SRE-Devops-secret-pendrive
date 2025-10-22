# Azure SRE Tools Guide

This guide covers all Azure-specific tools and scripts available in the SRE toolkit.

## Prerequisites

- Azure CLI installed (run `az-login-setup.sh` to install)
- Active Azure subscription
- Appropriate permissions for resource creation

## Infrastructure Management

### Create Virtual Network
Creates a VNet with subnet for Azure resources.

```bash
# Set environment variables
export AZURE_RESOURCE_GROUP="my-rg"
export AZURE_LOCATION="eastus"
export VNET_NAME="production-vnet"

# Run script
./scripts/azure/infrastructure/create-vnet.sh
```

### Create Virtual Machine
Launches a Linux VM with SSH key authentication.

```bash
export AZURE_RESOURCE_GROUP="my-rg"
export VM_NAME="web-server-01"

./scripts/azure/infrastructure/create-vm.sh
```

### Manage Resource Groups
Create, delete, list, or show resource groups.

```bash
# List all resource groups
./scripts/azure/infrastructure/manage-resource-group.sh list

# Create a new resource group
./scripts/azure/infrastructure/manage-resource-group.sh create my-rg eastus
```

## Monitoring

### Setup Azure Monitor
Creates Log Analytics workspace and action groups for alerting.

```bash
export ALERT_EMAIL="alerts@mycompany.com"
./scripts/azure/monitoring/setup-azure-monitor.sh
```

## Security

### Manage Key Vault
Comprehensive Key Vault management for secrets.

```bash
# Create Key Vault
./scripts/azure/security/manage-keyvault.sh create my-keyvault

# Store a secret
./scripts/azure/security/manage-keyvault.sh set-secret my-keyvault db-password "MySecurePassword"
```

### Security Audit
Performs comprehensive security audit of Azure resources.

```bash
./scripts/azure/security/security-audit.sh
```

## Best Practices

1. **Resource Tagging**: Always tag resources with environment, owner, and purpose
2. **Network Security**: Use Network Security Groups (NSGs) to restrict access
3. **Key Vault**: Store all secrets in Key Vault
4. **Monitoring**: Set up alerts for critical metrics
5. **RBAC**: Use Role-Based Access Control for least privilege access
