ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
VEHICLEDATABROKER_TAG=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .databroker.version | tr -d '"')
SEATSERVICE_TAG=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .seatservice.version | tr -d '"')
FEEDERCAN_TAG=$(cat $ROOT_DIRECTORY/prerequisite_settings.json | jq .feedercan.version | tr -d '"')
OPENPOLICYAGENT_TAG="edge-static"
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


    OPA_REPO=https://$cred@github.com/SoftwareDefinedVehicle/open-policy-agent-config.git
    git -C $ROOT_DIRECTORY/scripts/k3d/volume/open-policy-agent-config pull || git clone $OPA_REPO $ROOT_DIRECTORY/scripts/k3d/volume/open-policy-agent-config

    # We set the tag to the version from the variables above in the script. This overwrites the default values in the values-file.
    helm uninstall vehicleapppre --wait
    helm install vehicleapppre ./helm --values ./helm/values.yaml --set imageSeatService.tag=$SEATSERVICE_TAG --set imageVehicleDataBroker.tag=$VEHICLEDATABROKER_TAG --set imageFeederCan.tag=$FEEDERCAN_TAG --set imageOpa.tag=$OPENPOLICYAGENT_TAG --wait --timeout 60s --debug

else
    tput setaf 1; echo "ERROR: Please run 'docker login ghcr.io' and rerun the script"
fi

kubectl get svc --all-namespaces
kubectl get pods
