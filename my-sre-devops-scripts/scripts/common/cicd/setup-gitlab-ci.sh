#!/bin/bash

# GitLab CI/CD Setup Script
# Creates a basic CI/CD pipeline for GitLab

set -e

PROJECT_DIR="${PROJECT_DIR:-.}"
CLOUD_PROVIDER="${CLOUD_PROVIDER:-aws}"

echo "Setting up GitLab CI/CD pipeline..."
echo "Cloud Provider: $CLOUD_PROVIDER"

cat > "${PROJECT_DIR}/.gitlab-ci.yml" <<'EOF'
stages:
  - test
  - build
  - deploy

variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

test:
  stage: test
  image: ubuntu:latest
  script:
    - echo "Running tests..."
    # Add your test commands here
    # npm test
    # pytest
    # go test ./...

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - echo "Building application..."
    # Add your build commands here
    # docker build -t $DOCKER_IMAGE .
    # docker push $DOCKER_IMAGE
  only:
    - main
    - develop

deploy_staging:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploying to staging..."
    # Add deployment commands for staging
    # Install cloud CLI tools
    # Deploy application
  environment:
    name: staging
  only:
    - develop

deploy_production:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploying to production..."
    # Add deployment commands for production
    # Install cloud CLI tools
    # Deploy application
  environment:
    name: production
  only:
    - main
  when: manual
EOF

echo "GitLab CI/CD pipeline created: ${PROJECT_DIR}/.gitlab-ci.yml"
echo ""
echo "Next steps:"
echo "1. Add your test, build, and deploy commands to the pipeline"
echo "2. Configure CI/CD variables in GitLab project settings"
echo "3. Commit and push the pipeline file"
