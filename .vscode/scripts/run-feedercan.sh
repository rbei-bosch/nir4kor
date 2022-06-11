echo "#######################################################"
echo "### Running FeederCan                               ###"
echo "#######################################################"

ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
source $ROOT_DIRECTORY/.vscode/scripts/exec-check.sh "$@" $(basename $BASH_SOURCE .sh)
GITHUB_TOKEN="$ROOT_DIRECTORY/github_token.txt"

FEEDERCAN_VERSION=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .feedercan.version | tr -d '"')
DATABROKER_GRPC_PORT='52001'
sudo chown $(whoami) $HOME

# Downloading feedercan
FEEDERCAN_SOURCE="feedercan_source"
FEEDERCAN_EXEC_PATH="$ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION"

cred=$(cat $GITHUB_TOKEN)
API_URL=https://$cred@github.com/SoftwareDefinedVehicle/swdc-os-vehicleapi/tarball/

if [[ ! -f "$FEEDERCAN_EXEC_PATH/feeder_can/dbcfeeder.py" ]]
then
  echo "Downloading FEEDERCAN:$FEEDERCAN_VERSION"
  curl --create-dirs -o "$ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION/$FEEDERCAN_SOURCE" --location --remote-header-name --remote-name "$API_URL/$FEEDERCAN_VERSION"
  FEEDERCAN_BASE_DIRECTORY=$(tar -tzf $ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION/$FEEDERCAN_SOURCE | head -1 | cut -f1 -d"/")
  tar -xf $ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION/$FEEDERCAN_SOURCE -C $ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION/
  cp -r $ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION/$FEEDERCAN_BASE_DIRECTORY/feeder_can $ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION
  rm -rf $ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION/$FEEDERCAN_BASE_DIRECTORY
fi
cd $ROOT_DIRECTORY/.vscode/scripts/assets/feedercan/$FEEDERCAN_VERSION/feeder_can
pip3 install -r requirements.txt

export DAPR_GRPC_PORT=$DATABROKER_GRPC_PORT
export VEHICLEDATABROKER_DAPR_APP_ID=vehicledatabroker
export LOG_LEVEL=info,databroker=info,dbcfeeder.broker_client=debug,dbcfeeder=debug
dapr run \
  --app-id feedercan \
  --app-protocol grpc \
  --components-path $ROOT_DIRECTORY/.dapr/components \
  --config $ROOT_DIRECTORY/.dapr/config.yaml & \
  ./dbcfeeder.py
