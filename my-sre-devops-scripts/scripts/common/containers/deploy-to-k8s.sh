#!/bin/bash

# Kubernetes Deployment Script
# Deploys applications to Kubernetes with best practices

set -e

APP_NAME="${APP_NAME:-myapp}"
NAMESPACE="${NAMESPACE:-default}"
IMAGE="${IMAGE:-nginx:latest}"
REPLICAS="${REPLICAS:-2}"
PORT="${PORT:-80}"

echo "Deploying $APP_NAME to Kubernetes..."
echo "Namespace: $NAMESPACE"
echo "Image: $IMAGE"
echo "Replicas: $REPLICAS"

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Create deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
  labels:
    app: $APP_NAME
spec:
  replicas: $REPLICAS
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: $APP_NAME
        image: $IMAGE
        ports:
        - containerPort: $PORT
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: $PORT
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: $PORT
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
  namespace: $NAMESPACE
  labels:
    app: $APP_NAME
spec:
  type: LoadBalancer
  selector:
    app: $APP_NAME
  ports:
  - protocol: TCP
    port: 80
    targetPort: $PORT
EOF

echo ""
echo "Deployment created. Waiting for rollout..."
kubectl rollout status deployment/"$APP_NAME" -n "$NAMESPACE"

echo ""
echo "=== Deployment Complete ==="
kubectl get deployment "$APP_NAME" -n "$NAMESPACE"
kubectl get service "$APP_NAME" -n "$NAMESPACE"
kubectl get pods -n "$NAMESPACE" -l app="$APP_NAME"

echo ""
echo "To access the service:"
echo "kubectl get svc $APP_NAME -n $NAMESPACE"
