#!/bin/bash

# Kubernetes Cluster Health Check Script
# Comprehensive health check for Kubernetes clusters

set -e

echo "=== Kubernetes Cluster Health Check ==="
echo ""

# Check kubectl connectivity
if ! kubectl cluster-info > /dev/null 2>&1; then
  echo "Error: Cannot connect to Kubernetes cluster"
  exit 1
fi

echo "1. Cluster Information"
kubectl cluster-info

echo ""
echo "2. Node Status"
kubectl get nodes -o wide

echo ""
echo "3. Node Resource Usage"
kubectl top nodes 2>/dev/null || echo "Metrics server not available"

echo ""
echo "4. Pods Not Running"
kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded

echo ""
echo "5. Pod Resource Usage (Top 10)"
kubectl top pods --all-namespaces --sort-by=memory 2>/dev/null | head -11 || echo "Metrics server not available"

echo ""
echo "6. Recent Events (Last 20)"
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -20

echo ""
echo "7. Persistent Volume Claims Status"
kubectl get pvc --all-namespaces

echo ""
echo "8. Services"
kubectl get svc --all-namespaces

echo ""
echo "9. Deployments Not Ready"
kubectl get deployments --all-namespaces -o wide | grep -v "READY" | grep -v "/"

echo ""
echo "10. Failed Pods (Last 1 hour)"
kubectl get pods --all-namespaces --field-selector=status.phase=Failed

echo ""
echo "11. Pods with Restarts"
kubectl get pods --all-namespaces -o wide | awk 'NR==1 || $5 > 0'

echo ""
echo "12. Certificate Expiry (if using cert-manager)"
kubectl get certificates --all-namespaces -o wide 2>/dev/null || echo "cert-manager not found"

echo ""
echo "=== Health Check Complete ==="
echo ""
echo "Summary:"
echo "- Total Nodes: $(kubectl get nodes --no-headers | wc -l)"
echo "- Total Pods: $(kubectl get pods --all-namespaces --no-headers | wc -l)"
echo "- Running Pods: $(kubectl get pods --all-namespaces --field-selector=status.phase=Running --no-headers | wc -l)"
echo "- Failed Pods: $(kubectl get pods --all-namespaces --field-selector=status.phase=Failed --no-headers | wc -l)"
