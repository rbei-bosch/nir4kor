# Delete cluster and registry
k3d cluster delete dev-cluster
k3d registry delete k3d-devregistry.localhost

# Create k3d registry & cluster
k3d registry create devregistry.localhost --port 12345
k3d cluster create dev-cluster --registry-use k3d-devregistry.localhost:12345 -p "31883:31883"

GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
kubectl apply -f ./k8s-dashboard-admin-user.yml
kubectl apply -f ./k8s-dashboard-admin-role.yml

# Install Redis
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis bitnami/redis

# Install Mosquitto
kubectl apply -f ./mosquitto.yml

# Init Dapr in cluster
dapr init -k #--runtime-version=1.5.0 Use to select specific version

# Apply Dapr config
kubectl apply -f ./.dapr/config.yaml
kubectl apply -f ./.dapr/components/pubsub.yaml
kubectl apply -f ./.dapr/components/statestore.yaml

# Show the Token of the Kubernetes Dashboard admin user
echo
echo "Kubernetes Dashboard has been installed. It can take some minutes till the dashboard is available."
echo "Run 'kubectl proxy' to make the dashbpard available from outside the cluster and use this url to open the dasboard:"
echo 
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo
echo "Use the following token to login:"
echo
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token


