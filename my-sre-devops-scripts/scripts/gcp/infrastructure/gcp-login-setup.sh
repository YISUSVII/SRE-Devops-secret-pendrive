#!/bin/bash

# Login to GCP
echo "Logging in to GCP..."
gcloud auth login

# Set the default project (replace with your Project ID)
PROJECT_ID="your-project-id"
echo "Setting default project..."
gcloud config set project $PROJECT_ID

echo "GCP login setup complete."
