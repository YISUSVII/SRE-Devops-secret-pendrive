#!/bin/bash

# Function to install Azure CLI
install_azure_cli() {
  echo "Azure CLI not found. Installing Azure CLI..."
  
  # Detect OS and install accordingly
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Install for Linux
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Install for macOS
    brew update && brew install azure-cli
  else
    echo "Unsupported OS. Please install Azure CLI manually."
    exit 1
  fi
  
  echo "Azure CLI installed successfully."
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null
then
    install_azure_cli
else
    echo "Azure CLI is already installed."
fi

# Login to Azure CLI
echo "Logging in to Azure..."
az login

# Set the default subscription (replace with your Subscription ID)
SUBSCRIPTION_ID="your-subscription-id"
echo "Setting default subscription..."
az account set --subscription $SUBSCRIPTION_ID

echo "Azure login setup complete."
