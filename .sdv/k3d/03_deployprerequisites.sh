ROOT_DIRECTORY=$(git rev-parse --show-toplevel)
VEHICLEDATABROKER_TAG=$(cat $ROOT_DIRECTORY/.devcontainer/sdv/settings.json | jq .databroker.version | tr -d '"')
SEATSERVICE_TAG=$(cat $ROOT_DIRECTORY/.devcontainer/sdv/settings.json | jq .seatservice.version | tr -d '"')
GITHUB_TOKEN="$ROOT_DIRECTORY/github_token.txt"
cred=$(cat $GITHUB_TOKEN)
echo $cred | cut -d':' -f2 | docker login ghcr.io -u USERNAME --password-stdin

if grep -q ghcr.io /home/vscode/.docker/config.json; then
    docker pull ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/databroker:$VEHICLEDATABROKER_TAG
    docker tag ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/databroker:$VEHICLEDATABROKER_TAG localhost:12345/vehicledatabroker:$VEHICLEDATABROKER_TAG
    docker push localhost:12345/vehicledatabroker:$VEHICLEDATABROKER_TAG

    docker pull ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/seat_service:$SEATSERVICE_TAG
    docker tag ghcr.io/softwaredefinedvehicle/swdc-os-vehicleapi/seat_service:$SEATSERVICE_TAG localhost:12345/seatservice:$SEATSERVICE_TAG
    docker push localhost:12345/seatservice:$SEATSERVICE_TAG

    # We set the tag to the version from the variables above in the script. This overwrites the default values in the values-file.
    helm uninstall vehicleapppre --wait
    helm install vehicleapppre ./helm --values ./helm/values.yaml --set imageSeatService.tag=$SEATSERVICE_TAG --set imageVehicleDataBroker.tag=$VEHICLEDATABROKER_TAG --wait --timeout 60s --debug

else
    tput setaf 1; echo "ERROR: Please run 'docker login ghcr.io' and rerun the script"
fi
