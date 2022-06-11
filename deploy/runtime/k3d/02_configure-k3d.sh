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

k3d registry create devregistry.localhost --port 12345

if [ -n "$HTTP_PROXY" ]; then
  echo "Creating cluster with proxy configuration"
  k3d cluster create dev-cluster \
    --registry-use k3d-devregistry.localhost:12345 \
    -p "31883:31883" \
    -p "30555:30555" \
    -p "30051:30051" \
    -e "HTTP_PROXY=$HTTP_PROXY@server:0" \
    -e "HTTPS_PROXY=$HTTPS_PROXY@server:0" \
    --volume $(pwd)/volume:/mnt/data@server:0 \
    -e "NO_PROXY=localhost@server:0"
else
  echo "Creating cluster without proxy configuration"
  k3d cluster create dev-cluster \
    -p "30555:30555" \
    -p "31883:31883" \
    -p "30051:30051" \
    --volume $(pwd)/volume:/mnt/data@server:0 \
    --registry-use k3d-devregistry.localhost:12345
fi

# Deploy Zipkin
kubectl create deployment zipkin --image openzipkin/zipkin
kubectl expose deployment zipkin --type ClusterIP --port 9411

# Init Dapr in cluster
dapr init -k --wait --timeout 600 #--runtime-version=1.5.0 Use to select specific version

# Apply Dapr config
kubectl apply -f ./.dapr/config.yaml
kubectl apply -f ./.dapr/components/pubsub.yaml
