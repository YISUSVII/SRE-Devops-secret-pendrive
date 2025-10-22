# Azure Scripts

Azure-specific SRE and DevOps automation scripts.

## Available Scripts

### Infrastructure (`infrastructure/`)
- `az-login-setup.sh` - Install and configure Azure CLI
- `create-vnet.sh` - Create Virtual Network with subnet
- `create-vm.sh` - Launch Virtual Machine
- `manage-resource-group.sh` - Manage resource groups (create, delete, list, show)

### Monitoring (`monitoring/`)
- `setup-azure-monitor.sh` - Setup Log Analytics and action groups
- `create-metric-alert.sh` - Create metric-based alerts

### Security (`security/`)
- `manage-keyvault.sh` - Manage Key Vault and secrets
- `security-audit.sh` - Comprehensive security audit

## Quick Reference

```bash
# Setup
./infrastructure/az-login-setup.sh

# Create infrastructure
export AZURE_RESOURCE_GROUP="my-rg"
export AZURE_LOCATION="eastus"
./infrastructure/create-vnet.sh
./infrastructure/create-vm.sh

# Setup monitoring
export ALERT_EMAIL="alerts@example.com"
./monitoring/setup-azure-monitor.sh

# Security audit
./security/security-audit.sh
```

See [Azure Guide](../../docs/azure-guide.md) for detailed documentation.
