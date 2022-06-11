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
echo "### Running Seatservice                             ###"
echo "#######################################################"

export HTTP_PROXY=${HTTP_PROXY}
export HTTPS_PROXY=${HTTPS_PROXY}
export NO_PROXY=${NO_PROXY}

ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
GITHUB_TOKEN="$ROOT_DIRECTORY/github_token.txt"

SEATSERVICE_VERSION=$(cat $ROOT_DIRECTORY/.devcontainer/sdv/settings.json | jq .seatservice.version | tr -d '"')
SEATSERVICE_PORT='50051'
SEATSERVICE_GRPC_PORT='52002'
SEATSERVICE_LOG_DAPR="$HOME/seatservice-dapr.log"
SEATSERVICE_LOG_APP="$HOME/seatservice-app.log"
BACKGROUND_PROCESS=()
sudo chown $(whoami) $HOME
if [ ! -z "$1" ];
then
  #Run process as background when (devcontainer init)
  BACKGROUND_PROCESS=(">" "$SEATSERVICE_LOG_APP" "2>&1" "&" "disown")
fi

# Function will kill only VAL services and coressponding dapr isntances
function kill_service_by_port(){
  SERVICE="$(ps -p $1 -o command)"
  string='My long string'
  if [[ $SERVICE == *"dapr"* || $SERVICE == *"seatservice"* ]] ; then
    kill $1
  fi
}
export -f kill_service_by_port

#Terminate existing running VAL services
lsof -ti tcp:$SEATSERVICE_PORT | xargs -I{}  bash -c "kill_service_by_port {}"
lsof -ti tcp:$SEATSERVICE_GRPC_PORT | xargs -I{}  bash -c "kill_service_by_port {}"

#Detect host environment (distinguish for Mac M1 processor)
if [[ `uname -m` == 'aarch64' || `uname -m` == 'arm64' ]]; then
  echo "Detected ARM architecture"
  PROCESSOR="aarch64"
  SEATSERVICE_BINARY_NAME="bin_vservice_seat_release_aarch64.tar.gz"
  SEATSERVICE_EXEC_PATH="$ROOT_DIRECTORY/.devcontainer/sdv/assets/seatservice/$SEATSERVICE_VERSION/$PROCESSOR/target/aarch64/release/install/bin"
else
  echo "Detected x86_64 architecture"
  PROCESSOR="x86_64"
  SEATSERVICE_BINARY_NAME="bin_vservice_seat_release_x86_64.tar.gz"
  SEATSERVICE_EXEC_PATH="$ROOT_DIRECTORY/.devcontainer/sdv/assets/seatservice/$SEATSERVICE_VERSION/$PROCESSOR/target/x86_64/release/install/bin"
fi

cred=$(cat $GITHUB_TOKEN)
API_URL=https://$cred@api.github.com/repos/SoftwareDefinedVehicle/swdc-os-vehicleapi

if [[ ! -f "$SEATSERVICE_EXEC_PATH/val_start.sh" ]]
then
  echo "Downloading seatservice:$SEATSERVICE_VERSION"
  SEATSERVICE_ASSET_ID=$(curl $API_URL/releases/tags/$SEATSERVICE_VERSION | jq -r ".assets[] | select(.name == \"$SEATSERVICE_BINARY_NAME\") | .id")
  curl -o $ROOT_DIRECTORY/.devcontainer/sdv/assets/seatservice/$SEATSERVICE_VERSION/$PROCESSOR/$SEATSERVICE_BINARY_NAME --create-dirs -L -H "Accept: application/octet-stream" "$API_URL/releases/assets/$SEATSERVICE_ASSET_ID"
  tar -xf $ROOT_DIRECTORY/.devcontainer/sdv/assets/seatservice/$SEATSERVICE_VERSION/$PROCESSOR/$SEATSERVICE_BINARY_NAME -C $ROOT_DIRECTORY/.devcontainer/sdv/assets/seatservice/$SEATSERVICE_VERSION/$PROCESSOR
fi

rm -f "$SEATSERVICE_LOG_DAPR"
rm -f "$SEATSERVICE_LOG_APP"
export DAPR_GRPC_PORT=$SEATSERVICE_GRPC_PORT
export CAN=cansim
export VEHICLEDATABROKER_DAPR_APP_ID=vehicledatabroker

run_script="dapr run \
--app-id seatservice \
--app-protocol grpc \
--app-port $SEATSERVICE_PORT \
--dapr-grpc-port $SEATSERVICE_GRPC_PORT \
--components-path $ROOT_DIRECTORY/.dapr/components \
--config $ROOT_DIRECTORY/.dapr/config.yaml > $SEATSERVICE_LOG_DAPR 2>&1 & \
$SEATSERVICE_EXEC_PATH/val_start.sh \
${BACKGROUND_PROCESS[@]}"
eval $run_script
