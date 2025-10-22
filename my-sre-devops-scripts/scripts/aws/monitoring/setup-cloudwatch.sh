#!/bin/bash

# AWS CloudWatch Setup Script
# Sets up CloudWatch monitoring and alarms

set -e

REGION="${AWS_REGION:-us-east-1}"
SNS_TOPIC_NAME="${SNS_TOPIC_NAME:-sre-alerts}"
EMAIL="${ALERT_EMAIL:-alerts@example.com}"

echo "Setting up CloudWatch monitoring..."

# Create SNS topic for alerts
TOPIC_ARN=$(aws sns create-topic \
  --name "$SNS_TOPIC_NAME" \
  --region "$REGION" \
  --query 'TopicArn' \
  --output text)

echo "SNS Topic Created: $TOPIC_ARN"

# Subscribe email to SNS topic
aws sns subscribe \
  --topic-arn "$TOPIC_ARN" \
  --protocol email \
  --notification-endpoint "$EMAIL" \
  --region "$REGION"

echo "Email subscription created (check your email to confirm)"
echo ""
echo "=== CloudWatch Setup Complete ==="
echo "SNS Topic ARN: $TOPIC_ARN"
echo ""
echo "To create alarms, use: create-cloudwatch-alarm.sh"
