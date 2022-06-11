#!/bin/bash

k3d registry create devregistry.localhost --port 12345

if [ -n "$1" ]; then
  echo "Creating cluster with proxy configuration"
  k3d cluster create dev-cluster \
    --registry-use k3d-devregistry.localhost:12345 \
    -p "31883:31883" \
    -e "HTTP_PROXY=http://host.docker.internal:3128@server:0" \
    -e "HTTPS_PROXY=http://host.docker.internal:3128@server:0" \
    -e "NO_PROXY=localhost@server:0"
else
  echo "Creating cluster without proxy configuration"
  k3d cluster create dev-cluster -p "31883:31883" \
    --registry-use k3d-devregistry.localhost:12345
fi

# Install Mosquitto
kubectl apply -f ./mosquitto.yml

# Deploy Zipkin
kubectl create deployment zipkin --image openzipkin/zipkin
kubectl expose deployment zipkin --type ClusterIP --port 9411

# Init Dapr in cluster
dapr init -k --wait --timeout 600 #--runtime-version=1.5.0 Use to select specific version

# Apply Dapr config
kubectl apply -f ./.dapr/config.yaml
kubectl apply -f ./.dapr/components/pubsub.yaml
