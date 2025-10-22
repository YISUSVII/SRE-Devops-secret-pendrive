#!/bin/bash

# AWS CloudWatch Alarm Creation Script
# Creates CloudWatch alarms for EC2 instances

set -e

INSTANCE_ID="${INSTANCE_ID:-}"
ALARM_NAME="${ALARM_NAME:-high-cpu-alarm}"
METRIC_NAME="${METRIC_NAME:-CPUUtilization}"
THRESHOLD="${THRESHOLD:-80}"
SNS_TOPIC_ARN="${SNS_TOPIC_ARN:-}"
REGION="${AWS_REGION:-us-east-1}"

if [[ -z "$INSTANCE_ID" ]] || [[ -z "$SNS_TOPIC_ARN" ]]; then
  echo "Error: INSTANCE_ID and SNS_TOPIC_ARN are required"
  echo "Usage: INSTANCE_ID=i-xxx SNS_TOPIC_ARN=arn:aws:sns:... $0"
  exit 1
fi

echo "Creating CloudWatch alarm..."
echo "Instance: $INSTANCE_ID"
echo "Metric: $METRIC_NAME"
echo "Threshold: $THRESHOLD"

aws cloudwatch put-metric-alarm \
  --alarm-name "$ALARM_NAME" \
  --alarm-description "Alert when $METRIC_NAME exceeds $THRESHOLD%" \
  --metric-name "$METRIC_NAME" \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold "$THRESHOLD" \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value="$INSTANCE_ID" \
  --alarm-actions "$SNS_TOPIC_ARN" \
  --region "$REGION"

echo "CloudWatch alarm created: $ALARM_NAME"
