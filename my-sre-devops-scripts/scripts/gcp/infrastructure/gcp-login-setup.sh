#!/bin/bash

# Function to install GCP CLI
install_gcp_cli() {
  echo "GCP CLI not found. Installing GCP CLI..."
  
  # Detect OS and install accordingly
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Install for Linux
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-443.0.0-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-443.0.0-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Install for macOS
    brew install --cask google-cloud-sdk
  else
    echo "Unsupported OS. Please install GCP CLI manually."
    exit 1
  fi
  
  echo "GCP CLI installed successfully."
}

# Check if GCP CLI is installed
if ! command -v gcloud &> /dev/null
then
    install_gcp_cli
else
    echo "GCP CLI is already installed."
fi

# Login to GCP
echo "Logging in to GCP..."
gcloud auth login

# Set the default project (replace with your Project ID)
PROJECT_ID="your-project-id"
echo "Setting default project..."
gcloud config set project $PROJECT_ID

echo "GCP login setup complete."
