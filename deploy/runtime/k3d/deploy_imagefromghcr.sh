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

SHA="70a5999c66ad6f9e5fc81023706e273d411c1c1f"
REPO_NAME="softwaredefinedvehicle/vehicle-app-python-template"

jq -c '.[]' ./../../../vehicleApp.json | while read i; do
    name=$(jq -r '.Name' <<< "$i")

    pull_url="ghcr.io/$REPO_NAME/$name:$SHA"
    local_tag="k3d-devregistry.localhost:12345/$name:local"

    echo "Remote URL: $pull_url"
    echo "Local URL: $local_tag"

    docker pull $pull_url
    docker tag $pull_url $local_tag
    docker push $local_tag
done

helm install vapp-chart ./../../SeatAdjusterApp/helm/ --values ./values.yml --wait --timeout 60s --debug

kubectl get svc --all-namespaces
kubectl get pods

jq -c '.[]' ./../../../vehicleApp.json | while read i; do
    name=$(jq -r '.Name' <<< "$i")
    podname=$(kubectl get pods -o name | grep $name)
    kubectl describe $podname
    kubectl logs $podname --all-containers
done

sleep 5s
