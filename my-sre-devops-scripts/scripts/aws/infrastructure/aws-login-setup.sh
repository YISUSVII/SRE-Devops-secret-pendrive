#!/bin/bash

# Configure AWS CLI with your credentials
echo "Configuring AWS CLI..."
aws configure

# Set the default region (replace with your preferred region)
REGION="us-east-1"
echo "Setting default region..."
aws configure set region $REGION

echo "AWS login setup complete."
