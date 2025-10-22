#!/bin/bash

# Docker Container Health Check Script
# Monitors and reports health of Docker containers

set -e

echo "=== Docker Container Health Check ==="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running"
  exit 1
fi

echo "1. Container Status Overview"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

echo ""
echo "2. Resource Usage"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

echo ""
echo "3. Containers with High Resource Usage"
docker stats --no-stream --format "{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}" | awk '{
  gsub(/%/, "", $2)
  gsub(/%/, "", $3)
  if ($2 > 80 || $3 > 80) {
    print "WARNING: " $1 " - CPU: " $2 "%, Memory: " $3 "%"
  }
}'

echo ""
echo "4. Unhealthy Containers"
docker ps --filter "health=unhealthy" --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "5. Stopped Containers"
docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

echo ""
echo "6. Container Logs (Last 10 lines from running containers)"
for container in $(docker ps --format "{{.Names}}"); do
  echo ""
  echo "--- Logs for $container ---"
  docker logs --tail 10 "$container" 2>&1 | head -20
done

echo ""
echo "=== Health Check Complete ==="
