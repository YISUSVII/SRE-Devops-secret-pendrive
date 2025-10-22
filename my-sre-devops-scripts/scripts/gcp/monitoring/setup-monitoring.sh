#!/bin/bash

# GCP Cloud Monitoring Setup Script
# Sets up monitoring and alerting for GCP resources

set -e

PROJECT_ID="${GCP_PROJECT_ID:-}"
NOTIFICATION_EMAIL="${ALERT_EMAIL:-alerts@example.com}"

if [[ -z "$PROJECT_ID" ]]; then
  PROJECT_ID=$(gcloud config get-value project)
fi

echo "Setting up Cloud Monitoring for project: $PROJECT_ID"

# Enable Cloud Monitoring API
echo "Enabling Cloud Monitoring API..."
gcloud services enable monitoring.googleapis.com \
  --project="$PROJECT_ID"

# Create notification channel for email
echo "Creating notification channel..."
cat > /tmp/notification-channel.json <<EOF
{
  "type": "email",
  "displayName": "SRE Email Alerts",
  "labels": {
    "email_address": "$NOTIFICATION_EMAIL"
  },
  "enabled": true
}
EOF

CHANNEL_ID=$(gcloud alpha monitoring channels create \
  --channel-content-from-file=/tmp/notification-channel.json \
  --project="$PROJECT_ID" \
  --format="value(name)")

rm /tmp/notification-channel.json

echo ""
echo "=== Monitoring Setup Complete ==="
echo "Project: $PROJECT_ID"
echo "Notification Channel: $CHANNEL_ID"
echo "Email: $NOTIFICATION_EMAIL"
echo ""
echo "To create alerts, use: create-alert-policy.sh"
