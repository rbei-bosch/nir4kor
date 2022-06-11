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

WORKING_DIR=$(pwd)

if [ -f "./../../github_token.txt" ];
then
    GITHUB_TOKEN="github_token,src=github_token.txt"
else
    GITHUB_TOKEN="github_token"
fi

if [ -n "$HTTP_PROXY" ]; then
    echo "Building image with proxy configuration"

    cd $WORKING_DIR/../../
    DOCKER_BUILDKIT=1 docker build \
    -f src/SeatAdjusterApp/Dockerfile \
    --progress=plain --secret id=$GITHUB_TOKEN \
    -t localhost:12345/seatadjuster:local \
    --build-arg HTTP_PROXY="$HTTP_PROXY" \
    --build-arg HTTPS_PROXY="$HTTPS_PROXY" \
    --build-arg FTP_PROXY="$FTP_PROXY" \
    --build-arg ALL_PROXY="$ALL_PROXY" \
    --build-arg NO_PROXY="$NO_PROXY" . --no-cache
    docker push localhost:12345/seatadjuster:local

    cd $WORKING_DIR
else
    echo "Building image without proxy configuration"
    # Build, push vehicleapi image - NO PROXY

    cd $WORKING_DIR/../../
    DOCKER_BUILDKIT=1 docker build -f src/SeatAdjusterApp/Dockerfile --progress=plain --secret id=$GITHUB_TOKEN -t localhost:12345/seatadjuster:local . --no-cache
    docker push localhost:12345/seatadjuster:local

    cd $WORKING_DIR
fi

helm uninstall vapp-chart --wait

# Deploy in Kubernetes
helm install vapp-chart ./helm --values ../runtime/k3d/values.yml --wait --timeout 60s --debug
