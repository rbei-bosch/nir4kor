# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null

# (Optional) Install k9s
/home/linuxbrew/.linuxbrew/bin/brew install derailed/k9s/k9s
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install K8s dashboard
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
kubectl apply -f ./k8s-dashboard-admin-user.yml
kubectl apply -f ./k8s-dashboard-admin-role.yml

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
