#!/bin/bash

# Login to Azure CLI
echo "Logging in to Azure..."
az login

# Set the default subscription (replace with your Subscription ID)
SUBSCRIPTION_ID="your-subscription-id"
echo "Setting default subscription..."
az account set --subscription $SUBSCRIPTION_ID

echo "Azure login setup complete."
