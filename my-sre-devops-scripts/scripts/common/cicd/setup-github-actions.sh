#!/bin/bash

# GitHub Actions CI/CD Setup Script
# Creates a basic CI/CD workflow for GitHub Actions

set -e

PROJECT_DIR="${PROJECT_DIR:-.}"
WORKFLOW_NAME="${WORKFLOW_NAME:-ci-cd}"
CLOUD_PROVIDER="${CLOUD_PROVIDER:-aws}"

echo "Setting up GitHub Actions workflow..."
echo "Workflow: $WORKFLOW_NAME"
echo "Cloud Provider: $CLOUD_PROVIDER"

mkdir -p "${PROJECT_DIR}/.github/workflows"

cat > "${PROJECT_DIR}/.github/workflows/${WORKFLOW_NAME}.yml" <<'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run tests
      run: |
        echo "Running tests..."
        # Add your test commands here
        # npm test
        # pytest
        # go test ./...
    
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build application
      run: |
        echo "Building application..."
        # Add your build commands here
        # npm run build
        # go build
        # docker build -t myapp:${{ github.sha }} .
    
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to cloud
      env:
        CLOUD_PROVIDER: ${{ secrets.CLOUD_PROVIDER }}
      run: |
        echo "Deploying to $CLOUD_PROVIDER..."
        # Add your deployment commands here
        # For AWS: aws deploy ...
        # For Azure: az webapp ...
        # For GCP: gcloud app deploy ...
EOF

echo "GitHub Actions workflow created: ${PROJECT_DIR}/.github/workflows/${WORKFLOW_NAME}.yml"
echo ""
echo "Next steps:"
echo "1. Add your test, build, and deploy commands to the workflow"
echo "2. Configure secrets in GitHub repository settings"
echo "3. Commit and push the workflow file"
