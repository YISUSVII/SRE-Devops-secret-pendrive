#!/bin/bash

# GCP Alert Policy Creation Script
# Creates alert policies for monitoring metrics

set -e

PROJECT_ID="${GCP_PROJECT_ID:-}"
ALERT_NAME="${ALERT_NAME:-high-cpu-alert}"
INSTANCE_NAME="${INSTANCE_NAME:-}"
THRESHOLD="${THRESHOLD:-0.8}"
NOTIFICATION_CHANNEL="${NOTIFICATION_CHANNEL:-}"

if [[ -z "$PROJECT_ID" ]]; then
  PROJECT_ID=$(gcloud config get-value project)
fi

if [[ -z "$NOTIFICATION_CHANNEL" ]]; then
  echo "Error: NOTIFICATION_CHANNEL is required"
  echo "Get it from: gcloud alpha monitoring channels list"
  exit 1
fi

echo "Creating alert policy: $ALERT_NAME"

# Create alert policy
cat > /tmp/alert-policy.json <<EOF
{
  "displayName": "$ALERT_NAME",
  "conditions": [
    {
      "displayName": "CPU utilization above $THRESHOLD",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\"",
        "comparison": "COMPARISON_GT",
        "thresholdValue": $THRESHOLD,
        "duration": "300s",
        "aggregations": [
          {
            "alignmentPeriod": "60s",
            "perSeriesAligner": "ALIGN_MEAN"
          }
        ]
      }
    }
  ],
  "notificationChannels": [
    "$NOTIFICATION_CHANNEL"
  ],
  "alertStrategy": {
    "autoClose": "1800s"
  },
  "enabled": true
}
EOF

gcloud alpha monitoring policies create \
  --policy-from-file=/tmp/alert-policy.json \
  --project="$PROJECT_ID"

rm /tmp/alert-policy.json

echo "Alert policy created successfully!"
