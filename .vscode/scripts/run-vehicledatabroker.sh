#********************************************************************************
#* Copyright (c) 2021 Contributors to the Eclipse Foundation
#*
#* See the NOTICE file(s) distributed with this work for additional
#* information regarding copyright ownership.
#*
#* This program and the accompanying materials are made available under the
#* terms of the Eclipse Public License 2.0 which is available at
#* http://www.eclipse.org/legal/epl-2.0
#*
#* SPDX-License-Identifier: EPL-2.0
#********************************************************************************/

echo "#######################################################"
echo "### Running Databroker                              ###"
echo "#######################################################"

export HTTP_PROXY=${HTTP_PROXY}
export HTTPS_PROXY=${HTTPS_PROXY}
export NO_PROXY=${NO_PROXY}

ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
GITHUB_TOKEN="$ROOT_DIRECTORY/github_token.txt"

DATABROKER_VERSION=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .databroker.version | tr -d '"')
DATABROKER_PORT='55555'
DATABROKER_GRPC_PORT='52001'
sudo chown $(whoami) $HOME

# Function will kill only VAL services and coressponding dapr isntances
function kill_service_by_port(){
  SERVICE="$(ps -p $1 -o command)"
  string='My long string'
  if [[ $SERVICE == *"dapr"* || $SERVICE == *"vehicle-data-broker"* ]] ; then
    kill $1
  fi
}
export -f kill_service_by_port

#Terminate existing running VAL services
lsof -ti tcp:$DATABROKER_PORT | xargs -I{}  bash -c "kill_service_by_port {}"
lsof -ti tcp:$DATABROKER_GRPC_PORT | xargs -I{}  bash -c "kill_service_by_port {}"

#Detect host environment (distinguish for Mac M1 processor)
if [[ `uname -m` == 'aarch64' || `uname -m` == 'arm64' ]]; then
  echo "Detected ARM architecture"
  PROCESSOR="aarch64"
  DATABROKER_BINARY_NAME="bin_release_databroker_aarch64.tar.gz"
  DATABROKER_EXEC_PATH="$ROOT_DIRECTORY/.vscode/scripts/assets/databroker/$DATABROKER_VERSION/$PROCESSOR/target/aarch64-unknown-linux-gnu/release"
else
  echo "Detected x86_64 architecture"
  PROCESSOR="x86_64"
  DATABROKER_BINARY_NAME='bin_release_databroker_x86_64.tar.gz'
  DATABROKER_EXEC_PATH="$ROOT_DIRECTORY/.vscode/scripts/assets/databroker/$DATABROKER_VERSION/$PROCESSOR/target/release"
fi

cred=$(cat $GITHUB_TOKEN)
API_URL=https://$cred@api.github.com/repos/SoftwareDefinedVehicle/swdc-os-vehicleapi

if [[ ! -f "$DATABROKER_EXEC_PATH/vehicle-data-broker" ]]
then
  echo "Downloading databroker:$DATABROKER_VERSION"
  DATABROKER_ASSET_ID=$(curl $API_URL/releases/tags/$DATABROKER_VERSION | jq -r ".assets[] | select(.name == \"$DATABROKER_BINARY_NAME\") | .id")
  curl -o $ROOT_DIRECTORY/.vscode/scripts/assets/databroker/$DATABROKER_VERSION/$PROCESSOR/$DATABROKER_BINARY_NAME --create-dirs -L -H "Accept: application/octet-stream" "$API_URL/releases/assets/$DATABROKER_ASSET_ID"
  tar -xf $ROOT_DIRECTORY/.vscode/scripts/assets/databroker/$DATABROKER_VERSION/$PROCESSOR/$DATABROKER_BINARY_NAME -C $ROOT_DIRECTORY/.vscode/scripts/assets/databroker/$DATABROKER_VERSION/$PROCESSOR

fi

export DAPR_GRPC_PORT=$DATABROKER_GRPC_PORT

dapr run \
  --app-id vehicledatabroker \
  --app-protocol grpc \
  --app-port $DATABROKER_PORT \
  --dapr-grpc-port $DATABROKER_GRPC_PORT \
  --components-path $ROOT_DIRECTORY/.dapr/components \
  --config $ROOT_DIRECTORY/.dapr/config.yaml & \
  $DATABROKER_EXEC_PATH/vehicle-data-broker --address 0.0.0.0 --dummy-metadata
