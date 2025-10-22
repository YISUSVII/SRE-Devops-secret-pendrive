#!/bin/bash

# Cross-Cloud Database Backup Script
# Supports MySQL/PostgreSQL backups with cloud storage

set -e

DB_TYPE="${DB_TYPE:-mysql}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_NAME="${DB_NAME:-}"
BACKUP_DIR="${BACKUP_DIR:-/tmp/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CLOUD_PROVIDER="${CLOUD_PROVIDER:-local}"

if [[ -z "$DB_NAME" ]]; then
  echo "Error: DB_NAME is required"
  exit 1
fi

mkdir -p "$BACKUP_DIR"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql.gz"

echo "Starting database backup..."
echo "Database: $DB_NAME"
echo "Type: $DB_TYPE"
echo "Host: $DB_HOST"

case "$DB_TYPE" in
  mysql)
    echo "Backing up MySQL database..."
    mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" \
      --single-transaction --routines --triggers \
      "$DB_NAME" | gzip > "$BACKUP_FILE"
    ;;
  
  postgresql|postgres)
    echo "Backing up PostgreSQL database..."
    PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" \
      -d "$DB_NAME" | gzip > "$BACKUP_FILE"
    ;;
  
  *)
    echo "Error: Unsupported database type: $DB_TYPE"
    exit 1
    ;;
esac

echo "Backup completed: $BACKUP_FILE"
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "Backup size: $BACKUP_SIZE"

# Upload to cloud storage
case "$CLOUD_PROVIDER" in
  aws)
    S3_BUCKET="${S3_BUCKET:-my-backups}"
    echo "Uploading to S3: s3://$S3_BUCKET/"
    aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/database-backups/"
    ;;
  
  azure)
    STORAGE_ACCOUNT="${STORAGE_ACCOUNT:-mybackups}"
    CONTAINER="${CONTAINER:-backups}"
    echo "Uploading to Azure Storage..."
    az storage blob upload \
      --account-name "$STORAGE_ACCOUNT" \
      --container-name "$CONTAINER" \
      --file "$BACKUP_FILE" \
      --name "database-backups/$(basename $BACKUP_FILE)"
    ;;
  
  gcp)
    GCS_BUCKET="${GCS_BUCKET:-my-backups}"
    echo "Uploading to GCS: gs://$GCS_BUCKET/"
    gsutil cp "$BACKUP_FILE" "gs://$GCS_BUCKET/database-backups/"
    ;;
  
  local)
    echo "Backup stored locally: $BACKUP_FILE"
    ;;
  
  *)
    echo "Unknown cloud provider: $CLOUD_PROVIDER"
    ;;
esac

# Clean up old backups (keep last 7 days)
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

echo "Backup process complete!"
