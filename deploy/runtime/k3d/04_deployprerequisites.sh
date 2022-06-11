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

ROOT_DIRECTORY=$( realpath "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../../.." )
VEHICLEDATABROKER_TAG=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .databroker.version | tr -d '"')
SEATSERVICE_TAG=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .seatservice.version | tr -d '"')
FEEDERCAN_TAG=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .feedercan.version | tr -d '"')
GITHUB_TOKEN="$ROOT_DIRECTORY/github_token.txt"
cred=$(cat $GITHUB_TOKEN)
echo $cred | cut -d':' -f2 | docker login ghcr.io -u USERNAME --password-stdin

if grep -q ghcr.io $HOME/.docker/config.json; then
    docker pull ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/databroker:$VEHICLEDATABROKER_TAG
    docker tag ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/databroker:$VEHICLEDATABROKER_TAG localhost:12345/vehicledatabroker:$VEHICLEDATABROKER_TAG
    docker push localhost:12345/vehicledatabroker:$VEHICLEDATABROKER_TAG

    docker pull ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/seat_service:$SEATSERVICE_TAG
    docker tag ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/seat_service:$SEATSERVICE_TAG localhost:12345/seatservice:$SEATSERVICE_TAG
    docker push localhost:12345/seatservice:$SEATSERVICE_TAG

    docker pull ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/feeder_can:$FEEDERCAN_TAG
    docker tag ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/feeder_can:$FEEDERCAN_TAG localhost:12345/feedercan:$FEEDERCAN_TAG
    docker push localhost:12345/feedercan:$FEEDERCAN_TAG

    # We set the tag to the version from the variables above in the script. This overwrites the default values in the values-file.
    helm uninstall vehicleappruntime --wait
    helm install vehicleappruntime ./helm --values ./helm/values.yaml --set imageSeatService.tag=$SEATSERVICE_TAG --set imageVehicleDataBroker.tag=$VEHICLEDATABROKER_TAG --set imageFeederCan.tag=$FEEDERCAN_TAG --wait --timeout 60s --debug

else
    tput setaf 1; echo "ERROR: Please run 'docker login ghcr.io' and rerun the script"
fi

kubectl get svc --all-namespaces
kubectl get pods
