# Common SRE Tasks Guide

This guide covers cross-cloud tools and common SRE tasks.

## Backup Management

### Database Backup
Automated database backup script supporting MySQL and PostgreSQL.

```bash
export DB_TYPE="mysql"
export DB_HOST="localhost"
export DB_USER="root"
export DB_PASSWORD="your-password"
export DB_NAME="myapp"
export CLOUD_PROVIDER="aws"  # or azure, gcp, local
export S3_BUCKET="my-backups"  # for AWS

./scripts/common/backup/database-backup.sh
```

Supported database types:
- MySQL
- PostgreSQL

Supported storage providers:
- AWS S3
- Azure Blob Storage
- Google Cloud Storage
- Local filesystem

### Volume Snapshot
Creates snapshots of volumes/disks across cloud providers.

```bash
# AWS EBS snapshot
export CLOUD_PROVIDER="aws"
export RESOURCE_ID="vol-xxxxx"
export SNAPSHOT_NAME="backup-20231022"
./scripts/common/backup/volume-snapshot.sh

# Azure disk snapshot
export CLOUD_PROVIDER="azure"
export RESOURCE_ID="/subscriptions/.../disks/my-disk"
export AZURE_RESOURCE_GROUP="my-rg"
./scripts/common/backup/volume-snapshot.sh

# GCP disk snapshot
export CLOUD_PROVIDER="gcp"
export RESOURCE_ID="my-disk"
export GCP_ZONE="us-central1-a"
./scripts/common/backup/volume-snapshot.sh
```

## CI/CD Pipeline Setup

### GitHub Actions
Creates a basic CI/CD workflow for GitHub Actions.

```bash
export PROJECT_DIR="."
export WORKFLOW_NAME="ci-cd"
export CLOUD_PROVIDER="aws"

./scripts/common/cicd/setup-github-actions.sh
```

This creates `.github/workflows/ci-cd.yml` with:
- Test stage
- Build stage
- Deploy stage (manual approval for production)

### GitLab CI
Creates a basic CI/CD pipeline for GitLab.

```bash
export PROJECT_DIR="."
./scripts/common/cicd/setup-gitlab-ci.sh
```

This creates `.gitlab-ci.yml` with:
- Test stage
- Build stage
- Deploy to staging (automatic)
- Deploy to production (manual)

## Container Management

### Docker Health Check
Monitors and reports health of Docker containers.

```bash
./scripts/common/containers/docker-health-check.sh
```

Checks:
- Container status
- Resource usage (CPU, memory, network, I/O)
- Unhealthy containers
- Container logs

### Kubernetes Cluster Health
Comprehensive health check for Kubernetes clusters.

```bash
./scripts/common/containers/k8s-cluster-health.sh
```

Checks:
- Node status and resource usage
- Pod status
- Failed pods
- Recent events
- Deployments status
- Certificate expiry

### Deploy to Kubernetes
Deploys applications to Kubernetes with best practices.

```bash
export APP_NAME="myapp"
export NAMESPACE="production"
export IMAGE="myregistry/myapp:latest"
export REPLICAS="3"
export PORT="8080"

./scripts/common/containers/deploy-to-k8s.sh
```

Creates:
- Deployment with resource limits
- Service (LoadBalancer type)
- Health checks (liveness and readiness probes)

## Best Practices

### Backup Strategy
1. **Frequency**: Daily backups for production databases
2. **Retention**: Keep 7 days of daily backups, 4 weekly backups, 12 monthly backups
3. **Testing**: Regularly test backup restoration
4. **Encryption**: Always encrypt backups
5. **Off-site**: Store backups in different region/availability zone

### CI/CD Pipeline
1. **Testing**: Run comprehensive tests before deployment
2. **Staging**: Always deploy to staging before production
3. **Rollback**: Have automated rollback procedures
4. **Secrets**: Never commit secrets to version control
5. **Monitoring**: Monitor deployment success and application health

### Container Management
1. **Resource Limits**: Always set CPU and memory limits
2. **Health Checks**: Implement liveness and readiness probes
3. **Logging**: Use centralized logging
4. **Security**: Scan images for vulnerabilities
5. **Updates**: Keep images updated with security patches

## Troubleshooting

### Database Backup Issues
**Issue**: Connection timeout
**Solution**: Check database host, port, and firewall rules

**Issue**: Insufficient disk space
**Solution**: Clean old backups or increase storage

### Container Issues
**Issue**: Container keeps restarting
**Solution**: Check logs with `docker logs <container>` or `kubectl logs <pod>`

**Issue**: High memory usage
**Solution**: Check resource limits and optimize application

### Kubernetes Issues
**Issue**: Pods stuck in Pending state
**Solution**: Check node resources with `kubectl top nodes`

**Issue**: ImagePullBackOff error
**Solution**: Verify image name, registry credentials, and network connectivity
