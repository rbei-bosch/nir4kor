#!/bin/bash
# Copyright (c) 2022 Robert Bosch GmbH and Microsoft Corporation
#
# This program and the accompanying materials are made available under the
# terms of the Apache License, Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# SPDX-License-Identifier: Apache-2.0

# Install k9s
curl -sS https://webinstall.dev/k9s | bash

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
