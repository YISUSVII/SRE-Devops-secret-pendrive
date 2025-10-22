#!/bin/bash

# Function to install AWS CLI
install_aws_cli() {
  echo "AWS CLI not found. Installing AWS CLI..."
  
  # Detect OS and install accordingly
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Install for Linux
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Install for macOS
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
  else
    echo "Unsupported OS. Please install AWS CLI manually."
    exit 1
  fi
  
  echo "AWS CLI installed successfully."
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    install_aws_cli
else
    echo "AWS CLI is already installed."
fi

# Configure AWS CLI with your credentials
echo "Configuring AWS CLI..."
aws configure

# Set the default region (replace with your preferred region)
REGION="us-east-1"
echo "Setting default region..."
aws configure set region $REGION

echo "AWS login setup complete."
