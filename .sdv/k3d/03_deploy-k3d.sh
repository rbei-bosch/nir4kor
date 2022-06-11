# Build, push vehicleapi image
cd /workspaces/vehicle-app-python-template/vehicleapi
docker build -f Dockerfile.local -t localhost:12345/vehicleapi:local .
docker push localhost:12345/vehicleapi:local

cd /workspaces/vehicle-app-python-template/src
docker build -f Dockerfile.local -t localhost:12345/seatadjuster:local .
docker push localhost:12345/seatadjuster:local

cd /workspaces/vehicle-app-python-template/.sdv/k3d

# Deploy in Kubernetes
kubectl apply -f ./Deployment.vehicleapi.yml
kubectl apply -f ./Deployment.seatadjuster.yml