#!/bin/bash

# AWS IAM Security Audit Script
# Audits IAM users, roles, and policies for security best practices

set -e

REGION="${AWS_REGION:-us-east-1}"

echo "=== AWS IAM Security Audit ==="
echo ""

echo "1. Checking IAM Users..."
aws iam list-users --query 'Users[].{UserName:UserName,CreateDate:CreateDate}' --output table

echo ""
echo "2. Checking for users with access keys..."
for user in $(aws iam list-users --query 'Users[].UserName' --output text); do
  keys=$(aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[].{KeyId:AccessKeyId,Status:Status,Created:CreateDate}' --output table)
  if [[ -n "$keys" ]]; then
    echo "User: $user"
    echo "$keys"
  fi
done

echo ""
echo "3. Checking IAM Password Policy..."
aws iam get-account-password-policy --output table 2>/dev/null || echo "No password policy configured"

echo ""
echo "4. Checking for users with MFA disabled..."
for user in $(aws iam list-users --query 'Users[].UserName' --output text); do
  mfa=$(aws iam list-mfa-devices --user-name "$user" --query 'MFADevices[].SerialNumber' --output text)
  if [[ -z "$mfa" ]]; then
    echo "WARNING: User $user does not have MFA enabled"
  fi
done

echo ""
echo "5. Checking IAM Roles with admin access..."
aws iam list-roles --query 'Roles[?contains(RoleName, `Admin`) || contains(RoleName, `admin`)].{RoleName:RoleName,CreateDate:CreateDate}' --output table

echo ""
echo "6. Checking for overly permissive policies..."
aws iam list-policies --scope Local --query 'Policies[?PolicyName==`AdministratorAccess`].{PolicyName:PolicyName,Arn:Arn}' --output table

echo ""
echo "=== Audit Complete ==="
echo "Review findings above for security improvements."
